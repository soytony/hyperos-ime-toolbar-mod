#!/system/bin/sh

until [ "$(getprop sys.boot_completed)" = 1 ]; do
  sleep 2
done

settings put secure enable_miui_ime_bottom_view 1
