local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-- table_tamer가 나중에 대체할것
local TAMER_LIST = {
	{res = 'res/character/tamer/goni_i/goni_i.spine', t_name = '고니', t_desc = '고니는 남자아이이다.'},
	{res = 'res/character/tamer/nuri_i/nuri_i.spine', t_name = '누리', t_desc = '누리는 여자아이이다.'},
	{res = 'res/character/tamer/leon_i/leon_i.spine', t_name = '레온', t_desc = '레온은 지금 존재하지 않는다.'},
	{res = 'res/character/tamer/goni_i/goni_i.spine', t_name = '고니2', t_desc = '고니2는 고니의 반복이다.'},
	{res = 'res/character/tamer/nuri_i/nuri_i.spine', t_name = '누리2', t_desc = '누리2는 누리의 반복이다.'},
	{res = 'res/character/tamer/leon_i/leon_i.spine', t_name = '레온2', t_desc = '레온2 역시 존재하지 않는다.'},
}

-------------------------------------
-- class UI_TamerInfoPopup
-------------------------------------
UI_TamerInfoPopup = class(PARENT, {
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

	vars['rotatePlate']:registerScriptRotatedHandler(function() self:refresh_rotatePlate() end)
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

    vars['rotatePlate']:setLinearSlide(true)
    vars['rotatePlate']:removeAllChildren(true)
    vars['rotatePlate']:setRadiusX(300)
    vars['rotatePlate']:setRadiusY(0.1)
	vars['rotatePlate']:setOriginDirection(0)	-- 0:UP, 1:DOWN
	vars['rotatePlate']:setMinScale(0.3)

    for i, t_tamer in ipairs(TAMER_LIST) do
		local res = t_tamer['res']
		local tamer_ui = self:makeTamerAni(res, i)
        vars['rotatePlate']:addChild(tamer_ui)
    end
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

	local iFront = vars['rotatePlate']:getFrontChildIndex() + 1

	local t_tamer = TAMER_LIST[iFront]
	vars['tamerNameLabel']:setString(t_tamer['t_name'])
	vars['tamerDscLabel']:setString(t_tamer['t_desc'])
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
    
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_TamerInfoPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_TamerInfoPopup)
