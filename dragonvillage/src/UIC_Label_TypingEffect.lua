local PARENT = UIC_Node

-------------------------------------
-- class UIC_Label_TypingEffect
-------------------------------------
UIC_Label_TypingEffect = class(PARENT, {
        m_label = 'UIC_LabelTTF or UIC_RichLabel', -- 라벨
        m_bIsRich = 'boolean', -- Label, RichLabel 구분

        m_interval = 'number', -- 타자 진행 속도
        m_dueTime = 'number', -- 문장의 길이가 어떻든 dueTime 값이 있다면 해당 시간 안에 모두 출력되도록 함

        m_readyFunc = 'function', -- 각 글자에 대해 처음 세팅될 때 적용할 함수, setString할 때 호출됨. func(sprite) 꼴
        m_showFunc = 'function', -- 각 글자에 대해 보여질 때 적용할 함수. func(sprite) 꼴 
        m_finishCB = 'function', -- 텍스트 출력이 완료되었을 때 실행될 콜백 함수
        m_bIsFinish = 'boolean', -- 현재 텍스트 출력이 완료되었는가?

        m_updateNode = 'cc.Node', -- update용 노드
        m_timer = 'number', -- update에서 사용되는 타이머
        m_currNodeIdx = 'number', -- 다음에 켜질 노드 인덱스 [1, N]
        m_currStrIdx = 'number', -- 다음에 켜질 노드의 문자열 인덱스 [0, N-1]
    })

-------------------------------------
-- function MakeTypingEffectLabel
-- @param label : UIC_LabelTTF or UIC_RichLabel, 
-- @return : 이상한게 들어오면 nil을 반환
-------------------------------------
function MakeTypingEffectLabel(label)
    local label_typing_effect = UIC_Label_TypingEffect()
    local base_label = label
    
    -- LabelTTF
    if (isInstanceOf(base_label, UIC_LabelTTF)) then
        label_typing_effect.m_bIsRich = false
        label_typing_effect.m_node = base_label.m_node
    
    -- RichLabel
    elseif (isInstanceOf(base_label, UIC_RichLabel)) then
        label_typing_effect.m_bIsRich = true
        label_typing_effect.m_node = base_label.m_root
    
    -- 무언가 잘못된 경우
    else
        cclog('## ERROR : makeTypingEffectLabel(label)')
        return
    end

    label_typing_effect.m_label = base_label
    
    local node = UIC_Node:create()
    node:initGLNode()
    label_typing_effect.m_node:getParent():addChild(node.m_node)
    label_typing_effect.m_updateNode = node.m_node

    label_typing_effect.m_interval = 0.02
    label_typing_effect.m_bIsFinish = true

    return label_typing_effect
end

-------------------------------------
-- function init
-------------------------------------
function UIC_Label_TypingEffect:init()

end

-------------------------------------
-- function setReadyFunc
-- @param ready_func : func(sprite) 꼴, 해당 sprite에게 적용할 액션 등을 담음
-------------------------------------
function UIC_Label_TypingEffect:setReadyFunc(ready_func)
    self.m_readyFunc = ready_func
end

-------------------------------------
-- function defaultReadyFunc
-- @brief m_readyFunc == nil 일 때 적용되는 함수
-------------------------------------
function UIC_Label_TypingEffect:defaultReadyFunc(sprite)
    sprite:setVisible(false)
end

-------------------------------------
-- function setShowFunc
-- @param show_func : func(sprite) 꼴, 해당 sprite에게 적용할 액션 등을 담음
-------------------------------------
function UIC_Label_TypingEffect:setShowFunc(show_func)
    self.m_showFunc = show_func
end

-------------------------------------
-- function defaultShowFunc
-- @brief m_showFunc == nil 일 때 적용되는 함수
-------------------------------------
function UIC_Label_TypingEffect:defaultShowFunc(sprite)
    sprite:setVisible(true)
end

-------------------------------------
-- function setFinishCB
-- @param finish_cb : 모든 문자 출력이 끝난 다음에 콜백될 함수, func() 꼴
-------------------------------------
function UIC_Label_TypingEffect:setFinishCB(finish_cb)
    self.m_finishCB = finish_cb
end

-------------------------------------
-- function setInterval
-- @param : interval = 글자마다 출력되는 간격
-- @brief 각 문자마다 출력 사이의 텀을 결정한다. 다만 self.m_dueTime이 설정되어 있는 경우 무시된다.
-------------------------------------
function UIC_Label_TypingEffect:setInterval(interval)
    self.m_interval = interval
end

-------------------------------------
-- function setDueTime
-- @param : due_time = 모든 글자가 출력되는 시간
-------------------------------------
function UIC_Label_TypingEffect:setDueTime(due_time)
    self.m_dueTime = due_time
end

-------------------------------------
-- function calcIntervalFromDueTime
-- @brief self.m_dueTime의 값과 현재 문자열 길이를 통해 interval 계산
-------------------------------------
function UIC_Label_TypingEffect:calcIntervalFromDueTime()
   -- 모든 글자의 길이를 구한다
    local total_str_len = 0
    local due_time = self.m_dueTime

    local label = self.m_label

    local function getStrLenFromNode(node)
        local str_len = node:getStringLength()
        total_str_len = total_str_len + str_len
    end

    if (self.m_bIsRich == true) then
        for _, t_data in ipairs(label.m_nodeList) do
            local node = t_data['node']
            getStrLenFromNode(node)
        end
    
    else
        local node = self.m_node
        getStrLenFromNode(node)
    end
    
    local interval = due_time / (total_str_len - 1)

    self.m_interval = interval
end

-------------------------------------
-- function isFinish
-- @brief 텍스트 출력이 종료되었는지 판단
-------------------------------------
function UIC_Label_TypingEffect:isFinish()
    return self.m_bIsFinish
end

-------------------------------------
-- function startDirect
-- @brief 연출 시작
-------------------------------------
function UIC_Label_TypingEffect:startDirect()
    local label = self.m_label
    
    self.m_updateNode:unscheduleUpdate()
    
    if (self.m_bIsRich == true) then
        label:update(0)
        if (#label.m_nodeList == 0) then
            return
        end
    end

    local function setLetterReady(node)
        local str_len = node:getStringLength()
        local color = node:getColor()

        -- getLetter 함수는 인덱스가 루아와 다르게 0부터 시작한다.
        for idx = 0, str_len do
            -- 맨 처음 getLetter 할 때 글자가 색을 잃어버리는 버그가 있어서 다시 한번 색상 지정
            local letter = node:getLetter(idx)

            if (letter ~= nil) then
                letter:stopAllActions() -- 이전에 돌고 있던 액션 있다면 취소
                letter:setColor(color)

                if (self.m_readyFunc) then
                    self.m_readyFunc(letter)
                else
                    self:defaultReadyFunc(letter)
                end
            end
        end
    end

    -- RichLabel은 각 문장, 글자가 노드로 나뉘어져 있을 수 있으므로 for문을 한번 더 거친다.
    if (self.m_bIsRich == true) then
        for _, t_data in ipairs(label.m_nodeList) do
            local node = t_data['node']
            setLetterReady(node)
        end

    else
        local node = self.m_node
        setLetterReady(node)        
    end

    ---- 타이핑 이펙트 시작
    self.m_bIsFinish = false
    self.m_timer = 0
    self.m_currNodeIdx = 1
    self.m_currStrIdx = 0

    if (self.m_dueTime ~= nil) then
        self:calcIntervalFromDueTime()
    end

    self.m_updateNode:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function setString
-- @brief 텍스트를 설정하면서 각 문자에 m_readyFunc 적용
-------------------------------------
function UIC_Label_TypingEffect:setString(text)
    local label = self.m_label
    label:setString(text)
    self:startDirect()
end

-------------------------------------
-- function skip
-- @brief 바로 모든 문자열 출력
-------------------------------------
function UIC_Label_TypingEffect:skip()
    if (self.m_bIsFinish == true) then
        return
    end
    
    local label = self.m_label

    local node_list_size = (self.m_bIsRich == true) and (#label.m_nodeList) or 1
    local curr_node_idx = self.m_currNodeIdx
    local curr_str_idx = self.m_currStrIdx

    for node_idx = curr_node_idx, node_list_size do
        local node 
        if (self.m_bIsRich == true) then
            local t_data = label.m_nodeList[node_idx]
            node = t_data['node']
        else
            node = self.m_node
        end
        
        local str_len = node:getStringLength()

        -- getLetter 함수는 인덱스가 루아와 다르게 0부터 시작한다.
        for str_idx = curr_str_idx, (str_len - 1) do
            local letter = node:getLetter(str_idx)

            if (letter ~= nil) then
                letter:setVisible(true)

                if (self.m_showFunc) then
                    self.m_showFunc(letter)
                else
                    self:defaultShowFunc(letter)
                end
            end
        end

        curr_str_idx = 0
    end

    if (self.m_finishCB) then
        self.m_finishCB()
    end

    self.m_bIsFinish = true
    self.m_updateNode:unscheduleUpdate()
end

-------------------------------------
-- function update
-- @brief 순서대로 한 글자씩 출력
-------------------------------------
function UIC_Label_TypingEffect:update(dt)
    self.m_timer = self.m_timer - dt

    local b_is_finish = false

    while ((self.m_timer <= 0) and (b_is_finish == false)) do
        self.m_timer = self.m_timer + self.m_interval

        local label = self.m_label
        
        local curr_node_idx = self.m_currNodeIdx
        local curr_data
        local curr_node

        if (self.m_bIsRich == true) then
            curr_data = label.m_nodeList[curr_node_idx]
            curr_node = curr_data['node']
        else
            curr_node = self.m_node
        end

        local curr_node_str_len = curr_node:getStringLength()
        local curr_str_idx = self.m_currStrIdx

        -- RichLabel의 경우 여러 개의 노드로 이루어져있다.
        -- 현재 노드의 글자를 전부 출력한 경우 다음 노드로 넘어가고, 
        -- 다음 노드가 없는 경우 완료로 판단한다.
        if (self.m_bIsRich == true) then
            while (curr_node_str_len <= curr_str_idx) do
                curr_node_idx = curr_node_idx + 1
                curr_data = label.m_nodeList[curr_node_idx]
    
                if (curr_data == nil) then
                    b_is_finish = true
                    break
                end
                
                curr_node = curr_data['node']
                curr_node_str_len = curr_node:getStringLength()
                curr_str_idx = 0
            end
        
        -- RichLabel이 아닌 경우 단순 글자 길이 검사로 완료 여부 판단한다
        else
            if (curr_node_str_len <= curr_str_idx) then
                b_is_finish = true
            end
        end

        -- 아직 완료되지 않았다면 다음 글자를 출력한다.
        if ((curr_node) and (b_is_finish == false)) then
            local curr_letter = curr_node:getLetter(curr_str_idx)

            if (curr_letter ~= nil) then
                curr_letter:setVisible(true)

                if (self.m_showFunc) then
                    self.m_showFunc(curr_letter)
                else
                    self:defaultShowFunc(curr_letter)
                end
            end
            
            self.m_currNodeIdx = curr_node_idx
            self.m_currStrIdx = curr_str_idx + 1
        end
    end

    if (b_is_finish == true) then
        if (self.m_finishCB) then
            self.m_finishCB()
        end

        self.m_bIsFinish = true
        self.m_updateNode:unscheduleUpdate()
    end
end