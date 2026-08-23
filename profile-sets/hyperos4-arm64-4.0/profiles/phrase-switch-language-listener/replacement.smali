    .locals 1

    const/4 v0, 0x3

    invoke-virtual {p1, v0}, Landroid/view/View;->performHapticFeedback(I)Z

    invoke-static {}, Lcom/miui/inputmethod/InputMethodBottomManager;->switchKeyboardLanguage()V

    return-void
