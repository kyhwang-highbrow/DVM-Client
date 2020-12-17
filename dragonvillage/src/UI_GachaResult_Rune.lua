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
        m_tUIOriginPos = 'table', -- 액션시킬 UI들의 원래 위치 저장
        m_titleEffector = 'animator',
        m_selectRuneCard = 'UI_RuneCard',
        m_selectRuneEffector = 'animator',

        -- 스킵 연출 관련
        m_bIsSkipping = 'boolean', -- 현재 스킵 액션이 진행중인지
        m_skipUpdateNode = 'cc.Node', -- 업데이트 노드
        m_timer = 'number', -- 스킵 관련 타이머
     })

UI_GachaResult_Rune.UPDATE_OFFSET = 0.1

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
    self.m_tUIOriginPos = {}
    
    self.m_bIsSkipping= false

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

    vars['allOkBtn']:setVisible(false)

    -- 처음 진입 이펙트
    self:initEnterEffect()

    -- 사용 재화 표기
	self:refresh_wealth()

	-- 룬 수량 표시
	self:refresh_inventoryLabel()

    -- 포커싱된 룬 이펙트 애니메이터
    local res_name = 'res/ui/a2d/summon/summon.vrp'
    local animator = MakeAnimator(res_name)
    animator:setIgnoreLowEndMode(true)
    self.m_selectRuneEffector = animator
    vars['effectSelectNode']:addChild(animator.m_node)

    -- 액션으로 움직일 UI 노드들 위치 저장
    self.m_tUIOriginPos['runeInfo'] = vars['runeInfo']:getPosition()
    
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    
    -- 오른쪽에서 나올 UI들 위치 옮겨놓기
    do
        self.m_tUIOriginPos['runeInfo'] = {}
        self.m_tUIOriginPos['runeInfo']['x'], self.m_tUIOriginPos['runeInfo']['y'] = vars['runeInfo']:getPosition()
        vars['runeInfo']:setPositionX(self.m_tUIOriginPos['runeInfo']['x'] + visibleSize['width'])
    end
end

-------------------------------------
-- function initEnterEffect
-- @brief 처음 진입할 때 이펙트 보여주기
-------------------------------------
function UI_GachaResult_Rune:initEnterEffect()
	local vars = self.vars

    -- 타이틀 이펙트 애니메이션 설정
    local res_name = 'res/ui/spine/rune_gacha_result/rune_gacha_result.json'
    local animator = MakeAnimator(res_name)
    animator:setIgnoreLowEndMode(true)
    animator:changeAni('appear', false)

    local function finish_cb()
        -- 룬 카드들 생성
	    self:initRuneCardList()
        
        animator:changeAni('idle', true)
    end

    animator:addAniHandler(finish_cb)
    vars['titleNode']:addChild(animator.m_node)
    self.m_titleEffector = animator
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GachaResult_Rune:initButton()
	local vars = self.vars

	vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_skipBtn() end)
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

        vars['okBtn']:setVisible(true)
        vars['skipBtn']:setVisible(false)
    else
        vars['okBtn']:setVisible(false)
    end 
end

-------------------------------------
-- function isAllCardOpen
-------------------------------------
function UI_GachaResult_Rune:isAllCardOpen()
    if (self.m_titleEffector.m_currAnimation == 'appear') then
        return false
    end
    
    for roid, rune_card_gacha in pairs(self.m_tRuneCardTable) do
        if (not rune_card_gacha:isOpen())  then
            return false
        end
    end

    return true
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
    
    local b_is_first_open = true

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

        -- 카드를 뒤집고 나서 한번 호출되는 콜백함수
        local function open_rune_cb()
             -- 룬 옵션 창을 ACTION!
            if (b_is_first_open == true) then
                b_is_first_open = false
                
                self:actionRuneInfoUI('runeInfo') -- 룬 정보창 움직이기
            end

            self:refresh()
            click_rune_cb()
           
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

    vars['skipBtn']:setVisible(true)
end

-------------------------------------
-- function actionRuneInfoUI
-- @brief UI Action만으로 움직이기에 한계가 있어서
-- 코드로 움직이도록 구현
-------------------------------------
function UI_GachaResult_Rune:actionRuneInfoUI(node_name)
    local vars = self.vars

    local duration = 0.3
    
    local x, y = self.m_tUIOriginPos[node_name]['x'], self.m_tUIOriginPos[node_name]['y']
    local moveToLeft = cc.MoveTo:create(duration, cc.p(x, y))
    vars[node_name]:runAction(moveToLeft)
end

-------------------------------------
-- function refreshRuneInfo
-------------------------------------
function UI_GachaResult_Rune:refreshRuneInfo(struct_rune_object)
    local vars = self.vars

    local roid = struct_rune_object['roid']
    local rarity = struct_rune_object['rarity']
    local rune_card_node = vars['runeSelectNode']
    
    if (self.m_selectRuneCard ~= nil) then
        self.m_selectRuneCard.root:removeFromParent()
    end

    -- 룬 카드 세팅
    local rune_card = UI_RuneCard(struct_rune_object)
    self.m_selectRuneCard = rune_card
    rune_card_node:addChild(rune_card.root)
    cca.uiReactionSlow(rune_card.root, 1, 1, 1.3)

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

    -- 룬 뒷배경 이펙트
    local effect_animator = self.m_selectRuneEffector
    local effect_name = string.format('bottom_idle_%02d', rarity)
    effect_animator:setVisible(true)
    effect_animator:changeAni(effect_name, true)
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
-- function click_skipBtn
-------------------------------------
function UI_GachaResult_Rune:click_skipBtn()
    if (self.m_bIsSkipping == true) then
        return
    end
    
    self.m_bIsSkipping = true
    self.m_timer = UI_GachaResult_Rune.UPDATE_OFFSET

    self.m_skipUpdateNode = cc.Node:create()
    self.root:addChild(self.m_skipUpdateNode)
    
    self.m_skipUpdateNode:scheduleUpdateWithPriorityLua(function(dt) return self:update_skip(dt) end, 0)
end

-------------------------------------
-- function update_skip
-------------------------------------
function UI_GachaResult_Rune:update_skip(dt)
    self.m_timer = self.m_timer - dt
    
    if (self.m_timer <= 0) then
        for idx, t_rune_data in pairs(self.m_lGachaRuneList) do
            local roid = t_rune_data['id']
            local rune_card = self.m_tRuneCardTable[roid]

            if (rune_card:isClose()) then
                rune_card:openCard(false)
                self.m_timer = self.m_timer + UI_GachaResult_Rune.UPDATE_OFFSET
                return
            end
        end

        -- 모든 카드를 오픈한 이후
        if (self:isAllCardOpen()) then
            self:refresh()
            self.m_skipUpdateNode:unscheduleUpdate()
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