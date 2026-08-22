package io.github.soytony.dexpatchhelper;

import java.io.File;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

public final class ArchiveVerifier {
    private ArchiveVerifier() {}

    public static void main(String[] args) throws Exception {
        if (args.length != 3) throw new IllegalArgumentException("usage: ArchiveVerifier ORIGINAL PATCHED TARGET_DEXES");
        verify(new File(args[0]), new File(args[1]), names(args[2]));
    }

    private static Set<String> names(String value) {
        Set<String> result = new HashSet<>();
        for (String name : value.split(",")) result.add(name);
        return result;
    }

    private static void verify(File original, File patched, Set<String> targets) throws IOException {
        Map<String, String> before = entries(original, false);
        Map<String, String> after = entries(patched, false);
        if (!before.equals(after)) throw new IOException("non-DEX ZIP entries differ");

        Map<String, String> beforeDex = entries(original, true);
        Map<String, String> afterDex = entries(patched, true);
        if (!beforeDex.keySet().equals(afterDex.keySet())) throw new IOException("DEX entry set differs");
        for (String name : beforeDex.keySet()) {
            boolean changed = !beforeDex.get(name).equals(afterDex.get(name));
            if (targets.contains(name) != changed) {
                throw new IOException((targets.contains(name) ? "target DEX was not changed: " : "untargeted DEX changed: ") + name);
            }
        }
        if (!beforeDex.keySet().containsAll(targets)) throw new IOException("target DEX is absent from original archive");
        System.out.println("verified_non_dex_entries=" + before.size());
        System.out.println("verified_dex_entries=" + beforeDex.size());
        System.out.println("verified_target_dex_entries=" + targets.size());
    }

    private static Map<String, String> entries(File file, boolean dexOnly) throws IOException {
        Map<String, String> result = new LinkedHashMap<>();
        try (ZipFile zip = new ZipFile(file)) {
            java.util.Enumeration<? extends ZipEntry> entries = zip.entries();
            while (entries.hasMoreElements()) {
                ZipEntry entry = entries.nextElement();
                boolean dex = entry.getName().matches("classes(?:[0-9]+)?\\.dex");
                if (dex == dexOnly) result.put(entry.getName(), entry.getSize() + ":" + entry.getCrc());
            }
        }
        return result;
    }
}
