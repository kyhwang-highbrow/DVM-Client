local PARENT = GameState_Arena

-------------------------------------
-- class GameState_EventArena
-------------------------------------
GameState_EventArena = class(PARENT, {})

-------------------------------------
-- function initEnrage
-- @brief 광폭화 관련 초기화값 설정
-------------------------------------
function GameState_EventArena:initEnrage()
    PARENT.initEnrage(self)

    -- 배경 연출 정보 설정
    -- 그랜드 콜로세움 배경은 콜로세움의 광폭화 배경을 사용
    -- 중간에 별도로 변경하지 않음
    self.m_tEnrageBgInfo = {}
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameState_EventArena:initState()
    PARENT.initState(self)

    self:addState(GAME_STATE_START, GameState_EventArena.update_start)
end

-------------------------------------
-- function getCameraSacle
-- @brief 그랜드 콜로세움은 10대10으로
--        5대5인 콜로세움보다 줌아웃을 더 하게됨
--        배경 이미지가 작아서 위아래로 잘림
--        해상도에 따라서 줌아웃을 조절하여 해결
-------------------------------------
function GameState_EventArena:getCameraSacle()
    local visibleSize = cc.Director:getInstance():getVisibleSize()

    local curr_height = visibleSize.height

    local min_height = 720 -- 최소 height
    local max_height = 960 -- 최대 height (아이패드 4:3비율)

    local min_scale = 0.75 -- 최소 height에서의 줌아웃
    local max_scale = 0.95 -- 최대 height에서의 줌아웃

    local gap = (curr_height - min_height)
    local ratio = gap / (max_height - min_height)
    local scale = min_scale + ((max_scale - min_scale) * ratio)

    return scale
end

-------------------------------------
-- function update_start
-------------------------------------
function GameState_EventArena.update_start(self, dt)
    local world = self.m_world

    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            -- 아군 적군 드래곤들을 모두 숨김
            self:disappearAllDragon()

            -- 카메라 초기화
            world.m_gameCamera:reset()

        elseif (self:isPassedStepTime(0.5)) then
            
            -- 카메라 줌인
            world:changeCameraOption({
                pos_x = 0,
                --pos_y = -280,
                pos_y = -250,
                --scale = 1,
                scale = self:getCameraSacle(),
                time = 2,
                cb = function()
                    self:nextStep()
                end
            })

            world:changeHeroHomePosByCamera(0, 100, 0, true)
            world:changeEnemyHomePosByCamera(0, 100, 0, true)
	    
        end

    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            -- 아군 드래곤 소환
            world.m_tamer.m_animator.m_node:resume()
            
            -- 적군 드래곤 소환
            world.m_enemyTamer.m_animator.m_node:resume()
            
        elseif (self:isPassedStepTime(1)) then
            self:appearHero()
            self:appearEnemy()

            SoundMgr:playEffect('UI', 'ui_summon')

            world:dispatch('dragon_summon')

        elseif (self:getStepTimer() >= 3) then
            self:nextStep()

        end

    elseif (self:getStep() == 2) then
        if (self:isBeginningStep()) then
            -- 카메라 초기화
            world:changeCameraOption({
                pos_x = 0,
                pos_y = 0,
                --scale = 0.6,
                scale = self:getCameraSacle(),
                time = 2,
                cb = function()
                    self:nextStep()
                end
            })

            self.m_world.m_tamer:initBarrier()
            self.m_world.m_enemyTamer:initBarrier()
        end

    elseif (self:getStep() == 3) then
        if (self:isBeginningStep()) then
            
            if (world.m_tamer) then
                world.m_tamer:setAnimatorScale(0.5)
                world.m_tamer.m_barrier:setVisible(true)
            end

            if (world.m_enemyTamer) then
                world.m_enemyTamer:setAnimatorScale(0.5)
                world.m_enemyTamer.m_barrier:setVisible(true)
            end

            self:changeState(GAME_STATE_WAVE_INTERMISSION)
        end
    end
end

-------------------------------------
-- function makeResultUI
-- @param is_win boolean 전투 승리 여부
-------------------------------------
function GameState_EventArena:makeResultUI(is_win)

    -- 연습전 (개발 모드일 경우)
    local world = self.m_world
    if (world.m_bDevelopMode == true) then
        local t_data = { added_rp = 0, added_gold = 0, develop_mode = true }
        UI_EventArenaResult(is_win, t_data)
        return
    end

    local function finish_cb(ret)
        --local t_data = { added_rp = 0, added_gold = 0 }
        local t_data = ret
        UI_EventArenaResult(is_win, t_data)
    end

	-- GameState클래스에서 전투 종료 통신용 데이터 가공
    local t_param = self:makeGameFinishParam(is_win)

    local gamekey = g_gameScene.m_gameKey
    g_grandArena:requestGameFinish(gamekey, is_win, t_param['clear_time'], finish_cb)
end