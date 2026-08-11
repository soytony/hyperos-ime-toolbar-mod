# v1.2.7 implementation of InputMethodBottomManager.switchKeyboardLanguage().
# The true argument restricts the operation to the current IME's subtypes.

const/4 v0, 0x1
sget-object v1, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;
iget-object v1, v1, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mInputMethodService:Landroid/inputmethodservice/InputMethodService;
invoke-virtual {v1, v0}, Landroid/inputmethodservice/InputMethodService;->switchToNextInputMethod(Z)Z
