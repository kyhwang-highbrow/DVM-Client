local PARENT = GameWorld

-------------------------------------
-- class GameWorldClanRaid
-------------------------------------
GameWorldClanRaid = class(PARENT, {
        -- unit
        m_subLeftParticipants = 'table',        -- ������ �������� �Ʊ�
        m_subRightParticipants = 'table',       -- ������ �������� ����(�巡���̶� �� �����̶�� ���⿡ �߰���)
        m_subLeftNonparticipants = 'table',     -- �������� �Ʊ� �� ���� �Ʊ�(��Ȱ ������ ���)
        m_subRightNonparticipants = 'table',    -- �������� ���� �� ���� ����(��Ȱ ������ ���)

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

        m_pcGroup = 'string',   -- �÷��̾ ��Ʈ�� �� �� �ִ� �׷�Ű(PHYS.HERO_TOP or PHYS.HERO_BOTTOM)
        m_npcGroup = 'string',  -- �÷��̾ ��Ʈ�� �� �� ���� �׷�Ű(PHYS.HERO_TOP or PHYS.HERO_BOTTOM)
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

    self.m_pcGroup = PHYS.HERO_TOP
    self.m_npcGroup = PHYS.HERO_BOTTOM
end

-------------------------------------
-- function createComponent
-------------------------------------
function GameWorldClanRaid:createComponents()
    self.m_gameCamera = GameCamera(self, g_gameScene.m_cameraLayer)
    self.m_gameTimeScale = GameTimeScale(self)
    self.m_gameHighlight = GameHighlightMgr(self, self.m_darkLayer)
    self.m_gameDragonSkill = GameDragonSkill(self)
    self.m_shakeMgr = ShakeManager(self, g_gameScene.m_shakeLayer)

    -- �۷ι� ��Ÿ��
    self.m_gameCoolTime = GameCoolTime(self)
    self:addListener('set_global_cool_time_passive', self.m_gameCoolTime)
    self:addListener('set_global_cool_time_active', self.m_gameCoolTime)

    -- ���� ������ ����
    self.m_heroMana = GameMana(self, self:getPCGroup())
    self.m_heroMana:bindUI(self.m_inGameUI)
    self.m_subHeroMana = GameMana(self, self:getNPCGroup())

    -- �Ʊ� �ڵ��� AI
    do
        self.m_heroAuto = GameAuto_Hero(self, self.m_heroMana, self.m_inGameUI)
        self:addListener('auto_start', self.m_heroAuto)
        self:addListener('auto_end', self.m_heroAuto)

        self.m_subHeroAuto = GameAuto_Hero(self, self.m_subHeroMana)
    end

    -- ���� ������
    do
        self.m_gameState = GameState_ClanRaid(self)
        self.m_inGameUI:init_timeUI(false, self.m_gameState.m_limitTime)
    end
end

-------------------------------------
-- function initGame
-------------------------------------
function GameWorldClanRaid:initGame(stage_name)
    -- ���� ��ҵ��� ����
    self:createComponents()

    -- ���̺� �Ŵ��� ����
    self.m_waveMgr = WaveMgr_ClanRaid(self, stage_name, self.m_stageID, self.m_bDevelopMode)
        
	-- ��� ����
    self:initBG(self.m_waveMgr)

    -- ���� ũ�� ����
    self:changeWorldSize(1)
        
    -- ��ġ ǥ�� ����Ʈ ����
    self:init_formation()

	-- Game Log Recorder ����
	self.m_logRecorder = LogRecorderWorld(self)

    -- ���̸� ����
    self:initTamer()

    -- ���� ���õ� �巡�� ����
    self:makeHeroDeck()

    -- �ʱ� ��Ÿ�� ����
    self:initActiveSkillCool(self:getDragonList())

    -- �ʱ� ���� ����
    self.m_heroMana:addMana(START_MANA)
    self.m_subHeroMana:addMana(START_MANA)

    -- ���� �ý��� �ʱ�ȭ
    self:setBattleZone()
    
    do -- ��ų ���۰� �ʱ�ȭ
        self.m_skillIndicatorMgr = SkillIndicatorMgr(self)
    end

    do -- ī�޶� �ʱ� ��ġ ������ �ִٸ� ����
        local t_camera = self.m_waveMgr:getBaseCameraScriptData()
        if t_camera then
            t_camera['time'] = 0
            self:changeCameraOption(t_camera)
        end
    end

    -- �� �̵� ó���� ���� �Ŵ��� ����
    do
        local t_movement = self.m_waveMgr:getMovementScriptData()
        if (t_movement) then
            self.m_enemyMovementMgr = EnemyMovementMgr(self, t_movement)
        end
    end
    
    -- Game Log Recorder ����
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

    -- ���� ����
    self.m_subLeftFormationMgr = FormationMgr(true)
    self.m_subLeftFormationMgr:setSplitPos(20, 122)

    self.m_gameCamera:addListener('camera_set_home', self.m_subLeftFormationMgr)

    -- ������ ����
    self.m_subRightFormationMgr = FormationMgr(false)
    self.m_subRightFormationMgr:setSplitPos(1280-20, 200)

    self.m_gameCamera:addListener('camera_set_home', self.m_subRightFormationMgr)
end

-------------------------------------
-- function findTarget
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
        if v:isDead() then
        elseif l_remove and table.find(l_remove, v.phys_idx) then
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
-- @brief �������� ����
-------------------------------------
function GameWorldClanRaid:setBattleZone()

    local rage = (70 * 5)

    -- ���� �簢�� ����
    local min_x = 0
    local max_x = rage
    local min_y = -(rage / 2)
    local max_y = (rage / 2)

    -- �巡���� ������ ���� paddingó��
    local padding_x = 20
    local padding_y = 56
    min_x = (min_x + padding_x)
    max_x = (max_x - padding_x)
    min_y = (min_y + padding_y)
    max_y = (max_y - padding_y)

    -- offset ����(ī�޶� ����)
    local cameraHomePosX, cameraHomePosY = self.m_gameCamera:getHomePos()
    local x_start_offset = 150 + 85

    -- ���� ���� ��
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

    -- ���� �Ұ��� ��
    do
        local offset_x = cameraHomePosX + (CRITERIA_RESOLUTION_X / 2) - x_start_offset - rage
        local offset_y = cameraHomePosY + 30

        if (self:getNPCGroup() == PHYS.HERO_TOP) then
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
        
    -- �� Ÿ�Կ� ���� ��������Ʈ
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
	
	-- @TODO �ӽ� ó��
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
            for_mgr_delegate = FormationMgrDelegate(leftFormationMgr)
        else
            for_mgr_delegate = FormationMgrDelegate(rightFormationMgr)
        end

    elseif (team_type == 'enemy') then
        if (bLeftFormation) then
            for_mgr_delegate = FormationMgrDelegate(rightFormationMgr)
        else
            for_mgr_delegate = FormationMgrDelegate(leftFormationMgr)
        end

    elseif (team_type == 'all') then
        for_mgr_delegate = FormationMgrDelegate(leftFormationMgr, rightFormationMgr)
	else
		error('GameWorld:getTargetList ���� ���� ���� team_type  : ' .. team_type)
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

    -- �Ʊ� Ȩ ��ġ�� ī�޶��� Ȩ��ġ �������� ����
    local l_temp = table.merge(self.m_subLeftParticipants, self.m_subLeftNonparticipants)

    if (scale == 0.6) then
        self.m_subLeftFormationMgr:setSplitPos(self.m_leftFormationMgr.m_rearStartX - 200, 122)
        self.m_subRightFormationMgr:setSplitPos(self.m_rightFormationMgr.m_rearEndX + 200, 122)
    end

    for _, v in pairs(l_temp) do
        -- ����� ī�޶� ��ġ�� �°� Ȩ ��ġ ���� �� �̵�
        local homePosX = v.m_orgHomePosX + cameraHomePosX + offsetX
        local homePosY = v.m_orgHomePosY + cameraHomePosY + offsetY

        -- ī�޶� �ܾƿ��� ���¶�� �Ʊ� ��ġ ����(���� ����)
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
    local group_key = char and char['phys_key'] or self:getPCGroup()

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
-- @brief ������ �� �ִ� �׷�(Ű��)�� ����
-------------------------------------
function GameWorldClanRaid:getPCGroup()
    return self.m_pcGroup
end

-------------------------------------
-- function getNPCGroup
-- @brief ������ �� ���� �׷�(Ű��)�� ����
-------------------------------------
function GameWorldClanRaid:getNPCGroup()
    return self.m_npcGroup
end

-------------------------------------
-- function getOpponentPCGroup
-- @brief ������ �� �ִ� �׷��� ����� �׷�(Ű��)�� ����
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
-- @brief ������ �� ���� �׷��� ����� �׷�(Ű��)�� ����
-------------------------------------
function GameWorldClanRaid:getOpponentNPCGroup()
    if (self:getNPCGroup() == PHYS.HERO_TOP) then
        return PHYS.ENEMY_TOP
    else
        return PHYS.ENEMY_BOTTOM
    end
end