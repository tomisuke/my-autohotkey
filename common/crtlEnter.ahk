#HotIf WinActive("ahk_exe discord.exe")
F2:: {
    ;WinGetPos(&X, &Y, &Width, &Height)
    ;MsgBox("Discordのウィンドウ位置とサイズ:`nX: " . X . "`nY: " . Y . "`nWidth: " . Width . "`nHeight: " . Height)
    ;CreateMyGui()
}
#HotIf
/*
CreateMyGui()
{
    ; 新しいGUIを作成
    MyGui := Gui(,"discordText")
    MyGui.Opt("-Caption")
    MyGui.OnEvent("Close", GuiClose) ; GUIが閉じられた時の処理
    MyGui.SetFont("s10") ; フォントサイズを設定

    ; コントロールを追加
    MyGui.Add("Edit", "vs_Word w300", "AutoHotkey v2のGUIです。")
    MyGuiButton := MyGui.Add("Button",, "&Pause")v-
    MyGuiButton.OnEvent("Click", ButtonAction.Bind(MyGui)) ; ボタンがクリックされた時の処理をバインド

    ; GUIを表示
    MyGui.Show("w500 h50
    ")
}

; ボタンがクリックされた時のアクション
ButtonAction(this, *)
{
    oSaved := this.Submit()
    MsgBox(oSaved.s_Word)
}

; GUIが閉じられた時の処理
GuiClose(this)
{
    this.Destroy() ; GUIオブジェクトを破棄
}