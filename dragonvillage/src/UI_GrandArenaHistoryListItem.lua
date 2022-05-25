local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_GrandArenaHistoryListItem
-------------------------------------
UI_GrandArenaHistoryListItem = class(PARENT, {
        m_userInfo = '',
        m_type = '', -- 'atk' or 'def' 공격기록, 방어기록
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GrandArenaHistoryListItem:init(struct_user_info, type)
    self.m_userInfo = struct_user_info
    self.m_type = type 
    local vars = self:load('grand_arena_scene_history_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GrandArenaHistoryListItem:initUI()
    local vars = self.vars

    local user_info = self.m_userInfo
    local rank = user_info.m_rank

    -- 테이머
    icon = user_info:getDeckTamerIcon('grand_arena_up') -- deckname
    if (icon) then
        vars['profileNode']:removeAllChildren()
        vars['profileNode']:addChild(icon)
        vars['profileBtn']:registerScriptTapHandler(function() 
			local is_visit = true
			UI_UserInfoDetailPopup:open(user_info, is_visit, nil)
		end)
    end

    -- 점수 표시
    vars['scoreLabel']:setString(user_info:getRPText())

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(user_info:getUserText())

    -- 전투력 표시
    local combat_power = user_info:getDeckCombatPowerByDeckname('grand_arena_up') + user_info:getDeckCombatPowerByDeckname('grand_arena_down')
    vars['powerLabel']:setString(Str('전투력 : {1}', comma_value(combat_power)))

    -- 드래곤 리스트
    local t_deck_dragon_list = user_info:getDeck_dragonObjList('grand_arena_up')
    for i,v in pairs(t_deck_dragon_list) do
        local icon = UI_DragonCard(v)
        icon.root:setSwallowTouch(false)
        vars['dragonNode' .. i]:addChild(icon.root)
    end

    -- 드래곤 리스트
    local t_deck_dragon_list = user_info:getDeck_dragonObjList('grand_arena_down')
    for i,v in pairs(t_deck_dragon_list) do
        local icon = UI_DragonCard(v)
        icon.root:setSwallowTouch(false)
        vars['dragonNode' .. (i+5)]:addChild(icon.root)
    end

    -- 승, 패 여부
    if (user_info.m_matchResult == 1) then
        vars['resultLabel']:setColor(cc.c3b(0, 255, 0))
        vars['resultLabel']:setString(Str('승리'))
    else--if (info.m_matchResult == 0) then
        vars['resultLabel']:setColor(cc.c3b(223, 87, 87))
        vars['resultLabel']:setString(Str('패배'))
    end

    do -- 시간
        local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        local match_time = (user_info.m_matchTime / 1000)
        local time = (curr_time - match_time)
        local str = Str('{1} 전', ServerTime:getInstance():makeTimeDescToSec(time, true))
        vars['timeLabel']:setString(str)
    end

    -- 공통의 정보
    self:initRankInfo(vars, user_info)   
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GrandArenaHistoryListItem:initButton()
    local vars = self.vars
    vars['deckBtn']:registerScriptTapHandler(function() self:click_deckBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GrandArenaHistoryListItem:refresh()
end

-------------------------------------
-- function click_deckBtn
-- @brief 덱 정보
-------------------------------------
function UI_GrandArenaHistoryListItem:click_deckBtn()
    local user_info = self.m_userInfo
    local uid = user_info.m_uid
    g_grandArena:requestUserDeck_grandArena(uid)
end
