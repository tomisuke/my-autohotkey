#Requires AutoHotkey v2.0

global IMEFlag := false
#HotIf WinActive("ahk_group CtrlEnterToSend")
Space:: {
    global IMEFlag
    if (IME_GetConverting() != 0) {
        IMEFlag := true
        SendInput "{Space}"
    } else {
        SendInput "{Space}"
    }
}
Enter::
NumpadEnter::
{
    global IMEFlag
    imeMode := IME_GET()

    if (imeMode) {
        if (isIMEConverting()) {
            SendInput "{Enter}"
            IMEFlag := false
        } else {
            SendInput "+{Enter}"
        }
    } else {
        SendInput "+{Enter}"
    }
    return
}
^Enter::
{
    SendInput "{Enter}"
    return
}
#HotIf