;モニター構成の取得・切り離し・復元
;ChangeDisplaySettingsEx でディスプレイをデスクトップから detach / attach する
;外部ツールには依存せず DllCall のみで完結させる

;DISPLAY_DEVICEW
global ML_DD_SIZE := 840
global ML_DD_STATEFLAGS := 324
global ML_DEVICE_ACTIVE := 0x1      ;DISPLAY_DEVICE_ATTACHED_TO_DESKTOP
global ML_DEVICE_PRIMARY := 0x4     ;DISPLAY_DEVICE_PRIMARY_DEVICE
;DEVMODEW (dmSize = 220)
global ML_DM_SIZE := 220
global ML_DM_FIELDS := 0x20 | 0x40000 | 0x80000 | 0x100000 | 0x400000
;ChangeDisplaySettingsEx のフラグ
global ML_CDS_UPDATEREGISTRY := 0x01
global ML_CDS_SET_PRIMARY := 0x10
global ML_CDS_NORESET := 0x10000

global ML_STATE_FILE := A_ScriptDir "\remoteMonitor.state"

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

;残す1台以外をデスクトップから切り離す。keepName が空ならプライマリを残す
ML_SoloDisplay(keepName := "") {
    displays := ML_GetDisplays()
    if (displays.Length <= 1)
        return false
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
    ;CDS_UPDATEREGISTRY で保存値が 0 に上書きされるため、切り離す前に現在値を控える
    ML_SaveState(displays)
    ;残すモニターを (0,0) のプライマリにしておかないと、プライマリを切り離したときに構成が壊れる
    dmKeep := Buffer(ML_DM_SIZE, 0)
    NumPut("UShort", ML_DM_SIZE, dmKeep, 68)
    NumPut("UInt", 0x20, dmKeep, 72) ;DM_POSITION のみ
    DllCall("ChangeDisplaySettingsExW", "Str", keepName, "Ptr", dmKeep, "Ptr", 0
        , "UInt", ML_CDS_UPDATEREGISTRY | ML_CDS_SET_PRIMARY | ML_CDS_NORESET, "Ptr", 0)
    detached := 0
    for d in displays {
        if (d.name = keepName)
            continue
        ;位置と解像度をすべて 0 にすると detach になる
        dm := Buffer(ML_DM_SIZE, 0)
        NumPut("UShort", ML_DM_SIZE, dm, 68)
        NumPut("UInt", 0x20 | 0x80000 | 0x100000, dm, 72)
        DllCall("ChangeDisplaySettingsExW", "Str", d.name, "Ptr", dm, "Ptr", 0
            , "UInt", ML_CDS_UPDATEREGISTRY | ML_CDS_NORESET, "Ptr", 0)
        detached++
    }
    ;まとめて反映
    DllCall("ChangeDisplaySettingsExW", "Ptr", 0, "Ptr", 0, "Ptr", 0, "UInt", 0, "Ptr", 0)
    if !detached
        ML_ClearState()
    return detached > 0
}

;state ファイルの内容でマルチモニター構成へ戻す
ML_RestoreDisplays() {
    saved := ML_LoadState()
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
        NumPut("UInt", ML_DM_FIELDS, dm, 72)
        NumPut("Int", d.x, dm, 76)
        NumPut("Int", d.y, dm, 80)
        NumPut("UInt", d.bpp, dm, 168)
        NumPut("UInt", d.w, dm, 172)
        NumPut("UInt", d.h, dm, 176)
        NumPut("UInt", d.freq, dm, 184)
        flags := ML_CDS_UPDATEREGISTRY | ML_CDS_NORESET
        if d.primary
            flags |= ML_CDS_SET_PRIMARY
        DllCall("ChangeDisplaySettingsExW", "Str", d.name, "Ptr", dm, "Ptr", 0, "UInt", flags, "Ptr", 0)
    }
    DllCall("ChangeDisplaySettingsExW", "Ptr", 0, "Ptr", 0, "Ptr", 0, "UInt", 0, "Ptr", 0)
    ML_ClearState()
    return true
}

;1行1モニターの name|x|y|w|h|freq|bpp|primary 形式
ML_SaveState(displays) {
    text := ""
    for d in displays
        text .= d.name "|" d.x "|" d.y "|" d.w "|" d.h "|" d.freq "|" d.bpp "|" (d.primary ? 1 : 0) "`n"
    try FileDelete ML_STATE_FILE
    try FileAppend text, ML_STATE_FILE, "UTF-8"
}

ML_LoadState() {
    saved := []
    if !FileExist(ML_STATE_FILE)
        return saved
    try text := FileRead(ML_STATE_FILE, "UTF-8")
    catch
        return saved
    for line in StrSplit(text, "`n", "`r") {
        if (line = "")
            continue
        f := StrSplit(line, "|")
        if (f.Length < 8)
            continue
        saved.Push({ name: f[1], x: Integer(f[2]), y: Integer(f[3]), w: Integer(f[4])
            , h: Integer(f[5]), freq: Integer(f[6]), bpp: Integer(f[7]), primary: (f[8] = "1") })
    }
    return saved
}

ML_HasState() {
    return FileExist(ML_STATE_FILE) ? true : false
}

ML_ClearState() {
    try FileDelete ML_STATE_FILE
}
