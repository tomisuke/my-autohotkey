;ホスト側でParsecのリモート接続を検知し、接続中だけ
;  ・モニターを1画面に落とす
;  ・TomisukeDesktop.ahk を終了して TomisukeLaptop.ahk に切り替える
;切断したら元に戻す。主トリガーはParsecのホストログ、従として入力の注入フラグを使う。
;
;自分が「ローカル役」か「リモート役」かは起動しているスクリプト名から判断する。
;  TomisukeDesktop.ahk で動いている = ローカル役 → 接続を待つ
;  TomisukeLaptop.ahk  で動いている = リモート役 → 切断を待つ

;===== 設定 =====
global RM_ENABLE := activeDesktop           ;ホスト(デスクトップ)でのみ動作させる
global RM_LOCAL_SCRIPT := "TomisukeDesktop.ahk"
global RM_REMOTE_SCRIPT := "TomisukeLaptop.ahk"
global RM_SWITCH_MONITOR := true            ;リモート中にモニターを1画面へ落とすか
global RM_SWITCH_SCRIPT := true             ;リモート中にスクリプトを入れ替えるか
global RM_KEEP_DEVICE := ""                 ;残すモニター。空ならプライマリ
global RM_USE_INPUT_FALLBACK := true        ;ログで判定できないとき注入フラグで補うか
global RM_POLL_MS := 500
global RM_GRACE_MS := 5000                  ;起動直後は判定しない(切り替え直後の往復を防ぐ)
global RM_LOCAL_RETURN_MS := 1500           ;物理入力をこの時間内に観測したらローカル復帰とみなす
global RM_NO_PHYSICAL_MS := 3000            ;注入入力をリモートと判断するのに必要な「物理入力がない」時間
global RM_PHYSICAL_HITS := 3                ;ローカル復帰に必要な物理入力の回数

;Parsecホストログのパターン。初回の実接続後に remoteMonitor.log を見て詰める
global RM_CONNECT_PATTERNS := [
    "i)hosting:.*\bconnected\b",
    "i)\bguest\b.*\bconnected\b"
]
global RM_DISCONNECT_PATTERNS := [
    "i)hosting:.*\bdisconnected\b",
    "i)\bguest\b.*\bdisconnected\b"
]
;Parsec起動のたびに出る行など、接続とは無関係なのに紛らわしい行
global RM_IGNORE_PATTERNS := [
    "i)IPC AS Client Connected",
    "i)connected IGD"
]

;===== 内部状態 =====
global RM_logFile := A_ScriptDir "\remoteMonitor.log"
global RM_parsecLog := EnvGet("APPDATA") "\Parsec\log.txt"
global RM_state := (A_ScriptName = RM_REMOTE_SCRIPT) ? "remote" : "local"
global RM_since := A_TickCount
global RM_lastInjected := 0
global RM_lastPhysical := 0
global RM_physicalCount := 0
global RM_handingOver := false
global RM_logPos := 0
global RM_hookKb := 0
global RM_hookMs := 0
global RM_cbKb := 0
global RM_cbMs := 0

RM_Init()

RM_Init() {
    if !RM_ENABLE
        return
    RM_SyncMonitors()
    RM_InstallHooks()
    RM_SeekLogEnd()
    SetTimer RM_Poll, RM_POLL_MS
    OnExit RM_OnExit
    RM_Log("監視開始 役割=" RM_state " script=" A_ScriptName " モニター数=" ML_GetDisplays().Length)
}

;スクリプトの役割とモニター構成を一致させる
RM_SyncMonitors() {
    if !RM_SWITCH_MONITOR
        return
    if (RM_state = "remote") {
        ;受け渡しで来た場合は既に1画面。素の状態で起動されたときだけ落とす
        if !ML_HasState()
            ML_SoloDisplay(RM_KEEP_DEVICE)
        return
    }
    ;ローカル役なのに構成が残っている = 前回が正常に終わっていない
    if ML_HasState() && ML_RestoreDisplays()
        RM_Log("残っていたモニター構成を復元")
}

;===== 状態遷移 =====
RM_Poll() {
    hit := RM_ScanParsecLog()
    if (RM_state = "local") {
        if (hit = "connect")
            RM_GoRemote("Parsecログで接続を検出")
        else if RM_InjectedOnly()
            RM_GoRemote("注入入力を検出(ホストの物理入力なし)")
        return
    }
    if (hit = "disconnect")
        RM_GoLocal("Parsecログで切断を検出")
    else if RM_PhysicalReturn()
        RM_GoLocal("ホストの物理入力を検出")
}

;リモート操作されている: 注入入力が来ていて、ホストの物理入力は途絶えている
RM_InjectedOnly() {
    if !RM_USE_INPUT_FALLBACK
        return false
    now := A_TickCount
    return RM_lastInjected > RM_since + RM_GRACE_MS
        && now - RM_lastInjected < 1000
        && now - RM_lastPhysical > RM_NO_PHYSICAL_MS
}

;ローカルに戻った: ホストの物理入力が続けて来ている
;単発の取りこぼしで往復しないよう、回数のしきい値を設ける
RM_PhysicalReturn() {
    if !RM_USE_INPUT_FALLBACK
        return false
    return RM_physicalCount >= RM_PHYSICAL_HITS
        && A_TickCount - RM_lastPhysical < RM_LOCAL_RETURN_MS
}

RM_GoRemote(reason) {
    global RM_state
    RM_Log("リモート接続を検出 (" reason ")")
    if RM_SWITCH_MONITOR
        RM_Log("  モニター切り離し=" (ML_SoloDisplay(RM_KEEP_DEVICE) ? "成功" : "対象なし"))
    RM_state := "remote"
    RM_HandOver(RM_REMOTE_SCRIPT)
}

RM_GoLocal(reason) {
    global RM_state
    RM_Log("ローカル復帰を検出 (" reason ")")
    if RM_SWITCH_MONITOR
        RM_Log("  モニター復元=" (ML_RestoreDisplays() ? "成功" : "対象なし"))
    RM_state := "local"
    RM_HandOver(RM_LOCAL_SCRIPT)
}

;もう一方のスクリプトへ受け渡して自分は終了する
RM_HandOver(script) {
    global RM_handingOver, RM_since, RM_physicalCount
    if !RM_SWITCH_SCRIPT || (A_ScriptName = script) {
        ;スクリプトを入れ替えない設定のときは、この場で役割だけ切り替える
        RM_since := A_TickCount
        RM_physicalCount := 0
        return
    }
    RM_handingOver := true
    SetTimer RM_Poll, 0
    RM_RemoveHooks()
    RM_Log("  " script " へ切り替え")
    try Run '"' A_AhkPath '" "' A_ScriptDir '\' script '"', A_ScriptDir
    ExitApp
}

;手動トグル(動作確認用)
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

;===== Parsecログ監視 =====
;過去のログで誤発火しないよう、起動時は末尾まで読み飛ばす
RM_SeekLogEnd() {
    global RM_logPos
    try {
        f := FileOpen(RM_parsecLog, "r", "UTF-8")
        if IsObject(f) {
            RM_logPos := f.Length
            f.Close()
        }
    }
}

;前回読んだ位置以降の追記分だけを走査し、"connect" / "disconnect" / "" を返す
RM_ScanParsecLog() {
    global RM_logPos
    if !FileExist(RM_parsecLog)
        return ""
    try f := FileOpen(RM_parsecLog, "r", "UTF-8")
    catch
        return ""
    if !IsObject(f)
        return ""
    if (f.Length < RM_logPos)   ;ローテーションされた
        RM_logPos := 0
    if (f.Length = RM_logPos) {
        f.Close()
        return ""
    }
    f.Pos := RM_logPos
    text := f.Read()
    RM_logPos := f.Pos
    f.Close()

    result := ""
    for line in StrSplit(text, "`n", "`r`t ") {
        if (line = "")
            continue
        ;パターン調整のため、接続に関係しそうな行はマッチの有無によらず控えておく
        if (InStr(line, "hosting") || InStr(line, "onnect") || InStr(line, "uest"))
            RM_Log("parsec| " line)
        if RM_MatchAny(line, RM_IGNORE_PATTERNS)
            continue
        ;同じ読み込み分に複数あった場合は最後のイベントを採用する
        if RM_MatchAny(line, RM_DISCONNECT_PATTERNS)
            result := "disconnect"
        else if RM_MatchAny(line, RM_CONNECT_PATTERNS)
            result := "connect"
    }
    return result
}

RM_MatchAny(line, patterns) {
    for p in patterns
        if RegExMatch(line, p)
            return true
    return false
}

;===== 低レベル入力フック =====
RM_InstallHooks() {
    global RM_cbKb, RM_cbMs, RM_hookKb, RM_hookMs
    hMod := DllCall("GetModuleHandleW", "Ptr", 0, "Ptr")
    RM_cbKb := CallbackCreate(RM_KbProc, "F", 3)
    RM_cbMs := CallbackCreate(RM_MsProc, "F", 3)
    RM_hookKb := DllCall("SetWindowsHookExW", "Int", 13, "Ptr", RM_cbKb, "Ptr", hMod, "UInt", 0, "Ptr")
    RM_hookMs := DllCall("SetWindowsHookExW", "Int", 14, "Ptr", RM_cbMs, "Ptr", hMod, "UInt", 0, "Ptr")
}

RM_RemoveHooks() {
    global RM_hookKb, RM_hookMs
    if RM_hookKb
        DllCall("UnhookWindowsHookEx", "Ptr", RM_hookKb)
    if RM_hookMs
        DllCall("UnhookWindowsHookEx", "Ptr", RM_hookMs)
    RM_hookKb := 0
    RM_hookMs := 0
}

;KBDLLHOOKSTRUCT: flags=+8, dwExtraInfo=+16 / LLKHF_INJECTED = 0x10
RM_KbProc(nCode, wParam, lParam) {
    if (nCode >= 0)
        RM_Mark(NumGet(lParam, 8, "UInt") & 0x10, NumGet(lParam, 16, "UPtr"))
    return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

;MSLLHOOKSTRUCT: flags=+12, dwExtraInfo=+24(x64)/+20(x86) / LLMHF_INJECTED = 0x01
RM_MsProc(nCode, wParam, lParam) {
    if (nCode >= 0)
        RM_Mark(NumGet(lParam, 12, "UInt") & 0x01, NumGet(lParam, A_PtrSize = 8 ? 24 : 20, "UPtr"))
    return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

;フック内では変数を更新するだけにして、実処理は RM_Poll に委ねる
RM_Mark(injected, extra) {
    global RM_lastInjected, RM_lastPhysical, RM_physicalCount
    ;AHK自身の Send / MouseMove は KEY_IGNORE 系の dwExtraInfo が付くので除外する
    if (extra >= 0xFFC3D44D && extra <= 0xFFC3D44F)
        return
    if injected {
        RM_lastInjected := A_TickCount
        return
    }
    RM_lastPhysical := A_TickCount
    if (RM_lastPhysical - RM_since > RM_GRACE_MS)
        RM_physicalCount++
}

;===== 終了時 =====
RM_OnExit(reason, code) {
    RM_RemoveHooks()
    ;受け渡しとリロードでは構成を触らない。次のインスタンスが役割を引き継ぐ
    if (RM_handingOver || reason = "Reload")
        return 0
    if (RM_state = "remote" && RM_SWITCH_MONITOR) {
        ML_RestoreDisplays()
        RM_Log("終了(" reason ") → モニター構成を復元")
    }
    return 0
}

RM_Log(msg) {
    try FileAppend A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec " " msg "`n", RM_logFile, "UTF-8"
}
