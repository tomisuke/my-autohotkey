:*:meadoi@:: {
    stringTemplate("searakko3@gmail.com")
}
:*:meadou@:: {
    stringTemplate("b1024016@fun.ac.jp")
}
:*:phone@:: {
    stringTemplate("09047002044")
}
:*:sn@:: {
    stringTemplate("1024016")
}
:*:bsn@:: {
    stringTemplate("b1024016")
}
:*:fn@:: {
    stringTemplate("泰地")
}
:*:efn@:: {
    stringTemplate("Taichi")
}
:*:ln@:: {
    stringTemplate("石川")
}
:*:eln@:: {
    stringTemplate("Ishikawa")
}
:*:name@:: {
    stringTemplate("石川 泰地")
}
:*:ename@:: {
    stringTemplate("Taichi Ishikawa")
}


stringTemplate(x) {
    oldClip := ClipboardAll
    A_Clipboard := x
    Sleep 50
    Send "^{v}"
    Sleep 30
    Clipboard := oldClip
}
