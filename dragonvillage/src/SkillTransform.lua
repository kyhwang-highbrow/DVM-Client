local PARENT = Skill

-------------------------------------
-- class SkillTransform
-------------------------------------
SkillTransform = class(PARENT, {
		m_cid = 'number',       -- 변환될 Character ID(did or mid)
        m_lv = 'number',
        m_dest = 'string'       -- ex) RB17
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillTransform:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillTransform:init_skill(cid, lv, dest)
	PARENT.init_skill(self)

    -- 멤버 변수
    self.m_cid = cid
    self.m_lv = lv
    self.m_dest = dest

    -- 위치 설정
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillTransform:initState()
	self:setCommonState(self)
    self:addState('start', SkillTransform.st_idle, 'idle', false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillTransform.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        local enemy = owner:doTransform()
        
        -- 죽음 애니메이션이 있다
        if (owner.m_owner.m_animator:hasAni('die')) then
            -- 일단 만들어놓은걸 하이드
            enemy.m_rootNode:setVisible(false)

            -- 애니메이션 재생
            owner.m_owner.m_animator:changeAni('die', false)
            owner.m_owner.m_animator:setTimeScale(1)

            -- 후속 애니 등록
            owner.m_owner.m_animator:addAniHandler(function()
                owner.m_owner.m_rootNode:setVisible(false)
		    end)
        end

        owner.m_animator:addAniHandler(function()
            enemy.m_rootNode:setVisible(true)
            owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function doTransform
-------------------------------------
function SkillTransform:doTransform()
    local world = self.m_world
    local pos_x = self.m_owner.pos.x
	local pos_y = self.m_owner.pos.y

    -- 소환자 위치에 몬스터 소환
    local enemy = world.m_waveMgr:spawnEnemy_dynamic(self.m_cid, self.m_lv, 'Appear', nil, self.m_dest, 0.5)
    enemy:setPosition(pos_x, pos_y)
	enemy:setHomePos(pos_x, pos_y)

    -- 세상이 멈춰있는가?
    if (world.m_bPauseMode) then
        enemy:setTemporaryPause(true)
    end

	if (enemy.m_hpNode) then
		enemy.m_hpNode:setVisible(true)
	end

    return enemy
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillTransform:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local cid = t_skill['val_1']
	--local lv = t_skill['val_2']
    local lv = owner.m_lv
    local dest = t_skill['val_3']
	local res = t_skill['res_1']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillTransform(res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(cid, lv, dest)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

	return true
end