    .locals 14

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->mContext:Landroid/content/Context;
    const-string v1, "input_method"
    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, Landroid/view/inputmethod/InputMethodManager;
    invoke-virtual {v0}, Landroid/view/inputmethod/InputMethodManager;->getEnabledInputMethodList()Ljava/util/List;
    move-result-object v1
    invoke-interface {v1}, Ljava/util/List;->size()I
    move-result v2
    if-lez v2, :language_cycle_done

    sget-object v3, Lcom/miui/inputmethod/InputMethodBottomManager;->mContext:Landroid/content/Context;
    invoke-virtual {v3}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v3
    const-string v4, "default_input_method"
    invoke-static {v3, v4}, Landroid/provider/Settings$Secure;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v0}, Landroid/view/inputmethod/InputMethodManager;->getCurrentInputMethodSubtype()Landroid/view/inputmethod/InputMethodSubtype;
    move-result-object v4
    const/4 v5, 0x0
    const/4 v13, 0x0

    :find_language_ime
    if-ge v5, v2, :language_use_first_ime
    invoke-interface {v1, v5}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v6
    check-cast v6, Landroid/view/inputmethod/InputMethodInfo;
    invoke-virtual {v6}, Landroid/view/inputmethod/InputMethodInfo;->getId()Ljava/lang/String;
    move-result-object v7
    invoke-virtual {v7, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v12
    if-nez v12, :language_current_ime
    add-int/lit8 v5, v5, 0x1
    goto :find_language_ime

    :language_current_ime
    const/4 v12, 0x1
    invoke-virtual {v0, v6, v12}, Landroid/view/inputmethod/InputMethodManager;->getEnabledInputMethodSubtypeList(Landroid/view/inputmethod/InputMethodInfo;Z)Ljava/util/List;
    move-result-object v8
    invoke-interface {v8}, Ljava/util/List;->size()I
    move-result v9
    const/4 v10, 0x0

    :find_language_subtype
    if-ge v10, v9, :language_next_ime
    invoke-interface {v8, v10}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v11
    check-cast v11, Landroid/view/inputmethod/InputMethodSubtype;
    invoke-virtual {v11, v4}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z
    move-result v12
    if-nez v12, :language_found_subtype
    add-int/lit8 v10, v10, 0x1
    goto :find_language_subtype

    :language_found_subtype
    add-int/lit8 v10, v10, 0x1

    :language_find_next_subtype
    if-ge v10, v9, :language_next_ime
    invoke-interface {v8, v10}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v11
    check-cast v11, Landroid/view/inputmethod/InputMethodSubtype;
    invoke-virtual {v11}, Landroid/view/inputmethod/InputMethodSubtype;->getMode()Ljava/lang/String;
    move-result-object v12
    const-string v13, "voice"
    invoke-virtual {v13, v12}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v12
    if-eqz v12, :language_switch_subtype
    add-int/lit8 v10, v10, 0x1
    goto :language_find_next_subtype

    :language_switch_subtype
    sget-object v12, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;
    iget-object v12, v12, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mInputMethodService:Landroid/inputmethodservice/InputMethodService;
    invoke-virtual {v12, v7, v11}, Landroid/inputmethodservice/InputMethodService;->switchInputMethod(Ljava/lang/String;Landroid/view/inputmethod/InputMethodSubtype;)V
    goto :language_cycle_done

    :language_next_ime
    const/4 v13, 0x0

    :language_advance_ime
    add-int/lit8 v5, v5, 0x1
    if-lt v5, v2, :language_select_ime

    :language_use_first_ime
    const/4 v5, 0x0

    :language_select_ime
    if-ge v13, v2, :language_cycle_done
    add-int/lit8 v13, v13, 0x1
    invoke-interface {v1, v5}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v6
    check-cast v6, Landroid/view/inputmethod/InputMethodInfo;
    invoke-virtual {v6}, Landroid/view/inputmethod/InputMethodInfo;->getId()Ljava/lang/String;
    move-result-object v7
    const/4 v12, 0x1
    invoke-virtual {v0, v6, v12}, Landroid/view/inputmethod/InputMethodManager;->getEnabledInputMethodSubtypeList(Landroid/view/inputmethod/InputMethodInfo;Z)Ljava/util/List;
    move-result-object v8
    invoke-interface {v8}, Ljava/util/List;->size()I
    move-result v9
    const/4 v11, 0x0
    const/4 v10, 0x0
    if-lez v9, :language_switch_ime

    :language_find_first_subtype
    if-ge v10, v9, :language_advance_ime
    invoke-interface {v8, v10}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v11
    check-cast v11, Landroid/view/inputmethod/InputMethodSubtype;
    invoke-virtual {v11}, Landroid/view/inputmethod/InputMethodSubtype;->getMode()Ljava/lang/String;
    move-result-object v12
    const-string v6, "voice"
    invoke-virtual {v6, v12}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v12
    if-eqz v12, :language_switch_ime
    add-int/lit8 v10, v10, 0x1
    goto :language_find_first_subtype

    :language_switch_ime
    sget-object v12, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;
    iget-object v12, v12, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mInputMethodService:Landroid/inputmethodservice/InputMethodService;
    invoke-virtual {v12, v7, v11}, Landroid/inputmethodservice/InputMethodService;->switchInputMethod(Ljava/lang/String;Landroid/view/inputmethod/InputMethodSubtype;)V

    :language_cycle_done

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->mContext:Landroid/content/Context;

    const-string v1, "switch_keyboard_language"

    invoke-static {v0, v1}, Lcom/miui/inputmethod/InputMethodAnalyticsUtil;->addHighKeyboardRecord(Landroid/content/Context;Ljava/lang/String;)V

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->mContext:Landroid/content/Context;

    const-string v1, "\u5207\u6362\u8bed\u8a00"

    invoke-static {v0, v1}, Lcom/miui/inputmethod/InputMethodAnalyticsUtil;->addBottomClickRecord(Landroid/content/Context;Ljava/lang/String;)V

    invoke-static {}, Lcom/miui/inputmethod/InputMethodBottomManager;->dismissGuideView()V

    return-void
