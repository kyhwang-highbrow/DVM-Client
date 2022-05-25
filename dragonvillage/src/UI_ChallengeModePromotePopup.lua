local PARENT = UI

-------------------------------------
-- class UI_ChallengeModePromotePopup
-------------------------------------
UI_ChallengeModePromotePopup = class(PARENT,{

        m_close_cb = 'func',
        m_goto_cb = 'func'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModePromotePopup:init(close_cb, goto_cb)
	local vars = self:load('event_challenge_mode.ui')
	UIManager:open(self, UIManager.POPUP)
    
    self.m_close_cb = close_cb
    self.m_goto_cb = goto_cb

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() 
    self:refreshCoolTime() 
    self.m_close_cb() 
    self:close() 
    end, 'UI_ChallengeModePromotePopup')

	self:initUI()
	self:initButton()
	self:refresh()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeModePromotePopup:initUI()
	local vars = self.vars

    vars['promoteMenu']:setVisible(true)
    local struct_user_info = g_challengeMode:getPlayerArenaUserInfo()
    local rank_text = struct_user_info:getChallengeMode_RankText()
    local rank_full_text = Str('내 랭킹') .. ' ' .. rank_text
    vars['rankLabel']:setString(rank_full_text)

    local gold_label = Str(' {1}/{2}', comma_value(g_challengeMode:getCumulativeGold()), comma_value(10000000))
    local gold_title_label = Str('획득한 골드')
    vars['goldLabel']:setString(gold_title_label .. gold_label)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModePromotePopup:initButton()
	local vars = self.vars
    local refresh_cooltime_func

     -- 바로 가기 버튼 함수
     -- 코루틴 탈출
    vars['gotoBtn']:registerScriptTapHandler(function()
        -- 다음 코루틴 진행하지 않고 로비에서 벗어나므로 코루틴 강제 종료
        self.m_goto_cb()
        self:click_closeBtn()
        UINavigatorDefinition:goTo('challenge_mode')
    end)

    -- 닫기 버튼 함수
    -- 코루틴 진행
    vars['closeBtn']:setVisible(true)
    vars['closeBtn']:registerScriptTapHandler(function()
        self.m_close_cb()
        self:click_closeBtn()
    end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeModePromotePopup:refresh()
	local vars = self.vars

end

-------------------------------------
-- function refreshCoolTime
-------------------------------------
function UI_ChallengeModePromotePopup:refreshCoolTime()
	-- 팝업 만료시간 1일 후로 세팅 
    local cur_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local next_cool_time = cur_time + datetime.dayToSecond(1)
    g_settingData:setPromoteCoolTime('challenge_mode', next_cool_time)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ChallengeModePromotePopup:click_closeBtn()
    self:refreshCoolTime()
    self:close()
end


--@CHECK
UI:checkCompileError(UI_ChallengeModePromotePopup)
