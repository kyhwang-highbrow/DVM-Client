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
	local vars = self:load('event_popup.ui')
	UIManager:open(self, UIManager.POPUP)
    self.m_lobby_coroutine = co
	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ChallengeModePromotePopup')

    -- 이벤트 팝업 밑에 붙일 그림자 신전 팝업
    self.m_eventPopupUI = UI()
    self.m_eventPopupUI:load('event_challenge_mode.ui')

    -- 패키지 UI 크기에 따라 풀팝업 UI 사이즈 변경후 추가
    do
        local l_children = self.m_eventPopupUI.root:getChildren()
        local tar_menu = l_children[1]
    
        -- 최상위 메뉴 사이즈로 변경
        if (tar_menu) then
            local size = tar_menu:getContentSize()
            local width = size['width']
            local height = 640
            vars['mainNode']:setContentSize(cc.size(width, height))
        end
    
        vars['eventNode']:addChild(self.m_eventPopupUI.root)
    end

	self:initUI()
	self:initButton()
	self:refresh()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeModePromotePopup:initUI()
	local vars = self.vars
    local challenge_vars = self.m_eventPopupUI.vars

    challenge_vars['promoteMenu']:setVisible(true)
    local struct_user_info = g_challengeMode:getPlayerArenaUserInfo()
    local rank_text = struct_user_info:getChallengeMode_RankText()
    challenge_vars['rankLabel']:setString(rank_text)

    local gold_label = Str(' {1}/{2}', comma_value(g_challengeMode:getCumulativeGold()), comma_value(10000000))
    local gold_title_label = Str('획득한 골드')
    challenge_vars['goldLabel']:setString(gold_title_label .. gold_label)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModePromotePopup:initButton()
	local vars = self.vars
    local challenge_vars = self.m_eventPopupUI.vars

    local refresh_cooltime_func

     -- 바로 가기 버튼 함수
     -- 코루틴 탈출
    challenge_vars['gotoBtn']:registerScriptTapHandler(function()
        self:click_closeBtn()
        UINavigatorDefinition:goTo('challenge_mode')
        -- 다음 코루틴 진행하지 않고 로비에서 벗어나므로 코루틴 강제 종료
        self.m_lobby_coroutine.ESCAPE()
    end)

    -- 닫기 버튼 함수
    -- 코루틴 진행
    vars['closeBtn']:setVisible(true)
    vars['closeBtn']:registerScriptTapHandler(function()
        self:click_closeBtn()
        self.m_lobby_coroutine.NEXT() 
    end)
   
    vars['checkBtn']:setVisible(true)
    vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBtn() end)

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
-- @brief 닫을 때 [하루동안 다시 보지 않기 체크] 되어있으면 쿨타임 시작
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

    self.vars['checkSprite']:setVisible(self.m_isCheck)
end


--@CHECK
UI:checkCompileError(UI_ChallengeModePromotePopup)
