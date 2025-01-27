;IME制御
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