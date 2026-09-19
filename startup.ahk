#Requires AutoHotkey v2.0
timeOut := 20
;tomisukeLaptop
if (A_ComputerName = "tomisukeLaptop") {
    global activeLaptop := true
    global activeDesktop := false
    Run '*RunAs ".\TomisukeLaptop.ahk"'
} else {
    global activeLaptop := false
    global activeDesktop := true
    Run '*RunAs ".\TomisukeDesktop.ahk"'
}
;MouseByKeyboard
try {
    Run "C:\Users\Tomisuke\Local\Activity\mouseByKeyboard\KeyNavigator.exe"
}
;flowLauncher
try {
    Run "C:\Users\Tomisuke\AppData\Local\FlowLauncher\Flow.Launcher.exe"
}
;soundSwitch
try {
    Run "C:\Program Files\SoundSwitch\SoundSwitch.exe"
}
;clibor
try {
    Run "C:\Program Files\clibor\Clibor.exe"
}
;earTrumpet
try {
    Run "explorer.exe shell:AppsFolder\40459File-New-Project.EarTrumpet_1sdd7yawvg6ne!EarTrumpet"
}
;twinkleTray
try {
    Run "C:\Windows.old\Users\Tomisuke\AppData\Local\Programs\twinkle-tray\Twinkle Tray.exe"
}
;TickTick
try {
    Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TickTick\TickTick.lnk"
    WinWait("ahk_exe TickTick.exe", , timeOut)
    WinMinimize("ahk_exe TickTIck.exe")
}
;Thunderbird
try {
    Run "C:\Program Files (x86)\eM Client\MailClient.exe"
    WinWait("ahk_exe MailClient.exe", , timeOut)
    WinMinimize("ahk_exe MailClient.exe")
}
;Discord
try {
    Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
    WinWait("ahk_exe Discord.exe", , timeOut)
    WinMinimize("ahk_exe Discord.exe")
}
try {
    loop 10 {
        if WinExist("ahk_exe Discord.exe") {
            WinMinimize("ahk_exe Discord.exe")
            break
        }
        Sleep 500
    }
}
;Slack
try {
    Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Slack Technologies Inc\Slack.lnk"
    WinWait("ahk_exe Slack.exe", , timeOut)
    WinHide("ahk_exe Slack.exe")
}
;スマートフォン連携
try {
    Run "explorer.exe shell:AppsFolder\Microsoft.YourPhone_8wekyb3d8bbwe!App"
    WinWait("ahk_exe PhoneExperienceHost.exe", , timeOut)
    WinHide("ahk_exe PhoneExperienceHost.exe")
}
;GoogleDrive
try {
    Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Drive.lnk"
}
;powerToys
/*
try {
    Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PowerToys (Preview)\PowerToys (Preview).lnk"
}
*/
;everything
try {
    Run "C:\Program Files\Everything\Everything.exe"
    WinWait("ahk_exe Everything.exe", , timeOut)
    WinHide("ahk_exe Everything.exe")
}
;onedrive
try {
    Run A_ProgramFiles . "\Microsoft OneDrive\OneDrive.exe"
}
;NotionCalendar
try {
    Run "C:\Users\Tomisuke\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Notion Calendar.lnk"
    WinWait("ahk_exe Notion Calendar.exe", , timeOut)
    WinHide("ahk_exe Notion Calendar.exe")
}
try {
    Run "C:\Program Files\Google\NearbyShare\nearby_share.exe"
    WinWait("ahk_exe nearby_share.exe", , timeOut)
    WinHide("ahk_exe nearby_share.exe")
}
;manicTime
try {
    Run "C:\Program Files\ManicTime\ManicTime.exe"
}
try {
    Run "C:\Program Files\WhatPulse\WhatPulse.exe"
}
;シン・テレワークシステム(ホストはサーバー、ラップトップはクライアント)
try {
    StartThinTelework()
}
ExitApp

StartThinTelework() {
    exe := GetThinTeleworkExe(activeDesktop ? "server" : "client")
    if !exe
        return
    SplitPath exe, &procName
    if ProcessExist(procName)
        return
    Run '"' exe '"'
}

;シン・テレワークシステムの実行ファイルを探す
;kind: "server"(ホスト側) / "client"(クライアント側)
;インストーラはユーザーモード(%APPDATA%配下)とマシン共通(Program Files配下)の両方があるので順に探す
GetThinTeleworkExe(kind) {
    label := (kind = "server") ? "Server" : "Client"
    dirs := []
    ;アンインストール情報から引く。InstallLocation は空なので DisplayIcon のフォルダを使う
    ;(例: "C:\Program Files\Thin Telework System Client\ThinSetup.exe",13)
    for root in ["HKCU", "HKLM"] {
        icon := RegRead(root "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\softether_thin" kind, "DisplayIcon", "")
        if !icon
            continue
        SplitPath Trim(StrSplit(icon, ",")[1], ' "'), , &iconDir
        if iconDir
            dirs.Push(iconDir)
    }
    ;標準的なインストール先を順に試す
    for base in [EnvGet("APPDATA"), EnvGet("ProgramW6432"), A_ProgramFiles, EnvGet("ProgramFiles(x86)")] {
        if base
            dirs.Push(base "\Thin Telework System " label)
    }
    ;実行ファイル名はモードやバージョンで変わりうるので候補を順に探す
    ;サーバーのユーザーモードは ThinConfig.exe が常駐本体
    names := (kind = "server")
        ? ["ThinConfig.exe", "ThinServer.exe", "ThinTeleworkServer.exe"]
        : ["ThinClient.exe", "ThinTeleworkClient.exe"]
    return FindFirstExe(dirs, names)
}

;dirs を順に見て、names のいずれかが最初に見つかったフルパスを返す
FindFirstExe(dirs, names) {
    for dir in dirs {
        for name in names {
            if FileExist(exe := RTrim(dir, "\") "\" name)
                return exe
        }
    }
    return ""
}
