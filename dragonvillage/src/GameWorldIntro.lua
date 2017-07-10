local PARENT = GameWorld

-------------------------------------
-- class GameWorld
-------------------------------------
GameWorldIntro = class(PARENT, {
        m_enemyTamer = '',
		m_lEnemyDragons = '',
    })

-------------------------------------
-- function init
-------------------------------------
function GameWorldIntro:init(game_mode, stage_id, world_node, game_node1, game_node2, game_node3, ui, develop_mode)
    self.m_lEnemyDragons = {}

    -- 적군 AI
    self.m_gameAutoEnemy = GameAuto_Enemy(self, false)

    self.m_gameState = GameState_Intro(self)
    self.m_inGameUI:init_timeUI(true, self.m_gameState.m_limitTime)
    self.m_inGameUI:initIntroFight()
end

-------------------------------------
-- function initTamer
-------------------------------------
function GameWorldIntro:initTamer()
    local t_tamer = g_tamerData:getCurrTamerTable()

    -- 테이머 생성
    self.m_tamer = self:makeTamerNew(t_tamer)

    -- 테이머 UI 생성
	self.m_inGameUI:initTamerUI(self.m_tamer)

    self:addListener('dragon_summon', self)
end

-------------------------------------
-- function makeHeroDeck
-------------------------------------
function GameWorldIntro:makeHeroDeck()

    -- 인트로 전투에 쓰이는 덱은 고정 - 테이블화?
    local l_deck = {120011, 120102, 120431, 120223, 120294}
    local formation = 'attack'
    local deck_name = 'adv'
    local leader = 4

    self.m_deckFormation = formation

    -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
    self.m_myDragons = {}
    
    for i, did in ipairs(l_deck) do
        local t_dragon_data = StructDragonObject()
       
        if (t_dragon_data) then

            t_dragon_data['did'] = did
            t_dragon_data['grade'] = 6
            t_dragon_data['lv'] =  60
            t_dragon_data['evolution'] = 3
            t_dragon_data['skill_0'] = 1

            local is_right = false
            local hero = self:makeDragonNew(t_dragon_data, is_right)
            hero:setInvincibility(true) -- 무적모드
            if (hero) then
                self.m_myDragons[i] = hero
                hero:setPosIdx(tonumber(i))

                self.m_worldNode:addChild(hero.m_rootNode, WORLD_Z_ORDER.HERO)
                self.m_physWorld:addObject(PHYS.HERO, hero)
                self:addHero(hero)

                self.m_leftFormationMgr:setChangePosCallback(hero)

                -- 진형 버프 적용
                hero.m_statusCalc:applyFormationBonus(formation, i)

				-- 리더 등록
				if (i == leader) then
					self.m_leaderDragon = hero
				end
            end
        end
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameWorldIntro:onEvent(event_name, t_event, ...)
    GameWorld.onEvent(self, event_name, t_event, ...)
end

