local PARENT = MonsterLua_Boss

-------------------------------------
-- class Monster_DarkNix
-------------------------------------
Monster_DarkNix = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_DarkNix:init(file_name, body, ...)
end

-------------------------------------
-- function initState
-------------------------------------
function Monster_DarkNix:initState()
    PARENT.initState(self)

    self:addState('attack', Monster_DarkNix.st_attack, 'attack', false)
end

-------------------------------------
-- function st_attack
-------------------------------------
function Monster_DarkNix.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
        local t_skill = owner:getSkillTable(owner.m_reservedSkillId)
        if t_skill and t_skill['type'] == 'skill_heart_of_ruin' then
            SoundMgr:playEffect('EFFECT', 'darknix_shout')
        end
    end

    PARENT.st_attack(owner, dt)
end
