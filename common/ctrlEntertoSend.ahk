#Requires AutoHotkey v2.0
#SingleInstance Force
#Include IME.ahk

global IMEFlag := false
StartIMEFlagHook()
SetTimer(CheckIMEFlag, 100)
CheckIMEFlag() {
    ToolTip(imeFlag)
}

#HotIf WinActive("ahk_group CtrlEnterToSend")
global ih := InputHook("V")

imeFlagTrueKeys := ["{Space}", "{F2}", "{F3}", "{F4}", "{F5}", "{F6}", "{F7}", "{F8}", "{F9}", "{F10}", "{F11}"]
imeFlagFalseKeys := ["{Esc}", "{BackSpace}", "{Browser_Back}", "{Browser_Forward}"]

for key in imeFlagTrueKeys
    ih.KeyOpt(key, "E")

for key in imeFlagFalseKeys
    ih.KeyOpt(key, "E")
ih.KeyOpt("{Enter}", "E")
ih.OnEnd := OnEndManager
ih.Start()

OnEndManager(ih) {
    if (ih.EndReason != "EndKey") {
        ih.Start()
        return
    }

    key := "{" . ih.EndKey . "}"
    global IMEFlag

    for targetKey in imeFlagTrueKeys {
        if (targetKey = key) {
            ToolTip("Reason: " . ih.EndReason . " Key: " . ih.EndKey)
            imeFlagToTrue()
            ih.Start()
            return
        }
    }
    for targetKey in imeFlagFalseKeys {
        if (targetKey = key) {
            IMEFlag := false
            ih.Start()
            return
        }
    }
    if (key = "{Enter}") {
        imeMode := IME_GET()
        if (imeMode) {
            if (isIMEConverting()) {
                ToolTip("Enter pressed")
                SendInput "{Enter}"
                IMEFlag := false
            } else {
                SendInput "+{Enter}"
            }
        } else {
            SendInput "+{Enter}"
        }
    }
    ih.Start()
}

Enter:: Send ""
^Enter:: {
    SendInput "{Enter}"
    return
}
; ウィンドウ監視フック
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

StartIMEFlagHook() {
    global IMEFlag
    input := InputHook("V I1 L0")
    input.KeyOpt("{All}", "N")
    input.OnKeyDown := (input, vk, sc) => (IMEFlag := true)
    input.Start()
}
