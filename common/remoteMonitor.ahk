;ホスト側で「今このセッションがリモートか」を監視し、キーバインドを切り替える
;
;シン・テレワークシステムのサーバーを「システムモード」で入れると、中身はWindowsのRDPになる。
;RDPではセッションが物理コンソールとリモート端末の間を移動するだけなので、
;  ・常駐スクリプトは切断・再接続をまたいで生き残る
;  ・今がリモートかどうかは SM_REMOTESESSION で確実に分かる(推定に頼らなくてよい)
;  ・画面構成はRDPがクライアントに合わせるので、こちらからモニターを触る必要がない
;
;自分が「ローカル役」か「リモート役」かは起動しているスクリプト名から判断する。
;  TomisukeDesktop.ahk で動いている = ローカル役 → リモート接続を待つ
;  TomisukeLaptop.ahk  で動いている = リモート役 → コンソール復帰を待つ

;===== 設定 =====
global RM_ENABLE := activeDesktop           ;ホスト(デスクトップ)でのみ動作させる
global RM_LOCAL_SCRIPT := "TomisukeDesktop.ahk"
global RM_REMOTE_SCRIPT := "TomisukeLaptop.ahk"
global RM_SWITCH_SCRIPT := true             ;リモート中にスクリプトを入れ替えるか
;RDPセッションの画面はRDP側が管理するので、既定では触らない。
;画面を共有するだけのソフト(Parsec等)に戻したときだけ true にする
global RM_SWITCH_MONITOR := false
global RM_KEEP_DEVICE := "\\.\DISPLAY2"     ;RM_SWITCH_MONITOR が true のときだけ使う
global RM_POLL_MS := 1000                   ;通知を取りこぼした場合の保険

;===== 内部状態 =====
global RM_logFile := A_ScriptDir "\remoteMonitor.log"
global RM_state := (A_ScriptName = RM_REMOTE_SCRIPT) ? "remote" : "local"
global RM_handingOver := false
global RM_notifyRegistered := false

RM_Init()

RM_Init() {
    if !RM_ENABLE
        return
    RM_InstallSessionNotify()
    SetTimer RM_Check, RM_POLL_MS
    OnExit RM_OnExit
    RM_Log("監視開始 役割=" RM_state " script=" A_ScriptName
        . " SM_REMOTESESSION=" SysGet(0x1000) " モニター数=" MonitorGetCount())
    ;役割と実際のセッション状態がずれていたら直ちに揃える
    SetTimer RM_Check, -200
}

;===== セッション判定 =====
;SM_REMOTESESSION = 0x1000 (RDPセッションなら非0、物理コンソールなら0)
RM_IsRemoteSession() {
    return SysGet(0x1000) != 0
}

RM_Check() {
    if RM_handingOver
        return
    remote := RM_IsRemoteSession()
    if (remote && RM_state = "local")
        RM_GoRemote("リモートセッションに接続された")
    else if (!remote && RM_state = "remote")
        RM_GoLocal("物理コンソールに戻った")
}

;セッションの接続/切断はイベントで受け取る(ポーリングより早く確実)
RM_InstallSessionNotify() {
    global RM_notifyRegistered
    ;NOTIFY_FOR_THIS_SESSION = 0
    if DllCall("Wtsapi32\WTSRegisterSessionNotification", "Ptr", A_ScriptHwnd, "UInt", 0, "Int") {
        RM_notifyRegistered := true
        OnMessage(0x02B1, RM_OnSessionChange)   ;WM_WTSSESSION_CHANGE
        return
    }
    RM_Log("セッション通知の登録に失敗 err=" A_LastError " (ポーリングのみで動作する)")
}

RM_OnSessionChange(wParam, lParam, msg, hwnd) {
    ;1=CONSOLE_CONNECT 2=CONSOLE_DISCONNECT 3=REMOTE_CONNECT 4=REMOTE_DISCONNECT
    ;7=SESSION_LOCK 8=SESSION_UNLOCK
    RM_Log("セッション変化 code=" wParam)
    ;通知直後はまだ SM_REMOTESESSION が切り替わっていないことがあるので少し待って判定する
    SetTimer RM_Check, -500
    return 0
}

;===== 状態遷移 =====
RM_GoRemote(reason) {
    global RM_state
    RM_Log("リモート (" reason ")")
    if RM_SWITCH_MONITOR {
        method := ML_SoloDisplay(RM_KEEP_DEVICE)
        RM_Log("  1画面化=" (method != "" ? "成功(" method ")" : "失敗または対象なし"))
    }
    RM_state := "remote"
    RM_HandOver(RM_REMOTE_SCRIPT)
}

RM_GoLocal(reason) {
    global RM_state
    RM_Log("ローカル (" reason ")")
    if RM_SWITCH_MONITOR
        RM_Log("  モニター復元=" (ML_RestoreDisplays() ? "成功" : "対象なし"))
    RM_state := "local"
    RM_HandOver(RM_LOCAL_SCRIPT)
}

;もう一方のスクリプトへ受け渡して自分は終了する
RM_HandOver(script) {
    global RM_handingOver
    if !RM_SWITCH_SCRIPT || (A_ScriptName = script)
        return
    RM_handingOver := true
    SetTimer RM_Check, 0
    RM_Log("  " script " へ切り替え")
    try Run '"' A_AhkPath '" "' A_ScriptDir '\' script '"', A_ScriptDir
    ExitApp
}

;===== 手動操作(動作確認用) =====
;スクリプトの入れ替えだけを手動で試す
RM_Toggle() {
    if !RM_ENABLE {
        TrayTip("このPCでは無効です", "remoteMonitor", 2)
        return
    }
    if (RM_state = "remote")
        RM_GoLocal("手動トグル")
    else
        RM_GoRemote("手動トグル")
}

;モニターだけを切り替える(Parsec等、画面を共有するだけのソフトを使うとき用)
;RDPセッション中は仮想ディスプレイを壊しかねないので実行しない
RM_ToggleMonitor() {
    if !RM_ENABLE {
        TrayTip("このPCでは無効です", "remoteMonitor", 2)
        return
    }
    if RM_IsRemoteSession() {
        TrayTip("リモートセッション中は使えません`n画面はRDPが管理しています", "モニターのみ切替", 2)
        return
    }
    if ML_HasState() {
        ok := ML_RestoreDisplays()
        TrayTip(ok ? "元の構成に復元しました" : "復元できませんでした", "モニターのみ切替", 2)
        return
    }
    method := ML_SoloDisplay(RM_KEEP_DEVICE)
    if (method = "detach")
        TrayTip("1画面にしました (" RM_KEEP_DEVICE ")", "モニターのみ切替", 2)
    else if (method = "clone")
        TrayTip("切り離しに失敗したため複製にしました", "モニターのみ切替", 2)
    else
        TrayTip("1画面化に失敗。remoteMonitor.log を確認してください", "モニターのみ切替", 2)
}

;現在のセッションとモニター構成を表示する
RM_ShowDisplays() {
    text := "SM_REMOTESESSION = " SysGet(0x1000)
        . (RM_IsRemoteSession() ? "  (リモートセッション)" : "  (物理コンソール)") "`n"
        . "役割 = " RM_state "   script = " A_ScriptName "`n"
        . "MonitorGetCount = " MonitorGetCount() "`n`n"
    for d in ML_GetDisplays() {
        text .= d.name (d.primary ? "   [プライマリ]" : "") "`n"
            . "    " d.w "x" d.h " @" d.freq "Hz   位置(" d.x ", " d.y ")`n`n"
    }
    MsgBox(text, "セッションとモニター構成", "T30")
}

;===== 終了時 =====
RM_OnExit(reason, code) {
    if RM_notifyRegistered
        DllCall("Wtsapi32\WTSUnRegisterSessionNotification", "Ptr", A_ScriptHwnd, "Int")
    ;受け渡しとリロードでは何もしない。次のインスタンスが引き継ぐ
    if (RM_handingOver || reason = "Reload")
        return 0
    ;手動でモニターを触ったまま終了する場合だけ戻す
    if (RM_SWITCH_MONITOR && ML_HasState()) {
        ML_RestoreDisplays()
        RM_Log("終了(" reason ") → モニター構成を復元")
    }
    return 0
}

RM_Log(msg) {
    try FileAppend A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec " " msg "`n", RM_logFile, "UTF-8"
}
