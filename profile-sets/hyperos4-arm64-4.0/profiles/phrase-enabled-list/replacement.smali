    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Landroid/view/inputmethod/InputMethodInfo;",
            ">;"
        }
    .end annotation

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;

    iget-object v0, v0, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mImm:Landroid/view/inputmethod/InputMethodManager;

    invoke-virtual {v0}, Landroid/view/inputmethod/InputMethodManager;->getEnabledInputMethodList()Ljava/util/List;

    move-result-object v0

    return-object v0
