local PARENT = GameAuto

-------------------------------------
-- class GameAuto_Enemy
-------------------------------------
GameAuto_Enemy = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function GameAuto_Enemy:init(world)
    self:onStart()
end

-------------------------------------
-- function checkSkill
-- @brief 스킬 사용 여부를 확인
-------------------------------------
function GameAuto_Enemy:checkSkill(dragon, t_skill)
    --적군 AI는 쿨타임 기반으로 강제 설정
    return PARENT.checkSkill(self, dragon, t_skill, GAME_AUTO_AI_ATTACK__COOLTIME, GAME_AUTO_AI_HEAL__LOW_HP)
end


-------------------------------------
-- function doSkill
-- @brief 스킬 사용
-------------------------------------
function GameAuto_Enemy:doSkill(dragon, t_skill, target)
    PARENT.doSkill(self, dragon, t_skill, target)

    -- 적군 스킬 캐스팅을 강제 설정
    dragon.m_reservedSkillCastTime = COLOSSEUM__ENEMY_CASTING_TIME

    dragon:changeState('casting')
end

-------------------------------------
-- function isActive
-------------------------------------
function GameAuto_Enemy:getUnitList()
    return self.m_world:getEnemyList()
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameAuto_Enemy:onEvent(event_name, t_event, ...)
    if (event_name == 'enemy_active_skill') then
        self.m_aiDelayTime = GAME_AUTO_AI_DELAY_TIME
    end
end