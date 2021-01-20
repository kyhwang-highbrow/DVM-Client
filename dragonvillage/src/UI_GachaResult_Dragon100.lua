local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_GachaResult_Dragon100
-------------------------------------
UI_GachaResult_Dragon100 = class(PARENT, {
		m_type = 'string', -- 획득한 경로

        m_lGachaDragonList = 'list', -- 드래곤 데이터
		m_tDragonCardTable = 'table', -- 드래곤 카드 UI

		-- 연출 관련
        m_hideUIList = '',
        m_tUIOriginPos = 'table', -- 액션시킬 UI들의 원래 위치 저장
        m_tUIIsMoved = 'table', -- UI들이 움직였는가 체크
        m_titleEffector = 'animator',
        m_selectRuneCard = 'UI_RuneCard',
        m_selectRuneEffector = 'animator',

        m_bDirectingLegend = 'boolean', -- 현재 5성 드래곤 연출 중인지 

        -- 스킵 연출 관련
        m_bIsSkipping = 'boolean', -- 현재 스킵 액션이 진행중인지
        m_skipUpdateNode = 'cc.Node', -- 업데이트 노드
        m_timer = 'number', -- 스킵 관련 타이머
     })

UI_GachaResult_Dragon100.UPDATE_CARD_SUMMON_OFFSET = 0.3 -- 카드 줄마다 처음에 소환되는 간격
UI_GachaResult_Dragon100.UPDATE_CARD_OPEN_OFFSET = 0.05 -- 스킵할 때 다음 카드 뒤집는 간격
UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH = 15 -- 드래곤 카드가 가로줄 당 몇 개씩?
UI_GachaResult_Dragon100.DRAGON_CARD_SCALE = 0.45 -- 드래곤 카드 스케일 조정
UI_GachaResult_Dragon100.DRAGON_CARD_WIDTH_OFFSET = 72 -- 드래곤 카드 가로 오프셋
UI_GachaResult_Dragon100.DRAGON_CARD_HEIGHT_OFFSET = 72 -- 드래곤 카드 세로 오프셋



-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_GachaResult_Dragon100:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_bVisible = false -- onFocus 용도로만 쓰임
end

-------------------------------------
-- function init
-- @param type : 룬을 얻게된 방법
-------------------------------------
function UI_GachaResult_Dragon100:init(type, l_gacha_dragon_list)
	self.m_type = type

    require('UI_DragonCard_Gacha')

    self.m_uiName = 'UI_GachaResult_Dragon100'
    local vars = self:load('dragon_summon_100_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- @UI_ACTION
    self:doActionReset()
    --self:doAction(nil, false)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_GachaResult_Dragon100')

	-- 멤버 변수
    self.m_lGachaDragonList = l_gacha_dragon_list
    self.m_tDragonCardTable = {}

    self.m_hideUIList = {}
    self.m_tUIOriginPos = {}
    self.m_tUIIsMoved = {}
    
    self.m_bIsSkipping = false
    self.m_bDirectingLegend = false

	self:initUI()  
	self:initButton()
    self:refresh()

    SoundMgr:stopBGM()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GachaResult_Dragon100:initUI()
	local vars = self.vars
    
    self:registerOpenNode('okBtn')

    self:initDragonCardList()

    vars['skipBtn']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GachaResult_Dragon100:initButton()
	local vars = self.vars

	vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_skipBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GachaResult_Dragon100:refresh()
    local vars = self.vars

    local b_is_all_card_open = self:isAllCardOpen()

    if (b_is_all_card_open) then
        -- 마지막에만 보여야 하는 UI들을 관리
        for i,v in pairs(self.m_hideUIList) do
            v:setVisible(true)
        end

        self:doActionReset()
        self:doAction(nil, false)

        vars['skipBtn']:setVisible(false)
        SoundMgr:playEffect('UI', 'ui_grow_result')
    end 
end

-------------------------------------
-- function isAllCardOpen
-------------------------------------
function UI_GachaResult_Dragon100:isAllCardOpen()
    for doid, dragon_card_gacha in pairs(self.m_tDragonCardTable) do
        if (not dragon_card_gacha:isOpen())  then
            return false
        end
    end

    return true
end

-------------------------------------
-- function initDragonCardList
-------------------------------------
function UI_GachaResult_Dragon100:initDragonCardList()
	local vars = self.vars

    self.m_tDragonCardTable = {}
	local total_card_count = table.count(self.m_lGachaDragonList)	-- 총 드래곤 카드 수
    local first_width_card_count = (total_card_count % UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH)
    if (first_width_card_count == 0) then
        first_width_card_count = UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH
    end
    local vertical_count = math_floor(total_card_count / UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH) -- 세로 줄 수
    if (total_card_count % UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH ~= 0) then
        vertical_count = vertical_count + 1
    end

	local horizontal_card_interval = UI_GachaResult_Dragon100.DRAGON_CARD_WIDTH_OFFSET	-- 드래곤 카드 가로 오프셋
	local vertical_card_interval = UI_GachaResult_Dragon100.DRAGON_CARD_HEIGHT_OFFSET	-- 드래곤 카드 세로 오프셋

    local l_horizontal_pos_list = getSortPosList(horizontal_card_interval, UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH)
    local l_first_horizontal_pos_list = getSortPosList(horizontal_card_interval, first_width_card_count)
    local l_vertical_pos_list = getSortPosList(vertical_card_interval, vertical_count)
    
	for idx, t_dragon_data in ipairs(self.m_lGachaDragonList) do
		-- 드래곤 카드 생성
        local struct_dragon_object = StructDragonObject(t_dragon_data) -- raw data를 StructDragonObject 형태로 변경
        local doid = struct_dragon_object['id']
		
        local card = UI_DragonCard_Gacha(struct_dragon_object)
        
        card.root:setScale(UI_GachaResult_Dragon100.DRAGON_CARD_SCALE)
        vars['dragonMenu']:addChild(card.root)

        local function open_condition_func()
            return not self.m_bDirectingLegend
        end

        -- 카드를 뒤집고 나서 한번 호출되는 콜백함수
        local function open_dragon_cb()
            local str_rarity = struct_dragon_object:getRarity()
            -- 3성은 어둡게
            if (str_rarity == 'rare') then
                card.m_dragonCard:setShadowSpriteVisible(true)
            
            -- 5성 추가 연출
            elseif (str_rarity == 'legend') then
                self:directingLegend(struct_dragon_object)
            end

            self:refresh()
        end
        
        card:setOpenCB(open_dragon_cb)
        card:setOpenConditionFunc(open_condition_func)
        card:setClickCB(nil)

		self.m_tDragonCardTable[doid] = card

        -- 카드 위치 정렬
        local x_idx = (idx <= first_width_card_count) and idx or (idx - first_width_card_count)
        x_idx = x_idx % UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH

        local y_idx = math_floor(idx / UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH)
        if (idx <= first_width_card_count) then
            y_idx = 0
        else
            y_idx = math_floor((idx - first_width_card_count) / UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH) + 1
        end

        if (x_idx == 0) then
            x_idx = UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH
        else
            y_idx = y_idx + 1
        end

        local pox_x = (y_idx > 1) and l_horizontal_pos_list[x_idx] or l_first_horizontal_pos_list[x_idx]
        local pos_y = l_vertical_pos_list[y_idx]

        card.root:setPositionX(pox_x)     
        card.root:setPositionY(-pos_y)   

        -- 등장할 때 미끄러지면서 생성되기
        card.root:setOpacity(0)
        local x, y = card.root:getPosition()
        local move_distance = 20
        local duration = 0.2
        local move = cc.MoveTo:create(duration, cc.p(x, y))
        local fade_in = cc.FadeIn:create(duration)
        local move_action = cc.EaseInOut:create(cc.Spawn:create(fade_in, move), 1.3)
        local sequence = cc.Sequence:create(cc.DelayTime:create(UI_GachaResult_Dragon100.UPDATE_CARD_SUMMON_OFFSET * (y_idx - 1)), move_action)

        card.root:setPositionY(y + move_distance)
        card.root:runAction(sequence)
	end

    local function skip_btn_visible_true()
        vars['skipBtn']:setVisible(true)
    end
    
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(UI_GachaResult_Dragon100.UPDATE_CARD_SUMMON_OFFSET * (vertical_count - 1) + 0.2), cc.CallFunc:create(skip_btn_visible_true)))
end

-------------------------------------
-- function directingLegend
-- @brief 5성 드래곤에 대한 연출, 드래곤 애니메이터 크게 화면에 띄우기
-------------------------------------
function UI_GachaResult_Dragon100:directingLegend(struct_dragon_object)
    local vars = self.vars
    
    self.m_bDirectingLegend = true
    
    local did = struct_dragon_object.did
    local t_dragon = TableDragon():get(did)
    local res_name = t_dragon['res']
    local evolution = 3
    local attr = t_dragon['attr']

    local animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
    vars['dragonMenu']:addChild(animator.m_node)

    local dragon_card = self.m_tDragonCardTable[struct_dragon_object.id]
    local pos_x = dragon_card.root:getPositionX()
    local pos_y = dragon_card.root:getPositionY()
    animator.m_node:setPositionX(pos_x)
    animator.m_node:setPositionY(pos_y)

    animator.m_node:setScale(0.2)
    local scale_start_action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.3, 1), 1.7)
    local scale_finish_action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.3, 0), 1.7)

    local function finish_cb()
        self.m_bDirectingLegend = false
        animator.m_node:removeFromParent()
    end

    local sequence = cc.Sequence:create(scale_start_action, cc.DelayTime:create(1), scale_finish_action, cc.CallFunc:create(finish_cb))
    animator.m_node:runAction(sequence)
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UI_GachaResult_Dragon100:click_skipBtn()
    if (self.m_bIsSkipping == true) then
        return
    end
    
    if (self.vars['skipBtn']:isVisible() == false) then
        return
    end

    self.m_bIsSkipping = true
    self.m_timer = UI_GachaResult_Dragon100.UPDATE_CARD_OPEN_OFFSET

    self.m_skipUpdateNode = cc.Node:create()
    self.root:addChild(self.m_skipUpdateNode)
    
    self.m_skipUpdateNode:scheduleUpdateWithPriorityLua(function(dt) return self:update_skip(dt) end, 0)
end

-------------------------------------
-- function update_skip
-------------------------------------
function UI_GachaResult_Dragon100:update_skip(dt)
    -- 연출 중에는 타이머 X
    if (self.m_bDirectingLegend) then
        return
    end
    
    self.m_timer = self.m_timer - dt
    
    if (self.m_timer <= 0) then
        for idx, t_dragon_data in ipairs(self.m_lGachaDragonList) do
            local doid = t_dragon_data['id']
            local dragon_card = self.m_tDragonCardTable[doid]

            if (dragon_card:isClose()) then
                dragon_card:openCard(true)

                if (dragon_card.m_tDragonData:getRarity() == 'legend') then
                    self.m_bDirectingLegend = true
                end

                self.m_timer = self.m_timer + UI_GachaResult_Dragon100.UPDATE_CARD_OPEN_OFFSET
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
function UI_GachaResult_Dragon100:click_closeBtn()
    if(self:isAllCardOpen()) then
        SoundMgr:playPrevBGM()
        self:close()
    else
        self:click_skipBtn()
    end
end

-------------------------------------
-- function onFocus
-- @brief 탑바가 포커싱 되었을 때
-------------------------------------
function UI_GachaResult_Dragon100:onFocus()
end

-------------------------------------
-- function registerOpenNode
-------------------------------------
function UI_GachaResult_Dragon100:registerOpenNode(lua_name)
	local node = self.vars[lua_name]
	if (node) then 
		table.insert(self.m_hideUIList, node)
	end
end