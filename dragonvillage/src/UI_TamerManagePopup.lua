local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_TamerManagePopup
-------------------------------------
UI_TamerManagePopup = class(PARENT, {
		m_currTamerID = 'num',
		m_selectedTamerID = 'num',
		m_lTamerItemList = '',

		m_skillUI = 'UI',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerManagePopup:init()
    local vars = self:load('tamer_manage_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_TamerManagePopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- 멤버 변수
	self.m_currTamerID = g_tamerData:getTamerInfo('tid')
	self.m_selectedTamerID = self.m_currTamerID
	self.m_lTamerItemList = {}
	
	-- skill popup 생성
	self.m_skillUI = UI_SkillDetailPopup_Tamer()
	self.m_skillUI:setCloseCB(function() self:setTamerSkill() end)

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
	vars['obtainBtn']:registerScriptTapHandler(function() self:click_obtainBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TamerManagePopup:refresh()
	self:setTamerRes()
	self:setTamerText()
	self:setTamerSkill()
	self:refreshButtonState()
	self:refreshTamerItem()
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
		self.m_lTamerItemList[tamer_id] = tamer_item

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
	local t_tamer = self.m_lTamerItemList[self.m_selectedTamerID]:getTamerTable()

	-- 기존 이미지 정리
	vars['tamerNode']:removeAllChildren(true)
	vars['tamerSdNode']:removeAllChildren(true)

	-- 테이머 일러스트
	local illustration_res = t_tamer['res']
    local illustration_animator = MakeAnimator(illustration_res)
	illustration_animator:changeAni('idle', true)
    vars['tamerNode']:addChild(illustration_animator.m_node)

	-- 테이머 SD
	local sd_res = t_tamer['res_sd']
	local sd_animator = MakeAnimator(sd_res)
	sd_animator:setFlip(true)
    vars['tamerSdNode']:addChild(sd_animator.m_node)

	-- 없는 테이머는 음영 처리
	if (not g_tamerData:hasTamer(self.m_selectedTamerID)) then
		illustration_animator:setColor(COLOR['deep_dark_gray'])
		sd_animator:setColor(COLOR['deep_dark_gray'])
	end
end

-------------------------------------
-- function setTamerText
-- @brief
-------------------------------------
function UI_TamerManagePopup:setTamerText()
	local vars = self.vars
	local t_tamer = self.m_lTamerItemList[self.m_selectedTamerID]:getTamerTable()

	-- 테이머 이름
	local tamer_name = t_tamer['t_name']
	vars['tamerNameLabel']:setString(Str(tamer_name))

	-- 테이머 설명
	local tamer_desc = t_tamer['t_desc']
	vars['tamerDscLabel']:setString(Str(tamer_desc))

	-- 테이머 없을 시 획득 조건
	if (not g_tamerData:hasTamer(self.m_selectedTamerID)) then
		local obtain_desc = TableTamer:getTamerObtainDesc(t_tamer)
		vars['lockLabel']:setString(Str(obtain_desc))
	end
end

-------------------------------------
-- function setTamerSkill
-- @brief
-------------------------------------
function UI_TamerManagePopup:setTamerSkill()
	local vars = self.vars
	
	local t_tamer = self.m_lTamerItemList[self.m_selectedTamerID]:getTamerTable()
	local t_tamer_data = g_tamerData:getTamerServerInfo(self.m_selectedTamerID)

	-- 스킬 정보 및 스킬 상세보기 팝업 등록
	local skill_mgr = MakeTamerSkill_Temp(t_tamer_data)
	local l_skill_icon = skill_mgr:getDragonSkillIconList()
	local func_skill_detail_btn = function()
        self.m_skillUI:show()
		self.m_skillUI:refresh(t_tamer, skill_mgr)
    end

	for i = 1, 3 do 
		local skill_icon = l_skill_icon[i]
		if (skill_icon) then
			vars['skillNode' .. i]:removeAllChildren()
			vars['skillNode' .. i]:addChild(skill_icon.root)

			skill_icon.vars['clickBtn']:registerScriptTapHandler(func_skill_detail_btn)
			skill_icon.vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
		end
	end
end

-------------------------------------
-- function refreshButtonState
-- @brief
-------------------------------------
function UI_TamerManagePopup:refreshButtonState()
	local vars = self.vars

	-- 테이머 있음
	if (g_tamerData:hasTamer(self.m_selectedTamerID)) then
		-- 현재 사용중인 경우
		if (self.m_currTamerID == self.m_selectedTamerID) then
			vars['useBtn']:setVisible(true)
			vars['lockBtn']:setVisible(false)
			vars['selectBtn']:setVisible(false)
			vars['obtainBtn']:setVisible(false)

			vars['selectBtn']:setEnabled(false)
			vars['obtainBtn']:setEnabled(false)

		-- 선택 가능한 경우
		elseif (self.m_currTamerID ~= self.m_selectedTamerID) then
			vars['useBtn']:setVisible(false)
			vars['lockBtn']:setVisible(false)
			vars['selectBtn']:setVisible(true)
			vars['obtainBtn']:setVisible(false)

			vars['selectBtn']:setEnabled(true)
			vars['obtainBtn']:setEnabled(false)
		end

	-- 테이머 없음
	else
		-- 획득 가능
		if (g_tamerData:isObtainable(self.m_selectedTamerID)) then
			vars['useBtn']:setVisible(false)
			vars['lockBtn']:setVisible(false)
			vars['selectBtn']:setVisible(false)
			vars['obtainBtn']:setVisible(true)

			vars['selectBtn']:setEnabled(false)
			vars['obtainBtn']:setEnabled(true)

		-- 불가
		else
			vars['useBtn']:setVisible(false)
			vars['lockBtn']:setVisible(true)
			vars['selectBtn']:setVisible(true)
			vars['obtainBtn']:setVisible(false)

			vars['selectBtn']:setEnabled(false)
			vars['obtainBtn']:setEnabled(false)
		end
	end
end

-------------------------------------
-- function refreshTamerItem
-- @brief
-------------------------------------
function UI_TamerManagePopup:refreshTamerItem()
	for i, v in pairs(self.m_lTamerItemList) do
		v:refresh()
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
	local old_tamer_item = self.m_lTamerItemList[self.m_selectedTamerID]
	old_tamer_item:selectTamer(false)

	-- 새로운 테이머 select
	tamer_item:selectTamer(true)
	self.m_selectedTamerID = tamer_id

	-- refresh
	self:refresh()

	-- skill popup refresh
	if (self.m_skillUI:isShow()) then
		local t_tamer = tamer_item:getTamerTable()
		self.m_skillUI:refresh(t_tamer)
	end
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
		local old_tamer_item = self.m_lTamerItemList[self.m_currTamerID]
		old_tamer_item:setUseTamer(false)

		-- 새로운 테이머 use
		local new_tamer_item = self.m_lTamerItemList[tamer_id]
		new_tamer_item:setUseTamer(true)

		-- 사용중 테이머 ID 갱신
		self.m_currTamerID = tamer_id

		-- 테이머 선택 확인 노티
		local t_tamer = new_tamer_item:getTamerTable()
		local tamer_str = Str('[{1}]이/가 선택되었습니다.', t_tamer['t_name'])
		--UIManager:toastNotificationGreen(tamer_str)
		UI_ToastPopup(tamer_str)

		-- ui 갱신
		self:refresh()
	end

	-- 서버에 저장
	g_tamerData:request_setTamer(tamer_id, cb_func)
end

-------------------------------------
-- function click_obtainBtn
-- @brief tamer 획득
-------------------------------------
function UI_TamerManagePopup:click_obtainBtn()
	local tamer_id = self.m_selectedTamerID

	-- 콜백
	local function cb_func()
		-- 획득한 테이머
		local new_tamer_item = self.m_lTamerItemList[tamer_id]

		-- 테이머 선택 확인 노티
		local t_tamer = new_tamer_item:getTamerTable()
		local tamer_str = Str('[{1}]을/를 획득하였습니다.', t_tamer['t_name'])
		UI_ToastPopup(tamer_str)

		-- ui 갱신
		self:refresh()
	end

	-- 서버에 저장
	g_tamerData:request_getTamer(tamer_id, cb_func)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_TamerManagePopup:click_exitBtn()
	self.m_skillUI:close()
    self:close()
end


--@CHECK
UI:checkCompileError(UI_TamerManagePopup)
