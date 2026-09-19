;モニター構成の取得・1画面化・復元
;1画面化は2段構えで、うまくいった方式を state ファイルに記録して復元時に使い分ける
;  detach : ChangeDisplaySettingsEx で残す1台以外をデスクトップから切り離す(解像度をそのまま保てる本命)
;  clone  : SetDisplayConfig / DisplaySwitch で複製にする(切り離しが効かない環境向けの代替)
;どちらも結果を必ず検証し、失敗したらログに理由を残す

;DISPLAY_DEVICEW
global ML_DD_SIZE := 840
global ML_DD_STATEFLAGS := 324
global ML_DEVICE_ACTIVE := 0x1      ;DISPLAY_DEVICE_ATTACHED_TO_DESKTOP
global ML_DEVICE_PRIMARY := 0x4     ;DISPLAY_DEVICE_PRIMARY_DEVICE
;DEVMODEW (dmSize = 220)
global ML_DM_SIZE := 220
global ML_DM_POSITION := 0x20
global ML_DM_BITSPERPEL := 0x40000
global ML_DM_PELSWIDTH := 0x80000
global ML_DM_PELSHEIGHT := 0x100000
global ML_DM_DISPLAYFREQUENCY := 0x400000
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
    if (keepName = "") {
        for d in displays {
            if d.primary {
                keepName := d.name
                break
            }
        }
    }
    if (keepName = "")
        keepName := displays[1].name
    ;CDS_UPDATEREGISTRY で保存値が 0 に上書きされるため、変更前に現在値を控える
    ML_SaveState(displays, "")
    ML_Log("1画面化を開始 残す=" keepName " モニター数=" MonitorGetCount())

    if ML_TryDetach(displays, keepName) {
        ML_SaveState(displays, "detach")
        ML_Log("1画面化に成功 (detach)")
        return "detach"
    }
    ;切り離しが効かない環境向けの代替。途中まで変わっている可能性があるので一度戻す
    ML_Log("detach が効かなかったので複製にフォールバックする")
    ML_ApplyDevmodes(displays)
    if ML_TryClone() {
        ML_SaveState(displays, "clone")
        ML_Log("1画面化に成功 (clone)")
        return "clone"
    }
    ML_Log("1画面化に失敗。構成を元に戻す")
    ML_ApplyDevmodes(displays)
    ML_ClearState()
    return ""
}

;残す1台以外をデスクトップから切り離す
ML_TryDetach(displays, keepName) {
    ;残すモニターがプライマリでなければ、先に (0,0) のプライマリへ動かしておく
    ;(プライマリを切り離すと構成が壊れるため)
    for d in displays {
        if (d.name != keepName || d.primary)
            continue
        dm := Buffer(ML_DM_SIZE, 0)
        NumPut("UShort", ML_DM_SIZE, dm, 68)
        NumPut("UInt", ML_DM_POSITION, dm, 72)
        ret := DllCall("ChangeDisplaySettingsExW", "Str", keepName, "Ptr", dm, "Ptr", 0
            , "UInt", ML_CDS_UPDATEREGISTRY | ML_CDS_SET_PRIMARY | ML_CDS_NORESET, "Ptr", 0, "Int")
        ML_Log("  プライマリ化 " keepName " → " ML_DispChangeName(ret))
    }
    detached := 0
    for d in displays {
        if (d.name = keepName)
            continue
        ;位置・解像度・色深度・周波数をすべて 0 にすると切り離しになる
        dm := Buffer(ML_DM_SIZE, 0)
        NumPut("UShort", ML_DM_SIZE, dm, 68)
        NumPut("UInt", ML_DM_ALL, dm, 72)
        ret := DllCall("ChangeDisplaySettingsExW", "Str", d.name, "Ptr", dm, "Ptr", 0
            , "UInt", ML_CDS_UPDATEREGISTRY | ML_CDS_NORESET, "Ptr", 0, "Int")
        ML_Log("  切り離し " d.name " → " ML_DispChangeName(ret))
        if (ret = 0)
            detached++
    }
    if !detached {
        ML_Log("  切り離せたモニターがない")
        return false
    }
    ret := ML_Commit()
    ML_Log("  反映 → " ML_DispChangeName(ret))
    Sleep 500
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
        dm := Buffer(ML_DM_SIZE, 0)
        NumPut("UShort", ML_DM_SIZE, dm, 68)
        NumPut("UInt", ML_DM_ALL, dm, 72)
        NumPut("Int", d.x, dm, 76)
        NumPut("Int", d.y, dm, 80)
        NumPut("UInt", d.bpp, dm, 168)
        NumPut("UInt", d.w, dm, 172)
        NumPut("UInt", d.h, dm, 176)
        NumPut("UInt", d.freq, dm, 184)
        flags := ML_CDS_UPDATEREGISTRY | ML_CDS_NORESET
        if d.primary
            flags |= ML_CDS_SET_PRIMARY
        ret := DllCall("ChangeDisplaySettingsExW", "Str", d.name, "Ptr", dm, "Ptr", 0, "UInt", flags, "Ptr", 0, "Int")
        ML_Log("  復元 " d.name " " d.w "x" d.h " (" d.x "," d.y ") → " ML_DispChangeName(ret))
    }
    ML_Log("  反映 → " ML_DispChangeName(ML_Commit()))
    return true
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
