    .locals 0

    const/4 p0, 0x3

    invoke-virtual {p1, p0}, Landroid/view/View;->performHapticFeedback(I)Z

    invoke-static {}, Lcom/miui/inputmethod/InputMethodBottomManager;->voiceInput()V

    return-void
