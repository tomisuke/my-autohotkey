; ボタンA (修飾キーとして使うキー) & ボタンB (操作キー)
!BackSpace::
{
    ;初めてALT+Backspaceが押された場合の処理
    if !WinExist("MyCustomWindowGui")
    {
        ; ウィンドウを表示する処理
        MyGui := Gui(, "MyCustomWindowGui")
        MyGui.Add("Text",, "ウィンドウが表示されました")
        MyGui.Show("w300 h100")
        return
    }
    MsgBox("Altが押された状態でBackspaceが押された場合の処理",, "T0.5")
}

; ボタンAが離されたときの処理
~LAlt Up::
{
    ; すでにウィンドウが表示されていた場合（操作が行われていた場合）
    if WinExist("MyCustomWindowGui")
    {
        WinClose("MyCustomWindowGui")
        MsgBox("ボタンAが離されました。処理を終了します。",, "T1")
    }
}