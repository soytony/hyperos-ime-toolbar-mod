package io.github.hyperosime;

import java.io.*;
import java.util.HashSet;
import java.util.Set;
import java.util.zip.*;

public final class DexArchiveInjector {
    private static final byte[] BUFFER = new byte[128 * 1024];

    private DexArchiveInjector() {}

    public static void main(String[] args) throws Exception {
        if (args.length != 4) {
            throw new IllegalArgumentException("usage: DexArchiveInjector ORIGINAL REBUILT OUTPUT TARGET_DEXES");
        }
        inject(new File(args[0]), new File(args[1]), new File(args[2]), names(args[3]));
    }

    private static Set<String> names(String value) {
        Set<String> result = new HashSet<>();
        for (String name : value.split(",")) {
            if (!name.matches("classes(?:[0-9]+)?\\.dex")) {
                throw new IllegalArgumentException("invalid target DEX: " + name);
            }
            result.add(name);
        }
        if (result.isEmpty()) throw new IllegalArgumentException("no target DEX specified");
        return result;
    }

    private static void inject(File original, File rebuilt, File output, Set<String> requested) throws IOException {
        File dexDir = new File(output.getParentFile(), output.getName() + ".dex");
        if (!dexDir.mkdirs() && !dexDir.isDirectory()) throw new IOException("cannot create " + dexDir);
        Set<String> dexNames = extractDex(rebuilt, dexDir, requested);
        if (!dexNames.equals(requested)) throw new IOException("rebuilt archive is missing target DEX: " + requested);

        Set<String> replaced = new HashSet<>();
        try (ZipInputStream in = new ZipInputStream(new BufferedInputStream(new FileInputStream(original)));
             ZipOutputStream out = new ZipOutputStream(new BufferedOutputStream(new FileOutputStream(output)))) {
            ZipEntry entry;
            while ((entry = in.getNextEntry()) != null) {
                if (dexNames.contains(entry.getName())) {
                    writeFileEntry(out, entry, new File(dexDir, entry.getName()));
                    replaced.add(entry.getName());
                } else {
                    copyEntry(in, out, entry);
                }
            }
        }
        if (!replaced.equals(dexNames)) throw new IOException("rebuilt dex set differs from original: " + dexNames);
    }

    private static Set<String> extractDex(File archive, File directory, Set<String> requested) throws IOException {
        Set<String> names = new HashSet<>();
        try (ZipInputStream in = new ZipInputStream(new BufferedInputStream(new FileInputStream(archive)))) {
            ZipEntry entry;
            while ((entry = in.getNextEntry()) != null) {
                String name = entry.getName();
                if (requested.contains(name)) {
                    try (FileOutputStream out = new FileOutputStream(new File(directory, name))) { transfer(in, out); }
                    names.add(name);
                }
            }
        }
        return names;
    }

    private static void copyEntry(ZipInputStream in, ZipOutputStream out, ZipEntry source) throws IOException {
        ZipEntry target = cloneEntry(source);
        out.putNextEntry(target);
        transfer(in, out);
        out.closeEntry();
    }

    private static void writeFileEntry(ZipOutputStream out, ZipEntry source, File file) throws IOException {
        ZipEntry target = cloneEntry(source);
        if (target.getMethod() == ZipEntry.STORED) {
            CRC32 crc = new CRC32();
            try (FileInputStream in = new FileInputStream(file)) {
                int count;
                while ((count = in.read(BUFFER)) != -1) crc.update(BUFFER, 0, count);
            }
            target.setSize(file.length());
            target.setCompressedSize(file.length());
            target.setCrc(crc.getValue());
        }
        out.putNextEntry(target);
        try (FileInputStream in = new FileInputStream(file)) { transfer(in, out); }
        out.closeEntry();
    }

    private static ZipEntry cloneEntry(ZipEntry source) {
        ZipEntry target = new ZipEntry(source.getName());
        target.setMethod(source.getMethod());
        if (source.getTime() >= 0) target.setTime(source.getTime());
        if (source.getComment() != null) target.setComment(source.getComment());
        if (source.getExtra() != null) target.setExtra(source.getExtra());
        if (source.getMethod() == ZipEntry.STORED) {
            target.setSize(source.getSize());
            target.setCompressedSize(source.getCompressedSize());
            target.setCrc(source.getCrc());
        }
        return target;
    }

    private static void transfer(InputStream in, OutputStream out) throws IOException {
        int count;
        while ((count = in.read(BUFFER)) != -1) out.write(BUFFER, 0, count);
    }
}
