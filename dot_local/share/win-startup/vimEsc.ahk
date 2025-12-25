#Requires AutoHotkey v2.0

IME_SET(SetSts, WinTitle := "A") {
    hwnd := WinExist(WinTitle)
    if (WinActive(WinTitle)) {
        ptrSize := A_PtrSize
        cbSize := 4 + 4 + (ptrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, stGTI.Ptr, 0)
        hwnd := DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", stGTI.Ptr) 
                ? NumGet(stGTI.Ptr, 8 + ptrSize, "UInt") : hwnd
    }
    return DllCall("SendMessage"
        , "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "UInt", hwnd)
        , "UInt", 0x0283, "Int", 0x0006, "Int", SetSts)
}

^[:: {
    IME_SET(0)
    Sleep(50)
    Send("{Escape}")
}