local PARENT = GameAuto

-------------------------------------
-- class GameAuto_Hero
-------------------------------------
GameAuto_Hero = class(PARENT, {
        m_inGameUI = 'UI',
        m_group = 'string', -- PHYS.HERO or PHYS.HERO_TOP or PHYS.HERO_BOTTOM
        m_deckName = 'string',
        m_mMainDeck = 'Map<number, string>',
        m_useAutoMode = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function GameAuto_Hero:init(world, game_mana, ui)
    self.m_inGameUI = ui

    -- 전투 시작 시 자동모드 설정 처리
    local is_auto_mode = g_autoPlaySetting:get('auto_mode')
    self.m_useAutoMode = true

    if (self.m_world.m_gameMode == GAME_MODE_INTRO) then
        -- 인트로에서는 비활성화시킴
        is_auto_mode = false
        self.m_useAutoMode = false

    elseif (g_autoPlaySetting:isAutoPlay()) then
        -- 연속 전투가 활성화되어있다면 즉시 자동모드를 활성화시킴
        g_autoPlaySetting:setWithoutSaving('auto_mode', true)

        is_auto_mode = true
    end

    if (is_auto_mode) then
        self:onStart()
    end
end

-------------------------------------
-- function prepare
-------------------------------------
function GameAuto_Hero:prepare(unit_list)
    PARENT.prepare(self, unit_list)

    local unit = self.m_lUnitList[1]
    if (unit) then
        self.m_group = unit:getPhysGroup()
    end

    self.m_mMainDeck = {}
    if self.m_useAutoMode == false then
        return
    end

    local g_data
    if (self.m_world.m_gameMode == GAME_MODE_CLAN_RAID) then
        local attr = TableStageData:getStageAttr(self.m_world.m_stageID)
        g_data = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, attr)

    elseif (self.m_world.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
        g_data = MultiDeckMgr(MULTI_DECK_MODE.ANCIENT_RUIN)
    end

    local l_doid_list = {}
    if g_data ~= nil then
        local sel_deck = g_data:getMainDeck()
        local main_deck_name

        if (sel_deck == 'up') then
            main_deck_name = g_data:getDeckName('up')
        elseif (sel_deck == 'down') then
            main_deck_name = g_data:getDeckName('down')
        end

        -- 덱 이름
        local l_deck, formation, deck_name, leader = g_deckData:getDeck(main_deck_name)
        l_doid_list = clone(l_deck)
        self.m_deckName = main_deck_name
    else
        local l_deck, formation, deck_name, leader = g_deckData:getDeck()
        l_doid_list = clone(l_deck)
        self.m_deckName = deck_name
    end

    
    for i, doid in pairs(l_doid_list) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        if t_dragon_data ~= nil then
            self.m_mMainDeck[tonumber(t_dragon_data['did'])] = true
        end
    end
    -- 보정 처리
    self:correctDragSkillLock(self.m_deckName, l_doid_list)
end

-------------------------------------
-- function correctDragSkillLock
-------------------------------------
function GameAuto_Hero:correctDragSkillLock(deck_name, l_deck)
    local drag_did_list = g_settingData:getAutoDragSkillLockDidList(deck_name)    
    local deck_did_list = {}
    local dirty = false

    for _, v in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
        if (t_dragon_data) then
            table.insert(deck_did_list, t_dragon_data['did'])
        end
    end
    
    for idx = #drag_did_list, 1 , -1 do
        local did = drag_did_list[idx]
        if table.find(deck_did_list, did) == nil then
            table.remove(drag_did_list, idx)
            dirty = true
        end
    end

    if dirty == true then
        g_settingData:setAutoDragSkillLockDidList(deck_name, drag_did_list)
    end
end

-------------------------------------
-- function doWork
-------------------------------------
function GameAuto_Hero:doWork(dt)
    local world = self.m_world

    -- 인디케이터 조작중일 경우
    if (world.m_skillIndicatorMgr:isControlling()) then
        -- 같은 팀이 이미 조작 중인 경우만 막음 처리
        local hero = world.m_skillIndicatorMgr:getControllingHero()
        local controlling_group = hero:getPhysGroup()
        
        if (self.m_group == controlling_group) then
            return
        end
    end

    -- 전투 중일 때에만
    if (not world.m_gameState:isFight()) then
        return false
    end

    -- 글로벌 쿨타임 중일 경우
    if (world.m_gameCoolTime:isWaiting(GLOBAL_COOL_TIME.ACTIVE_SKILL)) then
        return false
    end

    -- 액티브 스킬 연출 중일 경우
    if (world.m_gameDragonSkill:isPlaying()) then
        return false
    end

    PARENT.doWork(self, dt)
end

-------------------------------------
-- function onStart
-------------------------------------
function GameAuto_Hero:onStart()
    PARENT.onStart(self)
    
    if (self.m_inGameUI) then
        self.m_inGameUI:setAutoMode(true, true)
    end
end

-------------------------------------
-- function onEnd
-------------------------------------
function GameAuto_Hero:onEnd()
    PARENT.onEnd(self)

    if (self.m_inGameUI) then
        self.m_inGameUI:setAutoMode(false, true)
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameAuto_Hero:onEvent(event_name, t_event, ...)
    if (event_name == 'auto_start') then
        self:onStart()

    elseif (event_name == 'auto_end') then
        self:onEnd()
        
    elseif (event_name == 'hero_active_skill') then
        self:setWorkTimer()

	elseif (event_name == 'farming_changed') then
		self:refreshSkillInfoListSortedByPriority()

    elseif (event_name == 'auto_skill_unlock') then
        local arg = {...}
        local unit = arg[1]
		self:unLockAutoDragSkill(unit)
    end
end

-------------------------------------
--- @function unLockAutoDragSkill
--- @brief 잠금해제 시에 사용 횟수를 조절하여 너무 높은 우선순위가 부여되지 않도록 만듦
-------------------------------------
function GameAuto_Hero:unLockAutoDragSkill(_unit)
    local maxium_count = 0
    for _, unit in ipairs(self.m_lUnitList) do
        local used_count = self.m_mUsedCount[unit]
        if maxium_count < used_count then
            maxium_count = used_count
        end
    end

    local result_used_count = math_max(maxium_count - 1, 0)
    self.m_mUsedCount[_unit] = result_used_count
    cclog('사용 횟수 조절 완료', self.m_mUsedCount[_unit])
end

-------------------------------------
-- function isAutoDragSkillLocked
-------------------------------------
function GameAuto_Hero:isAutoDragSkillLocked(unit, t_skill_info)
    -- 덱이름이 없으면 false
    if self.m_deckName == nil then
        return false
    end

    -- 드래그 스킬 잠금일 경우 체크
    local did = unit:getCharacterId()

    -- 메인덱이 아니냐??
    if self.m_mMainDeck[did] ~= true then
        return false
    end



    -- 드래그 스킬 여부 체크
    if t_skill_info ~= nil then
        local skill_id = t_skill_info.m_skillId
        local skill_indivisual_info = unit:getSkillIndivisualInfo('active')
        if skill_indivisual_info == nil then
            return false
        end

        if skill_id ~= skill_indivisual_info:getSkillID() then
            return false
        end
    end

    if g_settingData:isAutoDragSkillLockDid(self.m_deckName, did) == true then
        return true
    end

    return false
end

-------------------------------------
--- @function getSkillInfoListPerPriorityFilteredLock
-------------------------------------
function GameAuto_Hero:getSkillInfoListPerPriorityFilteredLock()
    local list = self.m_lSkillInfoListPerPriority[self.m_curPriority]
    local result_list = {}

    for _, struct_skill_info in ipairs(list) do
        local unit = struct_skill_info.m_unit
        -- 드래그 스킬 잠금 제외
        if self:isAutoDragSkillLocked(unit, struct_skill_info) == false then
            table.insert(result_list, struct_skill_info)
        end
    end

    return result_list
end

-------------------------------------
-- function makeSkillInfoListSortedByPriority
-- @brief state 상태에서의 우선순위별 해당하는 스킬 정보 리스트를 만듬
-------------------------------------
function GameAuto_Hero:makeSkillInfoListSortedByPriority(state)
    local list = PARENT.makeSkillInfoListSortedByPriority(self, state)
    local new_list = {}


    
	-- 모험모드 및 쫄작 옵션 체크
	if (not self.m_world:isDragonFarming()) then
		return list
	end

    new_list = {}
	-- 쫄작(farming) 시 쫄작기사(farmer)가 아니면 제외시킴
	for priority, l_skill in ipairs(list) do
		new_list[priority] = {}

		for _, struct_skill_info in ipairs(l_skill) do
            local unit = struct_skill_info.m_unit
			if (unit:isFarmer()) then
				table.insert(new_list[priority], struct_skill_info)
			end
		end
	end

    return new_list
end

-------------------------------------
-- function refreshSkillInfoListSortedByPriority
-- @brief 연속전투 옵션 중 쫄작 기능 변경 시 호출하여 스킬 사용 우선 순위 리스트 변경함
-- @comment 인게임 중 변경 시에만 호출 됨
-------------------------------------
function GameAuto_Hero:refreshSkillInfoListSortedByPriority()
	local state = (self.m_teamState == 0) and TEAM_STATE.NORMAL or self.m_teamState
	self.m_lSkillInfoListPerPriority = self:makeSkillInfoListSortedByPriority(state)

    local count = 0
    for i = 1, 4 do
        count = count + #self.m_lSkillInfoListPerPriority[i]
    end

    -- 만약 1~4우선순위의 리스트가 하나도 없을 경우 모든 유닛으로 설정(우선 순위에 상관없이 모든 유닛 중 랜덤)
    if (count == 0) then
        self.m_lSkillInfoListPerPriority = self:makeSkillInfoListSortedByPriority(TEAM_STATE.NORMAL)
    end
end