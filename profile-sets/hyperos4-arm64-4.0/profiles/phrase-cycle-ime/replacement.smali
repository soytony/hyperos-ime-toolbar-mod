    .locals 8

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->mContext:Landroid/content/Context;
    const-string v1, "input_method"
    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/view/inputmethod/InputMethodManager;
    invoke-virtual {v1}, Landroid/view/inputmethod/InputMethodManager;->getEnabledInputMethodList()Ljava/util/List;
    move-result-object v2
    invoke-interface {v2}, Ljava/util/List;->size()I
    move-result v3
    const/4 v7, 0x1
    if-le v3, v7, :cycle_done

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v4
    const-string v5, "default_input_method"
    invoke-static {v4, v5}, Landroid/provider/Settings$Secure;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4
    const/4 v5, 0x0

    :find_current
    if-ge v5, v3, :use_first
    invoke-interface {v2, v5}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v6
    check-cast v6, Landroid/view/inputmethod/InputMethodInfo;
    invoke-virtual {v6}, Landroid/view/inputmethod/InputMethodInfo;->getId()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v6, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v7
    if-nez v7, :found_current
    add-int/lit8 v5, v5, 0x1
    goto :find_current

    :found_current
    add-int/lit8 v5, v5, 0x1
    if-lt v5, v3, :select_next

    :use_first
    const/4 v5, 0x0

    :select_next
    invoke-interface {v2, v5}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v6
    check-cast v6, Landroid/view/inputmethod/InputMethodInfo;
    invoke-virtual {v6}, Landroid/view/inputmethod/InputMethodInfo;->getId()Ljava/lang/String;
    move-result-object v6
    sget-object v7, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;
    iget-object v7, v7, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mInputMethodService:Landroid/inputmethodservice/InputMethodService;
    invoke-virtual {v7, v6}, Landroid/inputmethodservice/InputMethodService;->switchInputMethod(Ljava/lang/String;)V

    :cycle_done

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->mContext:Landroid/content/Context;

    const-string v1, "switch_keyboard_type"

    invoke-static {v0, v1}, Lcom/miui/inputmethod/InputMethodAnalyticsUtil;->addHighKeyboardRecord(Landroid/content/Context;Ljava/lang/String;)V

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->mContext:Landroid/content/Context;

    const-string v1, "\u5207\u6362\u952e\u76d8"

    invoke-static {v0, v1}, Lcom/miui/inputmethod/InputMethodAnalyticsUtil;->addBottomClickRecord(Landroid/content/Context;Ljava/lang/String;)V

    invoke-static {}, Lcom/miui/inputmethod/InputMethodBottomManager;->dismissGuideView()V

    return-void
