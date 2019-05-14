local PARENT = SceneGame


local LIMIT_TIME = 15
-------------------------------------
-- class SceneGameIllusion
-------------------------------------
SceneGameIllusion = class(PARENT, {
        m_realStartTime = 'number', -- Ŭ�� ���� ���� �ð�
        m_realLiveTimer = 'number', -- Ŭ�� ���� ���� �ð� Ÿ�̸�
        m_enterBackTime = 'number', -- ��׶���� �������� �����ð�

        m_uiPopupTimeOut = 'UI',

        -- ���� ��� ����
        m_bWaitingNet = 'boolean', -- ������ ��� �� ����
    })

-------------------------------------
-- function init
-------------------------------------
function SceneGameIllusion:init(game_key, stage_id, stage_name, develop_mode, friend_match)
    self.m_realStartTime = Timer:getServerTime()
    self.m_realLiveTimer = 0
    self.m_enterBackTime = nil
    self.m_uiPopupTimeOut = nil
    self.m_bWaitingNet = false
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneGameIllusion:prepare()
    -- ���̺� ���ε�(�޸� ������ ����)
    self:addLoading(function()
        TABLE:reloadForGame()
    end)

    self:addLoading(function()

        -- ���̾� ����
        self:init_layer()
        self.m_gameWorld = GameWorld_Illusion(self.m_gameMode, self.m_stageID, self.m_worldLayer, self.m_gameNode1, self.m_gameNode2, self.m_gameNode3, self.m_inGameUI, self.m_bDevelopMode)
        self.m_gameWorld:initGame(self.m_stageName)
        
        -- ��ũ�� ������ �ʱ�ȭ
        self:sceneDidChangeViewSize()
    end)

    self:addLoading(function()
        -- ���ҽ� �����ε�
        self.m_resPreloadMgr:resCaching('res/ui/a2d/colosseum_result/colosseum_result.vrp')

        Translate:a2dTranslate('ui/a2d/ingame_enemy/ingame_enemy.vrp')

        local ret = self.m_resPreloadMgr:loadForColosseum()
        return ret
    end)

    self:addLoading(function()
        UILoader.cache('ingame_result.ui')
        UILoader.cache('ingame_pause.ui')
        return true
    end)

    self:addLoading(function()
		-- �׽�Ʈ ��忡���� ������г� on
		if (IS_TEST_MODE()) then
			self.m_inGameUI:init_debugUI()
		end

		self.m_inGameUI:init_dpsUI()
		self.m_inGameUI:init_panelUI()
    end)
end

-------------------------------------
-- function update
-------------------------------------
function SceneGameIllusion:update(dt)
    PARENT.update(self, dt)

    self:updateRealTimer(dt)
end

-------------------------------------
-- function updateRealTimer
-------------------------------------
function SceneGameIllusion:updateRealTimer(dt)
    local world = self.m_gameWorld
    local game_state = self.m_gameWorld.m_gameState
    
    -- ���� ���� �ð��� ���(��ӿ� ������ ���� �ʵ��� ��)
    local bUpdateRealLiveTimer = false

    if (not world:isPause() or self.m_bPause) then
        bUpdateRealLiveTimer = true
    end

    if (bUpdateRealLiveTimer) then
        self.m_realLiveTimer = self.m_realLiveTimer + (dt / self.m_timeScale)
    end

    -- �ð� ���� üũ �� ó��
    if (self.m_realLiveTimer > LIMIT_TIME and not world:isFinished()) then
        if (self.m_bPause) then
            -- �Ͻ� ���� ������ ��� ��� ���� ���� �� ����
            world:setGameFinish()

            local t_param = game_state:makeGameFinishParam(false)

            -- �� ������
            t_param['damage'] = game_state:getTotalDamage()

            self:networkGameFinish(t_param, {}, function()
                self:showTimeOutPopup()
            end)
        else
            if (game_state and game_state:isTimeOut() == false) then
                game_state:processTimeOut()
            end
        end
    end

    -- UI �ð� ǥ�� ����
    local remain_time = self:getRemainTimer()
    self.m_inGameUI:setTime(remain_time, true)
end

-------------------------------------
-- function getRemainTimer
-------------------------------------
function SceneGameIllusion:getRemainTimer()
    local remain_time = math_max(LIMIT_TIME - self.m_realLiveTimer, 0)
    return remain_time
end