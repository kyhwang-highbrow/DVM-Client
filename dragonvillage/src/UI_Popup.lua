local POPUP_CONTENT_WIDTH = 410
local POPUP_CONTENT_HEIGHT = 360

POPUP_TYPE = {
    OK = 1,            -- 확인
    YES_NO = 2,        -- 예, 아니오
}

-------------------------------------
-- function MakeSimplePopup
-------------------------------------
function MakeSimplePopup(type, msg, ok_btn_cb, cancel_btn_cb)

    if startsWith(msg, '{') then
        local l_content = RichLabel:splitByToken(msg)

        msg = nil
        for _,data in ipairs(l_content) do
            local l_lines = data['lines']
            for line_i,line in ipairs(l_lines) do
                if (not msg) then
                    msg = line
                elseif (line_i == 1) then
                    msg = msg .. line
                else
                    msg = msg .. '\n' .. line
                end
            end
        end
    end    

    local popup = UI_SimplePopup(type, msg, ok_btn_cb, cancel_btn_cb)
    --local popup = UI_Popup(type, msg, ok_btn_cb, cancel_btn_cb)
    --popup.m_cbOKBtn = ok_btn_cb
    --popup.m_cbCancelBtn = cancel_btn_cb
    --popup:setMessage(msg)
    return popup
end

-------------------------------------
-- function MakeSimplePopup_Confirm
-- @brief 단일 재화인 경우를 상정
-------------------------------------
function MakeSimplePopup_Confirm(item_key, item_value, msg, ok_btn_cb, cancel_btn_cb)
    
    if (item_key == 'cash') then
        local cash = g_userData:get('cash')

        -- 캐시가 충분히 있는지 체크
        if (cash < item_value) then
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('다이아몬드가 부족합니다.\n상점으로 이동하시겠습니까?'), openShopPopup_cash)
            return
        end
    elseif (item_key == 'gold') then
        local gold = g_userData:get('gold')

        -- 캐시가 충분히 있는지 체크
        if (gold < item_value) then
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('골드가 부족합니다.\n상점으로 이동하시겠습니까?'), openShopPopup_gold)
            return
        end
    end

    return UI_ConfirmPopup(item_key, item_value, msg, ok_btn_cb, cancel_btn_cb)
end