local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_GachaResult_Rune
-------------------------------------
UI_GachaResult_Rune = class(PARENT, {
		m_type = 'string', -- 획득한 경로

        m_lGachaRuneList = 'list', -- 룬 데이터
		m_tRuneCardTable = 'table', -- 룬 카드 UI

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

    require('UI_RuneCard_Gacha')

    self.m_uiName = 'UI_GachaResult_Rune'
    local vars = self:load('rune_gacha_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- @UI_ACTION
    -- self:doActionReset()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_GachaResult_Rune')

	-- 멤버 변수
    self.m_lGachaRuneList = l_gacha_rune_list
    self.m_tRuneCardTable = {}

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
    
    self:registerOpenNode('againBtn')
    self:registerOpenNode('okBtn')

    -- 사용 재화 표기
	self:refresh_wealth()

	-- 룬 수량 표시
	self:refresh_inventoryLabel()

    -- 룬 카드들 생성
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

    local b_is_all_card_open = self:isAllCardOpen()
    -- 마지막에만 보여야 하는 UI들을 관리
    for i,v in pairs(self.m_hideUIList) do
        v:setVisible(b_is_all_card_open)
    end
end

-------------------------------------
-- function isAllCardOpen
-------------------------------------
function UI_GachaResult_Rune:isAllCardOpen()
    local b_is_all_card_open = true

    for roid, rune_card_gacha in pairs(self.m_tRuneCardTable) do
        if (not rune_card_gacha:isOpen())  then
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
		local card = UI_RuneCard_Gacha(t_rune_data, function() self:openRuneCB() end, function() end)
		
        -- 카드 숨기기 (애니메이션 종료 후 오픈)
		card_node:addChild(card.root, 2)
		
		self.m_tRuneCardTable[roid] = card
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
-- function openRuneCB
-- @brief 룬카드 오픈할 때 호출할 CB
-------------------------------------
function UI_GachaResult_Rune:openRuneCB()
    self:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_GachaResult_Rune:click_closeBtn()
    SoundMgr:playPrevBGM()
    self:close()
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