;ホスト側でParsecのリモート接続を検知し、接続中だけモニターを1画面に落とす
;主トリガーはParsecのホストログ、従として入力の注入フラグを使う

;===== 設定 =====
global RM_ENABLE := true
global RM_KEEP_DEVICE := ""             ;残すモニター。空ならプライマリ("\\.\DISPLAY1" のように指定する)
global RM_POLL_MS := 500
global RM_GRACE_MS := 3000              ;状態を切り替えた直後は逆方向の判定を無視する
global RM_LOCAL_RETURN_MS := 1500       ;物理入力をこの時間内に観測したらローカル復帰とみなす
global RM_NO_PHYSICAL_MS := 3000        ;注入入力をリモートと判断するために必要な「物理入力がない」時間

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
global RM_reloadFlag := A_ScriptDir "\remoteMonitor.reload"
global RM_parsecLog := EnvGet("APPDATA") "\Parsec\log.txt"
global RM_state := "local"
global RM_localSince := A_TickCount
global RM_remoteSince := 0
global RM_lastInjected := 0
global RM_lastPhysical := 0
global RM_logPos := 0
global RM_hookKb := 0
global RM_hookMs := 0
global RM_cbKb := 0
global RM_cbMs := 0

RM_Init()

RM_Init() {
    if !RM_ENABLE
        return
    RM_RecoverState()
    RM_InstallHooks()
    RM_SeekLogEnd()
    SetTimer RM_Poll, RM_POLL_MS
    OnExit RM_OnExit
    RM_Log("監視開始 state=" RM_state " モニター数=" ML_GetDisplays().Length)
}

;===== 状態遷移 =====
RM_Poll() {
    hit := RM_ScanParsecLog()
    now := A_TickCount
    reason := ""
    if (RM_state = "local") {
        if (hit = "connect")
            reason := "Parsecログで接続を検出"
        else if (RM_lastInjected > RM_localSince + RM_GRACE_MS
            && now - RM_lastInjected < 1000
            && now - RM_lastPhysical > RM_NO_PHYSICAL_MS)
            reason := "注入入力を検出(ホストの物理入力なし)"
        if (reason != "")
            RM_GoRemote(reason)
        return
    }
    if (hit = "disconnect")
        reason := "Parsecログで切断を検出"
    else if (RM_lastPhysical > RM_remoteSince + RM_GRACE_MS && now - RM_lastPhysical < RM_LOCAL_RETURN_MS)
        reason := "ホストの物理入力を検出"
    if (reason != "")
        RM_GoLocal(reason)
}

RM_GoRemote(reason) {
    global RM_state, RM_remoteSince
    RM_state := "remote"
    RM_remoteSince := A_TickCount
    ok := ML_SoloDisplay(RM_KEEP_DEVICE)
    RM_Log("リモート → 1画面 (" reason ") 切り離し=" (ok ? "成功" : "対象なし"))
}

RM_GoLocal(reason) {
    global RM_state, RM_localSince
    RM_state := "local"
    RM_localSince := A_TickCount
    ok := ML_RestoreDisplays()
    RM_Log("ローカル → マルチモニター復元 (" reason ") 復元=" (ok ? "成功" : "対象なし"))
}

;手動トグル(動作確認用)
RM_Toggle() {
    if (RM_state = "remote")
        RM_GoLocal("手動トグル")
    else
        RM_GoRemote("手動トグル")
    TrayTip((RM_state = "remote") ? "1画面に切り替えました" : "マルチモニターに戻しました", "remoteMonitor", 2)
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
    global RM_lastInjected, RM_lastPhysical
    ;AHK自身の Send / MouseMove は KEY_IGNORE 系の dwExtraInfo が付くので除外する
    if (extra >= 0xFFC3D44D && extra <= 0xFFC3D44F)
        return
    if injected
        RM_lastInjected := A_TickCount
    else
        RM_lastPhysical := A_TickCount
}

;===== 起動時 / 終了時 =====
RM_RecoverState() {
    global RM_state, RM_remoteSince
    if !ML_HasState() {
        ;取り残されたリロードフラグを掃除しておく
        try FileDelete RM_reloadFlag
        return
    }
    if FileExist(RM_reloadFlag) {
        try FileDelete RM_reloadFlag
        RM_state := "remote"
        RM_remoteSince := A_TickCount
        RM_Log("リロードを検出 → 1画面モードをそのまま引き継ぎ")
        return
    }
    ;stateが残ったまま起動した = 前回は正常終了していない
    if ML_RestoreDisplays()
        RM_Log("前回の異常終了を検出 → モニター構成を復元")
}

RM_OnExit(reason, code) {
    RM_RemoveHooks()
    if (RM_state != "remote")
        return 0
    ;Alt+Ctrl+R のリロードでモニターがちらつかないよう、復元せずに次のインスタンスへ引き継ぐ
    if (reason = "Reload") {
        if ML_HasState() {
            try FileAppend "1", RM_reloadFlag
            RM_Log("リロードのため1画面モードを引き継ぐ (復元しない)")
        }
        return 0
    }
    ML_RestoreDisplays()
    RM_Log("終了(" reason ") → モニター構成を復元")
    return 0
}

RM_Log(msg) {
    try FileAppend A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec " " msg "`n", RM_logFile, "UTF-8"
}
