FORMATION_FRONT = 1
FORMATION_MIDDLE = 2
FORMATION_REAR = 3

-------------------------------------
-- class FormationMgr
-- @brief 전방(front), 중간(middle), 후방(rear)
-------------------------------------
FormationMgr = class(IEventListener:getCloneClass(), {
        m_bLeftFormation = 'boolean',

        m_offsetX = 'number',
        m_offsetY = 'number',

        -- 후방
        m_rearStartX = 'number',
        m_rearEndX = 'number',

        -- 중간
        m_middleStartX = 'number',
        m_middleEndX = 'number',

        -- 전방
        m_frontStartX = 'number',
        m_frontEndX = 'number',

        m_minY = 'number',
        m_maxY = 'number',

        -- 지역별 캐릭터 리스트
        m_rearCharList = '',
        m_middleCharList = '',
        m_frontCharList = '',
        
        -- x축만을 위한 리스트
        m_globalCharList = '',
        m_bDirtyGlobalCharList = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function FormationMgr:init(left_formation)
    self.m_bLeftFormation = left_formation

    self.m_offsetX = 0
    self.m_offsetY = 0

    self.m_rearCharList = {}
    self.m_middleCharList = {}
    self.m_frontCharList = {}

    self.m_globalCharList = {}
    self.m_bDirtyGlobalCharList = true

    self.m_minY = -(720/2)
    self.m_maxY = (720/2)
end

-------------------------------------
-- function getFormationRange
-------------------------------------
function FormationMgr:getFormationRange()
    if (self.m_bLeftFormation) then
        local left = self.m_rearStartX
        local right = self.m_frontEndX
        local bottom = self.m_minY
        local top = self.m_maxY
        return left, right, bottom, top
    else
        local left = self.m_frontEndX
        local right = self.m_rearStartX
        local bottom = self.m_minY
        local top = self.m_maxY
        return left, right, bottom, top
    end
end

-------------------------------------
-- function setSplitPos
-------------------------------------
function FormationMgr:setSplitPos(start_pos_x, interval)

    -- 왼쪽 지형
    if self.m_bLeftFormation then
        self.m_rearStartX = start_pos_x
        self.m_rearEndX = self.m_rearStartX + interval

        self.m_middleStartX = self.m_rearEndX
        self.m_middleEndX = self.m_middleStartX + interval

        self.m_frontStartX = self.m_middleEndX
        self.m_frontEndX = self.m_frontStartX + interval

    -- 오른쪽 지형
    else
        self.m_rearEndX = start_pos_x
        self.m_rearStartX = self.m_rearEndX - interval

        self.m_middleEndX = self.m_rearStartX
        self.m_middleStartX = self.m_middleEndX - interval

        self.m_frontEndX = self.m_middleStartX
        self.m_frontStartX = self.m_frontEndX - interval
    end
end

-------------------------------------
-- function getFormation
-------------------------------------
function FormationMgr:getFormation(x, y)
    local x = x - self.m_offsetX
    local y = y - self.m_offsetY

    -- 전방 (front)
    if (self.m_frontStartX <= x) and (x <= self.m_frontEndX) then
        return FORMATION_FRONT

    -- 중간 (middle)
    elseif (self.m_middleStartX <= x) and (x <= self.m_middleEndX) then
        return FORMATION_MIDDLE

    -- 후방 (rear)
    --elseif (self.m_rearStartX <= x) and (x <= self.m_rearEndX) then
    else
        return FORMATION_REAR

    end
end

-------------------------------------
-- function setFormation
-------------------------------------
function FormationMgr:setFormation(char, formation)
    local curr_formation = char.m_currFormation

    if curr_formation then
        self:removeChar(curr_formation, char)
    end

    local x = char.pos.x

    -- 전방 (front)
    if (formation == FORMATION_FRONT) then
        char.m_currFormation = FORMATION_FRONT
        table.insert(self.m_frontCharList, char)

    -- 중간 (middle)
    elseif (formation == FORMATION_MIDDLE) then
        char.m_currFormation = FORMATION_MIDDLE
        table.insert(self.m_middleCharList, char)

    -- 후방 (rear)
    elseif (formation == FORMATION_REAR) then
        char.m_currFormation = FORMATION_REAR
        table.insert(self.m_rearCharList, char)
    else
        char.m_currFormation = nil
    end

    self:changeFormation()
end

-------------------------------------
-- function removeChar
-------------------------------------
function FormationMgr:removeChar(formation, char)
    if (not formation) then
        return
    end

    local char_list = nil

    if (formation == FORMATION_FRONT) then
        char_list = self.m_frontCharList

    elseif (formation == FORMATION_MIDDLE) then
        char_list = self.m_middleCharList

    elseif (formation == FORMATION_REAR) then
        char_list = self.m_rearCharList
    end

    for i,v in ipairs(char_list) do
        if v == char then
            table.remove(char_list, i)
            self:changeFormation()
            break
        end
    end
end

-------------------------------------
-- function setChangePosCallback
-------------------------------------
function FormationMgr:setChangePosCallback(char)

    -- TODO 나중에 위치를 옮길 것
    table.insert(self.m_globalCharList, char)
    self.m_bDirtyGlobalCharList = true

    char.m_bLeftFormation = self.m_bLeftFormation

    char.m_cbChangePos = function(char_)
        local formation = self:getFormation(char_.pos.x, char_.pos.y) 

        if (char_.m_currFormation ~= formation) then
            self:setFormation(char_, formation)
        end

        -- 위치가 변경되었으니 정렬이 필요함
        self.m_bDirtyGlobalCharList = true
    end

    char:addListener('character_dead', self)
    char:addListener('character_revive', self)
end

-------------------------------------
-- function changeFormation
-------------------------------------
function FormationMgr:changeFormation()
    if true then
        return
    end
    
    if self.m_bLeftFormation == false then
        cclog('##############################################')
        cclog('##############################################')
        cclog('self.m_frontCharList : ' .. #self.m_frontCharList)
        cclog('self.m_middleCharList : ' .. #self.m_middleCharList)
        cclog('self.m_rearCharList : ' .. #self.m_rearCharList)
        cclog('##############################################')
        cclog('##############################################')
    end
end

-------------------------------------
-- function getTypicalTarget
-- @brief 일반적인 타겟
-- @param cahr 반대 진형의 캐릭터
-------------------------------------
function FormationMgr:getTypicalTarget(char)

    local formation = char.m_currFormation or FORMATION_FRONT

    -- 전방캐릭터의 타겟 로직
    if (formation == FORMATION_FRONT) then
        return self:getTypicalTarget_Near(char)

    -- 중간, 후방 캐릭터의 타겟 로직
    elseif (formation == FORMATION_MIDDLE) or (formation == FORMATION_REAR) then
        return self:getTypicalTarget_Random(char)
    end

    return nil
end


-------------------------------------
-- function getNearChar
-- @brief 리스트 내에서 가장 가까운 char를 리턴
-------------------------------------
function FormationMgr:getNearChar(char, char_list)
    local target = nil
    local near_dist = nil

    for i,v in ipairs(char_list) do
        if (not v:isDead()) then
            local dist = getDistance(char.pos.x, char.pos.y, v.pos.x, v.pos.y)

            if (not near_dist) or (dist < near_dist) then
                target = v
                near_dist = dist
            end
        end
    end

    return target
end

-------------------------------------
-- function getTypicalTarget_Near
-- @brief
-------------------------------------
function FormationMgr:getTypicalTarget_Near(char)
    local target = nil
    
    -- 전방
    target = self:getNearChar(char, self.m_frontCharList)
    if target then
        return target
    end

    -- 중간
    target = self:getNearChar(char, self.m_middleCharList)
    if target then
        return target
    end

    -- 후방
    target = self:getNearChar(char, self.m_rearCharList)
    if target then
        return target
    end

    return nil
end

-------------------------------------
-- function getRandomChar
-- @brief 리스트 내에서 랜덤 char를 리턴
-------------------------------------
function FormationMgr:getRandomChar(char_list)
    char_list = char_list or self.m_globalCharList
    local count = #char_list

    -- 리스트가 비어있을 경우
    if (count <= 0) then
        return nil

    -- 리스트에 1개만 존재할 경우
    elseif (count == 1) then
        return char_list[1]

    -- 리스트에 2개 이상이 존재할 경우
    else -- if(count >= 2) then
        local rand = math_random(1, count)
        return char_list[rand]
    end 
end

-------------------------------------
-- function getTypicalTarget_Random
-------------------------------------
function FormationMgr:getTypicalTarget_Random(char)
-- 죽은 char들은 리스트에서 자동으로 삭제된다고 가정
    local target = nil
    
    -- 전방
    target = self:getRandomChar(self.m_frontCharList)
    if target then
        return target
    end

    -- 중간
    target = self:getRandomChar(self.m_middleCharList)
    if target then
        return target
    end

    -- 후방
    target = self:getRandomChar(self.m_rearCharList)
    if target then
        return target
    end

    return nil
end

-------------------------------------
-- function getTypicalHealTarget
-- @brief 일반적인 회복 타겟
-- @param cahr 캐릭터
-------------------------------------
function FormationMgr:getTypicalHealTarget(count, l_remove)

    -- 죽은 char들은 리스트에서 자동으로 삭제된다고 가정
    local l_target = {}
    
    -- 전방
    self:getRandomChar_Heal(self.m_frontCharList, l_target, l_remove, count)

    -- 중간
    self:getRandomChar_Heal(self.m_middleCharList, l_target, l_remove, count)

    -- 후방
    self:getRandomChar_Heal(self.m_rearCharList, l_target, l_remove, count)

    return l_target
end

-------------------------------------
-- function getRandomChar_Heal
-- @brief 리스트 내에서 랜덤 char를 리턴
-------------------------------------
function FormationMgr:getRandomChar_Heal(char_list, l_target, l_remove, count)
    local max_random = #char_list

    if max_random <= 0 then
        return
    end

    local t_rand = {}
    for i=1, max_random do
        t_rand[i] = i
    end

    while (count > #l_target) and (max_random > 0) do
        local rand_num = math_random(1, max_random)
        local char = char_list[rand_num]

        if (not l_remove) or (not l_remove[char.phys_idx]) then
            table.insert(l_target, char)
            l_remove[char.phys_idx] = true
        end
        
        table.remove(t_rand, rand_num)

        max_random = max_random - 1
    end
end

-------------------------------------
-- function getRandomHealTarget
-- @brief
-------------------------------------
function FormationMgr:getRandomHealTarget()
    local char_list = {}
    for i,v in pairs(self.m_globalCharList) do
        if (not v:isDead()) and (v.m_hp < v.m_maxHp) then
            table.insert(char_list, v)
        end
    end

    if (#char_list == 1) then
        return char_list[1]
    elseif (#char_list > 1) then
        return char_list[math_random(1, #char_list)]
    else
         return nil
    end
end

-------------------------------------
-- local function sortGlobalCharList_left
-------------------------------------
local function sortGlobalCharList_left(a, b)
    return (a.pos.x > b.pos.x)
end

-------------------------------------
-- local function sortGlobalCharList_right
-------------------------------------
local function sortGlobalCharList_right(a, b)
    return (a.pos.x < b.pos.x)
end

-------------------------------------
-- function getHorizontalTarget
-- @brief 수평적인 위치의 타겟
-- @param cahr 반대 진형의 캐릭터
-------------------------------------
function FormationMgr:getHorizontalTarget()

    -- global char list의 정렬이 필요할 때
    if self.m_bDirtyGlobalCharList then
        if self.m_bLeftFormation then
            table.sort(self.m_globalCharList, sortGlobalCharList_left)
        else
            table.sort(self.m_globalCharList, sortGlobalCharList_right)
        end
        self.m_bDirtyGlobalCharList = false
    end
    
    -- 가장 가까운 적을 리스트에 담음(x위치가 같을 수 있으니 리스트 사용)
    local pos_x = nil
    local t_list = nil
    for i,v in ipairs(self.m_globalCharList) do
        if (t_list == nil) then
            t_list = {}
            table.insert(t_list, v)
            pos_x = v.pos.x
        else
            if (pos_x == v.pos.x) then
                table.insert(t_list, v)
            else
                break
            end
        end
    end

    -- 타겟이 없음
    if (not t_list) then
        return nil
    end

    -- 1명일 경우 바로 리턴
    if (#t_list == 1) then
        return t_list[1]
    end

    -- x위치가 같을 경우 그중에서 랜덤 리턴
    local rand_num = math_random(1, #t_list)
    return t_list[rand_num]
end


-------------------------------------
-- function onEvent
-------------------------------------
function FormationMgr:onEvent(event_name, t_event, ...)
    -- 캐릭터 사망
    if (event_name == 'character_dead') then
        local arg = {...}
        local char = arg[1]
        self:removeChar(char.m_currFormation, char)
        
        -- TODO 나중에 위치를 옮길 것
        local idx = table.find(self.m_globalCharList, char)
        table.remove(self.m_globalCharList, idx)

    -- 캐릭터 부활
    elseif (event_name == 'character_revive') then
        local arg = {...}
        local char = arg[1]
        self:setFormation(char, char.m_currFormation)
        
        -- TODO 나중에 위치를 옮길 것
        table.insert(self.m_globalCharList, char)
        self.m_bDirtyGlobalCharList = true

    -- 카메라 홈 위치가 변경되었을 경우
    elseif (event_name == 'camera_set_home') then
        local arg = {...}
        local x = arg[1]
        local y = arg[2]

        self.m_offsetX = x
        self.m_offsetY = y
    end
end

-------------------------------------
-- function printSpawnedList
-------------------------------------
function FormationMgr:printCharList()
	cclog('FRONT ######################')
	for i, v in pairs(self.m_frontCharList) do
		cclog(v:getName())
	end
	cclog('MIDDLE ######################')
	for i, v in pairs(self.m_middleCharList) do
		cclog(v:getName())
	end
	cclog('REAR ######################')
	for i, v in pairs(self.m_rearCharList) do
		cclog(v:getName())
	end
	cclog('#########################################################----')
end

-------------------------------------
-- function isFrontLineAlive
-------------------------------------
function FormationMgr:isFrontLineAlive()
    for _, v in pairs(self.m_frontCharList) do
        if (not v:isDead()) then return true end
    end
    return false
end

-------------------------------------
-- function isFrontLine
-------------------------------------
function FormationMgr:isFrontLine(char)
    for _, v in pairs(self.m_frontCharList) do
        if (v == char) then return true end
    end
    return false
end


-------------------------------------
-- class FormationMgrDelegate
-- @brief 전방(front), 중간(middle), 후방(rear)
-------------------------------------
FormationMgrDelegate = class({
        -- 지역별 캐릭터 리스트
        m_rearCharList = '',
        m_middleCharList = '',
        m_frontCharList = '',
        
        -- x축만을 위한 리스트
        m_globalCharList = '',
    })

-------------------------------------
-- function init
-------------------------------------
function FormationMgrDelegate:init(mgr1, mgr2)
    -- 지역별 캐릭터 리스트
    self.m_rearCharList = {}
    self.m_middleCharList = {}
    self.m_frontCharList = {}
        
    -- x축만을 위한 리스트
    self.m_globalCharList = {}

    if mgr1 then
        self:addList(self.m_rearCharList, mgr1.m_rearCharList)
        self:addList(self.m_middleCharList, mgr1.m_middleCharList)
        self:addList(self.m_frontCharList, mgr1.m_frontCharList)
        self:addList(self.m_globalCharList, mgr1.m_globalCharList)
    end

    if mgr2 then
        self:addList(self.m_rearCharList, mgr2.m_rearCharList)
        self:addList(self.m_middleCharList, mgr2.m_middleCharList)
        self:addList(self.m_frontCharList, mgr2.m_frontCharList)
        self:addList(self.m_globalCharList, mgr2.m_globalCharList)
    end
end

-------------------------------------
-- function addList
-------------------------------------
function FormationMgrDelegate:addList(std_list, add_list)
    if (not std_list) or (not add_list) then
        return
    end

    for i,v in pairs(add_list) do
        table.insert(std_list, v)
    end
end
-------------------------------------
-- function getTargetList
-------------------------------------
function FormationMgrDelegate:getTargetList(x, y, team_type, formation_type, rule_type, t_data)
    local t_ret = {}

	-- @TODO 임시 처리 self formation
	if (team_type == 'self') then
		local t_org_list_1 = self.m_globalCharList
        self:addList(t_ret, TargetRule_getTargetList('self', t_org_list_1, x, y, t_data))

    -- 항목에 데이터가 없다면 전, 중, 후 구별을 하지 않고 모두를 타겟
	elseif (formation_type == '') or (not formation_type) then
        local t_org_list_1 = self.m_globalCharList
        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_1, x, y, t_data))

    -- 전위, 중위, 후위 순으로 우선 타겟
    elseif (formation_type == 'front') then
        local t_org_list_1 = self.m_frontCharList
        local t_org_list_2 = self.m_middleCharList
        local t_org_list_3 = self.m_rearCharList

        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_1, x, y, t_data))
        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_2, x, y, t_data))
        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_3, x, y, t_data))

    -- 중위, 후위, 전위 순으로 우선 타겟
    elseif (formation_type == 'middle') then
        local t_org_list_1 = self.m_middleCharList
        local t_org_list_2 = self.m_rearCharList
        local t_org_list_3 = self.m_frontCharList

        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_1, x, y, t_data))
        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_2, x, y, t_data))
        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_3, x, y, t_data))

    -- 후위, 중위, 전위 순으로 우선 타겟
    elseif (formation_type == 'back') then
        local t_org_list_1 = self.m_rearCharList
        local t_org_list_2 = self.m_middleCharList
        local t_org_list_3 = self.m_frontCharList

        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_1, x, y, t_data))
        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_2, x, y, t_data))
        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_3, x, y, t_data))

    -- 전위와 중위를 우선 타겟 하고 대상이 없을 경우 후위 타겟
    elseif (formation_type == 'wide_front') then
        local t_org_list_1 = {}
        self:addList(t_org_list_1, self.m_frontCharList)
        self:addList(t_org_list_1, self.m_middleCharList)
        local t_org_list_2 = self.m_rearCharList

        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_1, x, y, t_data))
        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_2, x, y, t_data))

    -- 후위와 중위를 우선 타겟 하고 대상이 없을 경우 전위 타겟
    elseif (formation_type == 'wide_back') then
        local t_org_list_1 = {}
        self:addList(t_org_list_1, self.m_rearCharList)
        self:addList(t_org_list_1, self.m_middleCharList)
        local t_org_list_2 = self.m_frontCharList

        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_1, x, y, t_data))
        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_2, x, y, t_data))

    -- 전위와 후위를 우선 타겟 하고 대상이 없을 경우 중위 타겟
    elseif (formation_type == 'side') then
        local t_org_list_1 = {}
        self:addList(t_org_list_1, self.m_frontCharList)
        self:addList(t_org_list_1, self.m_rearCharList)
        local t_org_list_2 = self.m_middleCharList

        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_1, x, y, t_data))
        self:addList(t_ret, TargetRule_getTargetList(rule_type, t_org_list_2, x, y, t_data))

    else
        error("미구현 Formation Type!! : " .. formation_type)
    end

    -- 자기 자신은 제외
    if (team_type == 'teammate') then
        local self_char = t_data['self']
        for i, target in pairs(t_ret) do
            if (target == self_char) then
                table.remove(t_ret, i)
                break
            end
        end
    end

    return t_ret
end