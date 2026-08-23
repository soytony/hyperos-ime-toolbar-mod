    .locals 5

    invoke-static {}, Landroid/os/Binder;->getCallingUid()I

    move-result v0

    iget v1, p3, Lcom/android/server/inputmethod/UserData;->mUserId:I

    invoke-static {v1}, Lcom/android/server/inputmethod/InputMethodSettingsRepository;->get(I)Lcom/android/server/inputmethod/InputMethodSettings;

    move-result-object v2

    const-string v3, "#hyperos-ime-toolbar:default-voice"

    invoke-static {p1, v3}, Landroid/text/TextUtils;->equals(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Z

    move-result v3

    if-eqz v3, :voice_target_resolved

    invoke-virtual {v2}, Lcom/android/server/inputmethod/InputMethodSettings;->getDefaultVoiceInputMethod()Ljava/lang/String;

    move-result-object p1

    :voice_target_resolved
    invoke-virtual {v2}, Lcom/android/server/inputmethod/InputMethodSettings;->getMethodMap()Lcom/android/server/inputmethod/InputMethodMap;

    move-result-object v3

    invoke-virtual {v3, p1}, Lcom/android/server/inputmethod/InputMethodMap;->get(Ljava/lang/String;)Landroid/view/inputmethod/InputMethodInfo;

    move-result-object v3

    if-eqz v3, :cond_1

    invoke-virtual {v3}, Landroid/view/inputmethod/InputMethodInfo;->getPackageName()Ljava/lang/String;

    move-result-object v4

    # The MIUI IME toolbar is a privileged system UI path.  Its enabled-IME
    # list may contain packages hidden by ordinary package-visibility rules.
    # The method-map lookup above already proves this is a known IME.
    const/4 v4, 0x1

    if-eqz v4, :cond_1

    invoke-static {}, Lcom/android/server/inputmethod/MiuiInputMethodStub;->getInstance()Lcom/android/server/inputmethod/MiuiInputMethodStub;

    move-result-object v4

    invoke-interface {v4, v0, v1}, Lcom/android/server/inputmethod/MiuiInputMethodStub;->clearSecImeFlag(II)V

    invoke-static {}, Lcom/android/server/inputmethod/MiuiInputMethodStub;->getInstance()Lcom/android/server/inputmethod/MiuiInputMethodStub;

    move-result-object v4

    invoke-interface {v4, v0, v1}, Lcom/android/server/inputmethod/MiuiInputMethodStub;->setInputMethodChangedBySelf(II)V

    if-eqz p2, :cond_0

    invoke-virtual {p2}, Landroid/view/inputmethod/InputMethodSubtype;->hashCode()I

    move-result v4

    invoke-static {v3, v4}, Lcom/android/server/inputmethod/SubtypeUtils;->getSubtypeIndexFromHashCode(Landroid/view/inputmethod/InputMethodInfo;I)I

    move-result v4

    goto :goto_0

    :cond_0
    const/4 v4, -0x1

    :goto_0
    nop

    invoke-direct {p0, p1, v4, v1}, Lcom/android/server/inputmethod/InputMethodManagerService;->setInputMethodWithSubtypeIndexLocked(Ljava/lang/String;II)V

    return-void

    :cond_1
    invoke-static {p1}, Lcom/android/server/inputmethod/InputMethodManagerService;->getExceptionForUnknownImeId(Ljava/lang/String;)Ljava/lang/IllegalArgumentException;

    move-result-object v4

    throw v4
