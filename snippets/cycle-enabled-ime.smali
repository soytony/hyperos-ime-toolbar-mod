# Replace InputMethodBottomManager.switchKeyboardType() body conceptually.
#
# 1. InputMethodManager.getEnabledInputMethodList()
# 2. Settings.Secure.getString(resolver, "default_input_method")
# 3. Locate the InputMethodInfo whose getId() matches the current value.
# 4. Select (currentIndex + 1) % list.size().
# 5. InputMethodService.switchInputMethod(nextInfo.getId()).
#
# This avoids HyperOS's unreliable switchToNextInputMethod rotation policy.

invoke-virtual {v1}, Landroid/view/inputmethod/InputMethodManager;->getEnabledInputMethodList()Ljava/util/List;
move-result-object v2

invoke-static {v4, v5}, Landroid/provider/Settings$Secure;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
move-result-object v4

invoke-virtual {v6}, Landroid/view/inputmethod/InputMethodInfo;->getId()Ljava/lang/String;
move-result-object v6

invoke-virtual {v7, v6}, Landroid/inputmethodservice/InputMethodService;->switchInputMethod(Ljava/lang/String;)V
