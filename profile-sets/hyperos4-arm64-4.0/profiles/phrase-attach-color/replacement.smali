    .locals 5

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;

    iget-object v0, v0, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mMiuiBottomArea:Landroid/view/ViewGroup;

    const-string v1, "IMEBottomManager"

    if-nez v0, :cond_0

    const-string p0, "MiuiBottomArea is null."

    invoke-static {v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    return-void

    :cond_0
    invoke-virtual {v0}, Landroid/view/ViewGroup;->getChildCount()I

    move-result v0

    if-eqz v0, :cond_1

    const-string p0, "MiuiBottomArea only can word once"

    invoke-static {v1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    return-void

    :cond_1
    new-instance v0, Lcom/miui/inputmethod/InputMethodBottomView;

    invoke-direct {v0, p0}, Lcom/miui/inputmethod/InputMethodBottomView;-><init>(Landroid/content/Context;)V

    sget-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sImeLastMiui10Version:Ljava/util/HashMap;

    invoke-virtual {p0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Integer;

    if-eqz v2, :cond_2

    invoke-static {p0}, Lcom/miui/inputmethod/InputMethodBottomManager;->getImeVersionCode(Landroid/content/Context;)I

    move-result v3

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    if-gt v3, v2, :cond_2

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    const v3, 0x7f06003e

    invoke-virtual {v2, v3}, Landroid/content/res/Resources;->getColor(I)I

    move-result v2

    invoke-virtual {v0, v2}, Landroid/view/View;->setBackgroundColor(I)V

    :cond_2
    const v2, 0x7f0a0141

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/ImageView;

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sLeftButton:Landroid/widget/ImageView;

    const v2, 0x7f0a0142

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/ImageView;

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sRightButton:Landroid/widget/ImageView;

    const v2, 0x7f0a0143

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/LinearLayout;

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sLeftLayout:Landroid/widget/LinearLayout;

    const v2, 0x7f0a0144

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/LinearLayout;

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sRightLayout:Landroid/widget/LinearLayout;

    const v2, 0x7f0a01cd

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/ImageView;

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sLeftRedPoint:Landroid/widget/ImageView;

    const v2, 0x7f0a01ce

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/ImageView;

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sRightRedPoint:Landroid/widget/ImageView;

    const v2, 0x7f0a0146

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/RelativeLayout;

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomView:Landroid/widget/RelativeLayout;

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v3

    const v4, 0x7f06003d

    invoke-virtual {v3, v4}, Landroid/content/res/Resources;->getColor(I)I

    move-result v3

    invoke-virtual {v2, v3}, Landroid/view/View;->setBackgroundColor(I)V

    const v2, 0x7f0a011f

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sGuideRecImg:Landroid/view/View;

    const v2, 0x7f0a011c

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/ImageView;

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sGuideCirImg:Landroid/widget/ImageView;

    const v2, 0x7f0a016b

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/ImageView;

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sMecSkinImg:Landroid/widget/ImageView;

    const v2, 0x7f0a016a

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/ImageView;

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sMecLogoImg:Landroid/widget/ImageView;

    const v2, 0x7f0a0145

    invoke-virtual {v0, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Lcom/miui/inputmethod/InputMethodBottomSeekBar;

    sput-object v2, Lcom/miui/inputmethod/InputMethodUtil;->sInputMethodBottomSeekBar:Lcom/miui/inputmethod/InputMethodBottomSeekBar;

    invoke-virtual {p0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    invoke-virtual {v2, v4}, Landroid/content/res/Resources;->getColor(I)I

    move-result v2

    sput v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sDefBottomViewColor:I

    sput v2, Lcom/miui/inputmethod/InputMethodBottomManager;->currentBottomViewColor:I

    sget-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->mContext:Landroid/content/Context;

    const v3, 0x7f06052c

    invoke-virtual {v2, v3}, Landroid/content/Context;->getColor(I)I

    move-result v2

    sput v2, Lcom/miui/inputmethod/InputMethodBottomManager;->currentPhraseEditViewColor:I

    const v2, 0x7f060044

    invoke-virtual {p0, v2}, Landroid/content/Context;->getColor(I)I

    move-result v2

    sput v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sDefIconColorUnpressed:I

    const v2, 0x7f060043

    invoke-virtual {p0, v2}, Landroid/content/Context;->getColor(I)I

    move-result v2

    sput v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sDefIconColorPressed:I

    const/4 v2, 0x0

    invoke-static {v2, v2, v2, v2}, Lcom/miui/inputmethod/InputMethodBottomManager;->setBottomColor(ZIII)V

    invoke-static {p0}, Lcom/miui/inputmethod/InputMethodBottomManager;->setFunctionChanged(Landroid/content/Context;)V

    sget-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sLeftButton:Landroid/widget/ImageView;

    new-instance v3, Lcom/miui/inputmethod/InputMethodBottomManager$2;

    invoke-direct {v3, p0}, Lcom/miui/inputmethod/InputMethodBottomManager$2;-><init>(Landroid/content/Context;)V

    invoke-virtual {v2, v3}, Landroid/view/View;->post(Ljava/lang/Runnable;)Z

    invoke-static {p0}, Lcom/miui/inputmethod/InputMethodBottomManager;->updateMiddleFunction(Landroid/content/Context;)V

    sget-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sMiuiClipboardManager:Lcom/miui/inputmethod/MiuiClipboardManager;

    if-nez v2, :cond_3

    new-instance v2, Lcom/miui/inputmethod/MiuiClipboardManager;

    sget-object v3, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;

    iget-object v3, v3, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mInputMethodService:Landroid/inputmethodservice/InputMethodService;

    sget-object v4, Lcom/miui/inputmethod/InputMethodBottomManager;->clipBoardDataChangeInterface:Lcom/miui/inputmethod/ClipBoardDataChangeInterface;

    invoke-direct {v2, p0, v3, v4}, Lcom/miui/inputmethod/MiuiClipboardManager;-><init>(Landroid/content/Context;Landroid/inputmethodservice/InputMethodService;Lcom/miui/inputmethod/ClipBoardDataChangeInterface;)V

    sput-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sMiuiClipboardManager:Lcom/miui/inputmethod/MiuiClipboardManager;

    :cond_3
    invoke-static {}, Lcom/miui/inputmethod/InputMethodUtil;->isSupportLinearMotorVibrate()Z

    move-result v2

    sput-boolean v2, Lcom/miui/inputmethod/InputMethodUtil;->sIsSupportLinearMotorVibrate:Z

    sget-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sGlobalLayoutListener:Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;

    if-eqz v2, :cond_4

    :try_start_0
    sget-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;

    iget-object v2, v2, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mRootView:Landroid/view/View;

    invoke-virtual {v2}, Landroid/view/View;->getViewTreeObserver()Landroid/view/ViewTreeObserver;

    move-result-object v2

    sget-object v3, Lcom/miui/inputmethod/InputMethodBottomManager;->sGlobalLayoutListener:Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;

    invoke-virtual {v2, v3}, Landroid/view/ViewTreeObserver;->removeOnGlobalLayoutListener(Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v2

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "addMiuiBottomViewInner: "

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_4
    :goto_0
    new-instance v1, Lcom/miui/inputmethod/InputMethodBottomManager$MiuiBottomLayoutListener;

    sget-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;

    iget-object v2, v2, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mMiuiBottomArea:Landroid/view/ViewGroup;

    invoke-direct {v1, v2, p0}, Lcom/miui/inputmethod/InputMethodBottomManager$MiuiBottomLayoutListener;-><init>(Landroid/view/ViewGroup;Landroid/content/Context;)V

    sput-object v1, Lcom/miui/inputmethod/InputMethodBottomManager;->sGlobalLayoutListener:Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;

    sget-object v1, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;

    iget-object v1, v1, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mRootView:Landroid/view/View;

    invoke-virtual {v1}, Landroid/view/View;->getViewTreeObserver()Landroid/view/ViewTreeObserver;

    move-result-object v1

    sget-object v2, Lcom/miui/inputmethod/InputMethodBottomManager;->sGlobalLayoutListener:Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;

    invoke-virtual {v1, v2}, Landroid/view/ViewTreeObserver;->addOnGlobalLayoutListener(Landroid/view/ViewTreeObserver$OnGlobalLayoutListener;)V

    sget-object v1, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;

    iget-object v1, v1, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mMiuiBottomArea:Landroid/view/ViewGroup;

    invoke-virtual {v1, v0}, Landroid/view/ViewGroup;->addView(Landroid/view/View;)V

    invoke-static {p0}, Lcom/miui/inputmethod/InputMethodBottomManager;->refreshBottomSkin(Landroid/content/Context;)V
    invoke-static {}, Lcom/miui/inputmethod/InputMethodBottomManager;->updateBottomColorFromImeBackground()V

    return-void
