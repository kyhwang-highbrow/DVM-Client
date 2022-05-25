local PARENT = UI_ManagedButton 

-------------------------------------
-- class UI_ButtonPersonalpack
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonPersonalpack = class(PARENT, {
        m_ppid = 'number',
        m_endTime = 'timestamp',
    })

local kGruop = 'monthly_123'
-------------------------------------
-- function init
-------------------------------------
function UI_ButtonPersonalpack:init()
    -- Personalpack 범용적으로 사용하도록 UI가 나오고 있지는 않다. 나중에 수정이 필요함
    self:load('button_monthly_begin.ui')

    -- 버튼 설정
    local btn = self.vars['btn']
    if btn then
        btn:registerScriptTapHandler(function() self:click_btn() end)
    end

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonPersonalpack:isActive()
    if (self.m_ppid == nil) then
        return false
    else
        return g_personalpackData:isGroupActive(kGruop) and not g_personalpackData:isBuyAll(self.m_ppid)
    end
end

-------------------------------------
-- function click_btn
-- @brief 버튼 클릭
-------------------------------------
function UI_ButtonPersonalpack:click_btn()
    require('UI_Package_Personalpack')
    local ui = UI_Package_Personalpack(self.m_ppid)

    local function close_cb()
        -- 보급소 내에서 상품 상태 변경 시 notiSprite상태 갱신을 위해 호출
        self:callDirtyStatusCB()
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function update
-- @brief UI_Lobby에서 매 프레임 호출됨
-------------------------------------
function UI_ButtonPersonalpack:update(dt)
    if (self.m_ppid == nil) then
        self.m_ppid = g_personalpackData:findActivePpidByGroup(kGruop)
        return
    end
    if (self.m_endTime == nil) then
        self.m_endTime = g_personalpackData:getEndOfSaleTime(self.m_ppid)
        if (self.m_endTime ~= nil) then
            self.m_endTime = self.m_endTime / 1000
        end
        return
    end

    local time_label = self.vars['timeLabel']
    if time_label then
        local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        if (0 < self.m_endTime) and (curr_time < self.m_endTime) then
            local remain_time = (self.m_endTime - curr_time)
            local str = datetime.makeTimeDesc_timer_filledByZero(remain_time * 1000)
            time_label:setString(str)
        else
            time_label:setString('')
        end
    end
end