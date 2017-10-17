local PARENT = GameAuto

-------------------------------------
-- class GameAuto_Colosseum
-------------------------------------
GameAuto_Colosseum = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function GameAuto_Colosseum:init(world, bLeftFormation)
    self:onStart()
end

-------------------------------------
-- function update
-------------------------------------
function GameAuto_Colosseum:update(dt)
    if (not self:isActive()) then return end

    self:update_fight(dt)
end

-------------------------------------
-- function checkSkill
-- @brief 스킬 사용 여부를 확인
-------------------------------------
function GameAuto_Colosseum:checkSkill(dragon, t_skill)
    --적군 AI는 쿨타임 기반으로 강제 설정
    return PARENT.checkSkill(self, dragon, t_skill, GAME_AUTO_AI_ATTACK__COOLTIME, GAME_AUTO_AI_HEAL__LOW_HP)
end


-------------------------------------
-- function doSkill
-- @brief 스킬 사용
-------------------------------------
function GameAuto_Colosseum:doSkill(dragon, t_skill, target)
    PARENT.doSkill(self, dragon, t_skill, target)

    -- 적군 스킬 캐스팅을 강제 설정
    dragon.m_reservedSkillCastTime = COLOSSEUM__ENEMY_CASTING_TIME

    dragon:changeState('casting')
end