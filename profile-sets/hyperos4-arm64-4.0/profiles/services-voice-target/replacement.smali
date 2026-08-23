    .locals 4

    invoke-static {p3}, Lcom/android/server/inputmethod/InputMethodSettingsRepository;->get(I)Lcom/android/server/inputmethod/InputMethodSettings;
    move-result-object v0

    invoke-virtual {v0}, Lcom/android/server/inputmethod/InputMethodSettings;->getMethodMap()Lcom/android/server/inputmethod/InputMethodMap;
    move-result-object v1
    invoke-virtual {v1, p1}, Lcom/android/server/inputmethod/InputMethodMap;->get(Ljava/lang/String;)Landroid/view/inputmethod/InputMethodInfo;
    move-result-object v1
    if-eqz v1, :voice_target_allowed

    new-instance v1, Lcom/android/server/inputmethod/InputMethodManagerService$$ExternalSyntheticLambda26;
    invoke-direct {v1, p1}, Lcom/android/server/inputmethod/InputMethodManagerService$$ExternalSyntheticLambda26;-><init>(Ljava/lang/String;)V
    invoke-virtual {v0, v1}, Lcom/android/server/inputmethod/InputMethodSettings;->getEnabledInputMethodListWithFilter(Ljava/util/function/Predicate;)Ljava/util/ArrayList;
    move-result-object v1
    invoke-virtual {v1}, Ljava/util/ArrayList;->isEmpty()Z
    move-result v1
    if-eqz v1, :voice_target_allowed

    invoke-virtual {v0}, Lcom/android/server/inputmethod/InputMethodSettings;->getDefaultVoiceInputMethod()Ljava/lang/String;
    move-result-object v1
    invoke-static {p1, v1}, Landroid/text/TextUtils;->equals(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :voice_target_allowed

    new-instance v1, Ljava/lang/IllegalStateException;
    new-instance v2, Ljava/lang/StringBuilder;
    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V
    const-string v3, "Requested IME is not enabled: "
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v2
    invoke-direct {v1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V
    throw v1

    :voice_target_allowed
    invoke-static {}, Landroid/os/Binder;->clearCallingIdentity()J
    move-result-wide v1

    :try_start_0
    invoke-virtual {p0, p1, p2, p3}, Lcom/android/server/inputmethod/InputMethodManagerService;->setInputMethodLocked(Ljava/lang/String;II)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    invoke-static {v1, v2}, Landroid/os/Binder;->restoreCallingIdentity(J)V
    return-void

    :catchall_0
    move-exception v3
    invoke-static {v1, v2}, Landroid/os/Binder;->restoreCallingIdentity(J)V
    throw v3
