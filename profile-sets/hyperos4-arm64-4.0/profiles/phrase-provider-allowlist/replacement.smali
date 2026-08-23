    .locals 1

    # Permit clipboard/provider access for any IME caller.
    const/4 v0, 0x1
    return v0
