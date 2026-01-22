#Requires AutoHotkey v2.0

global IMEFlag := false
#HotIf WinActive("ahk_group CtrlEnterToSend")
global IMEFlag
Space:: imeFlagToTrue()
~F2:: imeFlagToTrue()
~F3:: imeFlagToTrue()
~F4:: imeFlagToTrue()
~F5:: imeFlagToTrue()
~F6:: imeFlagToTrue()
~F7:: imeFlagToTrue()
~F8:: imeFlagToTrue()
~F9:: imeFlagToTrue()
~F10:: imeFlagToTrue()
~F11:: imeFlagToTrue()
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
    ih.OnKeyDown := (ih, vk, sc) => (IMEFlag := true)
    ih.Start()
}