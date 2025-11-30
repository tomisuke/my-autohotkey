:*:meadoi@:: {
    stringTemplate("searakko3@gmail.com")
}
:*:meadou@:: {
    stringTemplate("b1024016@fun.ac.jp")
}
:*:phone@:: {
    stringTemplate("09047002044")
}

stringTemplate(x) {
    oldClip := ClipboardAll
    A_Clipboard := x
    Sleep 50
    Send "^{v}"
    Sleep 30
    Clipboard := oldClip
}
