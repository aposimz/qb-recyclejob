local Translations = {
    success = {
        you_have_been_clocked_in = "出勤しました",
    },
    text = {
        enter_warehouse= "倉庫に入る",
        point_enter_warehouse = "[E] 倉庫に入る",
        exit_warehouse= "倉庫から出る",
        point_exit_warehouse = "[E] 倉庫から出る",
        clock_out = "[E] 退勤する",
        clock_in = "[E] 出勤する",
        hand_in_package = "パッケージを渡す",
        point_hand_in_package = "[E] パッケージを渡す",
        get_package = "パッケージを入手",
        point_get_package = "[E] パッケージを入手",
        picking_up_the_package = "パッケージを取る",
        unpacking_the_package = "パッケージを開封する",
    },
    error = {
        you_have_clocked_out = "退勤しました"
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})