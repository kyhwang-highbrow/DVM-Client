local PARENT = UI

-------------------------------------
-- class UI_GrandArenaMatchListItem
-------------------------------------
UI_GrandArenaMatchListItem = class(PARENT, {
        m_structUserInfo = 'StructUserInfoArena',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GrandArenaMatchListItem:init(struct_user_info)
    self.m_structUserInfo = struct_user_info

    local vars = self:load('grand_arena_loading_tamer_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GrandArenaMatchListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_GrandArenaMatchListItem:refresh()
    local vars = self.vars

    local struct_user_info = self.m_structUserInfo

    -- 레벨, 닉네임
    local lv = struct_user_info:getLv()
    local nick = struct_user_info:getNickname()
    vars['userLabel']:setString(Str('Lv.{1} {2}', lv, nick))

    -- 순위
    local rank_text = struct_user_info:getGrandArena_RankText()
    vars['rankLabel']:setString(rank_text)

    -- 전투력
    local combat_power_up = struct_user_info:getDeckCombatPowerByDeckname('grand_arena_up') or 0
    local combat_power_down = struct_user_info:getDeckCombatPowerByDeckname('grand_arena_down') or 0
    local combat_power_str = comma_value(combat_power_up + combat_power_down)
    vars['powerLabel']:setString(Str('전투력 : {1}', combat_power_str))

    -- 테이머 아이콘
    local icon = struct_user_info:getDeckTamerIcon('grand_arena_up')
    vars['tamerNode']:removeAllChildren()
    if icon ~= nil then
        vars['tamerNode']:addChild(icon)
    end
    
    --selectedSprite
    --tamerInfoSprite
    --guideVisual
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GrandArenaMatchListItem:initButton()
    local vars = self.vars
    --vars['tamerBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
end