#Requires AutoHotkey v2.0
#Include <UIA>
;sc07b:無変換   sc079:変換

;入力抜け対策
SetKeyDelay 10, 10
SetWinDelay 100 ;default 100
SetControlDelay 20 ;default 20
SendMode "Event" ;default Input
;-----------------
;管理者権限で起動されていない場合は昇格して再起動す
if !A_IsAdmin && !(A_Args.Length && A_Args[-1] = "/elevated") {
    try {
        Run '*RunAs "' A_AhkPath '" "' A_ScriptFullPath '" /elevated', A_ScriptDir
        ExitApp
    }
    TrayTip "管理者権限なしで起動中。管理者権限アプリ内ではホットキーが動作しません", "TomisukeLaptop.ahk", 2
}
;-----------------
#Include app/ctrlEntertoSend.ahk
#Include %A_ScriptDir%/common/
#Include runApp.ahk
#Include IME.ahk
#include appOriginal.ahk
#include common.ahk
#Include string.ahk
#Include monitorLayout.ahk
#Include remoteMonitor.ahk
#Include Launcher/
#include bookmark.ahk
#Include launcher.ahk
;-----------------
;parsecd.exeがアクティブウィンドウになったらremoteDesktop.ahkに切り替える
;ホスト側でもこのスクリプトを使うため、クライアント(ラップトップ)のときだけ有効にする
if activeLaptop
    DllCall("SetWinEventHook", "UInt", 0x0003, "UInt", 0x0003, "Ptr", 0
        , "Ptr", CallbackCreate(OnForegroundChanged, "F"), "UInt", 0, "UInt", 0, "UInt", 0x0000)

;ホストでリモート判定を手動トグルする(動作確認用)
#HotIf activeDesktop
!^+F10:: RM_Toggle()
#HotIf

OnForegroundChanged(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
    if idObject != 0
        return
    try exe := WinGetProcessName("ahk_id " hwnd)
    catch
        return
    ;フック内では判定のみ行い、実際の切り替えは通常スレッドに委ねる
    if exe = "parsecd.exe"
        SetTimer SwitchToRemoteDesktop, -1
}

SwitchToRemoteDesktop() {
    try FileAppend A_Hour ":" A_Min ":" A_Sec " Parsecを検出 → remoteDesktop.ahkに切り替え`n", A_ScriptDir "\remoteDesktop.log"
    Run '"' A_AhkPath '" "' A_ScriptDir '\remoteDesktop.ahk"', A_ScriptDir
    ExitApp
}
;-----------------
myLauncher := appManager()
Pause:: {
    Run ".\TomisukeToQwerty.ahk"
    Msgbox "ゲストモード`nGuestMode", "LayoutChanger", "T0.5"
    ExitApp
}
;ピリオドレイヤー
;記号
. & r:: Send "_"
. & d:: Send "{sc028}"
. & y:: {
    SendText "["
}
. & p:: {
    SendText "]"
}
. & n:: Send "!"
. & t:: Send "?"
. & s:: Send "("
. & k:: Send ")"
. & h:: Send "&"
. & m:: Send "%"
. & g:: Send '"'
. & j:: Send "'"
. & f:: Send "#"
. & Delete:: Send "$"
. & b:: Send "{{}"
. & z:: Send "{}}"

;enterレイヤー
;矢印
Enter & n:: Send "{Blind}{Left}"
Enter & t:: Send "{Blind}{Down}"
Enter & s:: Send "{Blind}{Up}"
Enter & k:: Send "{Blind}{Right}"
Enter & g:: Send "{Blind}{Home}"
Enter & f:: Send "{Blind}{End}"
#HotIf WinActive("ahk_exe ONENOTE.EXE")
Enter & t:: DllCall("keybd_event", "UInt", 0x28, "UInt", 0, "UInt", 1, "UInt", 0) ; Down
Enter & s:: DllCall("keybd_event", "UInt", 0x26, "UInt", 0, "UInt", 1, "UInt", 0) ; Up
#HotIf
Enter & r:: Send "{Blind}{AppsKey}"
Enter & d:: Send "{Blind}{Tab}"

Enter & h:: Send "!+^{F1}"  ;fluentSearch
Enter & m:: Send "+{sc079}" ;再度変換
Enter & y:: Send "{Blind}{up}"

Enter & o:: launcher()

Enter & v:: typeTime()
Enter & w:: typeDate()

Space & Insert:: Send "{sc079}"
;コンマレイヤー
, & n:: Send 4
, & AppsKey:: Send 0
, & t:: Send 5
, & s:: Send 6
, & h:: Send 1
, & m:: Send 2
, & b:: Send 3
, & z:: Send "+"
, & r:: Send 7
, & d:: Send 8
, & y:: Send 9

;スペースレイヤー
;アプリ起動
Space & a:: mylauncher.runRegularApp(1)
Space & o:: mylauncher.runRegularApp(2)
Space & e:: mylauncher.runRegularApp(3)
Space & i:: mylauncher.runRegularApp(4)
Space & u:: mylauncher.runRegularApp(5)
Space & x:: mylauncher.activeAnotherApp()
Space & c:: mylauncher.runRegularApp(6)
Space & v:: mylauncher.runRegularApp(7)
Space & w:: mylauncher.runRegularApp(8)
Space & Delete:: mylauncher.runRegularApp(9)
Space & BackSpace:: mylauncher.runRegularApp(10)
;-レイヤー
- & n::AppsKey
- & t::+Tab
- & s::Tab

;FN
Space & j::F1
Space & h::F2
Space & m::F3
Space & b::F4
Space & z::F5
Space & \::F6
Space & g::F7
Space & n::F8
Space & t::F9
Space & s::F10
Space & k::F11
Space & f::F12
;輝度調整
Space & 1::!^F1
Space & ,::!^F2
;音量調整
Space & .::Volume_Down
Space & -::Volume_Up
Space & 4::Volume_Mute
;音声入出力切り換え
Space & ]:: { ;内蔵マイク
    btName := "OpenRun"  ; デバイス名
    Send("!^+#{F1}")
}
Space & [:: { ;OpenRun
    btName := "OpenRun"  ; デバイス名

    ; COM経由でWMIに問い合わせ（PS起動不要）
    wmi := ComObject("WbemScripting.SWbemLocator").ConnectServer()
    devices := wmi.ExecQuery("SELECT * FROM Win32_PnPEntity WHERE Name LIKE '%" . btName . "%'")

    connected := false
    for device in devices {
        if (device.Status = "OK")
            connected := true
    }
    if (!connected) {
        TrayTip("OpenRun接続中...", btName, 1)
        exitCode := RunWait(
            "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File `"C:\sync\program\OpenRunConnect.ps1`"", ,
            "Hide")
        if (exitCode != 0) {
            TrayTip("接続失敗", btName, 2)
            return
        }
        TrayTip("接続完了", btName, 1)

    }

    Send("!^+#{F2}")
}

;clibor
Enter & B::!^+0
Enter & z::!^+1
Enter & sc073::!^+2
;その他
sc029:: Send "{Esc}"
^+sc029:: Send "^+{Esc}"
Enter & j::!^+F13 ;flowLauncher
;ime制御
#HotIf WinExist("Flow.Launcher") OR WinActive("ahk_group IMEAbnormal")
F13:: IME_SET(1)
#HotIf
F13:: Send "{vk16}" ;かな/ローマ字キーtoIMEOn
#HotIf WinExist("Flow.Launcher") OR WinActive("ahk_group IMEAbnormal")
F14:: IME_SET(0)
#HotIf
F14:: Send "{vk1A}" ;EnterToIMEOff

;補助
Space::Space
,::,
.::.
enter::Enter
-::-

StartDebugFollow() {
    SetTimer(UpdateDebug, 50)
}
StopDebugFollow() {
    SetTimer(UpdateDebug, "Off"), ToolTip()
}
UpdateDebug() {
    try {
        el := UIA.GetFocusedElement()
        MouseGetPos &x, &y
        ; マウスの右下に表示（オフセット16px）  
        ToolTip IMEFlag " | " isIMEConverting() " | " el.CurrentControlType " " el.AriaRole " | " el.IsTextEditPatternAvailable " | "
        , x + 16, y + 16
    } catch {
        ; フォーカス要素が取得直後に無効化された場合（stale element）はこのティックをスキップ
    }
}
; StartDebugFollow()
