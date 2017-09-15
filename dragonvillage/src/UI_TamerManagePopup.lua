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
function UI_TamerManagePopup:init(tamer_id)
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
	self.m_currTamerID = tamer_id or g_tamerData:getCurrTamerID()
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
	vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
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

    -- spine 캐시 정리
    SpineCacheManager:getInstance():purgeSpineCacheData()
end

-------------------------------------
-- function initTamerItem
-- @brief 테이머 아이템 생성
-------------------------------------
function UI_TamerManagePopup:initTamerItem()
	local vars = self.vars
	local curr_tamer_id = self.m_currTamerID

    local table_tamer = TableTamer()
  
    local l_tamer = {}
    for i,v in pairs(table_tamer.m_orgTable) do
        table.insert(l_tamer, v)
    end
    local function sort_func(a, b)
        return a['tid'] < b['tid']
    end
    table.sort(l_tamer, sort_func)

    local l_pos = getSortPosList(112, table.count(table_tamer.m_orgTable))
	for idx, t_tamer in ipairs(l_tamer) do
        local tamer_id = t_tamer['tid']
		-- 테이머 아이템 생성
		local tamer_item = UI_TamerManageItem(t_tamer)
		-- 버튼 콜백 등록
		tamer_item.vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn(tamer_item) end)
		-- 사용중 테이머 표시 + 선택도 함
		if (curr_tamer_id == tamer_id) then
			tamer_item:setUseTamer(true)
			tamer_item:selectTamer(true)
		else
            tamer_item:setUseTamer(false)
			tamer_item:selectTamer(false)
        end

		-- 테이머 아이템 맵핑
		self.m_lTamerItemList[tamer_id] = tamer_item

        local pos_x = l_pos[idx]
        tamer_item.root:setPositionX(pos_x)

        vars['profileMenu']:addChild(tamer_item.root)        
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
	if (not self:_hasTamer(self.m_selectedTamerID)) then
		illustration_animator:setColor(COLOR['gray'])
		sd_animator:setColor(COLOR['gray'])
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

	-- 테이머 타입
	local tamer_type = t_tamer['t_title_desc']
	vars['tamerTypeLabel']:setString(Str(tamer_type))

	-- 테이머 설명
	local tamer_desc = t_tamer['t_desc']
	vars['tamerDscLabel']:setString(Str(tamer_desc))

	-- 테이머 없을 시 획득 조건
	if (not self:_hasTamer(self.m_selectedTamerID)) then
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
	local t_tamer_data = self:_getTamerServerInfo(self.m_selectedTamerID)

	-- 스킬 정보 및 스킬 상세보기 팝업 등록
	local skill_mgr = MakeTamerSkillManager(t_tamer_data)
	local l_skill_icon = skill_mgr:getDragonSkillIconList()
	local func_skill_detail_btn = function()
        self.m_skillUI:show()
		self.m_skillUI:refresh(t_tamer, skill_mgr)
    end

	for i = 1, 4 do 
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
	if (self:_hasTamer(self.m_selectedTamerID)) then
		-- 현재 사용중인 경우
		if (self.m_currTamerID == self.m_selectedTamerID) then
			vars['useBtn']:setVisible(true)
			vars['lockSprite']:setVisible(false)
			vars['selectBtn']:setVisible(false)
			vars['buyBtn']:setVisible(false)

		-- 선택 가능한 경우
		elseif (self.m_currTamerID ~= self.m_selectedTamerID) then
			vars['useBtn']:setVisible(false)
			vars['lockSprite']:setVisible(false)
			vars['selectBtn']:setVisible(true)
			vars['buyBtn']:setVisible(false)

		end

	-- 테이머 없음
	else
        local is_clear_cond = g_tamerData:isObtainable(self.m_selectedTamerID)

		-- 획득 가능
		vars['useBtn']:setVisible(false)
		vars['lockSprite']:setVisible(not is_clear_cond)
		vars['selectBtn']:setVisible(false)
		vars['buyBtn']:setVisible(true)

        do
            local vars = self.vars
            local t_tamer = self.m_lTamerItemList[self.m_selectedTamerID]:getTamerTable()
            
            -- 구매 조건 체크
            local buy_type
            if (is_clear_cond) then
                buy_type = 'clear'
            else
                buy_type = 'basic'
            end

            local l_price_info = seperate(t_tamer['price_' .. buy_type], ';')

	        -- 가격 아이콘
            vars['priceNode']:removeAllChildren()
            local icon = IconHelper:getPriceIcon(l_price_info[1])
            vars['priceNode']:addChild(icon)
	
            -- 가격
	        local price = l_price_info[2]
            vars['priceLabel']:setString(price)

	        -- 가격 아이콘 및 라벨, 배경 조정
	        UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])
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
		local tamer_str = Str('[{1}](이)가 선택되었습니다.', t_tamer['t_name'])
		--UIManager:toastNotificationGreen(tamer_str)
		UI_ToastPopup(tamer_str)

		-- ui 갱신
		self:refresh()
	end

	-- 선택 테이머 변경 요청
	self:_request_setTamer(tamer_id, cb_func)
end

-------------------------------------
-- function click_buyBtn
-- @brief tamer 획득
-------------------------------------
function UI_TamerManagePopup:click_buyBtn()
	local tamer_id = self.m_selectedTamerID
    local buy_type, price_type
    if (g_tamerData:isObtainable(self.m_selectedTamerID)) then
        buy_type = 'clear'
    else
        buy_type = 'basic'
    end

	-- 콜백
	local function cb_func()
		-- 획득한 테이머
		local new_tamer_item = self.m_lTamerItemList[tamer_id]

		-- 테이머 선택 확인 노티
		local t_tamer = new_tamer_item:getTamerTable()
		local tamer_str = Str('[{1}](을)를 획득하였습니다.', t_tamer['t_name'])
		UI_ToastPopup(tamer_str)

		-- ui 갱신
		self:refresh()
	end

    local function buy_func()
	    -- 서버에 저장
	    g_tamerData:request_getTamer(tamer_id, buy_type, cb_func)
    end

    -- 재화 사용 확인 팝업
    local t_tamer = self.m_lTamerItemList[self.m_selectedTamerID]:getTamerTable()
    local l_price_info = seperate(t_tamer['price_' .. buy_type], ';')
    MakeSimplePopup_Confirm(l_price_info[1], tonumber(l_price_info[2]), nil, buy_func)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_TamerManagePopup:click_exitBtn()
	self.m_skillUI:close()
    self:close()
end



-------------------------------------
-- function _hasTamer
-- @brief 플레이어가 테이머를 보유 했는지 여부
-- @return boolean
-------------------------------------
function UI_TamerManagePopup:_hasTamer(tamer_id)
    local has_tamer = g_tamerData:hasTamer(tamer_id)
    return has_tamer
end

-------------------------------------
-- function _isObtainable
-- @brief 플레이어가 테이머를 획득 가능한 상태인지 여부
-- @return boolean
-------------------------------------
function UI_TamerManagePopup:_isObtainable(tamer_id)
    local is_obtainable = g_tamerData:isObtainable(tamer_id)
    return is_obtainable
end

-------------------------------------
-- function _getTamerServerInfo
-- @brief 서버에 저장된 테이머 정보
-- @return table
-------------------------------------
function UI_TamerManagePopup:_getTamerServerInfo(tamer_id)
    local t_tamer_data = g_tamerData:getTamerServerInfo(tamer_id)
    return t_tamer_data
end

-------------------------------------
-- function _request_setTamer
-- @brief 서버에 선택된 테이머 저장
-------------------------------------
function UI_TamerManagePopup:_request_setTamer(tamer_id, cb_func)
	-- 서버에 저장
	g_tamerData:request_setTamer(tamer_id, cb_func)
end




--@CHECK
UI:checkCompileError(UI_TamerManagePopup)
