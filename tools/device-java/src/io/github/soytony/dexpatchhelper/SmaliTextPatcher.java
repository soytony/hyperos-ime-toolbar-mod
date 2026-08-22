package io.github.soytony.dexpatchhelper;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

public final class SmaliTextPatcher {
    private SmaliTextPatcher() {}

    public static void main(String[] args) throws Exception {
        if (args.length < 3) throw new IllegalArgumentException("usage: SmaliTextPatcher MODE TARGET MATCH [PAYLOAD]");
        File target = new File(args[1]);
        String text = read(target);
        String result;
        try {
            switch (args[0]) {
                case "replace-method":
                    result = replaceMethod(text, args[2], read(new File(args[3])));
                    break;
                case "replace-text":
                    result = replaceExactlyOnce(text, read(new File(args[2])), read(new File(args[3])));
                    break;
                case "insert-before-method":
                    result = insertBeforeMethod(text, args[2], read(new File(args[3])));
                    break;
                case "replace-method-result":
                    if (args.length < 5) throw new IllegalArgumentException("replace-method-result requires ANCHOR RETURN_TYPE VALUE");
                    result = replaceMethodResult(text, args[2], args[3], args[4]);
                    break;
                default:
                    throw new IllegalArgumentException("unsupported mode: " + args[0]);
            }
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("target=" + target.getPath() + ", mode=" + args[0] + ": " + e.getMessage(), e);
        }
        Files.write(target.toPath(), result.getBytes(StandardCharsets.UTF_8));
    }

    private static String replaceMethod(String text, String signature, String body) {
        int start = uniqueMethodStart(text, signature);
        int declarationEnd = text.indexOf('\n', start);
        int end = text.indexOf(".end method", declarationEnd);
        if (declarationEnd < 0 || end < 0) throw new IllegalArgumentException("malformed method: " + signature);
        end += ".end method".length();
        String normalizedBody = body.endsWith("\n") ? body : body + "\n";
        return text.substring(0, declarationEnd + 1) + normalizedBody + ".end method" + text.substring(end);
    }

    private static String insertBeforeMethod(String text, String signature, String payload) {
        int start = uniqueMethodStart(text, signature);
        String normalized = payload.endsWith("\n\n") ? payload : payload + (payload.endsWith("\n") ? "\n" : "\n\n");
        return text.substring(0, start) + normalized + text.substring(start);
    }

    private static int uniqueMethodStart(String text, String signature) {
        int found = -1;
        int from = 0;
        while (true) {
            int candidate = text.indexOf(".method ", from);
            if (candidate < 0) break;
            int lineEnd = text.indexOf('\n', candidate);
            if (lineEnd < 0) lineEnd = text.length();
            if (text.substring(candidate, lineEnd).endsWith(" " + signature)) {
                if (found >= 0) throw new IllegalArgumentException("ambiguous method: " + signature);
                found = candidate;
            }
            from = lineEnd + 1;
        }
        if (found < 0) throw new IllegalArgumentException("method not found: " + signature);
        return found;
    }

    private static String replaceExactlyOnce(String text, String oldText, String newText) {
        int first = text.indexOf(oldText);
        if (first < 0) throw new IllegalArgumentException("old smali fragment not found");
        if (text.indexOf(oldText, first + oldText.length()) >= 0) throw new IllegalArgumentException("ambiguous smali fragment");
        return text.substring(0, first) + newText + text.substring(first + oldText.length());
    }

    /** Replace each verified method result with a typed constant. */
    private static String replaceMethodResult(String text, String invokeAnchor, String returnType, String value) {
        if (!(returnType.equals("I") || returnType.equals("Z") || returnType.equals("B")
                || returnType.equals("S") || returnType.equals("C"))) {
            throw new IllegalArgumentException("unsupported result type for const/4: " + returnType);
        }
        int parsed;
        try { parsed = Integer.decode(value); }
        catch (NumberFormatException e) { throw new IllegalArgumentException("invalid integer value: " + value); }
        if (parsed < -8 || parsed > 7) throw new IllegalArgumentException("value out of const/4 range (-8..7): " + value);
        String[] lines = text.split("\\n", -1);
        int matches = 0;
        for (int i = 0; i < lines.length; i++) {
            if (!lines[i].contains(invokeAnchor)) continue;
            int resultLine = i + 1;
            while (resultLine < lines.length && lines[resultLine].trim().isEmpty()) resultLine++;
            if (resultLine >= lines.length || !lines[resultLine].trim().matches("move-result v[0-9]+"))
                throw new IllegalArgumentException("method invoke has no adjacent move-result: " + invokeAnchor);
            String reg = lines[resultLine].trim().replaceFirst("move-result (v[0-9]+)", "$1");
            lines[resultLine] = lines[resultLine] + "\n    const/4 " + reg + ", " + (parsed == 0 ? "0x0" : Integer.toString(parsed));
            matches++;
        }
        if (matches == 0) throw new IllegalArgumentException("method invoke not found: " + invokeAnchor);
        return String.join("\n", lines);
    }

    private static String read(File file) throws Exception {
        return new String(Files.readAllBytes(file.toPath()), StandardCharsets.UTF_8);
    }
}
