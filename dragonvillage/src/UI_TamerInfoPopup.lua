local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_TamerInfoPopup
-------------------------------------
UI_TamerInfoPopup = class(PARENT, {
		m_tamerTable = 'TableTamer',
		m_currTamerIdx = 'number',

		m_tamerAniList = 'list',
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

	-- 변수 지정
	self.m_currTamerIdx = g_userData:getRef('tamer') - TAMER_VALUE
	self.m_tamerTable = TableTamer()
	self.m_tamerAniList = {}

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
	self:refresh_tamerSkill()
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
    for i, t_tamer in pairs(self.m_tamerTable.m_orgTable) do
		local res = t_tamer['res']
		local tamer_ui = self:makeTamerAni(res)
        vars['rotatePlate']:addChild(tamer_ui, 0, i)
    end

	-- 현재 선택된 테이머를 가리키도록 한다.
	vars['rotatePlate']:setRotate(-1, self.m_currTamerIdx - 1)

	-- rotate plate 회전 시 실행 함수 등록
	vars['rotatePlate']:registerScriptRotatedHandler(function() self:refresh() end)
end

-------------------------------------
-- function makeTamerAni
-------------------------------------
function UI_TamerInfoPopup:makeTamerAni(res)
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
	if not (tamer.m_node) then 
		tamer = MakeAnimator('res/character/tamer/leon_i/leon_i.spine')
	end
	tamer:setDockPoint(0.5, 0.5)
	tamer:setAnchorPoint(0.5, 0.5)
	tamer:setScale(0.55)
	tamer:changeAni_Repeat({'lobby_idle', 'lobby_idle', 'lobby_idle', 'lobby_pose'}, true)

	-- 연출을 위해서 별로 리스트에 저장
	table.insert(self.m_tamerAniList, tamer)

	-- 순서대로 addchild
	menu:addChild(button)
	button:addChild(tamer.m_node)

	--[[ 버튼 동작 지정
	button:registerScriptTapHandler(function()
    end)]]

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
	local front_idx = vars['rotatePlate']:getFrontChildIndex() + 1
	local t_tamer = self.m_tamerTable:get(front_idx + TAMER_VALUE)
	self.m_currTamerIdx = front_idx

	-- 테이머 정보 UI 출력
	vars['tamerNameLabel']:setString(t_tamer['t_name'])
	vars['tamerDscLabel']:setString(t_tamer['t_desc'])

	-- 테이머 선택중 UI 조작
	local b_use_tamer = t_tamer['tid'] == t_tamer_info['tid']
	vars['useSprite']:setVisible(b_use_tamer)
	vars['selectBtn']:setVisible(not b_use_tamer)

	-- @TODO 얻지 않는 테이머 표시
	local b_lock = false --(not t_tamer['b_obtain'])
	vars['lockSprite']:setVisible(b_lock)
	if (b_lock) then
		vars['lockLabel']:setString(Str('획득 조건은 테이머마다 다릅니다.'))
		vars['selectBtn']:setVisible(not b_lock)
	end

	-- 중앙 테이머는 밝히고 나머지는 어둡게 액션을 준다.
	local gray_color = 75
	local duration = 0.25
	for i, tamer in pairs(self.m_tamerAniList) do
		if (i == front_idx) then
			local tint_action_light = cc.TintTo:create(duration, 255, 255, 255)
			tamer:runAction(tint_action_light)
		else
			local tint_action_dark = cc.TintTo:create(duration, gray_color, gray_color, gray_color)
			tamer:runAction(tint_action_dark)
		end
	end
end

-------------------------------------
-- function refresh_tamerSkill
-------------------------------------
function UI_TamerInfoPopup:refresh_tamerSkill()
	local vars = self.vars
	
	-- 현재 중앙에 있는 테이머 정보
	local front_idx = vars['rotatePlate']:getFrontChildIndex() + 1
	local t_tamer = self.m_tamerTable:get(front_idx + TAMER_VALUE)

	-- 테이머 스킬 테이블
	local tamer_skill_table = TableTamerSkill()

	-- 스킬1의 정보
	do
		vars['skillNode1']:removeAllChildren()

		local skill_1_id = t_tamer['skill_1']
		local t_skill_1 = tamer_skill_table:getTamerSkill(skill_1_id)
	
		if (t_skill_1) then
			-- 스킬명
			vars['skillTitleLabel1']:setString(Str(t_skill_1['t_name']))
			-- 스킬 상세
			vars['skillDscLabel1']:setString(Str(t_skill_1['t_desc']))
			-- 스킬 아이콘
			local skill_1_icon = MakeAnimator(t_skill_1['res_icon'])
			if (skill_1_icon) then
				vars['skillNode1']:addChild(skill_1_icon)
			end
		else
			vars['skillTitleLabel1']:setString('없음')
			vars['skillDscLabel1']:setString('-')
		end
	end

	-- 스킬2의 정보
	do
		vars['skillNode2']:removeAllChildren()
	
		local skill_2_id = t_tamer['skill_2']
		local t_skill_2 = tamer_skill_table:getTamerSkill(skill_2_id)
	
		if (t_skill_2) then
			-- 스킬명
			vars['skillTitleLabel2']:setString(Str(t_skill_2['t_name']))
			-- 스킬 상세
			vars['skillDscLabel2']:setString(Str(t_skill_2['t_desc']))
			-- 스킬 아이콘
			local skill_2_icon = MakeAnimator(t_skill_2['res_icon'])
			if (skill_2_icon) then
				vars['skillNode2']:addChild(skill_2_icon)
			end
		else
			vars['skillTitleLabel2']:setString('없음')
			vars['skillDscLabel2']:setString('-')
		end
	end
end

-------------------------------------
-- function click_prevBtn
-- @brief 뒤로가기
-------------------------------------
function UI_TamerInfoPopup:click_prevBtn()
	local rotate_plate = self.vars['rotatePlate']
    
	-- 뒤로 이동 -> 각도는 360/child.count 를 더한다.
	rotate_plate:setRotate(1, 1)

	-- 720도가 되면 360도로 강제이동하면서 튀는 현상이 있어 보정해준다.
	local angle = rotate_plate:getAngle()
	if (angle >= 660) then
		rotate_plate:setAngle(angle - 360)
	end
end

-------------------------------------
-- function click_nextBtn
-- @brief 앞으로가기
-------------------------------------
function UI_TamerInfoPopup:click_nextBtn()
	local rotate_plate = self.vars['rotatePlate']

	-- 앞으로 이동 -> 각도는  360/child.count 를 뺀다.
    rotate_plate:setRotate(-1, 1)

	-- -360도가 되면 0도로 강제이동하면서 튀는 현상이 있어 보정해준다.
	local angle = rotate_plate:getAngle()
	if (angle <= -300) then
		rotate_plate:setAngle(angle + 360)
	end
end

-------------------------------------
-- function click_selectBtn
-- @brief tamer 선택
-------------------------------------
function UI_TamerInfoPopup:click_selectBtn()
	local tamer_id = self.m_currTamerIdx + TAMER_VALUE
    
	-- 콜백
	local function cb_func()
		-- 테이머 선택 확인 노티
		local t_tamer = self.m_tamerTable:get(tamer_id)
		UIManager:toastNotificationGreen(Str('"{1}"가 선택되었습니다.', t_tamer['t_name']))
		-- ui 갱신
		self:refresh()
	end

	-- 서버에 저장
	g_userData:request_setTamer(tamer_id, cb_func)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_TamerInfoPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_TamerInfoPopup)
