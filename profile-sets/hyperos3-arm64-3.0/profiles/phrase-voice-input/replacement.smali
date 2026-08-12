    .locals 3

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->mContext:Landroid/content/Context;
    sget-object v1, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;
    iget-object v1, v1, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mInputMethodService:Landroid/inputmethodservice/InputMethodService;
    const-string v2, "#hyperos-ime-toolbar:default-voice"
    invoke-virtual {v1, v2}, Landroid/inputmethodservice/InputMethodService;->switchInputMethod(Ljava/lang/String;)V

    const-string v2, "voice_input"
    invoke-static {v0, v2}, Lcom/miui/inputmethod/InputMethodAnalyticsUtil;->addHighKeyboardRecord(Landroid/content/Context;Ljava/lang/String;)V
    const-string v2, "\u8bed\u97f3\u8f93\u5165"
    invoke-static {v0, v2}, Lcom/miui/inputmethod/InputMethodAnalyticsUtil;->addBottomClickRecord(Landroid/content/Context;Ljava/lang/String;)V
    invoke-static {}, Lcom/miui/inputmethod/InputMethodBottomManager;->dismissGuideView()V
    return-void
