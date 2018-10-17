local PARENT = UI

-------------------------------------
-- class UI_CostumeEventPopup
-------------------------------------
UI_CostumeEventPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CostumeEventPopup:init()
    self:load('event_costume_halloween.ui')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CostumeEventPopup:initUI()
    local vars = self.vars

    -- sgkim 2019.10.17 할로윈 코스튬 판매 종료 날짜를 표기할 방법이 없어서 하드코딩 (업데이트 전날 시간 부족으로)
    local struct_costume = g_tamerCostumeData:getCostumeDataWithCostumeID(730101)
    if (not struct_costume) then
        vars['timeLabel']:setString('')
        return
    end

    local is_limit, msg_limit = struct_costume:isLimit()
    vars['timeLabel']:setString(msg_limit)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CostumeEventPopup:initButton()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_CostumeEventPopup:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CostumeEventPopup:refresh()
end


-------------------------------------
-- function isActiveCostumeEventPopup
-------------------------------------
function UI_CostumeEventPopup:isActiveCostumeEventPopup()
    -- sgkim 2019.10.17 할로윈 코스튬 판매 종료 날짜를 표기할 방법이 없어서 하드코딩 (업데이트 전날 시간 부족으로)
    local struct_costume = g_tamerCostumeData:getCostumeDataWithCostumeID(730101)
    if (not struct_costume) then
        return false
    end

    if (struct_costume:isEnd()) then
        return false
    end

    return true
end


--@CHECK
UI:checkCompileError(UI_CostumeEventPopup)
