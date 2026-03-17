#Requires AutoHotkey v2.0

global IMEFlag := false
#HotIf WinActive("ahk_group CtrlEnterToSend")
global IMEFlag
Space:: imeFlagToTrue("Space") 
F2:: imeFlagToTrue("F2")
F3:: imeFlagToTrue("F3")
F4:: imeFlagToTrue("F4")
F5:: imeFlagToTrue("F5")
F6:: imeFlagToTrue("F6")
F7:: imeFlagToTrue("F7")
F8:: imeFlagToTrue("F8")
F9:: imeFlagToTrue("F9")
F10:: imeFlagToTrue("F10")
F11:: imeFlagToTrue("F11")
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