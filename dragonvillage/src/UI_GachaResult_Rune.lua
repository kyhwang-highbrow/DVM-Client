local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_GachaResult_Rune
-------------------------------------
UI_GachaResult_Rune = class(PARENT, {
		m_type = 'string', -- 획득한 경로

        m_lGachaRuneList = 'list', -- 룬 데이터
		m_tRuneCardTable = 'table', -- 룬 카드 UI
        m_optionLabel = 'UI', -- 룬 옵션 라벨

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
    self:doActionReset()
    --self:doAction(nil, false)

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
    
    if (self.m_type == 'rune_box') then
        self:registerOpenNode('againBtn')
    else
        vars['againBtn']:setVisible(false)
    end

    -- SUCCESS 이펙트
    -- self:initTitleEffect()

    -- 사용 재화 표기
	self:refresh_wealth()

	-- 룬 수량 표시
	self:refresh_inventoryLabel()

    -- 룬 카드들 생성
	self:initRuneCardList()
end

-------------------------------------
-- function initTitleEffect
-- @brief 타이틀 이펙트 보여주기
-------------------------------------
function UI_GachaResult_Rune:initTitleEffect()
	local vars = self.vars

    -- 타이틀 이펙트 애니메이션 설정
    local res_name = 'res/ui/spine/rune_gacha/rune_gacha_result.json'
    local animator = MakeAnimator(res_name)
    animator:setIgnoreLowEndMode(true)
    animator:changeAni('Appear', false)

    local function finish_cb()
        animator:changeAni('idle', true)
    end

    animator:addAniHandler(finish_cb)

    vars['titleMenu']:addChild(animator.m_node)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GachaResult_Rune:initButton()
	local vars = self.vars

	vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['allOkBtn']:registerScriptTapHandler(function() self:click_allOkBtn() end)
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

    if (b_is_all_card_open) then
        self:doActionReset()
        self:doAction(nil, false)

        vars['allOkBtn']:setVisible(false)
        vars['okBtn']:setVisible(true)
    else
        vars['allOkBtn']:setVisible(true)
        vars['okBtn']:setVisible(false)
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
	local card_interval = 110	-- 룬 카드 가로 오프셋

    local l_pos_list = getSortPosList(card_interval, total_card_count)

	for idx, t_rune_data in ipairs(self.m_lGachaRuneList) do
		-- 룬 카드 생성
        local struct_rune_object = StructRuneObject(t_rune_data) -- raw data를 StructRuneObject 형태로 변경
        local node = vars['runeNode' .. idx]
        local roid = struct_rune_object['roid']
		
        local card = UI_RuneCard_Gacha(struct_rune_object)

        -- 이미 열린 카드를 클릭할 때 호출되는 콜백함수
        local function click_rune_cb()
            self:refreshRuneInfo(struct_rune_object)
        end

        local b_is_first_open = true

        -- 카드를 뒤집고 나서 한번 호출되는 콜백함수
        local function open_rune_cb()
            self:refresh()
            click_rune_cb()
    
            -- 룬 옵션 창을 ACTION!
            if (b_is_first_open == true) then
                b_is_first_open = false
                
            end
        end
        
        card:setOpenCB(open_rune_cb)
        card:setClickCB(click_rune_cb)

		node:addChild(card.root)
		self.m_tRuneCardTable[roid] = card

        -- 카드 위치 정렬
        node:setPositionX(l_pos_list[idx])        
	end

    for roid, rune_card in pairs(self.m_tRuneCardTable) do
        rune_card.root:setOpacity(0)
        local x, y = rune_card.root:getPosition()
         -- 등장할 때 미끄러지면서 생성되기
        local move_distance = 50
        local duration = 0.2
        local move = cc.MoveTo:create(duration, cc.p(x, y))
        local fade_in = cc.FadeIn:create(duration)
        local action = cc.EaseInOut:create(cc.Spawn:create(fade_in, move), 1.3)
        
        rune_card.root:setPositionY(y + move_distance)
        rune_card.root:runAction(action)
    end
end

-------------------------------------
-- function refreshRuneInfo
-------------------------------------
function UI_GachaResult_Rune:refreshRuneInfo(struct_rune_object)
    local vars = self.vars

    local roid = struct_rune_object['roid']
    local rune_card_node = vars['runeSelectNode']
    rune_card_node:removeAllChildren()

    -- 룬 카드 세팅
    local rune_card = UI_RuneCard(struct_rune_object)
    rune_card_node:addChild(rune_card.root)

    -- 룬 이름 세팅
    vars['nameLabel']:setVisible(true)
    local name = struct_rune_object['name']
    vars['nameLabel']:setString(name)

    -- 룬 옵션 세팅
    vars['runeDscNode']:setVisible(true)
    if (not self.m_optionLabel) then
        self.m_optionLabel = struct_rune_object:getOptionLabel()
        self.vars['runeDscNode']:addChild(self.m_optionLabel.root)
    end

    struct_rune_object:setOptionLabel(self.m_optionLabel, 'use', false)

    -- 룬 세트 효과
    vars['itemDscNode2']:setVisible(true)
    local str = struct_rune_object:makeRuneSetDescRichText() or ''
    vars['itemDscLabel2']:setString(str)



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
function UI_GachaResult_Rune:click_allOkBtn()
    
    for roid, rune_card in pairs(self.m_tRuneCardTable) do
        if(not rune_card:isOpen()) then
            rune_card:click_clickBtn()
        end
    end
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