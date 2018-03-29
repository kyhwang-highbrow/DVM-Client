-------------------------------------
-- class UI_FruitFeedPress
-------------------------------------
UI_FruitFeedPress = class({
        m_friendshipUI = 'UI_DragonManagementFriendship',
        m_updateNode = 'cc.Node',
        m_currFruitBtn = 'button',
        m_currFruitLabel = 'label',
        m_currFruitID = 'number',
        m_friendshipObj = 'StructFriendshipObject',
        m_blockUI = 'UI_BlockPopup',

        m_timer = 'number',
        m_emotionTimer = 'number',

        ---
        m_fruitCount = 'number', -- 보유한 열매 갯수
        m_fruitExp = 'number', -- 열매 하나당 경험치

        m_currFeel = 'number', -- 현재 기분
        m_reqFeel = 'number', -- 레벨업까지 필요한 기분

        m_feedCount = 'number', -- 열매를 준 갯수
        m_feedCount120p = 'number',
        m_feedCount150p = 'number',

        m_block = 'boolean',
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
    self.m_emotionTimer = 0

    self.m_updateNode:unscheduleUpdate()
    
    if (self.m_blockUI) then
        self.m_blockUI:close()
    end
end


-------------------------------------
-- function fruitPressHandler
-------------------------------------
function UI_FruitFeedPress:fruitPressHandler(fruit_id, fruit_btn, fruit_label)
    if (self.m_block) then
        return
    end

    if (self.m_currFruitBtn) then
        return
    end

    self.m_friendshipObj = self.m_friendshipUI.m_selectDragonData:getFriendshipObject()

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

    self.m_emotionTimer = (self.m_emotionTimer - dt)
    if (self.m_emotionTimer <= 0) then
        self.m_friendshipUI:showEmotionEffect()
        self.m_emotionTimer = 2.5
    end
end

-------------------------------------
-- function checkPressAvalable
-- @brief
-------------------------------------
function UI_FruitFeedPress:checkPressAvalable(fruit_id)
    do-- 선택된 드래곤의 친밀도가 최대치인지 확인
        if self.m_friendshipObj:isMaxFriendshipLevel() then
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

    -- 프레스 처리를 위한 정보 초기화
    self:initPressInfo(fruit_id)

    return true
end

-------------------------------------
-- function initPressInfo
-------------------------------------
function UI_FruitFeedPress:initPressInfo(fruit_id)
    -- 보유한 열매 갯수
    self.m_fruitCount = g_userData:getFruitCount(fruit_id)

    local t_friendship_info = self.m_friendshipObj:getFriendshipInfo()

    -- 기분업까지 필요한 feel -> max_exp로 변경
    self.m_reqFeel = t_friendship_info['max_exp']

    -- 드래곤의 현재 feel -> exp로 변경
    self.m_currFeel = self.m_friendshipObj['fexp']

    self.m_feedCount = 0
    self.m_feedCount120p = 0
    self.m_feedCount150p = 0
end

-------------------------------------
-- function canFeed
-------------------------------------
function UI_FruitFeedPress:canFeed()
    -- 1. 열매가 있어야함
    if (self.m_fruitCount <= 0) then
        return false
    end

    -- 2. 기분이 남아있어야함
    if (self.m_currFeel >= self.m_reqFeel) then
        return false
    end

    return true
end


-------------------------------------
-- function feedFruit
-------------------------------------
function UI_FruitFeedPress:feedFruit()
    -- 2. 열매 감소
    self.m_fruitCount = (self.m_fruitCount - 1)

    local feel, emoji = self.m_friendshipObj:makeFeelUpInfo(self.m_currFruitID)

    -- 3. 경험치 증가
    self.m_currFeel = (self.m_currFeel + feel)

    -- 4. 열매를 준 갯수 카운트
    if (emoji == '100p') then
        self.m_feedCount = (self.m_feedCount + 1)
    elseif (emoji == '120p') then
        self.m_feedCount120p = (self.m_feedCount120p + 1)
    elseif (emoji == '150p') then
        self.m_feedCount150p = (self.m_feedCount150p + 1)
    else
        error('emoji : ' .. emoji)
    end

    self.m_friendshipUI:feedDirecting(self.m_currFruitID, self.m_currFruitBtn)

    self:feedFruitUIRefresh()
end

-------------------------------------
-- function feedFruitUIRefresh
-------------------------------------
function UI_FruitFeedPress:feedFruitUIRefresh()
    local vars = self.m_friendshipUI.vars

    do -- 드래곤 기분 UI 갱신
        local percentage = (self.m_currFeel / self.m_reqFeel) * 100
        percentage = math_clamp(percentage, 0, 100)
        local b_init = false
        self.m_friendshipUI:setHeartGauge(percentage, b_init)
    end

    -- 열매 갯수
    self.m_currFruitLabel:setNumber(self.m_fruitCount)
end

-------------------------------------
-- function finishPressFeed
-------------------------------------
function UI_FruitFeedPress:finishPressFeed()

    -- 실제로 준 열매의 갯수가 있을 경우 통신
    if (self.m_feedCount > 0) or (self.m_feedCount120p > 0) or (self.m_feedCount150p > 0) then
        local fid = self.m_currFruitID
        local fcnt = self.m_feedCount
        local fcnt_120p = self.m_feedCount120p
        local fcnt_150p = self.m_feedCount150p
        self.m_friendshipUI:pressProcess(fid, fcnt, fcnt_120p, fcnt_150p)
    end

    self:resetFruitFeedPress()
end