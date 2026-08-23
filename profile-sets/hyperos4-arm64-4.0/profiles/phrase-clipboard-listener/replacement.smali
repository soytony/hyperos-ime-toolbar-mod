    .locals 1

    const/4 v0, 0x3

    invoke-virtual {p1, v0}, Landroid/view/View;->performHapticFeedback(I)Z

    iget-boolean p1, p0, Lcom/miui/inputmethod/InputMethodBottomManager$MiuiClipboardPhraseListener;->mIsLeft:Z

    iget-object v0, p0, Lcom/miui/inputmethod/InputMethodBottomManager$MiuiClipboardPhraseListener;->mButtonView:Landroid/view/View;

    invoke-static {p1, v0}, Lcom/miui/inputmethod/InputMethodBottomManager;->showClipBoard(ZLandroid/view/View;)V

    return-void
