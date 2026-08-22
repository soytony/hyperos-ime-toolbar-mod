#!/system/bin/sh

# KernelSU exposes this script as the module's action button.
am start --user 0 -n com.android.settings/.Settings \
  --es :settings:show_fragment com.android.settings.language.MiuiLanguageAndInputSettings \
  >/dev/null 2>&1
