#Requires AutoHotkey v2.0

global IMEFlag := false
#HotIf WinActive("ahk_group CtrlEnterToSend")
global IMEFlag
~Space::
~F2::
~F3::
~F4::
~F5::
~F6::
~F7::
~F8::
~F9::
~F10::
~F11:: {
    imeFlagToTrue()
}

~Esc::
~LButton::
~RButton::
~BackSpace::
~Browser_Back::
~Browser_Forward::
~XButton1::
~XButton2::
{
    global IMEFlag
    IMEFlag := false
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
DllCall("SetWinEventHook"
    , "UInt", 0x0003
    , "UInt", 0x0003
    , "Ptr", 0
    , "Ptr", CallbackCreate(OnWindowChange)
    , "UInt", 0
    , "UInt", 0
    , "UInt", 0)

OnWindowChange(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
    global IMEFlag
    IMEFlag := false
}
#HotIf

StartIMEFlagHook()

StartIMEFlagHook() {
    global IMEFlag
    ih := InputHook("V I1 L0")
    ih.KeyOpt("{All}", "N")
    ih.OnKeyDown := OnIMEFlagInput
    ih.Start()
}

OnIMEFlagInput(ih, vk, sc) {
    imeFlagToTrue()
}
