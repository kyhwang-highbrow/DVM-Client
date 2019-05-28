local PARENT = GameWorld

-------------------------------------
-- class GameWorld_Illusion
-------------------------------------
GameWorld_Illusion = class(PARENT, {

    })

-------------------------------------
-- function init
-------------------------------------
function GameWorld_Illusion:init(game_mode, stage_id, world_node, game_node1, game_node2, game_node3, ui, develop_mode, friend_match)

end

-------------------------------------
-- function initGame
-------------------------------------
function GameWorld_Illusion:initGame(stage_name)
    -- 구성 요소들을 생성
    self:createComponents()
    self.m_waveMgr = WaveMgr_Illusion(self, stage_name, self.m_stageID, self.m_bDevelopMode)
    
	-- 배경 생성
    self:initBG(self.m_waveMgr)

    -- 월드 크기 설정
    self:changeWorldSize(1)
    
    -- 테이머 생성
    self:initTamer()

    -- 덱에 셋팅된 드래곤 생성
    self:makeHeroDeck()

    -- 친구 드래곤 생성
    self:makeFriendHero()

    -- 초기 쿨타임 설정
    self:initActiveSkillCool(self:getDragonList())
    
    -- 초기 마나 설정
    self.m_mUnitGroup[PHYS.HERO]:getMana():addMana(START_MANA)

    do -- 진형 시스템 초기화
        self:setBattleZone(self.m_deckFormation, true)
    end

    -- 스킬 조작계 초기화
    do
        self.m_skillIndicatorMgr = SkillIndicatorMgr(self)
    end

    -- 드랍 아이템 매니져 생성
    if (self.m_gameMode == GAME_MODE_ADVENTURE) then
        self.m_dropItemMgr = DropItemMgr(self)
    elseif (self.m_gameMode == GAME_MODE_EVENT_GOLD) then
        self.m_dropItemMgr = DropItemMgr_EventGold(self)
    end

    if (self.m_dropItemMgr and self.m_dropItemMgr.m_bActiveAutoItemPick == true) then
        self.m_inGameUI:showAutoItemPickUI()
    end
    
    do -- 카메라 초기 위치 설정이 있다면 적용
        local t_camera = self.m_waveMgr:getBaseCameraScriptData()
        if (t_camera) then
            t_camera['time'] = 0
            self:changeCameraOption(t_camera)
            self:changeHeroHomePosByCamera()
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

	-- mission manager 생성
	if (self.m_gameMode == GAME_MODE_ADVENTURE) then
		if (not self.m_bDevelopMode) then
			self.m_missionMgr = StageMissionMgr(self.m_logRecorder, self.m_stageID)
		end
	end

    -- UI
    self.m_inGameUI:doActionReset()
end

-------------------------------------
-- function makeHeroDeck
-------------------------------------
function GameWorld_Illusion:makeHeroDeck()
    -- 서버에 저장된 드래곤 덱 사용
    local l_deck, formation, deck_name, leader = g_deckData:getDeck()

    local formation_lv = g_formationData:getFormationInfo(formation)['formation_lv']
    l_deck = g_illusionDungeonData:getDragonDeck()


    self.m_deckFormation = formation
    self.m_deckFormationLv = formation_lv

    -- 팀보너스를 가져옴
    local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

    -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
    self.m_myDragons = {}

    for i, doid in pairs(l_deck) do
        local t_dragon_data = g_illusionDungeonData:getDragonDataFromUid(doid)
        if (t_dragon_data) then
            local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)
            local is_right = false
            local hero = self:makeDragonNew(t_dragon_data, is_right, status_calc)
            if (hero) then
                self.m_myDragons[i] = hero
                hero:setPosIdx(tonumber(i))

                self.m_worldNode:addChild(hero.m_rootNode, WORLD_Z_ORDER.HERO)
                self.m_physWorld:addObject(PHYS.HERO, hero)
                self:bindHero(hero)
                self:addHero(hero)

                -- 진형 버프 적용
                hero.m_statusCalc:applyFormationBonus(formation, formation_lv, i)

                -- 스테이지 버프 적용
                hero.m_statusCalc:applyStageBonus(self.m_stageID)
                hero:setStatusCalc(hero.m_statusCalc)

                -- 팀보너스 적용
                for i, teambonus_data in ipairs(l_teambonus_data) do
                    TeamBonusHelper:applyTeamBonusToDragonInGame(teambonus_data, hero)
                end

				-- 리더 등록
				if (i == leader) then
                    self.m_mUnitGroup[PHYS.HERO]:setLeader(hero)
				end
            end
        end
    end
end

-------------------------------------
-- function createComponent
-- @brief 구성 요소들을 생성
-------------------------------------
function GameWorld_Illusion:createComponents()
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
    self.m_mUnitGroup[PHYS.HERO] = GameUnitGroup(self, PHYS.HERO)
    self.m_mUnitGroup[PHYS.HERO]:createMana(self.m_inGameUI)
    self.m_mUnitGroup[PHYS.HERO]:createAuto(self.m_inGameUI)
    self.m_mUnitGroup[PHYS.HERO]:setAttackbleGroupKeys({PHYS.ENEMY})

    self.m_mUnitGroup[PHYS.ENEMY] = GameUnitGroup(self, PHYS.ENEMY)
    self.m_mUnitGroup[PHYS.ENEMY]:createMana()
    self.m_mUnitGroup[PHYS.ENEMY]:createAuto()
    self.m_mUnitGroup[PHYS.ENEMY]:setAttackbleGroupKeys({PHYS.HERO})

    -- 상태 관리자
    do
        -- ## 모드별 분기 처리
        local display_wave = true
        local display_time = nil
        self.m_gameState = GameState_Illusion(self)
        self.m_inGameUI:init_timeUI(display_wave, 0)

    end

    self:initGold()
    self:setMissileRange()
end

-------------------------------------
-- function makeDragonNew
-------------------------------------
function GameWorld_Illusion:makeDragonNew(t_dragon_data, bRightFormation, status_calc)
    local t_dragon_data = t_dragon_data
    local bLeftFormation = not bRightFormation
    local bPossibleRevive = true

	-- dragon 생성 시작
	local size = g_constant:get('INGAME', 'DRAGON_BODY_SIZE') or 20
    local dragon = Dragon(nil, {0, 0, size})
    self:addToUnitList(dragon)

    -- 환상던전 안의 드래곤 애니 세팅
    self:setIllusionDragonAni(dragon, t_dragon_data, bRightFormation)

    if (status_calc) then
        dragon:setStatusCalc(status_calc)
    end

	dragon:initState()
	dragon:initFormation()

    if (self.m_gameMode ~= GAME_MODE_COLOSSEUM and
        self.m_gameMode ~= GAME_MODE_ARENA and
        self.m_gameMode ~= GAME_MODE_CHALLENGE_MODE and
        self.m_gameMode ~= GAME_MODE_EVENT_ARENA and
        bRightFormation) then

        -- 스테이지 버프 적용
        dragon.m_statusCalc:applyStageBonus(self.m_stageID, true)

        -- 광폭화 버프 적용
        self.m_gameState:applyAccumEnrage(dragon)

        -- 스테이지별 hp_ratio 적용.
        local hp_ratio = TableStageData():getValue(self.m_stageID, 'hp_ratio') or 1
        dragon.m_statusCalc:appendHpRatio(hp_ratio)
    
        dragon:setStatusCalc(dragon.m_statusCalc)
    end

    self:dispatch('make_dragon', {['dragon']=dragon, ['is_right']=bRightFormation})

    return dragon
end

-------------------------------------
-- function setIllusionDragonAni
-------------------------------------
function GameWorld_Illusion:setIllusionDragonAni(dragon, t_dragon_data, bRightFormation)
    
    local dragon_id = t_dragon_data['did']
    local bLeftFormation = not bRightFormation
    local bPossibleRevive = true
    
    -- 테이블의 드래곤 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    if (not t_dragon_data['id']) then
        return
    end

    -- 드래곤 보다 앞에 출력됨 , 왜인지 setLocalZOrder가 안 먹힘
    local id = t_dragon_data['id']
    if (string.match(id, 'illusion')) then
        local back_illusion_effect = MakeAnimator('res/effect/effect_illusion/effect_illusion.vrp')
        back_illusion_effect:changeAni('idle_back', true)
        dragon.m_rootNode:addChild(back_illusion_effect.m_node)
    end

    dragon:init_dragon(dragon_id, t_dragon_data, t_dragon, bLeftFormation, bPossibleRevive)

    -- 드래곤 보다 뒤에 출력됨 setLocalZOrder가 안 먹힘
    if (string.match(id, 'illusion')) then
        local front_illusion_effect = MakeAnimator('res/effect/effect_illusion/effect_illusion.vrp')
        front_illusion_effect:changeAni('idle_front', true)
        dragon.m_rootNode:addChild(front_illusion_effect.m_node)
    end
end

-------------------------------------
-- function bindEnemy
-------------------------------------
function GameWorld_Illusion:bindEnemy(enemy)
    PARENT.bindEnemy(self, enemy)
    -- 이벤트
    enemy:addListener('character_set_hp', self.m_gameState)
end