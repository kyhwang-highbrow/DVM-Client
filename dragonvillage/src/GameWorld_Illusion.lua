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
-- function makeHeroDeck
-------------------------------------
function GameWorld_Illusion:makeHeroDeck()
    -- ������ ����� �巡�� �� ���
    local l_deck, formation, deck_name, leader = g_deckData:getDeck()

    local formation_lv = g_formationData:getFormationInfo(formation)['formation_lv']
    l_deck = g_illusionDungeonData:getDragonDeck()


    self.m_deckFormation = formation
    self.m_deckFormationLv = formation_lv

    -- �����ʽ��� ������
    local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

    -- ���� ���� �巡�� ��ü�� �����ϴ� �뵵 key : ���� idx, value :Dragon
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

                -- ���� ���� ����
                hero.m_statusCalc:applyFormationBonus(formation, formation_lv, i)

                -- �������� ���� ����
                hero.m_statusCalc:applyStageBonus(self.m_stageID)
                hero:setStatusCalc(hero.m_statusCalc)

                -- �����ʽ� ����
                for i, teambonus_data in ipairs(l_teambonus_data) do
                    TeamBonusHelper:applyTeamBonusToDragonInGame(teambonus_data, hero)
                end

				-- ���� ���
				if (i == leader) then
                    self.m_mUnitGroup[PHYS.HERO]:setLeader(hero)
				end
            end
        end
    end
end

-------------------------------------
-- function createComponent
-- @brief ���� ��ҵ��� ����
-------------------------------------
function GameWorld_Illusion:createComponents()
    self.m_gameCamera = GameCamera(self, g_gameScene.m_cameraLayer)
    self.m_gameTimeScale = GameTimeScale(self)
    self.m_gameHighlight = GameHighlightMgr(self, self.m_darkLayer)
    self.m_gameActiveSkillMgr = GameActiveSkillMgr(self)
    self.m_gameDragonSkill = GameDragonSkill(self)
    self.m_shakeMgr = ShakeManager(self, g_gameScene.m_shakeLayer)

    -- �۷ι� ��Ÿ��
    self.m_gameCoolTime = GameCoolTime(self)
    self:addListener('set_global_cool_time_active', self.m_gameCoolTime)

    -- ���� �׷캰 ������ ����
    self.m_mUnitGroup[PHYS.HERO] = GameUnitGroup(self, PHYS.HERO)
    self.m_mUnitGroup[PHYS.HERO]:createMana(self.m_inGameUI)
    self.m_mUnitGroup[PHYS.HERO]:createAuto(self.m_inGameUI)
    self.m_mUnitGroup[PHYS.HERO]:setAttackbleGroupKeys({PHYS.ENEMY})

    self.m_mUnitGroup[PHYS.ENEMY] = GameUnitGroup(self, PHYS.ENEMY)
    self.m_mUnitGroup[PHYS.ENEMY]:createMana()
    self.m_mUnitGroup[PHYS.ENEMY]:createAuto()
    self.m_mUnitGroup[PHYS.ENEMY]:setAttackbleGroupKeys({PHYS.HERO})

    -- ���� ������
    do
        -- ## ��庰 �б� ó��
        local display_wave = true
        local display_time = nil
        self.m_gameState = GameState_ClanRaid(self)
        self.m_inGameUI:init_timeUI(display_wave, 0)

    end

    self:initGold()
    self:setMissileRange()
end
