local PARENT = GameAuto

local GAME_AUTO_AI_DELAY_TIME = 0

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
    return PARENT.checkSkill(self, dragon, t_skill, GAME_AUTO_AI_ATTACK__COOLTIME, GAME_AUTO_AI_HEAL__COOLTIME)
    --return false
end

-------------------------------------
-- function isActive
-------------------------------------
function GameAuto_Enemy:getUnitList()
    local l_ret = {}

    for _, v in ipairs(self.m_world:getEnemyList()) do
        local skill_indivisual_info = v:getLevelingSkillByType('active')
        if (skill_indivisual_info) then
            table.insert(l_ret, v)
        end
    end

    return l_ret
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameAuto_Enemy:onEvent(event_name, t_event, ...)
    if (event_name == 'enemy_active_skill') then
        self.m_aiDelayTime = self:getAiDelayTime()
    end
end

-------------------------------------
-- function getAiDelayTime
-------------------------------------
function GameAuto_Enemy:getAiDelayTime()
    return GAME_AUTO_AI_DELAY_TIME
end