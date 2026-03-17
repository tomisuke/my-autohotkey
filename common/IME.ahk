;IME制御
; https://github.com/k-ayaki/IMEv2.ahk/blob/master/IMEv2.ahk   <- コピペ元
; IMEの状態の取得
;   WinTitle="A"    対象Window
;   戻り値          1:ON / 0:OFF
;-----------------------------------------------------------
IME_SET(SetSts, WinTitle := "A") {
    hwnd := WinGetID(WinTitle)
    if (WinActive(WinTitle)) {
        ptrSize := A_PtrSize ? A_PtrSize : 4
        cbSize := 4 + 4 + (ptrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, stGTI, 0)
        if (DllCall("GetGUIThreadInfo", "Uint", 0, "Ptr", stGTI)) {
            hwnd := NumGet(stGTI, 8 + ptrSize, "UInt")
        }
    }

    return DllCall("SendMessage"
        , "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd)
        , "UInt", 0x0283  ; Message : WM_IME_CONTROL
        , "Ptr", 0x006    ; wParam  : IMC_SETOPENSTATUS
        , "Ptr", SetSts)  ; lParam  : 0 or 1
}
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

        if (candHwnd)
        {
            ;; atok だと仮定して再度ウィンドウを検出する
            try {
                WinGetPos(&X, &Y, &Width, &Height, "ahk_id " . candHwnd)
            } catch {
                ; ウィンドウが消えた場合は ret=2 のまま抜ける
                SetTitleMatchMode tmm
                return ret
            }
        } else if (candGHwnd)
        {
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

isIMEConverting() {
    if (IME_GetConverting() = 0 AND !IMEFlag) {
        return false
    } else {
        return true
    }
}

imeFlagToTrue() {
    global IMEFlag
    if (IME_GetConverting() != 0) {
        IMEFlag := true
    }
}