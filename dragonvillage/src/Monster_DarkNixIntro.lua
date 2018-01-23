local PARENT = MonsterLua_Boss

-------------------------------------
-- class Monster_DarkNixIntro
-------------------------------------
Monster_DarkNixIntro = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_DarkNixIntro:init(file_name, body, ...)
end

-------------------------------------
-- function init_monster
-------------------------------------
function Monster_DarkNixIntro:init_monster(t_monster, monster_id, level)
    PARENT.init_monster(self, t_monster, monster_id, level)

    -- skill_4에 해당하는 스킬을 인트로용 스킬로 교체
    do
        local skill_id = 239004 -- 인트로용 스킬 아이디

        -- skill_4 스킬을 제거
        self:unsetSkillID(self.m_charTable['skill_4'])

        -- 원본 테이블을 참조하지 않고 복사한 후 skill_4 스킬을 변경
        self.m_charTable = clone(self.m_charTable)
        self.m_charTable['skill_4'] = skill_id

        -- 변경된 스킬을 등록
        local t_skill = TableMonsterSkill():get(skill_id)
        self:setSkillID(t_skill['chance_type'], skill_id, 1)

        -- 경질화 스킬을 제거시킴
        self:unsetSkillID(self.m_charTable['skill_2'])
    end
end

-------------------------------------
-- function initState
-------------------------------------
function Monster_DarkNixIntro:initState()
    PARENT.initState(self)

    self:addState('attack', Monster_DarkNixIntro.st_attack, 'attack', false)
    self:addState('dying', Monster_DarkNixIntro.st_dying, 'skill_1', false, PRIORITY.DYING)
    self:addState('escape', Monster_DarkNixIntro.st_escape, 'idle', true, PRIORITY.DYING)
end

-------------------------------------
-- function st_attack
-------------------------------------
function Monster_DarkNixIntro.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
        local t_skill = owner:getSkillTable(owner.m_reservedSkillId)
        if (t_skill) then
            local skill_id = t_skill['sid']
            local skill_type = t_skill['skill_type']

            if (skill_type == 'skill_heart_of_ruin') then
                SoundMgr:playEffect('EFFECT', 'darknix_shout') -- @memo 드히에서 사용하던 사운드 가져와 사용

            elseif (skill_id == owner.m_charTable['skill_4']) then
                owner.m_world.m_logRecorder:recordLog('boss_special_attack', 1)

            end
        end
    end

    PARENT.st_attack(owner, dt)
end

-------------------------------------
-- function st_dying
-------------------------------------
function Monster_DarkNixIntro.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:setSpeed(0)

        -- 사망 처리 시 StateDelegate Kill!
        owner:killStateDelegate()
        
        if (owner.m_hpNode) then
            owner.m_hpNode:setVisible(false)
        end

        if (owner.m_castingNode) then
            owner.m_castingNode:setVisible(false)
        end

        -- 포효 애니가 끝나면 뒤로 이동
        owner.m_animator:addAniHandler(function()
            owner:changeState('escape')
        end)
    end
end

-------------------------------------
-- function st_escape
-------------------------------------
function Monster_DarkNixIntro.st_escape(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:setMove(owner.pos.x + (CRITERIA_RESOLUTION_X / 2), owner.pos.y, 300)
        owner:setAfterImage(true)
    end

    -- 이동 완료 시 죽임
	if (not owner.m_isOnTheMove) then
        owner:changeState('dead')
    end
end