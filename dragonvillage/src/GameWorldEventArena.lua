local PARENT = GameWorldForDoubleTeam

-------------------------------------
-- class GameWorldEventArena
-------------------------------------
GameWorldEventArena = class(PARENT, {
        m_enemyTamer = '',

		m_lEnemyDragons = '',
        m_bFriendMatch = 'boolean',

        m_enemyDeckFormation = 'string',
        m_enemyDeckFormationLv = 'number',
        m_subEnemyDeckFormation = 'string',
        m_subEnemyDeckFormationLv = 'number',

        m_bStartedAuto = 'boolean', -- 전투 시작시 자동 여부
    })

-------------------------------------
-- function init
-------------------------------------
function GameWorldEventArena:init(game_mode, stage_id, world_node, game_node1, game_node2, game_node3, ui, develop_mode, friend_match)
    self.m_lEnemyDragons = {}
    self.m_bFriendMatch = friend_match or false

    self.m_bStartedAuto = g_autoPlaySetting:get('auto_mode') or false

    if (isWin32()) then
        cclog('연속전투 : ' .. luadump(g_autoPlaySetting:isAutoPlay()))
        cclog('자동모드 : ' .. luadump(self.m_bStartedAuto))
    end

    ui:lockButton()
end

-------------------------------------
-- function createComponents
-------------------------------------
function GameWorldEventArena:createComponents()
    PARENT.createComponents(self)

    for _, group_key in ipairs(self:getEnemyGroups()) do
        self.m_mUnitGroup[group_key]:createMana()
        self.m_mUnitGroup[group_key]:createAuto()
    end

    self.m_gameState = GameState_EventArena(self)
    self.m_inGameUI:init_timeUI(false, self.m_gameState.m_limitTime)
        -- 속도 배율 비주얼 처리
    self.m_inGameUI:init_speedUI()
    -- 적 마나 및 쿨타임 표시 상태인 경우 처리
    if (g_constant:get('DEBUG', 'DISPLAY_ENEMY_MANA_COOLDOWN')) then
        local pc_group = self:getPCGroup()
        local opponent_pc_group = self:getOpponentPCGroup()

        self.m_mUnitGroup[pc_group]:getMana():bindUI(nil)
        self.m_mUnitGroup[opponent_pc_group]:getMana():bindUI(self.m_inGameUI)
    end
end

-------------------------------------
-- function initGame
-------------------------------------
function GameWorldEventArena:initGame(stage_name)
    -- 구성 요소들을 생성
    self:createComponents()

    -- 웨이브 매니져 생성
    self.m_waveMgr = WaveMgr_Arena(self, stage_name, self.m_stageID, self.m_bDevelopMode)
        
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

    -- 적군 덱에 세팅된 드래곤 생성
    self:makeEnemyDeck()

    -- 초기 쿨타임 설정
    --self:initActiveSkillCool(self:getDragonList())
    self:initActiveSkillCool(self.m_mUnitGroup[self:getPCGroup()]:getSurvivorList())
    self:initActiveSkillCool(self.m_mUnitGroup[self:getNPCGroup()]:getSurvivorList())
    
    --self:initActiveSkillCool(self:getEnemyList())
    self:initActiveSkillCool(self.m_mUnitGroup[self:getOpponentPCGroup()]:getSurvivorList())
    self:initActiveSkillCool(self.m_mUnitGroup[self:getOpponentNPCGroup()]:getSurvivorList())

    -- 초기 마나 설정
    self.m_mUnitGroup[self:getPCGroup()]:getMana():addMana(START_MANA_COLOSSEUM)
    self.m_mUnitGroup[self:getNPCGroup()]:getMana():addMana(START_MANA_COLOSSEUM)
    self.m_mUnitGroup[self:getOpponentPCGroup()]:getMana():addMana(START_MANA_COLOSSEUM)
    self.m_mUnitGroup[self:getOpponentNPCGroup()]:getMana():addMana(START_MANA_COLOSSEUM)

    -- 진형 시스템 초기화
    self:setBattleZone()
    self:setBattleZoneForEnemys()
    
    do -- 스킬 조작계 초기화
        self.m_skillIndicatorMgr = SkillIndicatorMgr(self)
    end

    do -- 카메라 초기 위치 설정이 있다면 적용
        local t_camera = self.m_waveMgr:getBaseCameraScriptData()
        if t_camera then
            t_camera['time'] = 0
            self:changeCameraOption(t_camera)
        end
    end

    -- UI
    self.m_inGameUI:doActionReset()
end

-------------------------------------
-- function initBG
-------------------------------------
function GameWorldEventArena:initBG(waveMgr)
    local t_script_data = waveMgr.m_scriptData
    if not t_script_data then return end

    local bg_res = t_script_data['bg']
    local bg_type = t_script_data['bg_type'] or 'default'
	local bg_directing = t_script_data['bg_directing'] or 'floating_1'
    
    if (bg_type == 'animation') then
        self.m_mapManager = AnimationMap(self.m_bgNode, bg_res)

    elseif (bg_type == 'default') then
        self.m_mapManager = ScrollMap(self.m_bgNode)
        self.m_mapManager:setBg(bg_res)
        self.m_mapManager:setSpeed(-100)
        self.m_mapManager:bindCameraNode(g_gameScene.m_cameraLayer)
        self.m_mapManager:bindEventDispatcher(self)

        -- 배경 연출 정보 설정
        -- 그랜드 콜로세움 배경은 콜로세움의 광폭화 배경을 사용
        -- 중간에 별도로 변경하지 않음
        local map_layer = self.m_mapManager.m_tMapLayer[1]
        map_layer.m_animator:changeAni('idle_2', true)
    else
        error('bg_type : ' .. bg_type)
    end
end

-------------------------------------
-- function initTamer
-------------------------------------
function GameWorldEventArena:initTamer()
    local HERO_TAMER_POS_X = 320 - 50
    local ENEMY_TAMER_POS_X = 960 + 50
    --local TAMER_POS_Y = -600
    local TAMER_POS_Y = -580

    -- 아군 테이머 생성
    do
        local user_info = g_grandArena:getPlayerGrandArenaUserInfo()
        local tamer_id = user_info:getDeckTamerID('grand_arena_up')
        local t_tamer_data = clone(g_tamerData:getTamerServerInfo(tamer_id))
        local t_costume_data = g_tamerCostumeData:getCostumeDataWithTamerID(tamer_id)

        self.m_tamer = self:makeTamerNew(t_tamer_data, t_costume_data, false) -- param : t_tamer_data, t_costume_data, bRightFormation)
        self.m_tamer:setPosition(HERO_TAMER_POS_X, TAMER_POS_Y)
        --self.m_tamer:setAnimatorScale(1)
        self.m_tamer:setAnimatorScale(0.9)
        self.m_tamer:changeState('appear_colosseum')
        self.m_tamer.m_animator.m_node:pause()

        self.m_tamer:addListener('hero_tamer_skill_gauge', self)
    end
    
    -- 적군 테이머 생성
    do
        local user_info = g_grandArena:getMatchUserInfo()
        local tamer_id = user_info:getDeckTamerID('grand_arena_up')
        local t_tamer_data = clone(user_info:getDeckTamerInfo('grand_arena_up'))

        --local costume_id = user_info:getDefDeckCostumeID()
        local costume_id = t_tamer_data['costume']
        local t_costume = TableTamerCostume():get(costume_id)
        local t_costume_data = StructTamerCostume(t_costume)
                
        self.m_enemyTamer = self:makeTamerNew(t_tamer_data, t_costume_data, true) -- param : t_tamer_data, t_costume_data, bRightFormation)
        self.m_enemyTamer:setPosition(ENEMY_TAMER_POS_X, TAMER_POS_Y)
        self.m_enemyTamer:setAnimatorScale(1)
        self.m_enemyTamer:changeState('appear_colosseum')
        self.m_enemyTamer.m_animator.m_node:pause()

        self.m_enemyTamer:addListener('enemy_tamer_skill_gauge', self)
    end

    -- 테이머 UI 생성
    self.m_inGameUI:initTamerUI(self.m_tamer, self.m_enemyTamer)
end

-------------------------------------
-- function passiveActivate_Right
-- @brief 패시브 발동
-------------------------------------
function GameWorldEventArena:passiveActivate_Right()
    PARENT.passiveActivate_Right(self)

    -- 테이머 버프
    if (self.m_enemyTamer) then
        self.m_enemyTamer:doSkill_passive()
    end

    -- 적 리더 버프
    self.m_mUnitGroup[self:getOpponentPCGroup()]:doSkill_leader()
    self.m_mUnitGroup[self:getOpponentNPCGroup()]:doSkill_leader()
end

-------------------------------------
-- function changeCameraOption
-------------------------------------
function GameWorldEventArena:changeCameraOption(tParam, bKeepHomePos)
    local tParam = tParam or {}
    
    self.m_gameCamera:setAction(tParam)

    if not bKeepHomePos then
        self.m_gameCamera:setHomeInfo(tParam)
    end
end

-------------------------------------
-- function changeEnemyHomePosByCamera
-------------------------------------
function GameWorldEventArena:changeEnemyHomePosByCamera(offsetX, offsetY, move_time, no_tamer)
    local scale = self.m_gameCamera:getScale()
    local cameraHomePosX, cameraHomePosY = self.m_gameCamera:getHomePos()
    local gap_x, gap_y = self.m_gameCamera:getIntermissionOffset()
    local offsetX = offsetX or 0
    local offsetY = offsetY or 0
    local move_time = move_time or getInGameConstant("WAVE_INTERMISSION_TIME")

    -- 아군 홈 위치를 카메라의 홈위치 기준으로 변경
    for i, v in ipairs(self:getEnemyList()) do
        if (not v:isDead()) then
            -- 변경된 카메라 위치에 맞게 홈 위치 변경 및 이동
            local homePosX = v.m_orgHomePosX + cameraHomePosX + offsetX
            local homePosY = v.m_orgHomePosY + cameraHomePosY + offsetY

            -- 카메라가 줌아웃된 상태라면 적군 위치 조정(차후 정리)
            if (scale == 0.6) then
                homePosX = homePosX + 200
            end

            v:changeHomePosByTime(homePosX, homePosY, move_time)
        end
    end

    if (not no_tamer and self.m_enemyTamer) then
        -- 변경된 카메라 위치에 맞게 홈 위치 변경 및 이동
        local homePosX = self.m_enemyTamer.pos.x + gap_x + offsetX
        local homePosY = self.m_enemyTamer.pos.y + gap_y + offsetY

        -- 카메라가 줌아웃된 상태라면 아군 위치 조정(차후 정리)
        if (scale == 0.6) then
            homePosX = homePosX - 200
        end

        self.m_enemyTamer:changeHomePosByTime(homePosX, homePosY, move_time)
    end

end

-------------------------------------
-- function onEvent
-------------------------------------
function GameWorldEventArena:onEvent(event_name, t_event, ...)
    PARENT.onEvent(self, event_name, t_event, ...)

    if (event_name == 'character_set_hp') then
        local arg = {...}
        local char = arg[1]
        local unitList
        local totalHp = 0
        local totalMaxHp = 0

        if (char.m_bLeftFormation) then
            unitList = self.m_myDragons
        else
            unitList = self.m_lEnemyDragons
        end

        -- 진형에 따라 HP게이지 갱신
        for _, v in pairs(unitList) do
            totalHp = totalHp + v.m_hp
            totalMaxHp = totalMaxHp + v.m_maxHp
        end

        local percentage = (totalHp / totalMaxHp) * 100

        if (char.m_bLeftFormation) then
            self.m_inGameUI:setHeroHpGauge(percentage)
        else
            self.m_inGameUI:setEnemyHpGauge(percentage)
        end

    elseif (event_name == 'hero_tamer_skill_gauge') then
        local cur = t_event['cur']
        local max = t_event['max']

        local percentage = (cur / max) * 100
                
        self.m_inGameUI:setHeroTamerGauge(percentage)

    elseif (event_name == 'enemy_tamer_skill_gauge') then
        local cur = t_event['cur']
        local max = t_event['max']

        local percentage = (cur / max) * 100
                
        self.m_inGameUI:setEnemyTamerGauge(percentage)
        
    end
end

-------------------------------------
-- function prepareAuto
-------------------------------------
function GameWorldEventArena:prepareAuto()
    self.m_mUnitGroup[self:getPCGroup()]:prepareAuto()
    self.m_mUnitGroup[self:getNPCGroup()]:prepareAuto()
    self.m_mUnitGroup[self:getOpponentPCGroup()]:prepareAuto()
    self.m_mUnitGroup[self:getOpponentNPCGroup()]:prepareAuto()
end

-------------------------------------
-- function setBattleZone
-- @brief 전투영역 설정
-------------------------------------
function GameWorldEventArena:setBattleZone()

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
        local offset_y = cameraHomePosY - 50
        local distance = 400
        local half_distance = (distance / 2)
        
        if (self:getPCGroup() == PHYS.HERO_TOP) then
            offset_y = (offset_y + half_distance)
        else
            offset_y = (offset_y - half_distance)
        end

        local l_pos_list = TableFormationArena:getFormationPositionList(self.m_deckFormation, 
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
        local offset_y = cameraHomePosY - 50
        local distance = 400
        local half_distance = (distance / 2)

        if (self:getNPCGroup() == PHYS.HERO_TOP) then
            offset_y = (offset_y + half_distance)
        else
            offset_y = (offset_y - half_distance)
        end

        local l_pos_list = TableFormationArena:getFormationPositionList(self.m_subDeckFormation, 
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
-- function setBattleZoneForEnemys
-- @brief 전투영역 설정
-------------------------------------
function GameWorldEventArena:setBattleZoneForEnemys()

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
        local offset_x = cameraHomePosX + (CRITERIA_RESOLUTION_X / 2) + x_start_offset
        local offset_y = cameraHomePosY - 50
        local distance = 400
        local half_distance = (distance / 2)
        
        if (self:getOpponentPCGroup() == PHYS.ENEMY_TOP) then
            offset_y = (offset_y + half_distance)
        else
            offset_y = (offset_y - half_distance)
        end

        local l_pos_list = TableFormationArena:getFormationPositionList(self.m_enemyDeckFormation, 
            (min_x + offset_x),
            (max_x + offset_x),
            (min_y + offset_y),
            (max_y + offset_y),
            true
        )

        for _, unit in pairs(self.m_mUnitGroup[self:getOpponentPCGroup()]:getSurvivorList()) do
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
        local offset_x = cameraHomePosX + (CRITERIA_RESOLUTION_X / 2) + x_start_offset
        local offset_y = cameraHomePosY - 50
        local distance = 400
        local half_distance = (distance / 2)

        if (self:getOpponentNPCGroup() == PHYS.ENEMY_TOP) then
            offset_y = (offset_y + half_distance)
        else
            offset_y = (offset_y - half_distance)
        end

        local l_pos_list = TableFormationArena:getFormationPositionList(self.m_subEnemyDeckFormation, 
            (min_x + offset_x),
            (max_x + offset_x),
            (min_y + offset_y),
            (max_y + offset_y),
            true
        )

        for _, unit in pairs(self.m_mUnitGroup[self:getOpponentNPCGroup()]:getSurvivorList()) do
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
-- function isPossibleControl
-------------------------------------
function GameWorldEventArena:isPossibleControl()
    -- 항상 조작을 막기 위한 처리(드래곤 터치나 패널 조작)
    if (self.m_bStartedAuto) then
        return false
    else
        return PARENT.isPossibleControl(self)
    end
end

-------------------------------------
-- function makeHeroDeck
-------------------------------------
function GameWorldEventArena:makeHeroDeck()
    local g_data = MultiDeckMgr(MULTI_DECK_MODE.EVENT_ARENA)

    -- 조작할 그룹을 설정
    local sel_deck = g_data:getMainDeck()
    local main_deck_name
    local sub_deck_name

    if (sel_deck == 'up') then
        main_deck_name = g_data:getDeckName('up')
        sub_deck_name = g_data:getDeckName('down')

    elseif (sel_deck == 'down') then
        main_deck_name = g_data:getDeckName('down')
        sub_deck_name = g_data:getDeckName('up')

    else
        error('invalid sel_deck : ' .. sel_deck)
    end

    self.m_myDragons = {}

    -- 조작할 수 있는 덱을 가져옴
    do
        local l_deck, formation, deck_name, leader = g_deckData:getDeck(main_deck_name)
        local formation_lv = 0
    
        self.m_deckFormation = formation
        self.m_deckFormationLv = formation_lv

        -- 팀보너스를 가져옴
        local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

        -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
        for i, doid in pairs(l_deck) do
            local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
            if (t_dragon_data) then
                local status_calc = MakeOwnDragonStatusCalculator(doid, nil, 'pvp')
                local hero = self:makeDragonNew(t_dragon_data, false, status_calc)
                if (hero) then
                    self.m_myDragons[i] = hero
                    hero:setPosIdx(tonumber(i))

                    self.m_worldNode:addChild(hero.m_rootNode, WORLD_Z_ORDER.HERO)
                    self.m_physWorld:addObject(self:getPCGroup(), hero)
                    self:bindHero(hero)
                    self:addHero(hero)

                    -- 진형 버프 적용
                    hero.m_statusCalc:applyArenaFormationBonus(formation, formation_lv, i)

                    -- 스테이지 버프 적용
                    hero.m_statusCalc:applyStageBonus(self.m_stageID)

                    -- 라테아 버프 적용
                    hero.m_statusCalc:applyLairStats(g_lairData:getLairStats())

                    hero:setStatusCalc(hero.m_statusCalc)

                    -- 팀보너스 적용
                    for i, teambonus_data in ipairs(l_teambonus_data) do
                        TeamBonusHelper:applyTeamBonusToDragonInGame(teambonus_data, hero)
                    end

				    -- 리더 등록
				    if (i == leader) then
					    self.m_mUnitGroup[self:getPCGroup()]:setLeader(hero)
				    end
                end
            end
        end
    end

    -- 조작할 수 없는 덱을 가져옴
    do
        local l_deck, formation, deck_name, leader = g_deckData:getDeck(sub_deck_name)
        local formation_lv = 0
    
        self.m_subDeckFormation = formation
        self.m_subDeckFormationLv = formation_lv

        -- 팀보너스를 가져옴
        local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

        for i, doid in pairs(l_deck) do
            local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
            if (t_dragon_data) then
                local status_calc = MakeOwnDragonStatusCalculator(doid, nil, 'pvp')
                local hero = self:makeDragonNew(t_dragon_data, false, status_calc)
                if (hero) then
                    self.m_myDragons[5 + i] = hero
                    hero:setPosIdx(tonumber(i))

                    self.m_worldNode:addChild(hero.m_rootNode, WORLD_Z_ORDER.HERO)
                    self.m_physWorld:addObject(self:getNPCGroup(), hero)
                    self:bindHero(hero)
                    self:addHero(hero)

                    -- 진형 버프 적용
                    hero.m_statusCalc:applyArenaFormationBonus(formation, formation_lv, i)

                    -- 스테이지 버프 적용
                    hero.m_statusCalc:applyStageBonus(self.m_stageID)

                    -- 라테아 버프 적용
                    hero.m_statusCalc:applyLairStats(g_lairData:getLairStats())

                    hero:setStatusCalc(hero.m_statusCalc)

                    -- 팀보너스 적용
                    for i, teambonus_data in ipairs(l_teambonus_data) do
                        TeamBonusHelper:applyTeamBonusToDragonInGame(teambonus_data, hero)
                    end

				    -- 리더 등록
				    if (i == leader) then
					    self.m_mUnitGroup[self:getNPCGroup()]:setLeader(hero)
				    end
                end
            end
        end
    end
end

-------------------------------------
-- function makeEnemyDeck
-------------------------------------
function GameWorldEventArena:makeEnemyDeck()
    local struct_user_info = g_grandArena:getMatchUserInfo()

    -- 출전 중인 적드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
    self.m_lEnemyDragons = {}

    -- 조작할 수 있는 덱을 가져옴
    do
        local deck_name = 'grand_arena_up'
        local l_deck = struct_user_info:getDeck_dragonObjList(deck_name)
        local t_deck_low_data = struct_user_info:getDeckLowData(deck_name)
        local lair_stats = struct_user_info:getLairStats()
        local formation = t_deck_low_data['formation']
        local formation_lv = t_deck_low_data['formationlv']
        local leader = t_deck_low_data['leader']
    
        self.m_enemyDeckFormation = formation
        self.m_enemyDeckFormationLv = formation_lv

        -- 팀보너스를 가져옴
        local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

        -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
        for i, t_dragon_data in pairs(l_deck) do
            if (t_dragon_data) then
                local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data, 'pvp') -- t_dragon_data, game_mode
                local enemy = self:makeDragonNew(t_dragon_data, true, status_calc)
                if (enemy) then
                    self.m_lEnemyDragons[i] = enemy
                    enemy:setPosIdx(tonumber(i))

                    self.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
                    self.m_physWorld:addObject(self:getOpponentPCGroup(), enemy)
                    self:bindEnemy(enemy)
                    self:addEnemy(enemy)

                    -- 진형 버프 적용
                    enemy.m_statusCalc:applyArenaFormationBonus(formation, formation_lv, i)

                    -- 스테이지 버프 적용
                    enemy.m_statusCalc:applyStageBonus(self.m_stageID)

                    -- 라테아 버프 적용(삼뉴체크)
                    enemy.m_statusCalc:applyLairStats(lair_stats)

                    enemy:setStatusCalc(enemy.m_statusCalc)

                    -- 팀보너스 적용
                    for i, teambonus_data in ipairs(l_teambonus_data) do
                        TeamBonusHelper:applyTeamBonusToDragonInGame(teambonus_data, enemy)
                    end

				    -- 리더 등록
				    if (i == leader) then
					    self.m_mUnitGroup[self:getOpponentPCGroup()]:setLeader(enemy)
				    end
                end
            end
        end
    end

    -- 조작할 수 없는 덱을 가져옴
    do
        local deck_name = 'grand_arena_down'
        local l_deck = struct_user_info:getDeck_dragonObjList(deck_name)
        local t_deck_low_data = struct_user_info:getDeckLowData(deck_name)
        local lair_stats = struct_user_info:getLairStats()
        local formation = t_deck_low_data['formation']
        local formation_lv = t_deck_low_data['formationlv']
        local leader = t_deck_low_data['leader']
    
        self.m_subEnemyDeckFormation = formation
        self.m_subEnemyDeckFormationLv = formation_lv

        -- 팀보너스를 가져옴
        local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

        for i, t_dragon_data in pairs(l_deck) do
            if (t_dragon_data) then
                local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data, 'pvp') -- t_dragon_data, game_mode
                local enemy = self:makeDragonNew(t_dragon_data, true, status_calc)
                if (enemy) then
                    self.m_lEnemyDragons[5 + i] = enemy
                    enemy:setPosIdx(tonumber(i))

                    self.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
                    self.m_physWorld:addObject(self:getOpponentNPCGroup(), enemy)
                    self:bindEnemy(enemy)
                    self:addEnemy(enemy)

                    -- 진형 버프 적용 (콜로세움류에서는 진형 버프를 적용하지 않음)
                    enemy.m_statusCalc:applyArenaFormationBonus(formation, formation_lv, i)

                    -- 스테이지 버프 적용
                    enemy.m_statusCalc:applyStageBonus(self.m_stageID)

                    -- 라테아 버프 적용(삼뉴체크)
                    enemy.m_statusCalc:applyLairStats(lair_stats)

                    enemy:setStatusCalc(enemy.m_statusCalc)

                    -- 팀보너스 적용
                    for i, teambonus_data in ipairs(l_teambonus_data) do
                        TeamBonusHelper:applyTeamBonusToDragonInGame(teambonus_data, enemy)
                    end

				    -- 리더 등록
				    if (i == leader) then
					    self.m_mUnitGroup[self:getOpponentNPCGroup()]:setLeader(enemy)
				    end
                end
            end
        end
    end
end

-------------------------------------
-- function print_tamer_skill
-- @brief 테이머 스킬 보기
-------------------------------------
function GameWorldEventArena:print_tamer_skill()
    if (self.m_tamer) then
        self.m_tamer:printSkillManager()
    end

    if (self.m_enemyTamer) then
        self.m_enemyTamer:printSkillManager()
    end
end

-------------------------------------
-- function getRealtimeHpPercentage
-- @brief 현재 각자의 정확한 체력 퍼센트 받악오기
-- return left, right
-------------------------------------
function GameWorldEventArena:getRealtimeHpPercentage()
    local left_totalHp = 0
    local left_totalMaxHp = 0
    local right_totalHp = 0
    local right_totalMaxHp = 0

    -- left
    for _, v in pairs(self.m_myDragons) do
        left_totalHp = left_totalHp + v.m_hp
        left_totalMaxHp = left_totalMaxHp + v.m_maxHp
    end

    -- right
    for _, v in pairs(self.m_lEnemyDragons) do
        right_totalHp = right_totalHp + v.m_hp
        right_totalMaxHp = right_totalMaxHp + v.m_maxHp
    end

    -- devide by zero 방지
    if (left_totalMaxHp == 0) then left_totalMaxHp = 0 end
    if (right_totalMaxHp == 0) then right_totalMaxHp = 0 end

    local left_percentage = (left_totalHp / left_totalMaxHp) * 100
    local right_percentage = (right_totalHp / right_totalMaxHp) * 100

    return left_percentage, right_percentage
end