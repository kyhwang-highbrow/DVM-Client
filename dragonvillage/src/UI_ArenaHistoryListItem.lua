local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaHistoryListItem
-------------------------------------
UI_ArenaHistoryListItem = class(PARENT, {
        m_userInfo = '',
        m_type = '', -- 'atk' or 'def' 공격기록, 방어기록
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaHistoryListItem:init(struct_user_info, type)
    self.m_userInfo = struct_user_info
    self.m_type = type 

    local vars = self:load('arena_scene_history_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaHistoryListItem:initUI()
    local vars = self.vars

    local user_info = self.m_userInfo
    local rank = user_info.m_rank

    -- 코스튬 적용
    local icon = user_info:getDeckTamerIcon()
    if (icon) then
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
    local combat_power = user_info:getDeckCombatPower()
    vars['powerLabel']:setString(Str('전투력 : {1}', comma_value(combat_power)))

    -- 드래곤 리스트
    local t_deck_dragon_list = user_info:getDeck_dragonList()
    for i,v in pairs(t_deck_dragon_list) do
        local icon = UI_DragonCard(v)
        icon.root:setSwallowTouch(false)
        vars['dragonNode' .. i]:addChild(icon.root)
    end

    -- 승, 패 여부
    if (user_info.m_matchResult == 1) then
        vars['resultLabel']:setColor(cc.c3b(0, 255, 0))
        vars['resultLabel']:setString(Str('승리'))
    else--if (info.m_matchResult == 0) then
        vars['resultLabel']:setColor(cc.c3b(223, 87, 87))
        vars['resultLabel']:setString(Str('패배'))
    end

    -- 재도전, 복수전 (패배이고 도전가능한 상황일떄만 노출)
    -- 1번 도전이라 되있는데 이부분 서버 작업 필요함

    local str_retry = (self.m_type == 'atk') and Str('재도전') or Str('복수전')
    vars['retryLabel']:setString(str_retry)

    do -- 시간
        local curr_time = Timer:getServerTime()
        local match_time = (user_info.m_matchTime / 1000)
        local time = (curr_time - match_time)
        local str = Str('{1} 전', datetime.makeTimeDesc(time, true))
        vars['timeLabel']:setString(str)
    end

    -- 공통의 정보
    self:initRankInfo(vars, user_info)   
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaHistoryListItem:initButton()
    local vars = self.vars
    vars['retryBtn']:registerScriptTapHandler(function() self:click_retryBtn() end)
    vars['deckBtn']:registerScriptTapHandler(function() self:click_deckBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaHistoryListItem:refresh()
end

-------------------------------------
-- function click_retryBtn
-- @brief 복수전, 재도전
-------------------------------------
function UI_ArenaHistoryListItem:click_retryBtn()
end

-------------------------------------
-- function click_deckBtn
-- @brief 덱 정보
-------------------------------------
function UI_ArenaHistoryListItem:click_deckBtn()
    local user_info = self.m_userInfo
    local uid = user_info.m_uid

    -- 히스토리 저장될떄의 덱을 보여줌
    RequestUserDeckInfoPopupNew(uid)
end
