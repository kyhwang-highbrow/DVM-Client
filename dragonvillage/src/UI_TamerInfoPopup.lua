local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_TamerInfoPopup
-------------------------------------
UI_TamerInfoPopup = class(PARENT, {
		m_currTamerData = 'table'
     })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerInfoPopup:init()
    local vars = self:load('tamer_select.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_TamerInfoPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_TamerInfoPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_TamerInfoPopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('테이머 정보')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TamerInfoPopup:initUI()
	self:makeTamerRotatePlate()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TamerInfoPopup:initButton()
	local vars = self.vars

	vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
	vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)
	vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TamerInfoPopup:refresh()
	self:refresh_rotatePlate()
end

-------------------------------------
-- function makeTamerRotatePlate
-------------------------------------
function UI_TamerInfoPopup:makeTamerRotatePlate()
    local vars = self.vars

	-- 테이머 rotate plate 설정
    vars['rotatePlate']:setLinearSlide(true)
    vars['rotatePlate']:removeAllChildren(true)
    vars['rotatePlate']:setRadiusX(300)
    vars['rotatePlate']:setRadiusY(0.1)
	vars['rotatePlate']:setOriginDirection(0)	-- 0:UP, 1:DOWN
	vars['rotatePlate']:setMinScale(0.3)

	-- 테이블에서 정보를 받아와 테이머 생성
    for i, t_tamer in ipairs(L_TAMER_LIST) do
		local res = t_tamer['res']
		local tamer_ui = self:makeTamerAni(res, i)
        vars['rotatePlate']:addChild(tamer_ui)
    end

	-- 현재 선택된 테이머를 가리키도록 한다.
	local t_tamer_info = g_userData:getTamerInfo()

	-- rotate plate 회전 시 실행 함수 등록
	vars['rotatePlate']:registerScriptRotatedHandler(function() self:refresh_rotatePlate() end)
end

-------------------------------------
-- function makeTamerAni
-------------------------------------
function UI_TamerInfoPopup:makeTamerAni(res, idx)
	-- 바탕이 될 menu 생성
    local menu = cc.Menu:create()
	menu:setDockPoint(cc.p(0.5, 0))
	menu:setAnchorPoint(0.5, 0)
	menu:setContentSize(150, 500)
	menu:setSwallowTouch(false)

	-- 추가 동작이 필요한 경우를 위해 버튼 생성
	local button = cc.MenuItemImage:create()
	button:setDockPoint(cc.p(0.5, 0.5))
	button:setAnchorPoint(0.5, 0.5)
	button:setContentSize(150, 500)

	-- 실 리소스 생성
	local tamer = MakeAnimator(res)
	tamer:setDockPoint(0.5, 0.5)
	tamer:setAnchorPoint(0.5, 0.5)
	tamer:setScale(0.55)

	-- 순서대로 addchild
	menu:addChild(button)
	button:addChild(tamer.m_node)

	-- 버튼 동작 지정
	button:registerScriptTapHandler(function()
    end)

	return menu
end

-------------------------------------
-- function refresh_rotatePlate
-------------------------------------
function UI_TamerInfoPopup:refresh_rotatePlate()
	local vars = self.vars
	
	-- 서버의 테이머 정보
	local t_tamer_info = g_userData:getTamerInfo()
	
	-- 현재 중앙에 있는 테이머 정보
	local iFront = vars['rotatePlate']:getFrontChildIndex() + 1
	local t_tamer = L_TAMER_LIST[iFront]
	self.m_currTamerData = t_tamer

	-- 테이머 정보 UI 출력
	vars['tamerNameLabel']:setString(t_tamer['t_name'])
	vars['tamerDscLabel']:setString(t_tamer['t_desc'])

	-- 테이머 선택중 UI 조작
	local b_use_tamer = t_tamer['tmid'] == t_tamer_info['tmid']
	vars['useSprite']:setVisible(b_use_tamer)
	vars['selectBtn']:setVisible(not b_use_tamer)

	-- 얻지 않는 테이머 표시
	local b_lock = (not t_tamer['b_obtain'])
	vars['lockSprite']:setVisible(b_lock)
	if (b_lock) then
		vars['lockLabel']:setString(Str('획득 조건은 테이머마다 다릅니다.'))
		vars['selectBtn']:setVisible(not b_lock)
	end
end

-------------------------------------
-- function click_prevBtn
-- @brief 뒤로가기
-------------------------------------
function UI_TamerInfoPopup:click_prevBtn()
    self.vars['rotatePlate']:setRotate(1, 1)
end

-------------------------------------
-- function click_nextBtn
-- @brief 앞으로가기
-------------------------------------
function UI_TamerInfoPopup:click_nextBtn()
    self.vars['rotatePlate']:setRotate(-1, 1)
end

-------------------------------------
-- function click_selectBtn
-- @brief tamer 선택
-------------------------------------
function UI_TamerInfoPopup:click_selectBtn()
	local t_data = self.m_currTamerData
	UIManager:toastNotificationGreen(Str('"{1}"가 선택되었습니다.', t_data['t_name']))
    
	-- 서버에 저장..을 해야함
	g_userData:applyServerData(t_data, 'tamer')
	
	-- ui 갱신
	self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_TamerInfoPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_TamerInfoPopup)
