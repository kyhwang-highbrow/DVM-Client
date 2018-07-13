local PARENT = GameAuto

-------------------------------------
-- class GameAuto_Hero
-------------------------------------
GameAuto_Hero = class(PARENT, {
        m_inGameUI = 'UI',
        m_group = 'string', -- PHYS.HERO or PHYS.HERO_TOP or PHYS.HERO_BOTTOM
     })

-------------------------------------
-- function init
-------------------------------------
function GameAuto_Hero:init(world, game_mana, ui)
    self.m_inGameUI = ui

    -- 전투 시작 시 자동모드 설정 처리
    local is_auto_mode = g_autoPlaySetting:get('auto_mode')

    if (self.m_world.m_gameMode == GAME_MODE_INTRO) then
        -- 인트로에서는 비활성화시킴
        is_auto_mode = false

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
		self:refreshUnitListSortedByPriority()

    end
end

-------------------------------------
-- function makeUnitListSortedByPriority
-- @brief state 상태에서의 우선순위별 해당하는 스킬 보유자 리스트를 만듬
-------------------------------------
function GameAuto_Hero:makeUnitListSortedByPriority(state)
    local list = PARENT.makeUnitListSortedByPriority(self, state)

	-- 모험모드 및 쫄작 옵션 체크
	if (not self.m_world:isDragonFarming()) then
		return list
	end

    local new_list = {}

	-- 쫄작(farming) 시 쫄작기사(farmer)가 아니면 제외시킴
	for priority, l_unit in ipairs(list) do
		new_list[priority] = {}
		for _, unit in ipairs(l_unit) do 
			if (unit:isFarmer()) then
				table.insert(new_list[priority], unit)
			end
		end
	end

    return new_list
end

-------------------------------------
-- function refreshUnitListSortedByPriority
-- @brief 연속전투 옵션 중 쫄작 기능 변경 시 호출하여 스킬 사용 우선 순위 리스트 변경함
-- @comment 인게임 중 변경 시에만 호출 됨
-------------------------------------
function GameAuto_Hero:refreshUnitListSortedByPriority()
	local state = (self.m_teamState == 0) and 1 or self.m_teamState
	self.m_lUnitListPerPriority = self:makeUnitListSortedByPriority(state)
end