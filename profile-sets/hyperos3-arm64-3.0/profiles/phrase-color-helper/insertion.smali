.method private static updateBottomColorFromImeBackground()V
    .locals 10

    sget-object v0, Lcom/miui/inputmethod/InputMethodBottomManager;->sBottomViewHelper:Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;
    if-eqz v0, :color_done
    iget-object v1, v0, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mInputFrame:Landroid/view/ViewGroup;
    invoke-virtual {v1}, Landroid/view/View;->getWidth()I
    move-result v2
    invoke-virtual {v1}, Landroid/view/View;->getHeight()I
    move-result v3
    if-lez v2, :drawable_fallback
    const/4 v4, 0x5
    if-gt v3, v4, :sample_input_frame
    goto :drawable_fallback
    :sample_input_frame
    sget-object v4, Landroid/graphics/Bitmap$Config;->ARGB_8888:Landroid/graphics/Bitmap$Config;
    invoke-static {v2, v3, v4}, Landroid/graphics/Bitmap;->createBitmap(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;
    move-result-object v4
    new-instance v5, Landroid/graphics/Canvas;
    invoke-direct {v5, v4}, Landroid/graphics/Canvas;-><init>(Landroid/graphics/Bitmap;)V
    invoke-virtual {v1, v5}, Landroid/view/View;->draw(Landroid/graphics/Canvas;)V
    div-int/lit8 v6, v2, 0x2
    add-int/lit8 v7, v3, -0x5
    invoke-virtual {v4, v6, v7}, Landroid/graphics/Bitmap;->getPixel(II)I
    move-result v3
    invoke-virtual {v4}, Landroid/graphics/Bitmap;->recycle()V
    goto :color_value_ready
    :drawable_fallback
    invoke-virtual {v1}, Landroid/view/View;->getBackground()Landroid/graphics/drawable/Drawable;
    move-result-object v1
    instance-of v2, v1, Landroid/graphics/drawable/ColorDrawable;
    if-nez v2, :color_drawable_found
    iget-object v1, v0, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mRootView:Landroid/view/View;
    invoke-virtual {v1}, Landroid/view/View;->getBackground()Landroid/graphics/drawable/Drawable;
    move-result-object v1
    instance-of v2, v1, Landroid/graphics/drawable/ColorDrawable;
    if-nez v2, :color_drawable_found
    iget-object v0, v0, Lcom/miui/inputmethod/InputMethodBottomManager$BottomViewHelper;->mInputMethodService:Landroid/inputmethodservice/InputMethodService;
    invoke-virtual {v0}, Landroid/inputmethodservice/InputMethodService;->getWindow()Landroid/app/Dialog;
    move-result-object v0
    invoke-virtual {v0}, Landroid/app/Dialog;->getWindow()Landroid/view/Window;
    move-result-object v0
    if-eqz v0, :color_done
    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v0
    invoke-virtual {v0}, Landroid/view/View;->getBackground()Landroid/graphics/drawable/Drawable;
    move-result-object v1
    instance-of v2, v1, Landroid/graphics/drawable/ColorDrawable;
    if-eqz v2, :color_done
    :color_drawable_found
    check-cast v1, Landroid/graphics/drawable/ColorDrawable;
    invoke-virtual {v1}, Landroid/graphics/drawable/ColorDrawable;->getColor()I
    move-result v3
    :color_value_ready
    invoke-static {v3}, Landroid/graphics/Color;->alpha(I)I
    move-result v4
    const/16 v5, 0xc0
    if-lt v4, v5, :color_done
    invoke-static {v3}, Landroid/graphics/Color;->red(I)I
    move-result v4
    invoke-static {v3}, Landroid/graphics/Color;->green(I)I
    move-result v5
    add-int/2addr v4, v5
    invoke-static {v3}, Landroid/graphics/Color;->blue(I)I
    move-result v5
    add-int/2addr v4, v5
    const/16 v5, 0x180
    if-ge v4, v5, :light_background
    const/4 v6, -0x1
    const/high16 v7, -0x1000000
    goto :apply_color
    :light_background
    const/high16 v6, -0x1000000
    const/4 v7, -0x1
    :apply_color
    const/4 v0, 0x1
    invoke-static {v0, v3, v6, v7}, Lcom/miui/inputmethod/InputMethodBottomManager;->setBottomColor(ZIII)V
    :color_done
    return-void
.end method
