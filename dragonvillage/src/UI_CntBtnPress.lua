-------------------------------------
-- class UI_CntBtnPress
-- @brief 쉽게 사용할 수 있는 증감 버튼
-------------------------------------
UI_CntBtnPress = class({
        m_updateNode = 'cc.Node',
        
        m_quantityBtn = 'UIC_Button',
        
        m_sign = 'number', -- 현재 누르고 있는 버튼이 +1인지, -1인지
        
        m_cntFunc = 'function', -- 현재 개수를 반환하는 함수, m_cntFunc() = number
        m_condFunc = 'function', -- 현재 개수가 가능한지 판단하는 함수, condFunc(new_count) = true면 가능
        
        m_blockUI = 'UI_BlockPopup', -- 이게 nil이 아니라면 현재 작동 중이라는 뜻
        --------------------------
        m_timer = 'number',
        m_timerResetCount = 'number', -- 누르고 있는동안 타이머가 몇번 돌았는지
    })

-------------------------------------
-- function init
-- @param owner_ui : 주인 UI
-- @param cnt_func() : 현재 개수를 반환하는 함수
-- @param cond_func(count) : count가 가능하다면 true 반환, 불가능하다면 false 반환
-- @param refresh_func(count) : count를 매개변수로 받아 UI 및 값 갱신
-------------------------------------
function UI_CntBtnPress:init(owner_ui, cnt_func, cond_func)
    -- update함수를 위한 노드 추가
    self.m_updateNode = cc.Node:create()
    owner_ui.root:addChild(self.m_updateNode)

    self.m_cntFunc = cnt_func
    self.m_condFunc = cond_func
    
    self:resetQuantityBtnPress()
end

-------------------------------------
-- function resetQuantityBtnPress
-- @brief 상태 초기화
-------------------------------------
function UI_CntBtnPress:resetQuantityBtnPress()
    self.m_quantityBtn = nil
    
    self.m_timer = 0
    self.m_timerResetCount = 0

    self.m_updateNode:unscheduleUpdate()
    
    if (self.m_blockUI) then
        self.m_blockUI:close()
    end
end


-------------------------------------
-- function quantityBtnPressHandler
-- @brief 수량 조절 버튼이 press입력을 받기 시작할 때 호출
-- @param btn : 눌리고 있는 버튼
-- @param sign : (+1 OR -1)
-------------------------------------
function UI_CntBtnPress:quantityBtnPressHandler(btn, sign)
    if (self.m_quantityBtn) then
        return
    end

    self.m_blockUI = UI_BlockPopup() -- 이 UI가 살아있는 동안에는 backkey를 막아준다.
    self.m_quantityBtn = btn

    self.m_sign = sign

    self.m_updateNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UI_CntBtnPress:update(dt)
    -- 선택 해제
    if (not self.m_quantityBtn:isSelected()) then
        self:resetQuantityBtnPress()
        return
    end

    self.m_timer = (self.m_timer - dt)
    while (self.m_timer <= 0) do
        -- 현재 개수 반환
        local curr_count = self.m_cntFunc()

        local next_count = math_max(0, curr_count + self.m_sign)

        -- 해당 개수가 불가능할 때 false
        if (self.m_condFunc(next_count) == false) then
            self:resetQuantityBtnPress()
            return
        end

        self.m_timerResetCount = self.m_timerResetCount + 1
        local next_waiting_time = self:getWaitingTime()
        self.m_timer = (self.m_timer + next_waiting_time)
    end
end

-------------------------------------
-- function getWaitingTime
-- @brief 오래 누를수록 짧은 시간 반환
-------------------------------------
function UI_CntBtnPress:getWaitingTime()
    local reset_count = self.m_timerResetCount

    if (reset_count <= 3) then
        return 0.2
    elseif (reset_count <= 9) then
        return 0.1
    elseif (reset_count <= 24) then
        return 0.05
    else
        return 0.025
    end
end