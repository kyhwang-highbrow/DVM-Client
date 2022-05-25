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

    -- 재도전 (패배시에만 버튼 활성화)
    if (self.m_type == 'atk') then
        vars['retryBtn']:setVisible(user_info.m_matchResult ~= 1)
        vars['retryLabel']:setString(Str('재도전'))
    -- 복수전 (서버에서 주는 값으로 판단)
    else
        local b_revenge = user_info.m_history_revenge
        vars['retryBtn']:setVisible(not b_revenge and user_info.m_matchResult ~= 1)
        vars['retryLabel']:setString(Str('복수전'))
    end

    -- 친선전 가능
    local retry_cnt = user_info.m_retry_cnt
    local retry_max_cnt = user_info.m_rerty_max_cnt
    local is_available = (retry_cnt) and (retry_cnt > 0)
    vars['friendlyBattleBtn']:setVisible(is_available)
    if (is_available) then
        local cnt_str = string.format('%d/%d', retry_cnt, retry_max_cnt)
        vars['friendlyBattleNumberLabel']:setString(cnt_str)
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
function UI_ArenaHistoryListItem:initButton()
    local vars = self.vars
    vars['retryBtn']:registerScriptTapHandler(function() self:click_retryBtn() end)
    vars['friendlyBattleBtn']:registerScriptTapHandler(function() self:click_friendlyBattleBtn() end)
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
    -- 현재 히스토리 유저데이터 강제로 매칭데이터로 만들어줌
    g_arenaData.m_matchUserInfo = self.m_userInfo
    if (self.m_type == 'atk') then
        g_arenaData.m_tempLogData['match_type'] = 'retry'
    else
        g_arenaData.m_tempLogData['match_type'] = 'revenge'
    end
    UI_ArenaReady()
end

-------------------------------------
-- function click_friendlyBattleBtn
-- @brief 복수전, 재도전에 대한 친선전
-------------------------------------
function UI_ArenaHistoryListItem:click_friendlyBattleBtn()
    --UIManager:toastNotificationRed(Str('준비 중입니다.'))
    --if IS_TEST_MODE() then
    local user_info = self.m_userInfo
    local mode = (self.m_type == 'atk') and FRIEND_MATCH_MODE.RETRY or FRIEND_MATCH_MODE.REVENGE
    local history_id = user_info.m_history_id

    g_friendMatchData:request_arenaInfo(mode, history_id)
    --else
    --    UIManager:toastNotificationRed(Str('준비 중입니다.'))
    --end
end

-------------------------------------
-- function click_deckBtn
-- @brief 덱 정보
-------------------------------------
function UI_ArenaHistoryListItem:click_deckBtn()
    local user_info = self.m_userInfo
    local uid = user_info.m_uid
    local history_id = user_info.m_history_id

    -- 히스토리 저장될때의 덱을 보여줌
    RequestUserDeckInfoPopupNew(uid, history_id)
end
