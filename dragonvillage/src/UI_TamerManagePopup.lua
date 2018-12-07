local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_TamerManagePopup
-------------------------------------
UI_TamerManagePopup = class(PARENT, {
		m_currTamerID = 'num',
		m_selectedTamerID = 'num',

		m_skillUI = 'UI',

        m_selectCostumeData = 'StructTamerCostume',

        m_tamerTalbeView = 'UIC_TableView', -- 테이머 
        m_costumeTalbeView = 'UIC_TableView', -- 코스튬 
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
	
	-- skill popup 생성
	self.m_skillUI = UI_SkillDetailPopup_Tamer()
	self.m_skillUI:setCloseCB(function() self:setTamerSkill() end)

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function onFocus
-------------------------------------
function UI_TamerManagePopup:onFocus()
    -- 코스튬을 구매한 경우, 결과 적용하기 위해 통신 
    if (g_tamerCostumeData.m_bDirtyCostumeInfo) then
        g_tamerCostumeData:request_costumeInfo(nil, false)

        -- 초기화
        self:refresh()
        self:refreshCostumeData()
        self:setTamerCostume()
        
        g_tamerCostumeData.m_bDirtyCostumeInfo = false
    end
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
    self:initTamerTableView()
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
    self:refreshTamerMenu()
	self:refreshButtonState()

    -- spine 캐시 정리
    SpineCacheManager:getInstance():purgeSpineCacheData()
end

-------------------------------------
-- function refreshTamerMenu
-- @brief 왼쪽 테이머 메뉴 갱신
-------------------------------------
function UI_TamerManagePopup:refreshTamerMenu()
    for _, v in pairs(self.m_tamerTalbeView.m_itemList) do
        local ui = v['ui']
        if ui then
            ui:refresh(self.m_currTamerID)
        end
    end
end

-------------------------------------
-- function refreshCostumeData
-- @brief 해당 테이머 코스튬 메뉴 갱신
-------------------------------------
function UI_TamerManagePopup:refreshCostumeData()
    if (self.m_selectCostumeData) then
        for _, v in pairs(self.m_costumeTalbeView.m_itemList) do
            local ui = v['ui']
            if ui then
                local cid = self.m_selectCostumeData:getCid()
                ui:setSelected(cid)
                ui:refresh()
            end
        end
    end
end

-------------------------------------
-- function initTamerTableView
-- @brief 테이머 리스트
-------------------------------------
function UI_TamerManagePopup:initTamerTableView()
    local vars = self.vars

    local table_tamer = TableTamer()
    local tamer_list = table.MapToList(table_tamer.m_orgTable)
    table.sort(tamer_list, function(a, b)
        return a['tid'] < b['tid']
    end)

    -- 테이머 선택 버튼 
    local function create_func(ui, data)
        local btn = ui.vars['tamerBtn']
        local label = ui.vars['tamerNameLabel']
        local tid = data['tid']
        ui:refresh(self.m_currTamerID)

        self:addTabWithLabel(tid, btn, label)
    end

    local node = vars['profileMenu']
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(240, 100)
    table_view:setCellUIClass(UI_TamerListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local make_item = true
    table_view:setItemList(tamer_list, make_item)

    self.m_tamerTalbeView = table_view

    self:setTab(self.m_selectedTamerID)
end

-------------------------------------
-- function onChangeTab
-- @brief 테이머 선택
-------------------------------------
function UI_TamerManagePopup:onChangeTab(tab, first)
    if (self.m_selectedTamerID == tab) and (not first) then
        return
    end

    self.m_selectedTamerID = tab
    self.m_selectCostumeData = g_tamerCostumeData:getUsedStructCostumeData(self.m_selectedTamerID)

    -- 스킬 팝업 열려있는 경우 -- 선택한 테이머로 갱신
	if (self.m_skillUI:isShow()) then
        local table_tamer = TableTamer()
	    local t_tamer = table_tamer:get(self.m_selectedTamerID)
	    local t_tamer_data = self:_getTamerServerInfo(self.m_selectedTamerID)
        self.m_skillUI:refresh(t_tamer)
	end

    self:refresh()

    -- 테이머 변경때만 코스튬 테이블뷰 초기화
    self:setTamerCostume()
end

-------------------------------------
-- function setTamerRes
-- @brief 테이머 SD
-------------------------------------
function UI_TamerManagePopup:setTamerRes(costume_data)
	local vars = self.vars
    local table_tamer = TableTamer()
    local target_id = costume_data and costume_data:getTamerID() or self.m_selectedTamerID
	local t_tamer = table_tamer:get(target_id)

	-- 기존 이미지 정리
	vars['tamerSdNode']:removeAllChildren(true)

	-- 테이머 SD
    local costume_data = costume_data or g_tamerCostumeData:getCostumeDataWithTamerID(target_id)
    local sd_res = costume_data:getResSD()

	local sd_animator = MakeAnimator(sd_res)
	sd_animator:setFlip(true)
    vars['tamerSdNode']:addChild(sd_animator.m_node)

    local costume_name = costume_data:getName()
    vars['costumeTitleLabel']:setString(costume_name)

	-- 없는 테이머는 음영 처리
	if (not self:_hasTamer(target_id)) then
		sd_animator:setColor(COLOR['gray'])
	end
end

-------------------------------------
-- function setTamerText
-- @brief
-------------------------------------
function UI_TamerManagePopup:setTamerText()
	local vars = self.vars

	local table_tamer = TableTamer()
	local t_tamer = table_tamer:get(self.m_selectedTamerID)

	-- 테이머 이름
	local tamer_name = t_tamer['t_name']
	vars['tamerNameLabel']:setString(Str(tamer_name))

	-- 테이머 설명
	local tamer_desc = t_tamer['t_desc']
	vars['tamerDscLabel']:setString(Str(tamer_desc))

	-- 테이머 없을 시 획득 조건 & 코스튬 정보
    local msg = Str('코스튬')
	if (not self:_hasTamer(self.m_selectedTamerID)) then
		local obtain_desc = TableTamer:getTamerObtainDesc(t_tamer)
		vars['lockLabel']:setString(Str(obtain_desc))

        msg = Str('테이머 구입 후 코스튬을 사용할 수 있습니다.')
	end

    vars['costumeInfoLabel']:setString(msg)
end

-------------------------------------
-- function setTamerSkill
-- @brief
-------------------------------------
function UI_TamerManagePopup:setTamerSkill()
	local vars = self.vars
	
	local table_tamer = TableTamer()
	local t_tamer = table_tamer:get(self.m_selectedTamerID)
	local t_tamer_data = self:_getTamerServerInfo(self.m_selectedTamerID)

	-- 스킬 정보 및 스킬 상세보기 팝업 등록
	local skill_mgr = MakeTamerSkillManager(t_tamer_data)
	local l_skill_icon = skill_mgr:getTamerSkillIconList()
	local func_skill_detail_btn = function()
        self.m_skillUI:show()
		self.m_skillUI:refresh(t_tamer, skill_mgr)
    end

    for i = 0, 3 do 
		local skill_icon = l_skill_icon[i]
		if (skill_icon) then
			vars['skillNode' .. i]:removeAllChildren()
			vars['skillNode' .. i]:addChild(skill_icon.root)

			skill_icon.vars['skillBtn']:registerScriptTapHandler(func_skill_detail_btn)
			skill_icon.vars['skillBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
		end
	end
end

-------------------------------------
-- function setTamerCostume
-- @brief 해당 테이머 코스튬 테이블뷰 생성
-------------------------------------
function UI_TamerManagePopup:setTamerCostume()
	local vars = self.vars

    local node = vars['costumeListNode']
    node:removeAllChildren()

    local l_struct_costume = g_tamerCostumeData:makeStructCostumeList(self.m_selectedTamerID)

    -- 코스튬 버튼
    local function create_func(ui, data)
        -- 코스튬 미리보기
        ui.vars['costumeBtn']:registerScriptTapHandler(function()
            self:click_costume(ui.m_costumeData)
        end)

        -- 코스튬 선택하기
        ui.vars['selectBtn']:registerScriptTapHandler(function()
            self:click_select_costume(ui.m_costumeData)
        end)

        -- 코스튬 구입하기
        ui.vars['buyBtn']:registerScriptTapHandler(function()
            self:click_buy_costume(ui.m_costumeData)
        end)

         -- 상점으로 이동
        ui.vars['gotoBtn']:registerScriptTapHandler(function()
            self:click_go_shop(ui.m_costumeData)
        end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(170, 280)
    table_view:setCellUIClass(UI_TamerCostumeListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_struct_costume)

    self.m_costumeTalbeView = table_view
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
            local table_tamer = TableTamer()
	        local t_tamer = table_tamer:get(self.m_selectedTamerID)
            
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
            vars['priceLabel']:setString(comma_value(price))

	        -- 가격 아이콘 및 라벨, 배경 조정
	        UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])
        end
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
		-- 사용중 테이머 ID 갱신
		self.m_currTamerID = tamer_id

		-- 테이머 선택 확인 노티
		local table_tamer = TableTamer()
	    local t_tamer = table_tamer:get(self.m_currTamerID)
		local tamer_str = Str('[{1}](이)가 선택되었습니다.', Str(t_tamer['t_name']))
		UI_ToastPopup(tamer_str)

		-- ui 갱신
		self:refresh()

        -- 테이머 선택시 해당 테이머 코스튬 정보로 초기화
        self.m_selectCostumeData = g_tamerCostumeData:getUsedStructCostumeData(self.m_currTamerID)

        -- 코스튬 테이블뷰 초기화
        self:refreshCostumeData()
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
    local table_tamer = TableTamer()
    local buy_type, price_type
    if (g_tamerData:isObtainable(self.m_selectedTamerID)) then
        buy_type = 'clear'
    else
        buy_type = 'basic'
    end

	-- 콜백
	local function cb_func()
		-- 테이머 선택 확인 노티
	    local t_tamer = table_tamer:get(tamer_id)
		local tamer_str = Str('[{1}](을)를 획득하였습니다.', Str(t_tamer['t_name']))
		UI_ToastPopup(tamer_str)

		-- ui 갱신
		self:refresh()
	end

    local function buy_func()
	    -- 서버에 저장
	    g_tamerData:request_getTamer(tamer_id, buy_type, cb_func)
    end

    -- 재화 사용 확인 팝업
    local t_tamer = table_tamer:get(self.m_selectedTamerID)
    local l_price_info = seperate(t_tamer['price_' .. buy_type], ';')
    MakeSimplePopup_Confirm(l_price_info[1], tonumber(l_price_info[2]), nil, buy_func)
end


-------------------------------------
-- function click_costume
-- @brief 코스튬 미리보기
-------------------------------------
function UI_TamerManagePopup:click_costume(costume_data)
    if (self.m_selectCostumeData:getCid() == costume_data:getCid()) then
        return
    end

    self.m_selectCostumeData = costume_data
    self:refreshCostumeData()

    -- 테이머 Res만 변경
    self:setTamerRes(costume_data)
end

-------------------------------------
-- function click_select_costume
-- @brief 코스튬 선택
-------------------------------------
function UI_TamerManagePopup:click_select_costume(costume_data)
    self.m_selectCostumeData = costume_data
    local costume_id = costume_data:getCid()
    local tamer_id = costume_data:getTamerID()
    local has_tamer = self:_hasTamer(tamer_id)

    -- 변경 불가
    if (not has_tamer) then
        UIManager:toastNotificationRed(Str('열려있지 않은 테이머는 코스튬을 변경 할 수 없습니다.'))

    -- 코스튬 선택
    else
        local function finish_cb()
            UIManager:toastNotificationGreen(Str('코스튬을 변경하였습니다.'))

            -- 모든 상태 변경
            self:refresh()
            -- 코스튬 테이블뷰 초기화
            self:refreshCostumeData()
        end

        g_tamerCostumeData:request_costumeSelect(costume_id, tamer_id, finish_cb)
    end
end

-------------------------------------
-- function click_buy_costume
-- @brief 코스튬 구입
-------------------------------------
function UI_TamerManagePopup:click_buy_costume(costume_data)
    self.m_selectCostumeData = costume_data

    local function finish_cb()
        UIManager:toastNotificationGreen(Str('코스튬을 구입하였습니다.'))

        -- 모든 상태 변경
        self:refresh()
        -- 코스튬 테이블뷰 초기화
        self:refreshCostumeData()
    end
    
    local function show_popup()
        local ui = UI_TamerCostumeConfirmPopup(self.m_selectCostumeData)
        ui:setCloseCB(finish_cb)
    end

    local is_open = costume_data:isOpen() 
    local is_lock = costume_data:isTamerLock()
    local is_buyable = costume_data:isBuyable()

    if (not is_buyable) then
        return

    -- 열려있지않은 테이머라면 한번더 경고 문구
    elseif (not is_open and is_lock) then
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('해당 테이머를 소유하지 못했습니다.\n그래도 구매하시겠습니까?'), show_popup)
    else
        show_popup()
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_TamerManagePopup:click_exitBtn()
	self.m_skillUI:close()
    self:close()
end

-------------------------------------
-- function click_go_shop
-------------------------------------
function UI_TamerManagePopup:click_go_shop(costume_data)
	
    if (costume_data:isSaleType_topaz()) then
        UINavigator:goTo('shop', 'topaz')    
    elseif (costume_data:isValorCostume()) then
        UINavigator:goTo('shop', 'valor')
    end
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