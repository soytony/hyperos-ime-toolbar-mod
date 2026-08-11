package io.github.hyperosime;

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
            case "reset-signature-result":
                result = resetSignatureResult(text, args[2]);
                break;
            default:
                throw new IllegalArgumentException("unsupported mode: " + args[0]);
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

    /** Replace each verified signature-scheme result with zero, retaining move-result for verifier correctness. */
    private static String resetSignatureResult(String text, String invokeAnchor) {
        String[] lines = text.split("\\n", -1);
        int matches = 0;
        for (int i = 0; i < lines.length; i++) {
            if (!lines[i].contains(invokeAnchor)) continue;
            int resultLine = i + 1;
            while (resultLine < lines.length && lines[resultLine].trim().isEmpty()) resultLine++;
            if (resultLine >= lines.length || !lines[resultLine].trim().matches("move-result v[0-9]+"))
                throw new IllegalArgumentException("signature invoke has no adjacent move-result");
            String reg = lines[resultLine].trim().replaceFirst("move-result (v[0-9]+)", "$1");
            lines[resultLine] = lines[resultLine] + "\n    const/4 " + reg + ", 0x0";
            matches++;
        }
        if (matches == 0) throw new IllegalArgumentException("signature invoke not found: " + invokeAnchor);
        return String.join("\n", lines);
    }

    private static String read(File file) throws Exception {
        return new String(Files.readAllBytes(file.toPath()), StandardCharsets.UTF_8);
    }
}
