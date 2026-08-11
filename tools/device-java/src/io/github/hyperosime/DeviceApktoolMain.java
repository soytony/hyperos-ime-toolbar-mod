package io.github.hyperosime;

public final class DeviceApktoolMain {
    private DeviceApktoolMain() {}

    public static void main(String[] args) throws Exception {
        setDefault("os.name", "Linux");
        setDefault("os.arch", "aarch64");
        setDefault("sun.arch.data.model", "64");
        brut.apktool.Main.main(args);
    }

    private static void setDefault(String key, String value) {
        if (System.getProperty(key) == null) System.setProperty(key, value);
    }
}
