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
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadyScene_Deck:init(ui_ready_scene)
    self.m_uiReadyScene = ui_ready_scene

    self:init_deck()
    self:init_button()
end

-------------------------------------
-- function init_button
-------------------------------------
function UI_ReadyScene_Deck:init_button()
    local vars = self.m_uiReadyScene.vars

    for i=1, 9 do
        local btn_name = 'chBtn' .. string.format('%.2d', i)
        vars[btn_name]:registerScriptTapHandler(function() self:click_chBtn(i) end)
    end
end

-------------------------------------
-- function click_chBtn
-------------------------------------
function UI_ReadyScene_Deck:click_chBtn(idx)
    local vars = self.m_uiReadyScene.vars
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

    self.m_lDeckList = {}
    self.m_tDeckMap = {}

    self:setFocusDeckSlotEffect(1)
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

    local l_deck = g_deckData:getDeck('1')

    self.m_lDeckList = {}
    self.m_tDeckMap = {}

    for idx,doid in pairs(l_deck) do
        self:setSlot(idx, doid)
    end

    
    do -- 가장 빠른 slot으로 설정
        local idx = 1
        for i=1, 9 do
            if self.m_lDeckList[i] then
                idx = i
                break
            end
        end
        self:setFocusDeckSlotEffect(idx)
    end
end

-------------------------------------
-- function makeSettedDragonCard
-- @breif
-------------------------------------
function UI_ReadyScene_Deck:makeSettedDragonCard(t_dragon_data, idx)
    local vars = self.m_uiReadyScene.vars

    local ui = UI_DragonCard(t_dragon_data)
    
    -- 설정된 드래곤 표시 없애기
    ui:setCheckSettedDragonFunc(function() return false end)
    ui:setReadySpriteVisible(false)

    vars['chNode' .. idx]:addChild(ui.root)

    self.m_lSettedDragonCard[idx] = ui

    ui.vars['clickBtn']:registerScriptTapHandler(function()
        self:click_dragonCard(t_dragon_data)
    end)

    -- 장착된 드래곤
    self:refresh_dragonCard(t_dragon_data['id'])
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 카드 갱신
-------------------------------------
function UI_ReadyScene_Deck:refresh_dragonCard(doid)
    local item = self.m_uiReadyScene.m_tableViewExt.m_mapItem[doid]
    local is_setted = self.m_tDeckMap[doid]

    if (not item) then
        return
    end

    local ui = item['ui']

    if (not ui) then
        return
    end

    if is_setted then
        ui:setReadySpriteVisible(true)
    else
        ui:setReadySpriteVisible(false)
    end
end

-------------------------------------
-- function setSlot
-------------------------------------
function UI_ReadyScene_Deck:setSlot(idx, doid)

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
        self:refresh_dragonCard(doid)
    end

    do -- 5명이사이 되는지 확인 후 disableSprite로 표시
        local node = self.m_uiReadyScene.vars['disableSprite']
        local count = table.count(self.m_tDeckMap)
        if (count < 5) then
            node:setVisible(false)
        else
            node:setVisible(true)
            node:stopAllActions()
            node:setOpacity(0)
            node:runAction(cc.FadeIn:create(0.15))
        end
    end
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_ReadyScene_Deck:checkChangeDeck(next_func)
    local l_deck = g_deckData:getDeck('1')

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

    if (b_change) then
        local uid = g_userData:get('uid')

        local function success_cb(ret)
            if ret['deck'] then
                g_serverData:applyServerData(ret['deck'], 'deck')
            end
            next_func()
        end

        local ui_network = UI_Network()
        ui_network:setUrl('/users/set_deck')
        ui_network:setHmac(false)
        ui_network:setRevocable(true)
        ui_network:setParam('uid', uid)
        ui_network:setParam('deckno', 1)
        ui_network:setParam('edid1', self.m_lDeckList[1] and self.m_lDeckList[1] or nil)
        ui_network:setParam('edid2', self.m_lDeckList[2] and self.m_lDeckList[2] or nil)
        ui_network:setParam('edid3', self.m_lDeckList[3] and self.m_lDeckList[3] or nil)
        ui_network:setParam('edid4', self.m_lDeckList[4] and self.m_lDeckList[4] or nil)
        ui_network:setParam('edid5', self.m_lDeckList[5] and self.m_lDeckList[5] or nil)
        ui_network:setParam('edid6', self.m_lDeckList[6] and self.m_lDeckList[6] or nil)
        ui_network:setParam('edid7', self.m_lDeckList[7] and self.m_lDeckList[7] or nil)
        ui_network:setParam('edid8', self.m_lDeckList[8] and self.m_lDeckList[8] or nil)
        ui_network:setParam('edid9', self.m_lDeckList[9] and self.m_lDeckList[9] or nil)
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