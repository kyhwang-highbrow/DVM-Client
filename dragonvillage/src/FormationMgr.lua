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

        -- 죽은 캐릭터 리스트
        m_diedCharList = '',
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

    self.m_diedCharList = {}

    self.m_minY = -(720/2)
    self.m_maxY = (720/2)
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
        if (char_:isDead()) then
            return
        end

        local x, y = char_:getPosForFormation()
        local formation = self:getFormation(x, y)

        if (char_.m_currFormation ~= formation) then
            self:setFormation(char_, formation)
        end

        -- 위치가 변경되었으니 정렬이 필요함
        self.m_bDirtyGlobalCharList = true
    end

    char.m_cbDead = function(char_)
        self:removeChar(char_.m_currFormation, char_)
        char_.m_currFormation = nil
        local idx = table.find(self.m_globalCharList, char_)
        if (idx) then
            table.remove(self.m_globalCharList, idx)
        end

        local idx = table.find(self.m_diedCharList, char_)
        if (not idx) then
            table.insert(self.m_diedCharList, char_)
        end
    end

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
-- function onEvent
-------------------------------------
function FormationMgr:onEvent(event_name, t_event, ...)
    -- 캐릭터 부활
    if (event_name == 'character_revive') then
        local arg = {...}
        local char = arg[1]
        self:setFormation(char, char.m_currFormation)
        
        local idx = table.find(self.m_globalCharList, char)
        if (not idx) then
            table.insert(self.m_globalCharList, char)
            self.m_bDirtyGlobalCharList = true
        end

        idx = table.find(self.m_diedCharList, char)
        if (idx) then
            table.remove(self.m_diedCharList, idx)
        end

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

        -- 죽은 캐릭터 리스트
        m_diedCharList = '',
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

    -- 죽은 캐릭터 리스트
    self.m_diedCharList = {}

    if mgr1 then
        self:addList(self.m_rearCharList, mgr1.m_rearCharList)
        self:addList(self.m_middleCharList, mgr1.m_middleCharList)
        self:addList(self.m_frontCharList, mgr1.m_frontCharList)
        self:addList(self.m_globalCharList, mgr1.m_globalCharList)
        self:addList(self.m_diedCharList, mgr1.m_diedCharList)
    end

    if mgr2 then
        self:addList(self.m_rearCharList, mgr2.m_rearCharList)
        self:addList(self.m_middleCharList, mgr2.m_middleCharList)
        self:addList(self.m_frontCharList, mgr2.m_frontCharList)
        self:addList(self.m_globalCharList, mgr2.m_globalCharList)
        self:addList(self.m_diedCharList, mgr2.m_diedCharList)
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

    elseif (rule_type == 'all') then
        for i, v in ipairs(self.m_globalCharList) do
            table.insert(t_ret, v)
        end

    -- 죽은 대상
    elseif (rule_type == 'dead') then
        for i, v in ipairs(self.m_diedCharList) do
            -- 죽는 도중이 아닌 확실히 죽은 대상만 선별
            if (v.m_bDead) then
                table.insert(t_ret, v)
            end
        end

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