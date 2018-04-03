local PARENT = GameState

-------------------------------------
-- class GameStateForDoubleTeam
-------------------------------------
GameStateForDoubleTeam = class(PARENT, {
        m_bossHp = 'number',
        m_bossMaxHp = 'number',

        -- 더블팀 모드일 경우 보스는 공유 체력 게이지를 사용함
        m_uiBossHp = 'UI_IngameSharedBossHp',
    })

-------------------------------------
-- function init
-------------------------------------
function GameStateForDoubleTeam:init(world)
    self.m_bossMaxHp = SecurityNumberClass(0, false)
    self.m_bossHp = SecurityNumberClass(0, false)
    self.m_uiBossHp = nil
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameStateForDoubleTeam:initState()
    PARENT.initState(self)

    self:addState(GAME_STATE_FIGHT, GameStateForDoubleTeam.update_fight)
    self:addState(GAME_STATE_SUCCESS_WAIT, GameStateForDoubleTeam.update_success_wait)
end

-------------------------------------
-- function update_fight
-------------------------------------
function GameStateForDoubleTeam.update_fight(self, dt)
    local world = self.m_world
    
    if (self.m_stateTimer == 0) then
        if (world.m_waveMgr:isFinalWave()) then
            -- 보스 체력 게이지
            self:makeBossHp()
        end
    end

    PARENT.update_fight(self, dt)
end

-------------------------------------
-- function update_success
-------------------------------------
function GameStateForDoubleTeam.update_success_wait(self, dt)
    if (self.m_stateTimer == 0) then
        if (self.m_uiBossHp) then
            self.m_uiBossHp.root:removeFromParent(true)
            self.m_uiBossHp = nil
        end
    end

    PARENT.update_success_wait(self, dt)
end

-------------------------------------
-- function makeBossHp
-------------------------------------
function GameStateForDoubleTeam:makeBossHp()
    local world = self.m_world
    local boss = world.m_waveMgr.m_lBoss[1]
    local max_hp = boss.m_maxHp
    local hp = boss.m_hp
    
    self.m_bossHp:set(hp)
    self.m_bossMaxHp:set(max_hp)

    -- 체력 게이지 UI 생성
    if (not self.m_uiBossHp) then
        local parent = world.m_inGameUI.root

        self.m_uiBossHp = UI_IngameSharedBossHp(parent, world.m_waveMgr.m_lBoss, true)
    end

    self.m_uiBossHp:refresh(hp, max_hp)
end

-------------------------------------
-- function setBossHp
-------------------------------------
function GameStateForDoubleTeam:setBossHp(hp)
    self.m_bossHp:set(hp)
end

-------------------------------------
-- function onEvent
-- @brief
-------------------------------------
function GameStateForDoubleTeam:onEvent(event_name, t_event, ...)
    PARENT.onEvent(self, event_name, t_event, ...)

    -- 보스 체력 공유 처리
    if (event_name == 'character_set_hp') then
        local prev_hp = t_event['prev_hp']
        local new_hp = t_event['hp']

        -- 이전 체력이 동일한지 검사
        local safed_hp = self.m_bossHp:get()
        if (prev_hp ~= safed_hp) then
            -- 값이 동일하지 않을 경우 해킹인 것으로 간주해서 체력을 깍지 않음
            new_hp = safed_hp
        end

        -- 현재 체력 정보 갱신
        self:setBossHp(new_hp)
    end
end