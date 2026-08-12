    .locals 7

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->mContext:Landroid/content/Context;
    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v1
    const-string v2, "default_voice_input_method"
    invoke-static {v1, v2}, Landroid/provider/Settings$Secure;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2

    if-eqz v2, :voice_broadcast_fallback
    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z
    move-result v3
    if-nez v3, :voice_broadcast_fallback

    const-string v3, "input_method"
    invoke-virtual {v0, v3}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Landroid/view/inputmethod/InputMethodManager;
    invoke-virtual {v3}, Landroid/view/inputmethod/InputMethodManager;->getEnabledInputMethodList()Ljava/util/List;
    move-result-object v3
    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;
    move-result-object v4

    :voice_find_enabled
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z
    move-result v5
    if-eqz v5, :voice_broadcast_fallback
    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v5
    check-cast v5, Landroid/view/inputmethod/InputMethodInfo;
    invoke-virtual {v5}, Landroid/view/inputmethod/InputMethodInfo;->getId()Ljava/lang/String;
    move-result-object v5
    invoke-virtual {v2, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v5
    if-eqz v5, :voice_find_enabled

    sget-object v3, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;
    iget-object v3, v3, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mInputMethodService:Landroid/inputmethodservice/InputMethodService;
    invoke-virtual {v3, v2}, Landroid/inputmethodservice/InputMethodService;->switchInputMethod(Ljava/lang/String;)V
    goto :voice_record_action

    :voice_broadcast_fallback
    new-instance v2, Landroid/content/Intent;
    const-string v3, "miui.intent.action.START_IME_VOICE_INPUT"
    invoke-direct {v2, v3}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    sget-object v3, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;
    iget-object v3, v3, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mInputMethodService:Landroid/inputmethodservice/InputMethodService;
    invoke-virtual {v3}, Landroid/content/Context;->getPackageName()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;
    invoke-virtual {v0, v2}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    :voice_record_action
    const-string v6, "voice_input"
    invoke-static {v0, v6}, Lcom/miui/inputmethod/InputMethodAnalyticsUtil;->addHighKeyboardRecord(Landroid/content/Context;Ljava/lang/String;)V
    const-string v6, "\u8bed\u97f3\u8f93\u5165"
    invoke-static {v0, v6}, Lcom/miui/inputmethod/InputMethodAnalyticsUtil;->addBottomClickRecord(Landroid/content/Context;Ljava/lang/String;)V
    invoke-static {}, Lcom/miui/inputmethod/InputMethodBottomManager;->dismissGuideView()V
    return-void
