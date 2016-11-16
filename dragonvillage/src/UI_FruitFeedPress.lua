-------------------------------------
-- class UI_FruitFeedPress
-------------------------------------
UI_FruitFeedPress = class({
        m_friendshipUI = 'UI_DragonManagementFriendship',
        m_updateNode = 'cc.Node',
        m_currFruitBtn = 'button',
        m_currFruitLabel = 'label',
        m_currFruitID = 'number',
        m_blockUI = 'UI_BlockPopup',

        m_timer = 'number',

        ---
        m_fruitCount = 'number', -- 보유한 열매 갯수
        m_fruitExp = 'number', -- 열매 하나당 경험치

        m_currFExp = 'number', -- 현재 경험치
        m_currFReq = 'number', -- 레벨업까지 필요한 경험치

        m_currGold = 'number',
        m_fruitGold = 'number',

        m_feedCount = 'number', -- 열매를 준 갯수
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FruitFeedPress:init(friendship_ui)
    self.m_friendshipUI = friendship_ui

    -- update함수를 위한 노드 추가
    self.m_updateNode = cc.Node:create()
    friendship_ui.root:addChild(self.m_updateNode)

    self:resetFruitFeedPress()
end

-------------------------------------
-- function resetFruitFeedPress
-------------------------------------
function UI_FruitFeedPress:resetFruitFeedPress()
    self.m_currFruitBtn = nil
    self.m_currFruitID = nil
    self.m_timer = 0

    self.m_updateNode:unscheduleUpdate()
    
    if (self.m_blockUI) then
        self.m_blockUI:close()
    end
end


-------------------------------------
-- function fruitPressHandler
-------------------------------------
function UI_FruitFeedPress:fruitPressHandler(fruit_id, fruit_btn, fruit_label)
    if (self.m_currFruitBtn) then
        return
    end

    if (not self:checkPressAvalable(fruit_id)) then
        return
    end

    self.m_blockUI = UI_BlockPopup()

    self.m_currFruitBtn = fruit_btn
    self.m_currFruitLabel = fruit_label
    self.m_currFruitID = fruit_id

    self.m_updateNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UI_FruitFeedPress:update(dt)
    if (not self.m_currFruitBtn:isSelected()) then
        self:finishPressFeed()
        return
    end

    self.m_timer = (self.m_timer - dt)
    if (self.m_timer <= 0) then
        if self:canFeed() then
            self:feedFruit()
        else
            self:finishPressFeed()
            return
        end
        
        self.m_timer = 0.1
    end
end

-------------------------------------
-- function checkPressAvalable
-------------------------------------
function UI_FruitFeedPress:checkPressAvalable(fruit_id)
    do-- 선택된 드래곤의 친밀도가 최대치인지 확인
        local table_friendship = TableFriendship()
        local t_dragon_data = self.m_friendshipUI.m_selectDragonData
        local flv = t_dragon_data['flv']

        if table_friendship:isMaxFriendshipLevel(flv) then
            return false
        end
    end

    do-- 열매가 있는지 여부
        local count = g_userData:getFruitCount(fruit_id)
        if (count <= 0) then
            UIManager:toastNotificationRed(Str('열매가 부족하네요!!'))
            return false
        end
    end

    do-- 골드 확인
        local curr_gold = g_userData:get('gold')
        local table_fruit = TableFruit()
        local t_fruit = table_fruit:get(fruit_id)
        local req_gold = t_fruit['req_gold']

        if (curr_gold < req_gold) then
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('골드가 부족합니다.\n상점으로 이동하시겠습니까?'), openShopPopup)
            return false
        end
    end

    -- 프레스 처리를 위한 정보 초기화
    self:initPressInfo(fruit_id)

    return true
end

-------------------------------------
-- function initPressInfo
-------------------------------------
function UI_FruitFeedPress:initPressInfo(fruit_id)
    -- 보유한 열매 갯수
    self.m_fruitCount =g_userData:getFruitCount(fruit_id)
    
    -- 열매 하나당 주는 경험치
    local table_friendship = TableFriendship()
    local t_dragon_data = self.m_friendshipUI.m_selectDragonData
    local did = t_dragon_data['did']
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)
    local dragon_attr = t_dragon['attr']

    local table_fruit = TableFruit()
    local t_fruit = table_fruit:get(fruit_id)
    local fruit_attr = t_fruit['attr']

    self.m_fruitExp = t_fruit['exp']
    if (dragon_attr == fruit_attr) then
        self.m_fruitExp = (self.m_fruitExp * 1.5)
    end

    -- 드래곤의 현재 친밀도 필경
    local table_friendship = TableFriendship()
    local flv = t_dragon_data['flv']
    local t_friendship = table_friendship:get(flv)
    self.m_currFReq = t_friendship['req_exp']

    -- 드래곤의 현재 친밀도 경험치
    self.m_currFExp = t_dragon_data['fexp']

    -- 현재 골드 저장
    self.m_currGold = g_userData:get('gold')

    -- 열매 하나당 필요한 골드
    self.m_fruitGold = t_fruit['req_gold']

    self.m_feedCount = 0
end

-------------------------------------
-- function canFeed
-------------------------------------
function UI_FruitFeedPress:canFeed()
    -- 1. 열매가 있어야함
    if (self.m_fruitCount <= 0) then
        return false
    end

    -- 2. 경험치가 남아있어야함
    if (self.m_currFExp >= self.m_currFReq) then
        return false
    end

    -- 3. 골드가 있어야함
    if (self.m_currGold < self.m_fruitGold) then
        UIManager:toastNotificationRed(Str('골드가 부족합니다.'))
        return false
    end

    return true
end


-------------------------------------
-- function feedFruit
-------------------------------------
function UI_FruitFeedPress:feedFruit()
    -- 1. 골드 감소
    self.m_currGold = (self.m_currGold - self.m_fruitGold)

    -- 2. 열매 감소
    self.m_fruitCount = (self.m_fruitCount - 1)

    -- 3. 경험치 증가
    self.m_currFExp = (self.m_currFExp + self.m_fruitExp)

    -- 4. 열매를 준 갯수 카운트
    self.m_feedCount = (self.m_feedCount + 1)

    self.m_friendshipUI:feedDirecting(self.m_currFruitID, self.m_currFruitBtn)

    self:feedFruitUIRefresh()

    SoundMgr:playEffect('EFFECT', 'eat')
end

-------------------------------------
-- function feedFruitUIRefresh
-------------------------------------
function UI_FruitFeedPress:feedFruitUIRefresh()
    local vars = self.m_friendshipUI.vars

    do -- 친밀도 경험치 표시
        local cur_exp = self.m_currFExp
        local req_exp = self.m_currFReq
        vars['expLabel']:setString(Str('{1} / {2}', cur_exp, req_exp))
        local percentage = (cur_exp / req_exp) * 100
        vars['expGauge']:stopAllActions()
        vars['expGauge']:runAction(cc.ProgressTo:create(0.3, percentage))
    end

    -- 열매 갯수
    self.m_currFruitLabel:setString(comma_value(self.m_fruitCount))

    -- 남은 골드 표시
    g_topUserInfo:setGoldNumber(self.m_currGold)
end

-------------------------------------
-- function finishPressFeed
-------------------------------------
function UI_FruitFeedPress:finishPressFeed()

    -- 실제로 준 열매의 갯수가 있을 경우 통신
    if (self.m_feedCount > 0) then
        local fruit_id = self.m_currFruitID
        local count = self.m_feedCount
        self.m_friendshipUI:network_friendshipUp(fruit_id, count)
    end

    self:resetFruitFeedPress()
end