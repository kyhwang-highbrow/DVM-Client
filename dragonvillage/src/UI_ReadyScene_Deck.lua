-------------------------------------
-- class UI_ReadyScene_Deck
-------------------------------------
UI_ReadyScene_Deck = class({
        m_uiReadyScene = 'UI_ReadyScene',
        m_focusDeckSlotEffect = 'cc.Sprite',
        m_focusDeckSlot = 'number', -- 다음에 설정할 덱


        -- slot idx, dragon object id
        m_lDeckList = 'table',
        m_tDeckMap = 'tabke',

        --
        m_lSettedDragonCard = 'list',
        m_currFormation = '',
        m_radioButtonFormation = '',

        -- 드래그로 이동
        m_selectedDragonSlotIdx = 'number',
        m_selectedDragonCard = 'UI_DragonCard',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadyScene_Deck:init(ui_ready_scene)
    self.m_uiReadyScene = ui_ready_scene

    self:init_button()
    self:init_deck()
    self:makeTouchLayer_formation(self.m_uiReadyScene.vars['formationNode'])
end

-------------------------------------
-- function init_button
-------------------------------------
function UI_ReadyScene_Deck:init_button()
    local vars = self.m_uiReadyScene.vars

    for i=1, 9 do
        local btn_name = 'chBtn' .. string.format('%.2d', i)
        if vars[btn_name] then
            vars[btn_name]:registerScriptTapHandler(function() self:click_chBtn(i) end)
            vars[btn_name]:setEnabled(false) -- 드래그로 개편
        end
    end

    -- 진형 선택 버튼
    local radio_button = UIC_RadioButton()
    self.m_radioButtonFormation = radio_button
    radio_button:addButton('attack', vars['aFomationBtn'], vars['aFomationUseSprite'], function() self:setFormation('attack') end)
    radio_button:addButton('balance', vars['bFomationBtn'], vars['bFomationUseSprite'], function() self:setFormation('balance') end)
    radio_button:addButton('defence', vars['cFomationBtn'], vars['cFomationUseSprite'], function() self:setFormation('defence') end)
    radio_button:addButton('protect', vars['dFomationBtn'], vars['dFomationUseSprite'], function() self:setFormation('protect') end)
end

-------------------------------------
-- function click_chBtn
-------------------------------------
function UI_ReadyScene_Deck:click_chBtn(idx)
    self:setFocusDeckSlotEffect(idx)
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_ReadyScene_Deck:click_dragonCard(t_dragon_data)
    local doid = t_dragon_data['id']

    if self.m_tDeckMap[doid] then
        local idx = self.m_tDeckMap[doid]
        self:setSlot(idx, nil)
        self:setFocusDeckSlotEffect(idx)
    else
        self:setSlot(self.m_focusDeckSlot, doid)
    end

    self:refreshFocusDeckSlot()
end

-------------------------------------
-- function getFocusDeckSlotEffect
-- @brief 포커싱된 슬롯의 이펙트 생성
-------------------------------------
function UI_ReadyScene_Deck:getFocusDeckSlotEffect()
    if (not self.m_focusDeckSlotEffect) then
        self.m_focusDeckSlotEffect = cc.Sprite:create('res/ui/frame/dragon_select_frame.png')
        self.m_focusDeckSlotEffect:setDockPoint(cc.p(0.5, 0.5))
        self.m_focusDeckSlotEffect:setAnchorPoint(cc.p(0.5, 0.5))
    end

    self.m_focusDeckSlotEffect:retain()
    return self.m_focusDeckSlotEffect
end

-------------------------------------
-- function refreshFocusDeckSlot
-- @brief
-------------------------------------
function UI_ReadyScene_Deck:refreshFocusDeckSlot()
    local count = table.count(self.m_tDeckMap)
    if (count >= 5) then
        return
    end

    -- 가장 빠른 slot으로 설정
    local idx = 1
    for i=1, 9 do
        if (not self.m_lDeckList[i]) then
            idx = i
            break
        end
    end

    if (self.m_focusDeckSlot == idx) then
        return
    end

    self:setFocusDeckSlotEffect(idx)
end

-------------------------------------
-- function setFocusDeckSlotEffect
-- @brief 포커싱된 슬롯의 이펙트 설정
-------------------------------------
function UI_ReadyScene_Deck:setFocusDeckSlotEffect(idx)
    local vars = self.m_uiReadyScene.vars

    local effect = self:getFocusDeckSlotEffect()
    effect:removeFromParent()

    local node_name = 'chNode' .. idx
    vars[node_name]:addChild(effect, 2)
    effect:release()

    effect:stopAllActions()
    effect:setOpacity(255)
    effect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 255))))

    self.m_focusDeckSlot = idx
end

-------------------------------------
-- function clear_deck
-------------------------------------
function UI_ReadyScene_Deck:clear_deck()
    do -- UI 정리
        if self.m_lSettedDragonCard then
            for _,ui in pairs(self.m_lSettedDragonCard) do
                ui.root:removeFromParent()
            end
        end
        self.m_lSettedDragonCard = {}
    end

    local l_refresh_dragon_doid = clone(self.m_lDeckList)

    self.m_lDeckList = {}
    self.m_tDeckMap = {}

    -- 드래곤 인벤의 카드 갱신을 위해 호출
    for _,doid in  pairs(l_refresh_dragon_doid) do
        self:refresh_dragonCard(doid)
    end

    self:setFocusDeckSlotEffect(1)

    -- 즉시 정렬
    if self.m_uiReadyScene.m_dragonSortMgr then
        self.m_uiReadyScene.m_dragonSortMgr:changeSort()
    end
end

-------------------------------------
-- function init_deck
-------------------------------------
function UI_ReadyScene_Deck:init_deck()
    do -- UI 정리
        if self.m_lSettedDragonCard then
            for _,ui in pairs(self.m_lSettedDragonCard) do
                ui.root:removeFromParent()
            end
        end
        self.m_lSettedDragonCard = {}
    end

    local l_deck, formation = g_deckData:getDeck()
    l_deck = self:convertSimpleDeck(l_deck)

    self.m_lDeckList = {}
    self.m_tDeckMap = {}

    for idx,doid in pairs(l_deck) do
        local skip_sort = true
        self:setSlot(idx, doid, skip_sort)
    end

    -- focus deck
    self:refreshFocusDeckSlot()

    self:setFormation(formation)

    self.m_radioButtonFormation:setSelectedButton(formation)
end

-------------------------------------
-- function convertSimpleDeck
-- @brief 기존 1~9번의 index를 쓰던 것에서 1~5만 사용하는 것으로 변경
-------------------------------------
function UI_ReadyScene_Deck:convertSimpleDeck(l_deck)
    -- 변경이 필요한지 체크
    local need_convert = false
    for idx, doid in pairs(l_deck) do
        if (tonumber(idx) > 5) then
            need_convert = true
            break
        end
    end

    -- 변경이 필요 없으면 기존 덱 리턴
    if (not need_convert) then
        return l_deck
    end

    -- 정렬을 위한 임시 테이블 셋팅
    local l_deck_for_sort = {}
    for idx, doid in pairs(l_deck) do
        table.insert(l_deck_for_sort, {idx=idx, doid=doid})
    end

    -- idx가 낮은 순으로 정렬
    local function sort_func(a, b)
        return a['idx'] < b['idx']
    end
    table.sort(l_deck_for_sort, sort_func)

    -- 리턴할 덱 생성
    local l_deck = {}
    for i,v in ipairs(l_deck_for_sort) do
        l_deck[i] = v['doid']
    end

    return l_deck
end

-------------------------------------
-- function makeSettedDragonCard
-- @breif
-------------------------------------
function UI_ReadyScene_Deck:makeSettedDragonCard(t_dragon_data, idx)
    local vars = self.m_uiReadyScene.vars

    local ui = UI_DragonCard(t_dragon_data)

    cca.uiReactionSlow(ui.root, 1, 1, 0.7)
    
    
    -- 설정된 드래곤 표시 없애기
    ui:setReadySpriteVisible(false)

    vars['chNode' .. idx]:addChild(ui.root)

    self.m_lSettedDragonCard[idx] = ui

    ui.vars['clickBtn']:setEnabled(false) -- 드래그로 개편
    ui.vars['clickBtn']:registerScriptTapHandler(function()
        self:click_dragonCard(t_dragon_data)
    end)

    -- 장착된 드래곤
    self:refresh_dragonCard(t_dragon_data['id'])

    -- 상성
    local dragon_attr = TableDragon():getValue(t_dragon_data['did'], 'attr')
    local stage_attr = self.m_uiReadyScene.m_stageAttr
    ui:setAttrSynastry(getCounterAttribute(dragon_attr, stage_attr))
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 카드 갱신
-------------------------------------
function UI_ReadyScene_Deck:refresh_dragonCard(doid)
    local item = self.m_uiReadyScene.m_tableViewExt.m_itemMap[doid]
    local is_setted = self.m_tDeckMap[doid]

    if (not item) then
        return
    end

    local ui = item['ui']

    if (not ui) then
        return
    end

    cca.uiReactionSlow(ui.root, 0.7, 0.7, 0.7 * 0.7)

    if is_setted then
        ui:setReadySpriteVisible(true)
    else
        ui:setReadySpriteVisible(false)
    end
end

-------------------------------------
-- function setSlot
-------------------------------------
function UI_ReadyScene_Deck:setSlot(idx, doid, skip_sort)

    do -- 갯수 체크
        local count = table.count(self.m_tDeckMap)
        if self.m_lDeckList[idx] then
            count = (count - 1)
        end
        if (count >= 5) then
            UIManager:toastNotificationRed('5명까지 출전할 수 있습니다.')
            return
        end
    end


    -- 설정되어 있는 덱 해제
    if self.m_lDeckList[idx] then
        local prev_doid = self.m_lDeckList[idx]
        local prev_idx = self.m_tDeckMap[prev_doid]

        self.m_lDeckList[prev_idx] = nil
        self.m_tDeckMap[prev_doid] = nil

        -- 설정된 드래곤의 카드 삭제
        if self.m_lSettedDragonCard[prev_idx] then
            self.m_lSettedDragonCard[prev_idx].root:removeFromParent()
            self.m_lSettedDragonCard[prev_idx] = nil
        end

        -- 드래곤 리스트 갱신
        self:refresh_dragonCard(prev_doid)
    end

    -- 새롭게 생성
    if doid then
        self.m_lDeckList[idx] = doid
        self.m_tDeckMap[doid] = idx

        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        self:makeSettedDragonCard(t_dragon_data, idx)
    end

    -- 즉시 정렬
    if (not skip_sort) and self.m_uiReadyScene.m_dragonSortMgr then
        self.m_uiReadyScene.m_dragonSortMgr:changeSort()
    end
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_ReadyScene_Deck:checkChangeDeck(next_func)
    local l_deck, formation, deckname = g_deckData:getDeck()

    local b_change = false

    for i=1, 9 do
        -- 기존 드래곤이 해제된 경우
        if (l_deck[i] and (not self.m_lDeckList[i])) then
            b_change = true
            break
        end

        -- 기존 드래곤이 변경된 경우
        if l_deck[i] and (l_deck[i] ~= self.m_lDeckList[i]) then
            b_change = true
            break
        end

        -- 새로운 드래곤이 설정된 경우
        if (not l_deck[i] and (self.m_lDeckList[i])) then
            b_change = true
            break
        end
    end

    -- 진형이 변경되었을 경우
    if (self.m_currFormation ~= formation) then
        b_change = true
    end

    if (b_change) then
        local uid = g_userData:get('uid')

        local function success_cb(ret)
            if ret['deck'] then
                local ret_deck = ret['deck']
                local t_deck = ret_deck['deck']
                local deckname = ret_deck['deckname']

                g_deckData:setDeck(deckname, ret_deck)
            end
            next_func()
        end

        local ui_network = UI_Network()
        ui_network:setUrl('/users/set_deck')
        ui_network:setHmac(false)
        ui_network:setRevocable(true)
        ui_network:setParam('uid', uid)
        ui_network:setParam('deckname', deckname)
        ui_network:setParam('formation', self.m_currFormation)
        ui_network:setParam('edoid1', self.m_lDeckList[1] and self.m_lDeckList[1] or nil)
        ui_network:setParam('edoid2', self.m_lDeckList[2] and self.m_lDeckList[2] or nil)
        ui_network:setParam('edoid3', self.m_lDeckList[3] and self.m_lDeckList[3] or nil)
        ui_network:setParam('edoid4', self.m_lDeckList[4] and self.m_lDeckList[4] or nil)
        ui_network:setParam('edoid5', self.m_lDeckList[5] and self.m_lDeckList[5] or nil)
        ui_network:setParam('edoid6', self.m_lDeckList[6] and self.m_lDeckList[6] or nil)
        ui_network:setParam('edoid7', self.m_lDeckList[7] and self.m_lDeckList[7] or nil)
        ui_network:setParam('edoid8', self.m_lDeckList[8] and self.m_lDeckList[8] or nil)
        ui_network:setParam('edoid9', self.m_lDeckList[9] and self.m_lDeckList[9] or nil)
        ui_network:setSuccessCB(success_cb)
        ui_network:request()
    else
        next_func()
    end
end

-------------------------------------
-- function getDragonCount
-------------------------------------
function UI_ReadyScene_Deck:getDragonCount()
    local count = table.count(self.m_lDeckList)
    return count
end

-------------------------------------
-- function setFormation
-------------------------------------
function UI_ReadyScene_Deck:setFormation(formation)
    if (self.m_currFormation == formation) then
        return
    end

    local update_immediately = false
    if (not self.m_currFormation) then
        update_immediately = true
    end

    self.m_currFormation = formation
    self:updateFormation(formation, update_immediately)
end

-------------------------------------
-- function updateFormation
-------------------------------------
function UI_ReadyScene_Deck:updateFormation(formation, immediately)
    local vars = self.m_uiReadyScene.vars

    local min_x = -122
    local max_x = 122
    local min_y = -122
    local max_y = 122
    local l_pos_list = TableFormation:getFormationPositionList(formation, min_x, max_x, min_y, max_y)

    local table_formation = TableFormation()

    if immediately then
        for i,v in ipairs(l_pos_list) do
            vars['chNode' .. i]:setPosition(v['x'], v['y'])
        end
    else
        for i,v in ipairs(l_pos_list) do
            local action = cca.makeBasicEaseMove(0.3, v['x'], v['y'])
            cca.runAction(vars['chNode' .. i], action, 100)
        end
    end

    do -- 진형 아이콘
        local node = vars['fomationIconNode']
        node:removeAllChildren()
        local icon = table_formation:makeFormationIcon(formation)
        cca.uiReaction(icon, scale_x, scale_y)
        node:addChild(icon)
    end

    -- 진형 이름
    local t_formation = table_formation:get(formation)
    vars['fomationLabel']:setString(Str(t_formation['t_name']))

    -- 버프 설명
    local l_buff_str = table_formation:getBuffStrList(formation)
    for i=1, 10 do
        local node = vars['fomationdscLabel' .. i]
        local t_data = l_buff_str[i]
        if (node and t_data) then
            local str = t_data['str']
            node:setString(str)

            --local out_line_size = node:getOutlineSize()
            local out_line_size = 1
            local color_str = t_data['color']
            local color = COLOR_4[color_str]
            node:enableOutline(color)
            node:enableShadow(color)

        elseif (node) then
            node:setString('')
        else
            break
        end
    end
end





-------------------------------------
-- function makeTouchLayer
-- @brief 터치 레이어 생성
-------------------------------------
function UI_ReadyScene_Deck:makeTouchLayer_formation(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
    --listener:setSwallowTouches(false)
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function UI_ReadyScene_Deck:onTouchBegan(touch, event)
    local vars = self.m_uiReadyScene.vars
    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['formationNode']:getBoundingBox()
    local local_location = vars['formationNode']:getParent():convertToNodeSpace(location)
    local is_contain = cc.rectContainsPoint(bounding_box, local_location)
    if (not is_contain) then
        return false
    end

    -- 버튼 체크
    local select_idx = nil
    for i=1, 5 do
        local btn_name = 'chNode' .. string.format('%d', i)
        local btn_bounding_box = vars[btn_name]:getBoundingBox()

        local local_location = vars['formationNode']:convertToNodeSpace(location)
        local is_contain = cc.rectContainsPoint(btn_bounding_box, local_location)

        if (is_contain == true) then
            select_idx = i
            break
        end
    end

    if (not select_idx) then
        --cclog('선택된 슬롯 없음')
        return false
    end

    if (not self.m_lDeckList[select_idx]) then
        --cclog('비어있는 슬롯 ' .. select_idx)
        self:click_chBtn(select_idx)
        return false
    end

    do -- 드래곤 선택
        self.m_selectedDragonSlotIdx = select_idx
        self.m_selectedDragonCard = self.m_lSettedDragonCard[select_idx]

        local node = self.m_selectedDragonCard.root
        node:setScale(0.7)

        local local_pos = convertToAnoterParentSpace(node, vars['formationNode'])
        node:setPosition(local_pos['x'], local_pos['y'])

        -- root로 옮김
        node:retain()
        node:removeFromParent()
        vars['formationNode']:addChild(node)
        node:release()
    end

    return true
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function UI_ReadyScene_Deck:onTouchMoved(touch, event)
    self:moveSelectDragonCard(touch, event)
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function UI_ReadyScene_Deck:onTouchEnded(touch, event)
    self:moveSelectDragonCard(touch, event)

    local vars = self.m_uiReadyScene.vars
    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['formationNode']:getBoundingBox()
    local local_location = vars['formationNode']:getParent():convertToNodeSpace(location)
    local is_contain = cc.rectContainsPoint(bounding_box, local_location)
    if (not is_contain) then
        
        -- 장착 해제
        local doid = self.m_lDeckList[self.m_selectedDragonSlotIdx]
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        self:click_dragonCard(t_dragon_data)

        return false
    end


    -- 가장 가까운 버튼 찾기
    local near_idx = nil
    local near_distance = nil
    local local_location = convertToNodeSpace(vars['formationNode'], location)
    for i=1, 5 do
        local btn_name = 'chNode' .. string.format('%d', i)
        local slot_pos_x, slot_pos_y = vars[btn_name]:getPosition()

        local distance = getDistance(slot_pos_x, slot_pos_y, local_location['x'], local_location['y'])

        if (near_distance == nil) or (distance < near_distance) then
            near_distance = distance
            near_idx = i
        end
    end

    -- 같은 자리일 경우
    if (near_idx == self.m_selectedDragonSlotIdx) then
        local node = self.m_selectedDragonCard.root
        node:setScale(1)
        node:setPosition(0, 0)

        -- root로 옮김
        node:retain()
        node:removeFromParent()
        vars['chNode' .. near_idx]:addChild(node)
        node:release()

        self:setFocusDeckSlotEffect(self.m_selectedDragonSlotIdx)
    else
        local near_idx_doid = self.m_lDeckList[self.m_selectedDragonSlotIdx]
        local selected_idx_doid = self.m_lDeckList[near_idx]

        -- 둘 다 해제
        self:setSlot(near_idx, nil)
        self:setSlot(self.m_selectedDragonSlotIdx, nil)

        -- 다시 입력
        self:setSlot(near_idx, near_idx_doid)
        self:setSlot(self.m_selectedDragonSlotIdx, selected_idx_doid)

        self:refreshFocusDeckSlot()
    end
end

-------------------------------------
-- function moveSelectDragonCard
-------------------------------------
function UI_ReadyScene_Deck:moveSelectDragonCard(touch, event)
    local vars = self.m_uiReadyScene.vars
    
    local location = touch:getLocation()
    local local_location = convertToNodeSpace(vars['formationNode'], location)

    local node = self.m_selectedDragonCard.root
    node:setPosition(local_location['x'], local_location['y'])
end