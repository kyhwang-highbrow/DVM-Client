local PARENT = GameWorld

-------------------------------------
-- class GameWorldForDoubleTeam
-------------------------------------
GameWorldForDoubleTeam = class(PARENT, {
        m_subDeckFormation = 'string',
        m_subDeckFormationLv = 'number',

        m_pcGroup = 'string',   -- 플레이어가 컨트롤 할 수 있는 그룹키(PHYS.HERO_TOP or PHYS.HERO_BOTTOM)
        m_npcGroup = 'string',  -- 플레이어가 컨트롤 할 수 없는 그룹키(PHYS.HERO_TOP or PHYS.HERO_BOTTOM)
    })
    
-------------------------------------
-- function init
-------------------------------------
function GameWorldForDoubleTeam:init()
    -- 조작 덱 설정
    local sel_deck

    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        local attr = TableStageData:getStageAttr(self.m_stageID) 
        local multi_deck_mgr = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, attr)
        sel_deck = multi_deck_mgr:getMainDeck()

    elseif (self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
        local multi_deck_mgr = MultiDeckMgr(MULTI_DECK_MODE.ANCIENT_RUIN)
        sel_deck = multi_deck_mgr:getMainDeck()

    elseif (self.m_gameMode == GAME_MODE_WORLD_RAID) then
        local multi_deck_mgr = MultiDeckMgr(MULTI_DECK_MODE.WORLD_RAID_COOPERATION)
        sel_deck = multi_deck_mgr:getMainDeck()

    -- 그랜드 콜로세움은 자동으로 진행. 조작 가능한 덱이 없음
    elseif (self.m_gameMode == GAME_MODE_EVENT_ARENA) then
        sel_deck = 'up'

    else
        error('invalid game mode : ' .. self.m_gameMode)
    end
    
    if (sel_deck == 'down') then
        self.m_pcGroup = PHYS.HERO_BOTTOM
        self.m_npcGroup = PHYS.HERO_TOP
    else
        self.m_pcGroup = PHYS.HERO_TOP
        self.m_npcGroup = PHYS.HERO_BOTTOM
    end
end

-------------------------------------
-- function createComponents
-------------------------------------
function GameWorldForDoubleTeam:createComponents()
    self.m_gameCamera = GameCamera(self, g_gameScene.m_cameraLayer)
    self.m_gameTimeScale = GameTimeScale(self)
    self.m_gameHighlight = GameHighlightMgr(self, self.m_darkLayer)
    self.m_gameActiveSkillMgr = GameActiveSkillMgr(self)
    self.m_gameDragonSkill = GameDragonSkill(self)
    self.m_shakeMgr = ShakeManager(self, g_gameScene.m_shakeLayer)

    -- 글로벌 쿨타임
    self.m_gameCoolTime = GameCoolTime(self)
    self:addListener('set_global_cool_time_active', self.m_gameCoolTime)

    -- 유닛 그룹별 관리자 생성
    local pc_group = self:getPCGroup()
    local npc_group = self:getNPCGroup()
    local opponent_pc_group = self:getOpponentPCGroup()
    local opponent_npc_group = self:getOpponentNPCGroup()
    
    self.m_mUnitGroup[pc_group] = GameUnitGroup(self, pc_group, self.m_inGameUI)
    self.m_mUnitGroup[pc_group]:createMana(self.m_inGameUI)
    self.m_mUnitGroup[pc_group]:createAuto(self.m_inGameUI)
    self.m_mUnitGroup[pc_group]:setAttackbleGroupKeys({ PHYS.ENEMY, opponent_pc_group })
    
    self.m_mUnitGroup[npc_group] = GameUnitGroup(self, npc_group)
    self.m_mUnitGroup[npc_group]:createMana()
    self.m_mUnitGroup[npc_group]:createAuto()
    self.m_mUnitGroup[npc_group]:setAttackbleGroupKeys({ PHYS.ENEMY, opponent_npc_group })

    for _, group_key in ipairs(self:getEnemyGroups()) do
        self.m_mUnitGroup[group_key] = GameUnitGroup(self, group_key)

        if (self.m_gameMode == GAME_MODE_EVENT_ARENA) then
            self.m_mUnitGroup[group_key]:createMana()
            self.m_mUnitGroup[group_key]:createAuto()
        end

        self.m_mUnitGroup[group_key]:setAttackbleGroupKeys({ self.m_mUnitGroup[group_key]:getOpponentGroupKey() })
    end

    -- 상태 관리자
    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        self.m_gameState = GameState_ClanRaid(self)
        self.m_inGameUI:init_timeUI(false, 0)

    elseif (self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
        self.m_gameState = GameState_AncientRuin(self)
        self.m_inGameUI:init_timeUI(true, 0)

    elseif (self.m_gameMode == GAME_MODE_EVENT_ARENA) then
        self.m_gameState = GameState_Arena(self)
        self.m_inGameUI:init_timeUI(true, 0)

    elseif (self.m_gameMode == GAME_MODE_WORLD_RAID) then
        self.m_gameState = GameState_WorldRaid_Cooperation(self)
        self.m_inGameUI:init_timeUI(true, 0)

    else
        error('invalid game mode : ' .. self.m_gameMode)

    end

    -- 속도 배율 비주얼 처리
    self.m_inGameUI:init_speedUI()
end

-------------------------------------
-- function initGame
-------------------------------------
function GameWorldForDoubleTeam:initGame(stage_name)
    -- 구성 요소들을 생성
    self:createComponents()

    -- 웨이브 매니져 생성
    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        self.m_waveMgr = WaveMgr_ClanRaid(self, stage_name, self.m_stageID, self.m_bDevelopMode)
    elseif (self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
        self.m_waveMgr = WaveMgr(self, stage_name, self.m_stageID, self.m_bDevelopMode)
    elseif (self.m_gameMode == GAME_MODE_WORLD_RAID) then
        self.m_waveMgr = WaveMgr(self, stage_name, self.m_stageID, self.m_bDevelopMode)
    else
        error('invalid game mode : ' .. self.m_gameMode)
    end
        
	-- 배경 생성
    self:initBG(self.m_waveMgr)

    -- 월드 크기 설정
    self:changeWorldSize(1)

	-- Game Log Recorder 생성
	self.m_logRecorder = LogRecorderWorld(self)

    -- 테이머 생성
    self:initTamer()

    -- 덱에 셋팅된 드래곤 생성
    self:makeHeroDeck()

    -- 초기 쿨타임 설정
    --self:initActiveSkillCool(self:getDragonList())
    self:initActiveSkillCool(self.m_mUnitGroup[self:getPCGroup()]:getSurvivorList())
    self:initActiveSkillCool(self.m_mUnitGroup[self:getNPCGroup()]:getSurvivorList())

    -- 초기 마나 설정
    self.m_mUnitGroup[self:getPCGroup()]:getMana():addMana(START_MANA)
    self.m_mUnitGroup[self:getNPCGroup()]:getMana():addMana(START_MANA)

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
-- function setBattleZone
-- @brief 전투영역 설정
-------------------------------------
function GameWorldForDoubleTeam:setBattleZone()

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

        for _, unit in pairs(self.m_mUnitGroup[self:getPCGroup()]:getSurvivorList()) do
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

        for _, unit in pairs(self.m_mUnitGroup[self:getNPCGroup()]:getSurvivorList()) do
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
-- function prepareAuto
-------------------------------------
function GameWorldForDoubleTeam:prepareAuto()
    self.m_mUnitGroup[self:getPCGroup()]:prepareAuto()

    self.m_mUnitGroup[self:getNPCGroup()]:prepareAuto()
    self.m_mUnitGroup[self:getNPCGroup()]:startAuto()
end

-------------------------------------
-- function resetEnemyMana
-------------------------------------
function GameWorldForDoubleTeam:resetEnemyMana()
    local l_group_key = self:getEnemyGroups()
    for _, group_key in ipairs(l_group_key) do
        local mana = self.m_mUnitGroup[group_key]:getMana()
        if (mana) then
            mana:resetMana()
        end
    end
end

-------------------------------------
-- function getPCGroup
-- @brief 조작할 수 있는 그룹(키값)을 리턴
-------------------------------------
function GameWorldForDoubleTeam:getPCGroup()
    return self.m_pcGroup
end

-------------------------------------
-- function getNPCGroup
-- @brief 조작할 수 없는 그룹(키값)을 리턴
-------------------------------------
function GameWorldForDoubleTeam:getNPCGroup()
    return self.m_npcGroup
end

-------------------------------------
-- function getOpponentPCGroup
-- @brief 조작할 수 있는 그룹의 상대편 그룹(키값)을 리턴
-------------------------------------
function GameWorldForDoubleTeam:getOpponentPCGroup()
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
function GameWorldForDoubleTeam:getOpponentNPCGroup()
    if (self:getNPCGroup() == PHYS.HERO_TOP) then
        return PHYS.ENEMY_TOP
    else
        return PHYS.ENEMY_BOTTOM
    end
end

-------------------------------------
-- function getHeroGroups
-------------------------------------
function GameWorldForDoubleTeam:getHeroGroups()
    return { PHYS.HERO_TOP, PHYS.HERO_BOTTOM }
end

-------------------------------------
-- function getEnemyGroups
-------------------------------------
function GameWorldForDoubleTeam:getEnemyGroups()
    return { PHYS.ENEMY, PHYS.ENEMY_TOP, PHYS.ENEMY_BOTTOM }
end

-------------------------------------
-- function onExterminateGroup
-- @brief 아군이나 적군 그룹 중 하나가 전멸되었을때 호출되는 함수
-------------------------------------
function GameWorldForDoubleTeam:onExterminateGroup(group_key)
    -- 팀 전멸 시 남은 팀이 공격 받을 수 있도록 변경
    if (group_key == PHYS.HERO_TOP) then
        self.m_physWorld:modifyGroup(PHYS.HERO_BOTTOM, { PHYS.MISSILE.ENEMY, PHYS.MISSILE.ENEMY_TOP, PHYS.MISSILE.ENEMY_BOTTOM })
    elseif (group_key == PHYS.HERO_BOTTOM) then
        self.m_physWorld:modifyGroup(PHYS.HERO_TOP, { PHYS.MISSILE.ENEMY, PHYS.MISSILE.ENEMY_TOP, PHYS.MISSILE.ENEMY_BOTTOM })
    elseif (group_key == PHYS.ENEMY_TOP) then
        self.m_physWorld:modifyGroup(PHYS.ENEMY_BOTTOM, { PHYS.MISSILE.HERO, PHYS.MISSILE.HERO_TOP, PHYS.MISSILE.HERO_BOTTOM })
    elseif (group_key == PHYS.ENEMY_BOTTOM) then
        self.m_physWorld:modifyGroup(PHYS.ENEMY_TOP, { PHYS.MISSILE.HERO, PHYS.MISSILE.HERO_TOP, PHYS.MISSILE.HERO_BOTTOM })
    end
end