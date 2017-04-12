local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_TamerManagePopup
-------------------------------------
UI_TamerManagePopup = class(PARENT, {
		m_currTamerID = 'num',
		m_selectedTamerID = 'num',
		m_tamerTable = 'TableClass',

		m_lTamerProfileItemList = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerManagePopup:init()
    local vars = self:load('tamer_manage_scene_new.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_TamerManagePopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- 멤버 변수
	self.m_currTamerID = g_userData:getTamerInfo('tid')
	self.m_selectedTamerID = self.m_currTamerID
	self.m_lTamerProfileItemList = {}

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_TamerManagePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_TamerManagePopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('테이머')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TamerManagePopup:initUI()
    self:initTamerItem()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TamerManagePopup:initButton()
    local vars = self.vars
	vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TamerManagePopup:refresh()
	self:setTamerRes()
	self:setTamerText()
	self:setTamerSkill()
	self:refreshButtonState()
end

-------------------------------------
-- function initTamerItem
-- @brief 테이머 아이템 생성
-------------------------------------
function UI_TamerManagePopup:initTamerItem()
	local vars = self.vars
	local curr_tamer_id = self.m_currTamerID

	local idx = 1
	for tamer_id, t_tamer in pairs(TableTamer().m_orgTable) do
		-- 테이머 아이템 생성
		local tamer_item = UI_TamerManageItem(t_tamer)
		-- 버튼 콜백 등록
		tamer_item.vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn(tamer_item) end)
		-- 사용중 테이머 표시 + 선택도 함
		if (curr_tamer_id == tamer_id) then
			tamer_item:setUseTamer(true)
			tamer_item:selectTamer(true)
		end

		-- 테이머 아이템 맵핑
		self.m_lTamerProfileItemList[tamer_id] = tamer_item

		vars['profileNode' .. idx]:addChild(tamer_item.root)

		idx = idx + 1
	end
end

-------------------------------------
-- function setTamerRes
-- @brief 테이머 illustration 과 SD
-------------------------------------
function UI_TamerManagePopup:setTamerRes()
	local vars = self.vars
	local t_tamer = self.m_lTamerProfileItemList[self.m_selectedTamerID]:getTamerTable()

	-- 기존 이미지 정리
	vars['tamerNode']:removeAllChildren(true)
	vars['tamerSdNode']:removeAllChildren(true)

	-- 테이머 일러스트
	local illustration_res = t_tamer['res']
    local illustration_animator = MakeAnimator(illustration_res)
    vars['tamerNode']:addChild(illustration_animator.m_node)
	self:adjustTamerIllustration(illustration_animator, t_tamer['type'])

	-- 테이머 SD
	local sd_res = t_tamer['res_sd']
	local sd_animator = MakeAnimator(sd_res)
    vars['tamerSdNode']:addChild(sd_animator.m_node)
end

-------------------------------------
-- function setTamerText
-- @brief
-------------------------------------
function UI_TamerManagePopup:setTamerText()
	local vars = self.vars
	local t_tamer = self.m_lTamerProfileItemList[self.m_selectedTamerID]:getTamerTable()

	-- 테이머 이름
	local tamer_name = t_tamer['t_name']
	vars['tamerNameLabel']:setString(Str(tamer_name))

	-- 테이머 설명
	local tamer_desc = t_tamer['t_desc']
	vars['tamerDscLabel']:setString(Str(tamer_desc))
end

-------------------------------------
-- function setTamerSkill
-- @brief
-------------------------------------
function UI_TamerManagePopup:setTamerSkill()
end

-------------------------------------
-- function refreshButtonState
-- @brief
-------------------------------------
function UI_TamerManagePopup:refreshButtonState()
	local vars = self.vars

	-- 잠긴 경우
	if (false) then
	else
		-- 현재 사용중인 경우
		if (self.m_currTamerID == self.m_selectedTamerID) then
			vars['useBtn']:setVisible(true)
			vars['selectBtn']:setVisible(false)

		-- 선택 가능한 경우
		elseif (self.m_currTamerID ~= self.m_selectedTamerID) then
			vars['useBtn']:setVisible(false)
			vars['selectBtn']:setVisible(true)

		end
	end
end

-------------------------------------
-- function adjustTamerIllustration
-- @brief 테이머 개별로 예쁘게 보이게 수정해준다.
-------------------------------------
function UI_TamerManagePopup:adjustTamerIllustration(illustration_animator, tamer_type)
	if (tamer_type == 'goni') then
		illustration_animator:setPositionY(-50)
		illustration_animator:setFlip(true)
		illustration_animator:setScale(1.3)

	elseif (tamer_type == 'nuri') then	
		illustration_animator:setScale(1.4)

	elseif (tamer_type == 'dede') then
		illustration_animator:setScale(1.4)

	elseif (tamer_type == 'kesath') then
		illustration_animator:setScale(1.3)

	elseif (tamer_type == 'durun') then
		illustration_animator:setPositionY(-150)
		illustration_animator:setScale(1.3)

	elseif (tamer_type == 'mokoji') then
		illustration_animator:setFlip(true)
		illustration_animator:setScale(1.1)

	end
end

-------------------------------------
-- function click_tamerBtn
-------------------------------------
function UI_TamerManagePopup:click_tamerBtn(tamer_item)
	-- 기존 선택한 테이머와 같은 것이면 탈출
	local tamer_id = tamer_item:getTamerId()

	if (self.m_selectedTamerID == tamer_id) then 
		return
	end

	-- 기존 테이머 unSelect
	local old_tamer_item = self.m_lTamerProfileItemList[self.m_selectedTamerID]
	old_tamer_item:selectTamer(false)

	-- 새로운 테이머 select
	tamer_item:selectTamer(true)
	self.m_selectedTamerID = tamer_id

	-- refresh
	self:refresh()
end

-------------------------------------
-- function click_selectBtn
-- @brief tamer 선택
-------------------------------------
function UI_TamerManagePopup:click_selectBtn()
	local tamer_id = self.m_selectedTamerID

	-- 콜백
	local function cb_func()
		-- 기존 테이머 unUse
		local old_tamer_item = self.m_lTamerProfileItemList[self.m_currTamerID]
		old_tamer_item:setUseTamer(false)

		-- 새로운 테이머 use
		local new_tamer_item = self.m_lTamerProfileItemList[tamer_id]
		new_tamer_item:setUseTamer(true)

		-- 사용중 테이머 ID 갱신
		self.m_currTamerID = tamer_id

		-- 테이머 선택 확인 노티
		local t_tamer = new_tamer_item:getTamerTable()
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
function UI_TamerManagePopup:click_exitBtn()
    self:close()
end


--@CHECK
UI:checkCompileError(UI_TamerManagePopup)
