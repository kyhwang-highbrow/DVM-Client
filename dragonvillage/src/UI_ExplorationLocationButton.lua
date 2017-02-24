local PARENT = UI

-------------------------------------
-- class UI_ExplorationLocationButton
-------------------------------------
UI_ExplorationLocationButton = class(PARENT,{
        m_eprID = '',
        m_status = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationLocationButton:init(epr_id)
    self.m_eprID = epr_id

    local vars = self:load('exploration_map_list.ui')

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

    -- 지역 순서
    vars['orderLabel']:setString(Str(location_info['order']))

    -- 지역 이름
    vars['locationLabel']:setString(Str(location_info['t_name']))
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

    self.m_status = status

    self.root:unscheduleUpdate()

    -- 아래에서 필요한 상태에 따라 true
    vars['lockSprite']:setVisible(false)
    vars['ingNode']:setVisible(false)
    vars['completeNode']:setVisible(false)

    if (status == 'exploration_idle') then
        

    elseif (status == 'exploration_lock') then
        vars['lockLabel']:setString(Str('레벨 {1}', location_info['open_condition']))
        vars['lockSprite']:setVisible(true)

    elseif (status == 'exploration_ing') then
        vars['ingNode']:setVisible(true)

    elseif (status == 'exploration_complete') then
        vars['completeNode']:setVisible(true)
    end

    -- 시간 업데이트
    if (status == 'exploration_ing') then
        local function update(dt)
            self:update(dt)
        end
        self.root:scheduleUpdateWithPriorityLua(update, 0)
        self:update(0)
    end
end

-------------------------------------
-- function update
-- @brief exploration_ing 상태에서만 업데이트됨
-------------------------------------
function UI_ExplorationLocationButton:update(dt)
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    local end_time = (my_location_info['end_time'] / 1000)
    local server_time = Timer:getServerTime()
    local remain_time = (end_time - server_time)

    if remain_time > 0 then
        local time_str = datetime.makeTimeDesc(remain_time, true)
        vars['timeLabel']:setString(time_str)
    else
        self.m_status = 'exploration_complete'
        vars['ingNode']:setVisible(false)
        vars['completeNode']:setVisible(true)
        self.root:unscheduleUpdate()
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
        local message = Str('[{1}]은(는) 테이머레벨 {2}이상이 되어야 입장할 수 있습니다.', Str(location), open_condition)
        UIManager:toastNotificationRed(message)

    elseif (self.m_status == 'exploration_idle') then
        local ui = UI_ExplorationReady(self.m_eprID)
        ui:setCloseCB(function() self:refresh() end)

    elseif (self.m_status == 'exploration_ing') or (self.m_status == 'exploration_complete') then
        local ui = UI_ExplorationIng(self.m_eprID)
        ui:setCloseCB(function() self:refresh() end)
    end

end

--@CHECK
UI:checkCompileError(UI_ExplorationLocationButton)
