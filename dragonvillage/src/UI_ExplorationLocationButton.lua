-------------------------------------
-- class UI_ExplorationLocationButton
-------------------------------------
UI_ExplorationLocationButton = class({
        vars = '',
        m_eprID = '',
        m_status = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationLocationButton:init(owner, epr_id)
    self.vars = owner.vars
    self.m_eprID = epr_id

    do -- owner UI로부터 vars를 가져옴
        -- 탐험 지역의 idx를 얻어옴
        local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)
        local location_idx = location_info['order']

        -- owner UI에서 idx가 붙어있는 항목 리스트업
        local t_change_list = {}
        table.insert(t_change_list, 'locationMenu')
        table.insert(t_change_list, 'mapLockSprite')
        table.insert(t_change_list, 'lockSprite')
        table.insert(t_change_list, 'mapLockSprite')
        table.insert(t_change_list, 'completeSprite')
        table.insert(t_change_list, 'explorationLabel')
        table.insert(t_change_list, 'timeLabel')
        table.insert(t_change_list, 'timeNode')
        table.insert(t_change_list, 'clickBtn')
        table.insert(t_change_list, 'dragonNode')
        

        -- self의 vars에 지역 idx를 제거한 형태로 저장
        self.vars = {}
        for i,v in ipairs(t_change_list) do
            self.vars[v] = owner.vars[v .. location_idx]
        end
    end

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExplorationLocationButton:initUI()
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    local order_num = location_info['order']
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationLocationButton:initButton()
    local vars = self.vars
    vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationLocationButton:refresh()
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)
    local location_idx = location_info['order']

    self.m_status = status

    vars['locationMenu']:unscheduleUpdate()

    -- 아래에서 필요한 상태에 따라 true
    vars['lockSprite']:setVisible(false)
    vars['mapLockSprite']:setVisible(false)
    vars['completeSprite']:setVisible(false)
    vars['timeNode']:setVisible(false)
    vars['explorationLabel']:setColor(cc.c3b(255, 255, 255))

    if (status == 'exploration_idle') then
        vars['explorationLabel']:setString(Str('탐험 준비'))

    elseif (status == 'exploration_lock') then
        vars['explorationLabel']:setString(Str('레벨 {1}', location_info['open_condition']))
        vars['lockSprite']:setVisible(true)
        vars['mapLockSprite']:setVisible(true)

    elseif (status == 'exploration_ing') then
        vars['explorationLabel']:setString(Str('탐험 중'))
        vars['timeNode']:setVisible(true)

    elseif (status == 'exploration_complete') then
        vars['explorationLabel']:setString(Str('탐험 완료'))
        vars['explorationLabel']:setColor(cc.c3b(255, 216, 0))
        vars['completeSprite']:setVisible(true)
    end

    -- 시간 업데이트
    if (status == 'exploration_ing') then
        local function update(dt)
            self:update(dt)
        end
        vars['locationMenu']:scheduleUpdateWithPriorityLua(update, 0)
        self:update(0)
    end

    -- 드래곤 실 리소스 생성
    vars['dragonNode']:removeAllChildren()
    if isExistValue(status, 'exploration_ing', 'exploration_complete') then
        local doid = my_location_info['doid_list'][1]
        local animator = g_dragonsData:getDragonAnimator(doid)
        local struct_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

        if (struct_dragon_data) then
            local animator = AnimatorHelper:makeDragonAnimatorByTransform(struct_dragon_data)
            if (animator) then
                vars['dragonNode']:addChild(animator.m_node)
            end
        end
    end
end

-------------------------------------
-- function update
-- @brief exploration_ing 상태에서만 업데이트됨
-------------------------------------
function UI_ExplorationLocationButton:update(dt)
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)
    local location_idx = location_info['order']

    local end_time = (my_location_info['end_time'] / 1000)
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local remain_time = (end_time - server_time)

    if remain_time > 0 then
        local time_str = datetime.makeTimeDesc(remain_time, true)
        vars['timeLabel']:setString(time_str)
    else
        self.m_status = 'exploration_complete'
        self:refresh()
        vars['locationMenu']:unscheduleUpdate()
    end
end

-------------------------------------
-- function click_clickBtn
-- @brief
-------------------------------------
function UI_ExplorationLocationButton:click_clickBtn()
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    if (self.m_status == 'exploration_lock') then
        local location = location_info['t_name']
        local open_condition = location_info['open_condition']
        local message = Str('[{1}](은)는 테이머레벨 {2}이상이 되어야 입장할 수 있습니다.', Str(location), open_condition)
        UIManager:toastNotificationRed(message)

    elseif (self.m_status == 'exploration_idle') then
        local ui = UI_ExplorationReady(self.m_eprID)
        local function close_cb()
            self:refresh()
            if (ui.m_bActive) then
                self:click_clickBtn()
            end
        end
        ui:setCloseCB(close_cb)

    elseif (self.m_status == 'exploration_ing') then
        local ui = UI_ExplorationIng(self.m_eprID)
        ui:setCloseCB(function() self:refresh() end)

    elseif (self.m_status == 'exploration_complete') then
        local function finish_cb(ret)
            local ui = UI_ExplorationResultPopup(self.m_eprID, ret)
            ui:setCloseCB(function() self:refresh() end)
        end

        local epr_id = self.m_eprID
        g_explorationData:request_explorationReward(epr_id, finish_cb)
    end

end

--@CHECK
UI:checkCompileError(UI_ExplorationLocationButton)
