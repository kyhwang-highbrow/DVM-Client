local PARENT = SkillAoESquare

-------------------------------------
-- class SkillAoESquare_Heal
-------------------------------------
SkillAoESquare_Heal = class(PARENT, {
		m_healRate = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoESquare_Heal:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoESquare_Heal:init_skill(skill_width, skill_height, hit, heal_rate)
    PARENT.init_skill(self, skill_width, skill_height, hit)
	
	-- 멤버 변수
	self.m_healRate = heal_rate
	
	-- 위치 설정
	local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
	self:setPosition(self.m_targetPos.x, cameraHomePosY) -- Y좌표값은 화면의 중심으로 세팅
end

-------------------------------------
-- function attack
-------------------------------------
function SkillAoESquare_Heal:attack(target_char)
	if (not target_char) then return end

    if (self.m_owner.m_bLeftFormation == target_char.m_bLeftFormation) then
        -- 아군 회복
        local heal_rate = (self.m_healRate / 100)
        local atk_dmg = self.m_activityCarrier:getStat('atk')
        local heal = HealCalc_M(atk_dmg) * heal_rate
        target_char:healAbs(self.m_owner, heal, false)

        -- 회복 이펙트
        local effect = self.m_world:addInstantEffect('res/effect/effect_heal/effect_heal.vrp', 'idle', target_char.pos.x, target_char.pos.y)
        effect:setScale(1.5)
    else
        PARENT.attack(self, target_char)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoESquare_Heal:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	local skill_width = t_skill['val_1']		-- 공격 반경 가로
	local skill_height = t_skill['val_2']		-- 공격 반경 세로
	
	local heal_rate = t_skill['val_3']			-- 힐량 (공격력 대비)
    local hit = t_skill['hit'] -- 공격 횟수

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoESquare_Heal(missile_res)
	
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
	skill:init_skill(skill_width, skill_height, hit, heal_rate)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        --world.m_gameHighlight:addMissile(skill)
    end
end
