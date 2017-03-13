local PARENT = SkillAoERound

-------------------------------------
-- class SkillAoERound_Sura
-------------------------------------
SkillAoERound_Sura = class(PARENT, {
		m_addActivityCarrier = 'ActivityCarrier',
		m_addAttackCount = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoERound_Sura:init(file_name, body, ...)    
end
 
-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoERound_Sura:init_skill(attack_count, range, aoe_res, add_attack_count)
    PARENT.init_skill(self, attack_count, range, aoe_res, nil)

	-- 변수 선언
	self.m_addActivityCarrier = clone(self.m_activityCarrier)
	self.m_addActivityCarrier:setPowerRate(SURA_ADD_POWER_RATE)
	self.m_addActivityCarrier:setAttackType(SURA_ADD_ATK_TYPE)

	self.m_addAttackCount = add_attack_count
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoERound_Sura:initState()
	self:setCommonState(self)
	local add_str = ''
	if (self.m_addAttackCount > 0) then 
		add_str = 'effect_'
	end
    self:addState('start', SkillAoERound.st_appear, add_str .. 'appear', false)
    self:addState('attack', SkillAoERound.st_attack, add_str .. 'idle', true)
	self:addState('disappear', SkillAoERound.st_disappear, add_str .. 'disappear', false)
end

-------------------------------------
-- function setAttackInterval
-- @Overridding
-------------------------------------
function SkillAoERound_Sura:setAttackInterval()
	-- 공격 애니 재생시간을 hit수로 나눔
	self.m_hitInterval = (self.m_animator:getDuration() / self.m_maxAttackCnt)
end

-------------------------------------
-- function doSpecailEffect
-- @Overridding
-------------------------------------
function SkillAoERound_Sura:doSpecailEffect(t_target)
	-- 직접 타격한 대상이 없다면 탈출
	if (not t_target) or (table.count(t_target) == 0) then 
		return 
	end

	-- 랜덤한 순서의 전체 적군 리스트
	local l_enemy_list = table.sortRandom(self.m_owner:getOpponentList())
	for i, enemy in pairs(l_enemy_list) do 
		-- 최대 공격횟수 초과했다면 탈출
		if (i > self.m_addAttackCount) then 
			break
		end

		-- 현재 타겟리스트를 순회하여 스킬의 본공격 대상이라면 제외
		local is_attackable = true
		for _, target in pairs(t_target) do
			if (enemy == target) then
				is_attackable = false
				break
			end
		end
		
		-- 스킬 공격 맞고 있는 대상이 아닐 경우 공격
		if (is_attackable) then
			self:fireMissile(enemy)
		end
	end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillAoERound_Sura:fireMissile(target)
    if (not target) then
        return
    end

    local char = self.m_owner
    local t_option = {}
    
    t_option['target'] = target
    t_option['pos_x'] = self.pos.x
    t_option['pos_y'] = self.pos.y

    t_option['physics_body'] = {0, 0, 20}
    t_option['attack_damage'] = self.m_addActivityCarrier
    t_option['object_key'] = char:getAttackPhysGroup()
	t_option['bFixedAttack'] = true

    t_option['missile_res_name'] = SkillHelper:getAttributeRes(SURA_ADD_MISSILE_RES, char)
	t_option['attr_name'] = self.m_owner:getAttribute()
	t_option['missile_type'] = 'NORMAL'
    t_option['movement'] ='lua_curve' 

    t_option['lua_param'] = {}
    t_option['lua_param']['value1'] = math_random(-SURA_ADD_HEIGHT_RANGE, SURA_ADD_HEIGHT_RANGE)
	t_option['lua_param']['value2'] = 0.5
	t_option['lua_param']['value3'] = 0

	t_option['effect'] = {}
	t_option['effect']['afterimage'] = true

    t_option['cbFunction'] = function()
		-- 타격 카운트 갱신
        self:addHitCount()
	end

    -- 하이라이트
    t_option['highlight'] = self.m_bHighlight
    
	local world = self.m_world
    local missile = world.m_missileFactory:makeMissile(t_option)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound_Sura:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
    local range = t_skill['val_1']		  -- 공격 반경
	local add_attack_count = t_skill['val_2'] -- 추가 공격 한회당 발사하는 탄의 수
	
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스
	local aoe_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)		-- 추가 이펙트를 위해 저장

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoERound_Sura(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, range, aoe_res, add_attack_count)
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
        world.m_gameHighlight:addMissile(skill)
    end
end
