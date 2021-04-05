-------------------------------------
-- class FormationMgr
-------------------------------------
FormationMgr = class(IEventListener:getCloneClass(), {
        m_bLeftFormation = 'boolean',

        m_offsetX = 'number',
        m_offsetY = 'number',
        
        -- 생존중인 캐릭터
        m_globalCharList = '',

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
    
    self.m_globalCharList = {}
    self.m_diedCharList = {}
end

-------------------------------------
-- function setChangePosCallback
-------------------------------------
function FormationMgr:setChangePosCallback(char)
    table.insert(self.m_globalCharList, char)

    char.m_bLeftFormation = self.m_bLeftFormation

    char:addListener('character_dying', self)
    char:addListener('character_revive', self)
end

-------------------------------------
-- function onEvent
-------------------------------------
function FormationMgr:onEvent(event_name, t_event, ...)
                    
    -- 캐릭터 죽음
    if (event_name == 'character_dying') then
        local arg = {...}
        local char = arg[1]

        local idx = table.find(self.m_globalCharList, char)
        if (idx) then
            table.remove(self.m_globalCharList, idx)
        end

        local idx = table.find(self.m_diedCharList, char)
        if (not idx) then
            table.insert(self.m_diedCharList, char)
        end

    -- 캐릭터 부활
    elseif (event_name == 'character_revive') then
        local arg = {...}
        local char = arg[1]
                
        local idx = table.find(self.m_globalCharList, char)
        if (not idx) then
            table.insert(self.m_globalCharList, char)
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
-- function isEmpty
-------------------------------------
function FormationMgr:isEmpty()
    return (#self.m_globalCharList == 0)
end









-------------------------------------
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- FormationMgrDelegate
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-------------------------------------
-------------------------------------
-- class FormationMgrDelegate
-------------------------------------
FormationMgrDelegate = class({
        -- x축만을 위한 리스트
        m_globalCharList = '',

        -- 죽은 캐릭터 리스트
        m_diedCharList = '',
    })

-------------------------------------
-- function init
-------------------------------------
function FormationMgrDelegate:init(mgr1, mgr2)
    -- x축만을 위한 리스트
    self.m_globalCharList = {}

    -- 죽은 캐릭터 리스트
    self.m_diedCharList = {}

    if mgr1 then
        self:addList(self.m_globalCharList, mgr1.m_globalCharList)
        self:addList(self.m_diedCharList, mgr1.m_diedCharList)
    end

    if mgr2 then
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
-- function addGlobalList
-------------------------------------
function FormationMgrDelegate:addGlobalList(add_list)
    self:addList(self.m_globalCharList, add_list)
end

-------------------------------------
-- function addDiedList
-------------------------------------
function FormationMgrDelegate:addDiedList(add_list)
    self:addList(self.m_diedCharList, add_list)
end

-------------------------------------
-- function getTargetList
-------------------------------------
function FormationMgrDelegate:getTargetList(x, y, team_type, formation_type, rule_type, t_data)
    local formation_type = formation_type or ''
    local char = t_data['self']
    local game_mode = t_data['game_mode']

    local t_ret = {}
    local target_type = rule_type
    local l_origin = self.m_globalCharList

    -- 18/02/02 formation_type(front, middle, back)의 기능 변경
    -- front : 가장 가까운 적 우선
    -- back : 가장 먼 적 우선
    -- 4/5/2021 타게팅 로직 개선 
    if (string.find(formation_type, 'front')) then
        target_type = 'front'
        
    elseif (string.find(formation_type, 'back')) then
        target_type = 'back'

    elseif (team_type == 'self') then
        target_type = 'self'

    elseif (team_type == 'boss') then
        target_type = 'boss'

    elseif (rule_type == 'all') then
        target_type = 'all'

    elseif (rule_type == 'dead') then
        target_type = 'dead'
		l_origin = self.m_diedCharList

	else
        -- 항목에 데이터가 없다면 전, 중, 후 구별을 하지 않고 모두를 타겟

    end

    self:addList(t_ret, TargetRule_getTargetList(target_type, l_origin, x, y, t_data))

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

    -- 적군 대상인 경우면 바디가 활성화된 대상만 가져옴
    --[[
    if (char) then
        local is_left = char.m_bLeftFormation
        local temp = {}
        
        for i, target in ipairs(t_ret) do
            if (target.enable_body or is_left == target.m_bLeftFormation) then
                table.insert(temp, target)
            end
        end

        t_ret = temp
    end
    ]]--
    
    return t_ret
end

-------------------------------------
-- function isEmpty
-------------------------------------
function FormationMgrDelegate:isEmpty()
    return (#self.m_globalCharList == 0)
end