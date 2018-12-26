local PARENT = UI

-------------------------------------
-- class UI_ChallengeModePromotePopup
-------------------------------------
UI_ChallengeModePromotePopup = class(PARENT,{
        m_lobby_coroutine = 'coroutine',
        m_isCheck = 'bool',
        m_eventPopupUI = 'ui'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModePromotePopup:init(co)
	local vars = self:load('event_challenge_mode.ui')
	UIManager:open(self, UIManager.POPUP)
    self.m_lobby_coroutine = co
	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ChallengeModePromotePopup')

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
    vars['rankLabel']:setString(rank_text)

    local gold_label = Str(' {1}/{2}', comma_value(g_challengeMode:getCumulativeGold()), comma_value(10000000))
    local gold_title_label = Str('획득한 골드')
    vars['goldLabel']:setString(gold_title_label .. gold_label)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModePromotePopup:initButton()
	local vars = self.vars
    local ui = UI()
    self.m_eventPopupUI = ui:load('event_popup.ui')
    local ui_check = self.m_eventPopupUI
    ui_check['mainNode']:removeFromParent()
    self.root:addChild(ui_check['mainNode'])

    -- 하위 버튼 눌리도록
    ui_check['eventNode']:removeFromParent()
    ui_check['clickBtn']:removeFromParent()

    local refresh_cooltime_func

     -- 바로 가기 버튼 함수
     -- 코루틴 탈출
    vars['gotoBtn']:registerScriptTapHandler(function()
        self:click_closeBtn()
        UINavigatorDefinition:goTo('challenge_mode')
        self.m_lobby_coroutine.ESCAPE()
    end)

    -- 닫기 버튼 함수
    -- 코루틴 진행
    ui_check['closeBtn']:setVisible(true)
    ui_check['closeBtn']:registerScriptTapHandler(function()
        self:click_closeBtn()
        self.m_lobby_coroutine:NEXT() 
    end)
   
    ui_check['checkBtn']:setVisible(true)
    ui_check['checkBtn']:registerScriptTapHandler(function() self:click_checkBtn() end)

    local size = vars['MainMenu']:getContentSize()
    local width = size['width']
    local height = size['height']
    ui_check['mainNode']:setContentSize(cc.size(width, height))
    ui_check['mainNode']:setPosition(vars['MainMenu']:getPosition())

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
    local cur_time = Timer:getServerTime()
    local next_cool_time = cur_time + datetime.dayToSecond(1)
    g_settingData:setPromoteCoolTime('challenge_mode', next_cool_time)
end

-------------------------------------
-- function click_closeBtn
-- @brief 닫을 때 [하루동안 다시 보지 않기 체크] 확인
-------------------------------------
function UI_ChallengeModePromotePopup:click_closeBtn()
    if (self.m_isCheck) then
        self:refreshCoolTime()
    end
    self:close()
end

-------------------------------------
-- function click_checkBtn
-------------------------------------
function UI_ChallengeModePromotePopup:click_checkBtn()
    if (self.m_isCheck) then
        self.m_isCheck = false
    else
        self.m_isCheck = true
    end

    self.m_eventPopupUI['checkSprite']:setVisible(self.m_isCheck)
end


--@CHECK
UI:checkCompileError(UI_ChallengeModePromotePopup)
