local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_GachaResult_Rune
-------------------------------------
UI_GachaResult_Rune = class(PARENT, {
		m_type = 'string', -- 획득한 경로

        m_lGachaRuneList = 'list', -- 룬 데이터
		m_tRuneCardTable = 'table', -- 룬 카드 UI
        m_tRuneCardAnimator = 'table', -- 룬 카드 애니메이터
        m_tRuneCardOpen = 'table', -- 룬 카드가 오픈되었는지 저장
		m_tRuneCardEffectTable = 'table', -- 카드가 오픈된 이후 이펙트

		-- 연출 관련
        m_hideUIList = '',

     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_GachaResult_Rune:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_bVisible = false -- onFocus 용도로만 쓰임
end

-------------------------------------
-- function init
-- @param type : 룬을 얻게된 방법
-------------------------------------
function UI_GachaResult_Rune:init(type, l_gacha_rune_list)
	self.m_type = type

    -- 연출 관련 애니메이션 프레임캐시에 등록
    -- Translate:a2dTranslate('ui/a2d/summon/summon_cut.plist')

    self.m_uiName = 'UI_GachaResult_Rune'
    local vars = self:load('rune_gacha_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- @UI_ACTION
    self:doActionReset()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_GachaResult_Rune')

	-- 멤버 변수
    self.m_lGachaRuneList = l_gacha_rune_list
    self.m_tRuneCardTable = {}
    self.m_tRuneCardAnimator = {}
    self.m_tRuneCardOpen = {}
    self.m_tRuneCardEffectTable = {}

    self.m_hideUIList = {}

	self:initUI()  
	self:initButton()
    self:refresh()

    SoundMgr:stopBGM()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GachaResult_Rune:initUI()
	local vars = self.vars
    
    vars['againBtn']:setVisible(false)
    vars['okBtn']:setVisible(false)

    self:registerOpenNode('againBtn')
    self:registerOpenNode('okBtn')

	self:initRuneCardList()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GachaResult_Rune:initButton()
	local vars = self.vars

	vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
	vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GachaResult_Rune:refresh()
    local vars = self.vars

    -- 사용 재화 표기
	self:refresh_wealth()

	-- 룬 수량 표시
	self:refresh_inventoryLabel()

    if (self:isAllCardOpen()) then
        -- 마지막에만 보여야 하는 UI들을 관리
        for i,v in pairs(self.m_hideUIList) do
            v:setVisible(true)
        end
    end
end

-------------------------------------
-- function isAllCardOpen
-------------------------------------
function UI_GachaResult_Rune:isAllCardOpen()
    local b_is_all_card_open = true

    for roid, v in pairs(self.m_tRuneCardOpen) do
        if (v == false)  then
            b_is_all_card_open = false
            break
        end
    end

    return b_is_all_card_open
end


-------------------------------------
-- function initRuneCardList
-------------------------------------
function UI_GachaResult_Rune:initRuneCardList()
	local vars = self.vars

    self.m_tRuneCardTable = {}
	local total_card_count = table.count(self.m_lGachaRuneList)	-- 총 룬 카드 수
	local horizontal_offset = 10	-- 룬 카드 가로 오프셋
	local vertical_offset = 10		-- 룬 카드 세로 오프셋

    local l_use_node = {}
    local l_vertical_node_list = {vars['itemMenu1']}
    local l_top_ui_list = {}
    local l_bottom_ui_list = {}

    -- 5개 이하일 땐 한 줄로 배치
    if (total_card_count <= 5) then
        for idx = 1, total_card_count do
            table.insert(l_use_node, vars['itemNode' .. idx])
            table.insert(l_top_ui_list, vars['itemNode' .. idx])
        end
        
    else
         -- 짝수일땐 위아래 똑같은 수 배치, 홀수일땐 위에 하나 더 배치
        local bottom_card_count = math_floor(total_card_count / 2)
        for idx = 6, (6 + bottom_card_count - 1) do
            table.insert(l_use_node, vars['itemNode' .. idx])
            table.insert(l_top_ui_list, vars['itemNode' .. idx])
        end

        local top_card_count = total_card_count - bottom_card_count
        for idx = 1, (top_card_count) do
            table.insert(l_use_node, vars['itemNode' .. idx])
            table.insert(l_bottom_ui_list, vars['itemNode' .. idx])
        end
        
        table.insert(l_vertical_node_list, vars['itemMenu2'])
    end

	for idx, t_rune_data in ipairs(self.m_lGachaRuneList) do
		-- 룬 카드 생성
        t_rune_data = StructRuneObject(t_rune_data) -- raw data를 StructRuneObject 형태로 변경
        local roid = t_rune_data['roid']
        local card_node = l_use_node[idx]
		local card = UI_RuneCard(t_rune_data)
		
		-- 카드 숨기기 (애니메이션 종료 후 오픈)
		card.root:setVisible(true)
		--card.root:setVisible(false)
		card_node:addChild(card.root, 2)
		
		-- 리스트에 저장 (연출을 위해)
		self.m_tRuneCardTable[roid] = card

        -- 카드 오픈 관련 변수 설정
        --self.m_tRuneCardOpen[roid] = false
        self.m_tRuneCardOpen[roid] = true

        -- 카드 오픈 관련 애니메이션 설정
        --local res_name = 'res/ui/a2d/summon/summon.vrp'
        --local animator = MakeAnimator(res_name)
        --animator:setIgnoreLowEndMode(true)
        --animator:changeAni('appear_01', true)
        --animator:setScale(0.4)
        --card_node:addChild(animator.m_node, 3)
--
        --local node = cc.MenuItemImage:create()
        --node:setDockPoint(CENTER_POINT)
        --node:setAnchorPoint(CENTER_POINT)
        --node:setPosition(0, 0)
        --node:setContentSize(300, 300)
        --local btn = UIC_Button(animator.m_node)
        --btn:registerScriptTapHandler(function() self:click_openRune(roid) end)
        --card_node:addChild(node, 4)
--
        --self.m_tRuneCardAnimator[roid] = animator

        -- TODO : 카드 희귀도에 따른 이펙트 저장
        
	end

    -- 카드 위치 정렬
    AlignUIPos(l_vertical_node_list, 'VERTICAL', 'CENTER', vertical_offset)
    AlignUIPos(l_top_ui_list, 'HORIZONTAL', 'CENTER', horizontal_offset)
    AlignUIPos(l_bottom_ui_list, 'HORIZONTAL', 'CENTER', horizontal_offset)
end

-------------------------------------
-- function refresh_wealth
-------------------------------------
function UI_GachaResult_Rune:refresh_wealth()
	local vars = self.vars

    local type = self.m_type
    
    -- 룬 상자 
    if (type == 'rune_box') then
        local rune_box_count = g_userData:get('rune_box')
        vars['countLabel']:setString(comma_value(rune_box_count))
        vars['againBtn']:setVisible(true)
    end
end

-------------------------------------
-- function refresh_inventoryLabel
-- @brief
-------------------------------------
function UI_GachaResult_Rune:refresh_inventoryLabel()
    local vars = self.vars
    local inven_type = 'rune'
    local rune_count = table.count(g_runesData:getUnequippedRuneList())
    local max_count = g_inventoryData:getMaxCount(inven_type)
    self.vars['inventoryLabel']:setString(string.format('%d/%d', rune_count, max_count))
end

-------------------------------------
-- function click_inventoryBtn
-- @brief 인벤 확장
-------------------------------------
function UI_GachaResult_Rune:click_inventoryBtn()
    local item_type = 'rune'
    local function finish_cb()
        self:refresh_inventoryLabel()
		self:refresh_wealth()
    end

    g_inventoryData:extendInventory(item_type, finish_cb)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_GachaResult_Rune:click_closeBtn()
    SoundMgr:playPrevBGM()
    self:close()
end

-------------------------------------
-- function click_openRune
-- @brief 뒤집어져있는 룬 카드를 클릭했을 때
-------------------------------------
function UI_GachaResult_Rune:click_openRune(roid)
    cclog('click open rune')
    -- 이미 열린 경우 패스
    if (self.m_tRuneCardOpen[roid] == true) then
        cclog('pass 1')

        return
    end

    -- 열리고 있는 도중인 경우 패스
    local animator = self.m_tRuneCardAnimator[roid]
    if (animator.m_currAnimation == 'crack_high_01') then
        cclog('pass 2')
        
        return
    end

    -- 카드를 뒤집는 애니메이션이 끝나면 룬 카드를 오픈 
    local function finish_cb()
        animator:setVisible(false)
        self.m_tRuneCardOpen[roid] = true
        local rune_card = self.m_tRuneCardTable[roid]
        rune_card:setVisible(true)
        cclog('finish cb')
    end

    animator:changeAni('crack_high_01')
    animator:addAniHandler(function() finish_cb() end)
end


-------------------------------------
-- function onFocus
-- @brief 탑바가 Lobby UI에 포커싱 되었을 때
-------------------------------------
function UI_GachaResult_Rune:onFocus()
    self:refresh_wealth()
end

-------------------------------------
-- function registerOpenNode
-------------------------------------
function UI_GachaResult_Rune:registerOpenNode(lua_name)
	local node = self.vars[lua_name]
	if (node) then 
		table.insert(self.m_hideUIList, node)
	end
end