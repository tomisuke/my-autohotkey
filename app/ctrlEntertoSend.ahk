#Requires AutoHotkey v2.0
GroupAdd "CtrlEnterToSend", "ahk_exe Discord.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe ChatGPT.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe Perplexity.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe claude.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe LINE.exe"
GroupAdd "CtrlEnterToSend", "ahk_exe ticktick.exe"
global IMEFlag := false
#HotIf WinActive("ahk_group CtrlEnterToSend") AND isTextBoxFocused()
Enter::
NumpadEnter::
{
    global IMEFlag
    imeMode := IME_GET()
    if (imeMode AND isIMEConverting()) {
        SendInput "{Enter}"
        IMEFlag := false
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
    ih.OnKeyDown := OnIMEFlagInput
    ih.Start()
}

OnIMEFlagInput(ih, vk, sc) {
    global IMEFlag
    if (IMEFlag || !WinActive("ahk_group CtrlEnterToSend")) {
        return
    }
    if (!IsTextBoxFocused() || !IME_GET()) {
        return
    }
    if (IME_GetConverting() != 0) {
        IMEFlag := true
        return
    }
    if (isTextGeneratingKey(vk)) {
        IMEFlag := true
    }
}

isIMEConverting() {
    return (IME_GetConverting() != 0 OR IMEFlag)
}
isTextBoxFocused() {
    try {
        el := UIA.GetFocusedElement()
        ctrlType := el.CurrentControlType
        return (ctrlType = 50004) || (ctrlType = 50030)
    } catch {
        return false
    }
}
getFocusedElementText() {
    try {
        el := UIA.GetFocusedElement()
    } catch {
        return ""
    }

    text := ""
    try {
        vp := el.GetPattern("ValuePattern")
        text := vp.CurrentValue
    } catch {
        try {
            tp := el.GetPattern("TextPattern")
            text := tp.DocumentRange.GetText(-1)
        } catch {
            return ""
        }
    }

    return StrReplace(text, Chr(0xFEFF), "")
}
isTextGeneratingKey(vk) {
    static NonTextKeys := Map(
        ;マウスボタン
        0x01, true, 0x02, true, 0x04, true, 0x05, true, 0x06, true,
        ;制御・特殊キー
        0x08, true, ; BackSpace(別処理でカバー済みだが除外)
        0x09, true, ; Tab
        0x0C, true, ; Clear
        0x0D, true, ; Enter(別処理でカバー済みだが除外)
        0x13, true, ; Pause
        0x14, true, ; CapsLock
        0x1B, true, ; Escape
        ;IME制御
        0x15, true, ; Kana/IME_ON
        0x17, true, ; Junja
        0x18, true, ; Final
        0x19, true, ; Kanji/Hanja
        0x1A, true, ; IME_OFF
        0x1C, true, ; Convert-変換
        0x1D, true, ; NonConvert-無変換
        0x1E, true, ; Accept
        0x1F, true, ; ModeChange
        ;ナビゲーション
        0x21, true, 0x22, true, 0x23, true, 0x24, true, ; PageUp/Down/End/Home
        0x25, true, 0x26, true, 0x27, true, 0x28, true, ; 矢印
        0x29, true, ; Select
        0x2A, true, ; Print
        0x2B, true, ; Execute
        0x2C, true, ; PrintScreen
        0x2D, true, 0x2E, true, ; Insert, Delete
        0x2F, true, ; Help
        ;Windows、Apps
        0x5B, true, 0x5C, true, 0x5D, true, ; LWin, RWin, Apps
        0x5F, true, ; Sleep
        ;Fn
        0x70, true, 0x71, true, 0x72, true, 0x73, true, 0x74, true, 0x75, true,
        0x76, true, 0x77, true, 0x78, true, 0x79, true, 0x7A, true, 0x7B, true,
        0x7C, true, 0x7D, true, 0x7E, true, 0x7F, true, 0x80, true, 0x81, true,
        0x82, true, 0x83, true, 0x84, true, 0x85, true, 0x86, true, 0x87, true,
        ;ロック系
        0x90, true, 0x91, true, ; NumLock, ScrollLock
        ;修飾キー
        0x10, true, 0xA0, true, 0xA1, true, ; Shift系
        0x11, true, 0xA2, true, 0xA3, true, ; Ctrl系
        0x12, true, 0xA4, true, 0xA5, true, ; Alt系
        ;ブラウザ系
        0xA6, true, 0xA7, true, 0xA8, true, 0xA9, true,
        0xAA, true, 0xAB, true, 0xAC, true,
        ;メディア・音量系
        0xAD, true, 0xAE, true, 0xAF, true,
        0xB0, true, 0xB1, true, 0xB2, true, 0xB3, true,
        0xB4, true, 0xB5, true, 0xB6, true, 0xB7, true,
        ;IME関連(拡張)
        0xE5, true, ; VK_PROCESSKEY (IME処理中のキー、環境依存)
        ;その他システム系
        0xF6, true, 0xF7, true, 0xF8, true, 0xF9, true,
        0xFA, true, 0xFB, true, 0xFC, true, 0xFD, true, 0xFE, true
    )

    return !NonTextKeys.Has(vk)
}

;==========================================================================
;  IME 文字入力の状態を返す
;  (パクリ元 : http://sites.google.com/site/agkh6mze/scripts#TOC-IME- )
;    標準対応IME : ATOK系 / MS-IME2002 2007 / WXG / SKKIME
;    その他のIMEは 入力窓/変換窓を追加指定することで対応可能
;
;       WinTitle="A"   対象Window
;       ConvCls=""     入力窓のクラス名 (正規表現表記)
;       CandCls=""     候補窓のクラス名 (正規表現表記)
;       戻り値      1 : 文字入力中 or 変換中
;                   2 : 変換候補窓が出ている
;                   0 : その他の状態
;
;   ※ MS-Office系で 入力窓のクラス名 を正しく取得するにはIMEのシームレス表示を
;      OFFにする必要がある
;      オプション-編集と日本語入力-編集中の文字列を文書に挿入モードで入力する
;      のチェックを外す
;==========================================================================
IME_GetConverting(WinTitle := "A", ConvCls := "", CandCls := "") {
    ;IME毎の 入力窓/候補窓Class一覧 ("|" 区切りで適当に足してけばOK)
    ConvCls .= (ConvCls ? "|" : "")                 ;--- 入力窓 ---
    . "ATOK\d+CompStr"                     ; ATOK系
    . "|imejpstcnv\d+"                     ; MS-IME系
    . "|WXGIMEConv"                        ; WXG
    . "|SKKIME\d+\.*\d+UCompStr"           ; SKKIME Unicode
    . "|MSCTFIME Composition"              ; SKKIME for Windows Vista, Google日本語入力

    CandCls .= (CandCls ? "|" : "")                 ;--- 候補窓 ---
    . "ATOK\d+Cand"                        ; ATOK系
    . "|imejpstCandList\d+|imejpstcand\d+" ; MS-IME 2002(8.1)XP付属
    . "|mscandui\d+\.candidate"            ; MS Office IME-200
    . "|WXGIMECand"                        ; WXG
    . "|SKKIME\d+\.*\d+UCand"              ; SKKIME Unicode

    CandGCls := "GoogleJapaneseInputCandidateWindow" ;Google日本語入力

    hwnd := WinExist(WinTitle)
    if (WinActive(WinTitle)) {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        cbSize := 4 + 4 + (PtrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("Uint", cbSize, stGTI.Ptr, 0)   ;   DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", "Uint", 0, "Ptr", stGTI.Ptr)
            ? NumGet(stGTI.Ptr, 8 + PtrSize, "UInt") : hwnd
    }
    ret := 0
    pid := 0
    if (hwnd) {
        try {
            pid := WinGetPID("ahk_id " . hwnd)	;WinGet, pid, PID,% "ahk_id " hwnd
        }
    }
    tmm := A_TitleMatchMode
    SetTitleMatchMode "RegEx"

    ; ウィンドウの存在確認と hwnd 保持（競合回避）
    candHwnd := WinExist("ahk_class " . CandCls . " ahk_pid " pid)
    candGHwnd := WinExist("ahk_class " . CandGCls)
    convHwnd := WinExist("ahk_class " . ConvCls . " ahk_pid " pid)

    ret := candHwnd ? 2
        : candGHwnd ? 2
            : convHwnd ? 1
                : 0
    ;; 推測変換(atok)や予想入力(msime)中は候補窓が出ていないものとして取り扱う
    if (2 == ret) {
        X := 0
        Y := 0
        Width := 0
        Height := 0

        if (candHwnd) {
            ;; atok だと仮定して再度ウィンドウを検出する
            try {
                WinGetPos(&X, &Y, &Width, &Height, "ahk_id " . candHwnd)
            } catch {
                ; ウィンドウが消えた場合は ret=2 のまま抜ける
                SetTitleMatchMode tmm
                return ret
            }
        } else if (candGHwnd) {
            ;; Google IME だと仮定して再度ウィンドウを検出する
            try {
                WinGetPos(&X, &Y, &Width, &Height, "ahk_id " . candGHwnd)
            } catch {
                SetTitleMatchMode tmm
                return ret
            }
        }
        X1 := X
        Y1 := Y
        X2 := X + Width
        Y2 := Y + Height

        CoordMode "Pixel", "Screen"
        ;; ATOK については 推測変換中か否かを確実に検出できる
        ;; MS-IME は変換候補窓の表示中のみを検出できる
        ;; Google IME も変換候補窓の表示中のみを検出できる
        ;; そこで変換候補窓が表示されていないと仮定して処理を進めてみる
        ret := 1
        not_auto_cand_list := [0xFFE1C4  ; ATOK
            , 0xF6E8CB  ; MS-IME
            , 0xFFEAD1] ; Google IME
        for index, ColorID in not_auto_cand_list {
            elevel := PixelSearch(&OutputVarX, &OutputVarY, X1, Y1, X2, Y2, ColorID)
            ;;  the color was not found
            if (0 == elevel) {
                ret := 2
                break
            }
        }
        CoordMode "Pixel", "Window"
    }
    SetTitleMatchMode tmm
    return ret
}
;==========================================================================
;  IME 状態取得関数
;  元コード: eamat氏 IME.ahk (https://w.atwiki.jp/eamat/pages/17.html)
;    ※ 原文中に「改変・再配布ともにご自由にどうぞ」との記載を確認済み
;       (確認元: https://w.atwiki.jp/eamat/pages/17.html)
;  AutoHotkey v2構文に書き換えて使用
;==========================================================================
IME_GET(WinTitle := "A") {
    hwnd := WinExist(WinTitle)
    if (WinActive(WinTitle)) {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        cbSize := 4 + 4 + (PtrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("DWORD", cbSize, stGTI.Ptr, 0)   ;   DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", "Uint", 0, "Uint", stGTI.Ptr)
            ? NumGet(stGTI.Ptr, 8 + PtrSize, "Uint") : hwnd
    }
    return DllCall("SendMessage"
        , "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hwnd)
        , "UInt", 0x0283  ;Message : WM_IME_CONTROL
        , "Int", 0x0005  ;wParam  : IMC_GETOPENSTATUS
        , "Int", 0)      ;lParam  : 0
}
