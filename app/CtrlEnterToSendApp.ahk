#SingleInstance Force
#Requires AutoHotkey v2.0
#Include *i ..\common\IME.ahk
#Include *i common\IME.ahk
#Include *i IME.ahk 

global IMEFlag := false
SplitPath A_LineFile, , &thisFileDir
global ctrlEnterConfigPath := thisFileDir . "\CtrlEnterToSend.targets.txt"
global ctrlEnterTargets := LoadCtrlEnterTargets()
global ctrlEnterGui := Gui(, "CtrlEnterToSend")
global ctrlEnterListView := 0
global ctrlEnterInput := 0
global ctrlEnterStatus := 0
global ctrlEnterImeHook := 0
global ctrlEnterWinEventHook := 0
global ctrlEnterWindowChangeCallback := 0
global ctrlEnterLastForegroundHwnd := 0
global ctrlEnterSelectingMode := false

ctrlEnterGui.SetFont("s11")
ctrlEnterGui.Add("Text", "xm w560", "Ctrl+Enter を Enter に変えたいウィンドウを登録します。")
ctrlEnterGui.Add("Text", "xm w560", "例: ahk_exe Discord.exe / ahk_class CabinetWClass")
ctrlEnterListView := ctrlEnterGui.Add("ListView", "xm w560 r12", ["判定文字列"])
ctrlEnterListView.ModifyCol(1, 540)
ctrlEnterInput := ctrlEnterGui.Add("Edit", "xm w420")
addActiveButton := ctrlEnterGui.Add("Button", "x+m yp w130", "対象のアプリを選択")
addInputButton := ctrlEnterGui.Add("Button", "xm w120", "入力値を追加")
removeButton := ctrlEnterGui.Add("Button", "x+m w120", "選択を削除")
reloadButton := ctrlEnterGui.Add("Button", "x+m w120", "再読込")
ctrlEnterStatus := ctrlEnterGui.Add("Text", "xm w560", "")

addActiveButton.OnEvent("Click", SelectActiveTarget)
addInputButton.OnEvent("Click", AddInputTarget)
removeButton.OnEvent("Click", RemoveSelectedTarget)
reloadButton.OnEvent("Click", ReloadTargets)
ctrlEnterGui.OnEvent("Close", HideGui)
ctrlEnterGui.OnEvent("Escape", HideGui)

RefreshTargetList()
StartIMEFlagHook()
StartWindowChangeHook()
if (A_LineFile == A_ScriptFullPath) {
    ctrlEnterGui.Show()
}                                                                  

#HotIf (A_LineFile == A_ScriptFullPath) && IsCtrlEnterTarget()
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
        if (isIMEConverting() AND !IsTextBoxFocused()) {
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

IsCtrlEnterTarget() {
    global ctrlEnterTargets
    for target in ctrlEnterTargets {
        try {
            if WinActive(target)
                return true
        } catch {
        }
    }
    return false
}

LoadCtrlEnterTargets() {
    global ctrlEnterConfigPath
    defaultTargets := [
        "ahk_exe Discord.exe",
        "ahk_exe ChatGPT.exe",
        "ahk_exe Perplexity.exe",
        "ahk_exe claude.exe",
        "ahk_exe LINE.exe",
    ]

    if !FileExist(ctrlEnterConfigPath) {
        return defaultTargets
    }

    try {
        rawTargets := StrSplit(FileRead(ctrlEnterConfigPath), "`n")
    } catch {
        return defaultTargets
    }

    targets := []
    for rawTarget in rawTargets {
        target := Trim(rawTarget, " `t`r`n")
        if (target = "" || SubStr(target, 1, 1) = ";")
            continue
        if !HasTarget(targets, target)
            targets.Push(target)
    }

    return targets.Length ? targets : defaultTargets
}

SaveCtrlEnterTargets() {
    global ctrlEnterConfigPath, ctrlEnterTargets, ctrlEnterStatus
    file := FileOpen(ctrlEnterConfigPath, "w", "UTF-8")
    try {
        for target in ctrlEnterTargets {
            file.Write(target . "`n")
        }
    } finally {
        file.Close()
    }
    ctrlEnterStatus.Value := "保存しました。登録数: " . ctrlEnterTargets.Length
}

RefreshTargetList() {
    global ctrlEnterListView, ctrlEnterTargets, ctrlEnterStatus
    while (ctrlEnterListView.GetCount()) {
        ctrlEnterListView.Delete(1)
    }
    for target in ctrlEnterTargets {
        ctrlEnterListView.Add(, target)
    }
    ctrlEnterStatus.Value := "登録数: " . ctrlEnterTargets.Length
}

AddTarget(target) {
    global ctrlEnterTargets, ctrlEnterInput
    target := Trim(target, " `t`r`n")
    if (target = "") {
        return
    }
    if HasTarget(ctrlEnterTargets, target) {
        ctrlEnterInput.Value := target
        return
    }
    ctrlEnterTargets.Push(target)
    SaveCtrlEnterTargets()
    RefreshTargetList()
    ctrlEnterInput.Value := target
}

RemoveTarget(target) {
    global ctrlEnterTargets
    index := FindTargetIndex(ctrlEnterTargets, target)
    if (index = 0) {
        return
    }
    ctrlEnterTargets.RemoveAt(index)
    SaveCtrlEnterTargets()
    RefreshTargetList()
}

SelectActiveTarget(*) {
    global ctrlEnterSelectingMode, ctrlEnterGui, ctrlEnterStatus
    ctrlEnterSelectingMode := true
    ctrlEnterStatus.Value := "登録したいウィンドウをクリックしてください（右クリック/Escでキャンセル）"

    ; 一時的にホットキーを有効化
    Hotkey("~LButton", HandleWindowSelection, "On")
    Hotkey("~RButton", CancelWindowSelection, "On")
    Hotkey("~Esc", CancelWindowSelection, "On")
}

HandleWindowSelection(HotkeyName) {
    global ctrlEnterGui, ctrlEnterStatus

    ; クリックされた位置のウィンドウIDを取得
    MouseGetPos , , &clickedHwnd

    ; 自分自身のGUIをクリックした場合は無視する
    if (clickedHwnd = ctrlEnterGui.Hwnd) {
        return
    }

    ; ホットキーを解除
    DisableSelectionHotkeys()

    processName := ""
    if (clickedHwnd) {
        try {
            processName := WinGetProcessName("ahk_id " . clickedHwnd)
        } catch {
            processName := ""
        }
    }

    if (processName != "") {
        targetStr := "ahk_exe " . processName
        result := MsgBox("以下のアプリを登録しますか？`n`n" . targetStr, "登録確認", "YesNo Icon?")
        if (result = "Yes") {
            AddTarget(targetStr)
            ctrlEnterStatus.Value := processName . " を追加しました。"
        } else {
            ctrlEnterStatus.Value := "追加をキャンセルしました。"
        }
        return
    }

    className := ""
    if (clickedHwnd) {
        try {
            className := WinGetClass("ahk_id " . clickedHwnd)
        } catch {
            className := ""
        }
    }

    if (className != "") {
        targetStr := "ahk_class " . className
        result := MsgBox("以下のアプリを登録しますか？`n`n" . targetStr, "登録確認", "YesNo Icon?")
        if (result = "Yes") {
            AddTarget(targetStr)
            ctrlEnterStatus.Value := className . " を追加しました。"
        } else {
            ctrlEnterStatus.Value := "追加をキャンセルしました。"
        }
        return
    }

    ctrlEnterStatus.Value := "ウィンドウ情報の取得に失敗しました。"
}

CancelWindowSelection(HotkeyName) {
    global ctrlEnterStatus
    DisableSelectionHotkeys()
    ctrlEnterStatus.Value := "選択をキャンセルしました。"
}

DisableSelectionHotkeys() {
    global ctrlEnterSelectingMode
    ctrlEnterSelectingMode := false
    try Hotkey("~LButton", "Off")
    try Hotkey("~RButton", "Off")
    try Hotkey("~Esc", "Off")
}

AddInputTarget(*) {
    global ctrlEnterInput
    AddTarget(ctrlEnterInput.Value)
}

RemoveSelectedTarget(*) {
    global ctrlEnterListView
    row := ctrlEnterListView.GetNext(0)
    if (row = 0) {
        return
    }
    target := ctrlEnterListView.GetText(row, 1)
    RemoveTarget(target)
}

ReloadTargets(*) {
    global ctrlEnterTargets
    ctrlEnterTargets := LoadCtrlEnterTargets()
    RefreshTargetList()
}

HideGui(*) {
    global ctrlEnterGui, ctrlEnterSelectingMode
    if (ctrlEnterSelectingMode) {
        CancelWindowSelection("")
        return
    }
    ctrlEnterGui.Hide()
}

HasTarget(targets, target) {
    for existingTarget in targets {
        if (StrLower(existingTarget) = StrLower(target))
            return true
    }
    return false
}

FindTargetIndex(targets, target) {
    for index, existingTarget in targets {
        if (StrLower(existingTarget) = StrLower(target))
            return index
    }
    return 0
}

StartIMEFlagHook() {
    global ctrlEnterImeHook
    ctrlEnterImeHook := InputHook("V I1 L0")
    ctrlEnterImeHook.KeyOpt("{All}", "N")
    ctrlEnterImeHook.OnKeyDown := OnIMEFlagInput
    ctrlEnterImeHook.Start()
}

OnIMEFlagInput(ih, vk, sc) {
    imeFlagToTrue()
}

StartWindowChangeHook() {
    global ctrlEnterWindowChangeCallback, ctrlEnterWinEventHook
    ctrlEnterWindowChangeCallback := CallbackCreate(OnWindowChange)
    ctrlEnterWinEventHook := DllCall("SetWinEventHook"
        , "UInt", 0x0003
        , "UInt", 0x0003
        , "Ptr", 0
        , "Ptr", ctrlEnterWindowChangeCallback
        , "UInt", 0
        , "UInt", 0
        , "UInt", 0)
}

OnWindowChange(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
    global IMEFlag, ctrlEnterGui, ctrlEnterLastForegroundHwnd
    ; ウィンドウオブジェクト (OBJID_WINDOW=0, CHILDID_SELF=0) のイベントのみを対象にする
    if (idObject != 0 || idChild != 0)
        return
    if (hwnd && (!ctrlEnterGui || hwnd != ctrlEnterGui.Hwnd)) {
        ctrlEnterLastForegroundHwnd := hwnd
    }
    IMEFlag := false
}

OnMessage(0x0010, OnCloseMessage) ; WM_CLOSE を監視

OnCloseMessage(wParam, lParam, msg, hwnd) {
    global ctrlEnterGui
    if (hwnd = ctrlEnterGui.Hwnd) {
        CleanupHooks()
        ExitApp
    }
}

CleanupHooks() {
    global ctrlEnterWinEventHook, ctrlEnterWindowChangeCallback
    try {
        if (ctrlEnterWinEventHook) {
            DllCall("UnhookWinEvent", "Ptr", ctrlEnterWinEventHook)
            ctrlEnterWinEventHook := 0
        }
    } catch {
    }
    try {
        if (ctrlEnterWindowChangeCallback) {
            CallbackFree(ctrlEnterWindowChangeCallback)
            ctrlEnterWindowChangeCallback := 0
        }
    } catch {
    }
}

OnExit(ExitFunc)

ExitFunc(ExitReason, ExitCode) {
    CleanupHooks()
}

IsTextBoxFocused() {
    try {
        ; UIAutomation オブジェクトの作成
        uia := ComObject("{ff48dba4-6085-4f09-94b6-be0dee3507a1}", "{30cbe57d-d9d3-4a2a-8577-65810cd7ded7}")
        ; 現在フォーカスされている要素を取得
        focusedElement := uia.GetFocusedElement()
        if !focusedElement
            return false

        ; コントロールタイプのIDを取得
        ; 50004 = UIA_EditControlTypeId (一般的な入力欄)
        ; 50030 = UIA_DocumentControlTypeId (ブラウザ内の入力欄やVS Codeのエディタ部分など)
        controlType := focusedElement.CurrentControlType
        return (controlType == 50004 || controlType == 50030)
    } catch {
        return false
    }
}
