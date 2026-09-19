;モニター構成の取得・1画面化・復元
;1画面化は方式を順に試し、うまくいった方式を state ファイルに記録して復元時に使い分ける
;  detach : ChangeDisplaySettingsEx で残す1台以外をデスクトップから切り離す(狙った1台だけを残せる本命)
;  clone  : SetDisplayConfig / DisplaySwitch で複製にする(切り離しがどうしても効かない環境向けの最終手段)
;どちらも結果を必ず検証し、失敗したらログに理由を残す

;DISPLAY_DEVICEW
global ML_DD_SIZE := 840
global ML_DD_STATEFLAGS := 324
global ML_DEVICE_ACTIVE := 0x1      ;DISPLAY_DEVICE_ATTACHED_TO_DESKTOP
global ML_DEVICE_PRIMARY := 0x4     ;DISPLAY_DEVICE_PRIMARY_DEVICE
;DEVMODEW (dmSize = 220)
global ML_DM_SIZE := 220
global ML_DM_ALL := 0x20 | 0x40000 | 0x80000 | 0x100000 | 0x400000
;ChangeDisplaySettingsEx のフラグ
global ML_CDS_UPDATEREGISTRY := 0x01
global ML_CDS_SET_PRIMARY := 0x10
global ML_CDS_NORESET := 0x10000000
;SetDisplayConfig のフラグ
global ML_SDC_TOPOLOGY_CLONE := 0x02
global ML_SDC_TOPOLOGY_EXTEND := 0x04
global ML_SDC_APPLY := 0x80

global ML_STATE_FILE := A_ScriptDir "\remoteMonitor.state"
global ML_LOG_FILE := A_ScriptDir "\remoteMonitor.log"

;デスクトップに接続中のディスプレイを配列で返す
ML_GetDisplays() {
    displays := []
    dd := Buffer(ML_DD_SIZE, 0)
    i := 0
    loop {
        NumPut("UInt", ML_DD_SIZE, dd, 0)
        if !DllCall("EnumDisplayDevicesW", "Ptr", 0, "UInt", i++, "Ptr", dd, "UInt", 0)
            break
        state := NumGet(dd, ML_DD_STATEFLAGS, "UInt")
        if !(state & ML_DEVICE_ACTIVE)
            continue
        name := StrGet(dd.Ptr + 4, "UTF-16")
        dm := Buffer(ML_DM_SIZE, 0)
        NumPut("UShort", ML_DM_SIZE, dm, 68)
        if !DllCall("EnumDisplaySettingsW", "Str", name, "UInt", -1, "Ptr", dm) ;ENUM_CURRENT_SETTINGS
            continue
        displays.Push({
            name: name,
            primary: !!(state & ML_DEVICE_PRIMARY),
            x: NumGet(dm, 76, "Int"),
            y: NumGet(dm, 80, "Int"),
            bpp: NumGet(dm, 168, "UInt"),
            w: NumGet(dm, 172, "UInt"),
            h: NumGet(dm, 176, "UInt"),
            freq: NumGet(dm, 184, "UInt")
        })
    }
    return displays
}

;1画面にする。成功したら使った方式("detach" / "clone")を、失敗したら "" を返す
ML_SoloDisplay(keepName := "") {
    if (MonitorGetCount() <= 1) {
        ML_Log("既に1画面のため何もしない")
        return ""
    }
    displays := ML_GetDisplays()
    if (displays.Length <= 1) {
        ML_Log("接続中のディスプレイが1台以下のため何もしない")
        return ""
    }
    keepName := ML_ResolveKeepName(displays, keepName)
    ;CDS_UPDATEREGISTRY で保存値が 0 に上書きされるため、変更前に現在値を控える
    ML_SaveState(displays, "")
    ML_Log("1画面化を開始 残す=" keepName " モニター数=" MonitorGetCount())

    if ML_TryDetach(displays, keepName) {
        ML_SaveState(displays, "detach")
        ML_Log("1画面化に成功 (detach)")
        return "detach"
    }
    ;切り離しがどうしても効かない環境向けの最終手段
    ;狙った1台だけを残すことはできないが、マルチモニターのままよりはましという位置づけ
    ML_Log("detach が効かなかったので複製にフォールバックする")
    ML_ApplyDevmodes(displays)
    if ML_TryClone() {
        ML_SaveState(displays, "clone")
        ML_Log("1画面化に成功 (clone) ※狙った1台だけを残せていない")
        return "clone"
    }
    ML_Log("1画面化に失敗。構成を元に戻す")
    ML_ApplyDevmodes(displays)
    ML_ClearState()
    return ""
}

;残すモニターを決める。指定が実在しなければプライマリに落とす
;(存在しない名前をそのまま使うと全台切り離して画面が無くなるため、ここは必ず通す)
ML_ResolveKeepName(displays, keepName) {
    for d in displays
        if (d.name = keepName)
            return d.name
    if (keepName != "")
        ML_Log("指定された " keepName " が見つからないのでプライマリを残す")
    for d in displays
        if d.primary
            return d.name
    return displays[1].name
}

;残す1台以外をデスクトップから切り離す
ML_TryDetach(displays, keepName) {
    ;残すモニターがプライマリでなければ、先に単独で (0,0) のプライマリにしておく
    ;プライマリは切り離せないので、ここは切り離しとは別に確実に反映させる
    for d in displays {
        if (d.name != keepName || d.primary)
            continue
        dm := ML_Devmode(0, 0, d.w, d.h, d.freq, d.bpp)
        ret := DllCall("ChangeDisplaySettingsExW", "Str", keepName, "Ptr", dm, "Ptr", 0
            , "UInt", ML_CDS_UPDATEREGISTRY | ML_CDS_SET_PRIMARY, "Ptr", 0, "Int")
        ML_Log("  " keepName " をプライマリにする → " ML_DispChangeName(ret))
        Sleep 600
    }
    ;1回目: まとめて積んで一括反映
    if ML_DetachOthers(displays, keepName, true)
        return true
    ;2回目: 一括反映を受け付けないドライバ向けに、1台ずつ即時反映する
    ML_Log("  一括反映が効かないので1台ずつ試す")
    return ML_DetachOthers(displays, keepName, false)
}

ML_DetachOthers(displays, keepName, batched) {
    flags := ML_CDS_UPDATEREGISTRY | (batched ? ML_CDS_NORESET : 0)
    detached := 0
    for d in displays {
        if (d.name = keepName)
            continue
        ;位置・解像度・色深度・周波数をすべて 0 にすると切り離しになる
        ret := DllCall("ChangeDisplaySettingsExW", "Str", d.name, "Ptr", ML_Devmode(0, 0, 0, 0, 0, 0)
            , "Ptr", 0, "UInt", flags, "Ptr", 0, "Int")
        ML_Log("  切り離し " d.name " (" (batched ? "一括" : "即時") ") → " ML_DispChangeName(ret))
        if (ret = 0)
            detached++
        if !batched
            Sleep 400
    }
    if !detached {
        ML_Log("  切り離せたモニターがない")
        return false
    }
    if batched
        ML_Log("  反映 → " ML_DispChangeName(ML_Commit()))
    Sleep 700
    ;戻り値が成功でも実際に反映されないことがあるので、必ず数えて確かめる
    count := MonitorGetCount()
    ML_Log("  反映後のモニター数=" count)
    return count = 1
}

;複製(クローン)にする。SetDisplayConfig が効かなければ DisplaySwitch にフォールバック
ML_TryClone() {
    ret := ML_ApplyTopology(ML_SDC_TOPOLOGY_CLONE)
    ML_Log("  SetDisplayConfig(clone) → " (ret = 0 ? "成功" : "エラー " ret))
    Sleep 800
    if (MonitorGetCount() = 1)
        return true
    ML_Log("  DisplaySwitch.exe /clone を試す")
    try Run "DisplaySwitch.exe /clone", , "Hide"
    catch as e {
        ML_Log("  DisplaySwitch の起動に失敗: " e.Message)
        return false
    }
    Sleep 2500
    count := MonitorGetCount()
    ML_Log("  複製後のモニター数=" count)
    return count = 1
}

;state ファイルの内容で元のマルチモニター構成へ戻す
ML_RestoreDisplays() {
    state := ML_LoadState()
    if !state.list.Length
        return false
    ML_Log("復元を開始 方式=" (state.method = "" ? "(未記録)" : state.method) " モニター数=" MonitorGetCount())
    if (state.method = "clone") {
        ret := ML_ApplyTopology(ML_SDC_TOPOLOGY_EXTEND)
        ML_Log("  SetDisplayConfig(extend) → " (ret = 0 ? "成功" : "エラー " ret))
        if (ret != 0) {
            try Run "DisplaySwitch.exe /extend", , "Hide"
            Sleep 2500
        } else {
            Sleep 800
        }
    }
    ML_ApplyDevmodes(state.list)
    Sleep 500
    ML_Log("  復元後のモニター数=" MonitorGetCount())
    ML_ClearState()
    return true
}

;保存しておいた位置・解像度・周波数・色深度をまとめて適用する
ML_ApplyDevmodes(saved) {
    if !saved.Length
        return false
    ;プライマリを先に戻さないと他モニターの座標が受け付けられないことがある
    ordered := []
    for d in saved
        if d.primary
            ordered.Push(d)
    for d in saved
        if !d.primary
            ordered.Push(d)
    for d in ordered {
        flags := ML_CDS_UPDATEREGISTRY | ML_CDS_NORESET
        if d.primary
            flags |= ML_CDS_SET_PRIMARY
        ret := DllCall("ChangeDisplaySettingsExW", "Str", d.name, "Ptr", ML_Devmode(d.x, d.y, d.w, d.h, d.freq, d.bpp)
            , "Ptr", 0, "UInt", flags, "Ptr", 0, "Int")
        ML_Log("  復元 " d.name " " d.w "x" d.h " (" d.x "," d.y ") → " ML_DispChangeName(ret))
    }
    ML_Log("  反映 → " ML_DispChangeName(ML_Commit()))
    return true
}

;すべて 0 を渡すと「切り離し」を表す DEVMODE になる
ML_Devmode(x, y, w, h, freq, bpp) {
    dm := Buffer(ML_DM_SIZE, 0)
    NumPut("UShort", ML_DM_SIZE, dm, 68)
    NumPut("UInt", ML_DM_ALL, dm, 72)
    NumPut("Int", x, dm, 76)
    NumPut("Int", y, dm, 80)
    NumPut("UInt", bpp, dm, 168)
    NumPut("UInt", w, dm, 172)
    NumPut("UInt", h, dm, 176)
    NumPut("UInt", freq, dm, 184)
    return dm
}

;CDS_NORESET で積んだ変更をまとめて反映する
ML_Commit() {
    return DllCall("ChangeDisplaySettingsExW", "Ptr", 0, "Ptr", 0, "Ptr", 0, "UInt", 0, "Ptr", 0, "Int")
}

;Win+P 相当のトポロジ変更。戻り値 0 が成功(ERROR_SUCCESS)
ML_ApplyTopology(topologyFlag) {
    return DllCall("SetDisplayConfig", "UInt", 0, "Ptr", 0, "UInt", 0, "Ptr", 0
        , "UInt", topologyFlag | ML_SDC_APPLY, "Int")
}

ML_DispChangeName(code) {
    switch code {
        case 0: return "成功"
        case 1: return "要再起動(DISP_CHANGE_RESTART)"
        case -1: return "失敗(DISP_CHANGE_FAILED)"
        case -2: return "モード不正(DISP_CHANGE_BADMODE)"
        case -3: return "レジストリ未更新(DISP_CHANGE_NOTUPDATED)"
        case -4: return "フラグ不正(DISP_CHANGE_BADFLAGS)"
        case -5: return "引数不正(DISP_CHANGE_BADPARAM)"
        case -6: return "デュアルビュー不正(DISP_CHANGE_BADDUALVIEW)"
        default: return "不明(" code ")"
    }
}

;1行目に方式、2行目以降に name|x|y|w|h|freq|bpp|primary
ML_SaveState(displays, method) {
    text := "#method|" method "`n"
    for d in displays
        text .= d.name "|" d.x "|" d.y "|" d.w "|" d.h "|" d.freq "|" d.bpp "|" (d.primary ? 1 : 0) "`n"
    try FileDelete ML_STATE_FILE
    try FileAppend text, ML_STATE_FILE, "UTF-8"
}

ML_LoadState() {
    state := { method: "", list: [] }
    if !FileExist(ML_STATE_FILE)
        return state
    try text := FileRead(ML_STATE_FILE, "UTF-8")
    catch
        return state
    for line in StrSplit(text, "`n", "`r") {
        if (line = "")
            continue
        f := StrSplit(line, "|")
        if (f[1] = "#method") {
            state.method := f.Length >= 2 ? f[2] : ""
            continue
        }
        if (f.Length < 8)
            continue
        state.list.Push({ name: f[1], x: Integer(f[2]), y: Integer(f[3]), w: Integer(f[4])
            , h: Integer(f[5]), freq: Integer(f[6]), bpp: Integer(f[7]), primary: (f[8] = "1") })
    }
    return state
}

ML_HasState() {
    return FileExist(ML_STATE_FILE) ? true : false
}

ML_ClearState() {
    try FileDelete ML_STATE_FILE
}

ML_Log(msg) {
    try FileAppend A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec " [monitor] " msg "`n", ML_LOG_FILE, "UTF-8"
}
