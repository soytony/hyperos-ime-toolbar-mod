    .locals 1

    # Do not apply package-visibility filtering to the enabled IME switcher list.
    # IME processes need to enumerate every user-enabled IME to switch between them.
    const/4 v0, 0x0

    return v0
