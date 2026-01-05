global yamaokaya := Gui()
yamaokaya.SetFont("s16")
yamaokaya.Add("Text", , "北海道の山岡家をランダムで表示します")
global checkBoxDounan := yamaokaya.Add("CheckBox", , "道南")
yamaokaya.Add("Text", , "上磯,苫小牧糸井,室蘭,伊達,八雲,苫小牧舟見,函館鍛冶,倶知安,新ひだか,函館万代,苫小牧")
checkBoxDounan.Value := 1
global checkBoxDouou := yamaokaya.Add("CheckBox", , "道央")
yamaokaya.Add("Text", , "恵庭,北広島,岩見沢,樽川,滝川,千歳,朝里,富良野,余市,新文教台,江別,羊ヶ丘通")
checkBoxDouou.Value := 1
global checkBoxDouhoku := yamaokaya.Add("CheckBox", , "道北")
yamaokaya.Add("Text", , "旭川永山,稚内,東光,遠軽,士別,紋別,留萌,旭川神居")
checkBoxDouhoku.Value := 1
global checkBoxDoutou := yamaokaya.Add("CheckBox", , "道東")
checkBoxDoutou.Value := 1
yamaokaya.Add("Text", , "釧路,北見,帯広,美幌,帯広南,釧路町,網走,音更,中標津")
yamaokayaButton := yamaokaya.Add("Button", , "ルーレットを回す")
yamaokayaButton.OnEvent("Click", showYamaokaya)
global resultText := yamaokaya.Add("Text", "w500", "")
yamaokaya.Show()

showYamaokaya(*) {
    global resultText
    Loop (100) {
        resultText.Value := "今回はラーメン山岡家 " . randomYamaokaya() . "店に決定！"
        Sleep(50)
    }
    resultText.Value := "今回はラーメン山岡家 "
    Sleep(1000)
    determin := randomYamaokaya()
    resultText.Value := "今回はラーメン山岡家 " . determin . "店に決定！"
    Sleep(1000)
    run "https://www.google.co.jp/maps/dir/?api=1&origin=公立はこだて未来大学&destination=ラーメン山岡家+" . determin . "店&travelmode=driving"
}

randomYamaokaya() {
    yamaokayaList := []
    if (checkBoxDoutou.Value) {
        yamaokayaDoutou := ["釧路", "北見", "帯広", "美幌", "帯広南", "釧路町", "網走", "音更", "中標津"]
        yamaokayaList.Push(yamaokayaDoutou*)
    }
    if (checkBoxDouhoku.Value) {
        yamaokayaDouhoku := ["旭川永山", "稚内", "東光", "遠軽", "士別", "紋別", "留萌", "旭川神居"]
        yamaokayaList.Push(yamaokayaDouhoku*)
    }
    if (checkBoxDouou.Value) {
        yamaokayaDouou := ["恵庭", "北広島", "岩見沢", "樽川", "滝川", "千歳", "朝里", "富良野", "余市", "新文教台", "江別", "羊ヶ丘通"]
        yamaokayaList.Push(yamaokayaDouou*)
    }
    if (checkBoxDounan.Value) {
        yamaokayaDounan := ["上磯", "苫小牧糸井", "室蘭", "伊達", "八雲", "苫小牧舟見", "函館鍛冶", "倶知安", "新ひだか", "函館万代", "苫小牧"]
        yamaokayaList.Push(yamaokayaDounan*)
    }
    return yamaokayaList[Random(1, yamaokayaList.Length)]
}