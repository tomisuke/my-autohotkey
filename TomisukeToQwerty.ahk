#Requires AutoHotkey v2.0
Enter & q:: {
    Run ".\TomisukeLaptop.ahk"
    Msgbox "デフォルトモード`nDefaultMode", "LayoutChanger", "T2"
    ExitApp
}

/::1
^::-
\::^
:::\
@::BS

1::q
,::w
.::e
-::r
`;::t
l::y
r::u
d::i
y::o
q::@

BackSpace::CapsLock
o::s
e::d
i::f
u::g
g::h
n::j
t::k
s::l
k::;
f:::

x::z
c::x
v::c
w::v
Delete::b
j::n
h::m
m::,
b::.
z::/

RShift:: Send "{Space}"

F14::Enter
F15::Esc
;Space:: Send "{vk1A}"    ;無変換toIMEOff
;Enter:: Send "{vk16}"    ;変換toIMEOn

!^r:: Reload
!^e:: Edit