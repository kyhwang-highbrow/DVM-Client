local PARENT = GameWorld

-------------------------------------
-- class GameWorldClanRaid
-------------------------------------
GameWorldClanRaid = class(PARENT, {
        -- unit
        m_subLeftParticipants = 'table',        -- 전투에 참여중인 아군
        m_subRightParticipants = 'table',       -- 전투에 참여중인 적군(드래곤이라도 적 진형이라면 여기에 추가됨)
        m_subLeftNonparticipants = 'table',     -- 참여중인 아군 중 죽은 아군(부활 가능한 대상만)
        m_subRightNonparticipants = 'table',    -- 참여중인 적군 중 죽은 적군(부활 가능한 대상만)

        m_leftAllParticipants = 'table',
        m_rightAllParticipants = 'table',

        m_subDeckFormation = 'string',
        m_subDeckFormationLv = 'number',

        m_subHeroMana = 'GameMana',
        m_subHeroAuto = 'GameAuto',

        -- # GameWorld_Formation
        m_subLeftFormationMgr = '',
        m_subRightFormationMgr = '',

        m_subLeaderDragon = 'Dragon',

        m_pcGroup = 'string',   -- 플레이어가 컨트롤 할 수 있는 그룹키(PHYS.HERO_TOP or PHYS.HERO_BOTTOM)
        m_npcGroup = 'string',  -- 플레이어가 컨트롤 할 수 없는 그룹키(PHYS.HERO_TOP or PHYS.HERO_BOTTOM)
    })
    
-------------------------------------
-- function init
-------------------------------------
function GameWorldClanRaid:init()
    self.m_subLeftParticipants = {}
    self.m_subRightParticipants = {}
    self.m_subLeftNonparticipants = {}
    self.m_subRightNonparticipants = {}

    self.m_leftAllParticipants = {}
    self.m_rightAllParticipants = {}

    -- 조작 덱 설정
    local sel_deck = g_clanRaidData:getMainDeck()
    
    if (sel_deck == 'down') then
        self.m_pcGroup = PHYS.HERO_BOTTOM
        self.m_npcGroup = PHYS.HERO_TOP
    else
        self.m_pcGroup = PHYS.HERO_TOP
        self.m_npcGroup = PHYS.HERO_BOTTOM
    end
end

-------------------------------------
-- function createComponent
-------------------------------------
function GameWorldClanRaid:createComponents()
    self.m_gameCamera = GameCamera(self, g_gameScene.m_cameraLayer)
    self.m_gameTimeScale = GameTimeScale(self)
    self.m_gameHighlight = GameHighlightMgr(self, self.m_darkLayer)
    self.m_gameActiveSkillMgr = GameActiveSkillMgr(self)
    self.m_gameDragonSkill = GameDragonSkill(self)
    self.m_shakeMgr = ShakeManager(self, g_gameScene.m_shakeLayer)

    -- 글로벌 쿨타임
    self.m_gameCoolTime = GameCoolTime(self)
    self:addListener('set_global_cool_time_passive', self.m_gameCoolTime)
    self:addListener('set_global_cool_time_active', self.m_gameCoolTime)

    -- 마나 관리자 생성
    self.m_heroMana = GameMana(self, self:getPCGroup())
    self.m_heroMana:bindUI(self.m_inGameUI)
    self.m_subHeroMana = GameMana(self, self:getNPCGroup())
    
    -- 아군 자동시 AI
    do
        self.m_heroAuto = GameAuto_Hero(self, self.m_heroMana, self.m_inGameUI)
        self:addListener('auto_start', self.m_heroAuto)
        self:addListener('auto_end', self.m_heroAuto)

        self.m_subHeroAuto = GameAuto_Hero(self, self.m_subHeroMana)
    end

    -- 상태 관리자
    do
        self.m_gameState = GameState_ClanRaid(self)
        self.m_inGameUI:init_timeUI(false, 0)
    end
end

-------------------------------------
-- function initGame
-------------------------------------
function GameWorldClanRaid:initGame(stage_name)
    -- 구성 요소들을 생성
    self:createComponents()

    -- 웨이브 매니져 생성
    self.m_waveMgr = WaveMgr_ClanRaid(self, stage_name, self.m_stageID, self.m_bDevelopMode)
        
	-- 배경 생성
    self:initBG(self.m_waveMgr)

    -- 월드 크기 설정
    self:changeWorldSize(1)
        
    -- 위치 표시 이펙트 생성
    self:init_formation()

	-- Game Log Recorder 생성
	self.m_logRecorder = LogRecorderWorld(self)

    -- 테이머 생성
    self:initTamer()

    -- 덱에 셋팅된 드래곤 생성
    self:makeHeroDeck()

    -- 초기 쿨타임 설정
    self:initActiveSkillCool(self:getDragonList())

    -- 초기 마나 설정
    self.m_heroMana:addMana(START_MANA)
    self.m_subHeroMana:addMana(START_MANA)

    -- 진형 시스템 초기화
    self:setBattleZone()
    
    do -- 스킬 조작계 초기화
        self.m_skillIndicatorMgr = SkillIndicatorMgr_ClanRaid(self)
    end

    do -- 카메라 초기 위치 설정이 있다면 적용
        local t_camera = self.m_waveMgr:getBaseCameraScriptData()
        if t_camera then
            t_camera['time'] = 0
            self:changeCameraOption(t_camera)
        end
    end

    -- 적 이동 처리를 위한 매니져 생성
    do
        local t_movement = self.m_waveMgr:getMovementScriptData()
        if (t_movement) then
            self.m_enemyMovementMgr = EnemyMovementMgr(self, t_movement)
        end
    end
    
    -- Game Log Recorder 생성
	self.m_logRecorder = LogRecorderWorld(self)

    -- UI
    self.m_inGameUI:doActionReset()
end

-------------------------------------
-- function init_formation
-- @brief
-------------------------------------
function GameWorldClanRaid:init_formation()
    PARENT.init_formation(self)

    -- 왼쪽 진형
    self.m_subLeftFormationMgr = FormationMgr(true)
    self.m_subLeftFormationMgr:setSplitPos(20, 122)

    self.m_gameCamera:addListener('camera_set_home', self.m_subLeftFormationMgr)

    -- 오른쪽 진형
    self.m_subRightFormationMgr = FormationMgr(false)
    self.m_subRightFormationMgr:setSplitPos(1280-20, 200)

    self.m_gameCamera:addListener('camera_set_home', self.m_subRightFormationMgr)
end


-------------------------------------
-- function makePassiveStartEffect
-- @brief
-------------------------------------
function GameWorldClanRaid:makePassiveStartEffect(char, str_map)
    local root_node = PARENT.makePassiveStartEffect(self, char, str_map)

    -- 보스의 경우는 충돌영역 위치로 표시
    if (isInstanceOf(char, Monster_ClanRaidBoss)) then
        -- 실시간 위치 동기화
        root_node:scheduleUpdateWithPriorityLua(function(dt)
            local x, y = char:getCenterPos()
            root_node:setPosition(x, y)
        end, 0)
    end
end

-------------------------------------
-- function findTarget
-- @brief 가장 가까운 대상을 찾음
-------------------------------------
function GameWorldClanRaid:findTarget(group_key, x, y, l_remove)
    local target
    local unitList
    local distance = nil

    if (string.find(group_key, 'enemy')) then
        unitList = self:getEnemyList({phys_key = group_key})
    else
        unitList = self:getDragonList({phys_key = group_key})
    end

    for i,v in pairs(unitList) do
        if (v:isDead()) then
        elseif (l_remove and table.find(l_remove, v.phys_idx)) then
        else
            local dist = getDistance(x, y, v.pos.x + v.body.x, v.pos.y + v.body.y)
            if (not distance) or (dist < distance) then
                distance = dist
                target = v
            end
        end
    end

    return target
end

-------------------------------------
-- function setBattleZone
-- @brief 전투영역 설정
-------------------------------------
function GameWorldClanRaid:setBattleZone()

    local rage = (70 * 5)

    -- 실제 사각형 영역
    local min_x = 0
    local max_x = rage
    local min_y = -(rage / 2)
    local max_y = (rage / 2)

    -- 드래곤의 포지션 영역 padding처리
    local padding_x = 20
    local padding_y = 56
    min_x = (min_x + padding_x)
    max_x = (max_x - padding_x)
    min_y = (min_y + padding_y)
    max_y = (max_y - padding_y)

    -- offset 지정(카메라 역할)
    local cameraHomePosX, cameraHomePosY = self.m_gameCamera:getHomePos()
    local x_start_offset = 150 + 85

    -- 조작 가능 덱
    do
        local offset_x = cameraHomePosX + (CRITERIA_RESOLUTION_X / 2) - x_start_offset - rage
        local offset_y = cameraHomePosY + 30
        
        if (self:getPCGroup() == PHYS.HERO_TOP) then
            offset_y = offset_y + 250
        else
            offset_y = offset_y - 270
        end

        local l_pos_list = TableFormation:getFormationPositionList(self.m_deckFormation, 
            (min_x + offset_x),
            (max_x + offset_x),
            (min_y + offset_y),
            (max_y + offset_y)
        )

        for _, unit in pairs(self.m_leftParticipants) do
            local pos_idx = unit:getPosIdx()
            local pos_x = l_pos_list[pos_idx]['x']
            local pos_y = l_pos_list[pos_idx]['y']
        
            unit:setOrgHomePos(pos_x, pos_y)     
            unit:setHomePos(pos_x, pos_y)
            unit:setPosition(pos_x, pos_y)
        end
    end

    -- 조작 불가능 덱
    do
        local offset_x = cameraHomePosX + (CRITERIA_RESOLUTION_X / 2) - x_start_offset - rage
        local offset_y = cameraHomePosY + 30

        if (self:getNPCGroup() == PHYS.HERO_TOP) then
            offset_y = offset_y + 250
        else
            offset_y = offset_y - 270
        end

        local l_pos_list = TableFormation:getFormationPositionList(self.m_subDeckFormation, 
            (min_x + offset_x),
            (max_x + offset_x),
            (min_y + offset_y),
            (max_y + offset_y)
        )

        for _, unit in pairs(self.m_subLeftParticipants) do
            local pos_idx = unit:getPosIdx()
            local pos_x = l_pos_list[pos_idx]['x']
            local pos_y = l_pos_list[pos_idx]['y']
        
            unit:setOrgHomePos(pos_x, pos_y)     
            unit:setHomePos(pos_x, pos_y)
            unit:setPosition(pos_x, pos_y)
        end
    end
end

-------------------------------------
-- function getTargetList
-------------------------------------
function GameWorldClanRaid:getTargetList(char, x, y, team_type, formation_type, rule_type, t_data)
    local bLeftFormation = char.m_bLeftFormation
	local t_data = t_data or {}

    t_data['self'] = char
    t_data['team_type'] = team_type
    
    -- 팀 타입에 따른 델리게이트
    local for_mgr_delegate = nil
    local leftFormationMgr = self.m_leftFormationMgr
    local rightFormationMgr = self.m_rightFormationMgr

    if (bLeftFormation) then
        if (char:getPhysGroup() == self:getNPCGroup()) then
            leftFormationMgr = self.m_subLeftFormationMgr
            rightFormationMgr = self.m_subRightFormationMgr
        end
    else
        if (char:getPhysGroup() == self:getOpponentNPCGroup()) then
            leftFormationMgr = self.m_subLeftFormationMgr
            rightFormationMgr = self.m_subRightFormationMgr
        end
    end
	
	-- @TODO 임시 처리
    if (team_type == 'self') then
		if (bLeftFormation) then
            for_mgr_delegate = FormationMgrDelegate(leftFormationMgr)
        else
            for_mgr_delegate = FormationMgrDelegate(rightFormationMgr)
        end

    elseif (team_type == 'teammate') then
        if (bLeftFormation) then
            for_mgr_delegate = FormationMgrDelegate(leftFormationMgr)
        else
            for_mgr_delegate = FormationMgrDelegate(rightFormationMgr)
        end

    elseif (team_type == 'ally') then
        if (bLeftFormation) then
            if (rule_type == 'all' and self.m_leftFormationMgr ~= self.m_subLeftFormationMgr) then
                for_mgr_delegate = FormationMgrDelegate(self.m_leftFormationMgr, self.m_subLeftFormationMgr)
            else
                for_mgr_delegate = FormationMgrDelegate(leftFormationMgr)
            end
        else
            if (rule_type == 'all' and self.m_rightFormationMgr ~= self.m_subRightFormationMgr) then
                for_mgr_delegate = FormationMgrDelegate(self.m_rightFormationMgr, self.m_subRightFormationMgr)
            else
                for_mgr_delegate = FormationMgrDelegate(rightFormationMgr)
            end
        end

    elseif (team_type == 'enemy') then
        if (bLeftFormation) then
            if (rule_type == 'all' and self.m_rightFormationMgr ~= self.m_subRightFormationMgr) then
                for_mgr_delegate = FormationMgrDelegate(self.m_rightFormationMgr, self.m_subRightFormationMgr)
            else
                for_mgr_delegate = FormationMgrDelegate(rightFormationMgr)
            end
        else
            if (rule_type == 'all' and self.m_leftFormationMgr ~= self.m_subLeftFormationMgr) then
                for_mgr_delegate = FormationMgrDelegate(self.m_leftFormationMgr, self.m_subLeftFormationMgr)
            else
                for_mgr_delegate = FormationMgrDelegate(leftFormationMgr)
            end
        end

    elseif (team_type == 'all') then
        for_mgr_delegate = FormationMgrDelegate(leftFormationMgr, rightFormationMgr)
	else
		error('GameWorld:getTargetList 정의 되지 않은 team_type  : ' .. team_type)
    end

    return for_mgr_delegate:getTargetList(x, y, team_type, formation_type, rule_type, t_data)
end

-------------------------------------
-- function changeSubHeroHomePosByCamera
-------------------------------------
function GameWorldClanRaid:changeHeroHomePosByCamera(offsetX, offsetY, move_time, no_tamer)
    PARENT.changeHeroHomePosByCamera(self, offsetX, offsetY, move_time, no_tamer)

    self:changeSubHeroHomePosByCamera(offsetX, offsetY, move_time)
end

-------------------------------------
-- function changeSubHeroHomePosByCamera
-------------------------------------
function GameWorldClanRaid:changeSubHeroHomePosByCamera(offsetX, offsetY, move_time)
    local scale = self.m_gameCamera:getScale()
    local cameraHomePosX, cameraHomePosY = self.m_gameCamera:getHomePos()
    local gap_x, gap_y = self.m_gameCamera:getIntermissionOffset()
    local offsetX = offsetX or 0
    local offsetY = offsetY or 0
    local move_time = move_time or getInGameConstant("WAVE_INTERMISSION_TIME")

    -- 아군 홈 위치를 카메라의 홈위치 기준으로 변경
    local l_temp = table.merge(self.m_subLeftParticipants, self.m_subLeftNonparticipants)

    if (scale == 0.6) then
        self.m_subLeftFormationMgr:setSplitPos(self.m_leftFormationMgr.m_rearStartX - 200, 122)
    end

    for _, v in pairs(l_temp) do
        -- 변경된 카메라 위치에 맞게 홈 위치 변경 및 이동
        local homePosX = v.m_orgHomePosX + cameraHomePosX + offsetX
        local homePosY = v.m_orgHomePosY + cameraHomePosY + offsetY

        -- 카메라가 줌아웃된 상태라면 아군 위치 조정(차후 정리)
        if (scale == 0.6) then
            homePosX = homePosX - 200
        end
            
        v:changeHomePosByTime(homePosX, homePosY, move_time)
    end
end

-------------------------------------
-- function prepareAuto
-------------------------------------
function GameWorldClanRaid:prepareAuto()
    if (self.m_heroAuto) then
        self.m_heroAuto:prepare(self.m_leftParticipants)
    end
    if (self.m_subHeroAuto) then
        self.m_subHeroAuto:prepare(self.m_subLeftParticipants)
        self.m_subHeroAuto:onStart()
    end
end

-------------------------------------
-- function updateAuto
-------------------------------------
function GameWorldClanRaid:updateAuto(dt)
    if (self.m_heroAuto) then
        self.m_heroAuto:update(dt)
    end
    if (self.m_subHeroAuto) then
        self.m_subHeroAuto:update(dt)
    end
end

-------------------------------------
-- function updateMana
-------------------------------------
function GameWorldClanRaid:updateMana(dt)
    if (self.m_heroMana) then
        self.m_heroMana:update(dt)
    end
    if (self.m_subHeroMana) then
        self.m_subHeroMana:update(dt)
    end
end

-------------------------------------
-- function getMana
-------------------------------------
function GameWorldClanRaid:getMana(char)
    local group_key = char and char:getPhysGroup() or self:getPCGroup()

    if (group_key == self:getPCGroup()) then
        return self.m_heroMana
    else
        return self.m_subHeroMana
    end
end

-------------------------------------
-- function isAutoPlay
-------------------------------------
function GameWorldClanRaid:isAutoPlay()
    return self.m_heroAuto:isActive()
end
    
-------------------------------------
-- function getPCGroup
-- @brief 조작할 수 있는 그룹(키값)을 리턴
-------------------------------------
function GameWorldClanRaid:getPCGroup()
    return self.m_pcGroup
end

-------------------------------------
-- function getNPCGroup
-- @brief 조작할 수 없는 그룹(키값)을 리턴
-------------------------------------
function GameWorldClanRaid:getNPCGroup()
    return self.m_npcGroup
end

-------------------------------------
-- function getOpponentPCGroup
-- @brief 조작할 수 있는 그룹의 상대편 그룹(키값)을 리턴
-------------------------------------
function GameWorldClanRaid:getOpponentPCGroup()
    if (self:getPCGroup() == PHYS.HERO_TOP) then
        return PHYS.ENEMY_TOP
    else
        return PHYS.ENEMY_BOTTOM
    end
end

-------------------------------------
-- function getOpponentNPCGroup
-- @brief 조작할 수 없는 그룹의 상대편 그룹(키값)을 리턴
-------------------------------------
function GameWorldClanRaid:getOpponentNPCGroup()
    if (self:getNPCGroup() == PHYS.HERO_TOP) then
        return PHYS.ENEMY_TOP
    else
        return PHYS.ENEMY_BOTTOM
    end
end