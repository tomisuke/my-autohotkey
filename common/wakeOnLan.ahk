;外出先からデスクトップをWake on LANで起動する
;
;シン・テレワークシステム純正のWoL機能はトリガーPCにWindows版サーバーを要求するため使わない。
;マジックパケットは送信元OSを問わないので、自宅LAN内の常時起動Linux機にTailscale経由で
;SSHし、そこから送らせる。純正機能が担っていた「外からLAN内への中継」をTailscaleで代替する形。
;
;  ラップトップ --(Tailscale)--> Linux機 --(マジックパケット/同一L2)--> デスクトップ
;
;接続情報はpublicリポジトリに置けないので wakeOnLan.config.ahk に分離する。
;既定値をここで宣言し、config側が代入で上書きする(インクルード順に注意)

global WOL_HOST := "", WOL_USER := "", WOL_MAC := "", WOL_TARGET := ""
global WOL_KEY := EnvGet("USERPROFILE") "\.ssh\id_ed25519_wol"
global WOL_logFile := A_ScriptDir "\wakeOnLan.log"
global WOL_waitedMs := 0

;===== 送信 =====
WOL_Wake() {
    if (WOL_HOST = "" || WOL_MAC = "") {
        TrayTip("common/wakeOnLan.config.ahk が未設定です", "Wake on LAN", 2)
        return
    }
    TrayTip("起動信号を送信中...", "Wake on LAN", 1)
    WOL_Log("send to " WOL_HOST " target=" WOL_MAC)
    ;ConnectTimeout : Linux機が落ちている場合のフリーズを5秒で打ち切る
    ;BatchMode      : 鍵認証が通らないときパスワード入力待ちで固まらせない
    cmd := Format('ssh -o ConnectTimeout=5 -o BatchMode=yes -i "{1}" {2}@{3} "wakeonlan {4}"'
        , WOL_KEY, WOL_USER, WOL_HOST, WOL_MAC)
    code := RunWait(A_ComSpec ' /c ' cmd ' >> "' WOL_logFile '" 2>&1', , "Hide")
    if (code != 0) {
        WOL_Log("  送信失敗 rc=" code)
        TrayTip("送信に失敗しました (rc=" code ")`nwakeOnLan.log を確認してください", "Wake on LAN", 2)
        return
    }
    TrayTip("起動信号を送信しました`n起動を待っています...", "Wake on LAN", 1)
    WOL_waitedMs := 0
    SetTimer WOL_PollBoot, 5000
}

;===== 起動待ち =====
;起動したかどうかはデスクトップがTailscale上で応答するかで判定する
WOL_PollBoot() {
    global WOL_waitedMs
    WOL_waitedMs += 5000
    if (WOL_TARGET != "" && RunWait(A_ComSpec ' /c ping -n 1 -w 1000 ' WOL_TARGET, , "Hide") = 0) {
        SetTimer WOL_PollBoot, 0
        WOL_Log("  起動を確認 (" (WOL_waitedMs // 1000) "秒)")
        TrayTip("デスクトップが起動しました (" (WOL_waitedMs // 1000) "秒)", "Wake on LAN", 1)
        return
    }
    if (WOL_waitedMs >= 120000) {
        SetTimer WOL_PollBoot, 0
        WOL_Log("  2分待っても応答なし")
        TrayTip("2分待っても応答がありません`nBIOSのWoL設定を確認してください", "Wake on LAN", 2)
    }
}

WOL_Log(msg) {
    try FileAppend A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec " " msg "`n", WOL_logFile, "UTF-8"
}
