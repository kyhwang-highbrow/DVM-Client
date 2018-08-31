local PARENT = CommonMissile

-------------------------------------
-- class CommonMissile_High
-------------------------------------
CommonMissile_High = class(PARENT, {
		m_jumpHeight = 'num',
		m_explosionSize = 'num',
		m_explosionRes = 'str',
		m_delayTime = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile_High:init(file_name, body)
end

-------------------------------------
-- function initCommonMissile
-------------------------------------
function CommonMissile_High:initCommonMissile(owner, t_skill, t_data)
	PARENT.initCommonMissile(self, owner, t_skill, t_data)
	
	-- 특수 변수
	local attr = owner:getAttributeForRes()
	self.m_jumpHeight = SkillHelper:getValid(t_skill['val_1'], 100)
	self.m_explosionSize = SkillHelper:getValid(t_skill['val_2'], 100)
	self.m_explosionRes  = string.gsub(t_skill['res_3'], '@', attr)
	self.m_delayTime = 0
end

-------------------------------------
-- function setMissile
-------------------------------------
function CommonMissile_High:setMissile()
    local t_option = {}
    
	-- 수정 X
	t_option['owner'] = self.m_owner
	t_option['target'] = self.m_target
    t_option['pos_x'] = self.m_attackPos.x
    t_option['pos_y'] = self.m_attackPos.y
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['bFixedAttack'] = true
    t_option['object_key'] = self.m_owner:getMissilePhysGroup()

	-- 수정 가능 부분
	-----------------------------------------------------------------------------------
	
	t_option['dir'] = -5
	t_option['rotation'] = t_option['dir']

    t_option['missile_res_name'] = self.m_missileRes -- 테이블에서 가져오나 하드코딩 가능 
    t_option['attr_name'] = self.m_owner:getAttribute()
    
	t_option['physics_body'] = {0, 0, 20}
	t_option['offset'] = {0, 0}

	t_option['movement'] ='lua_angle' 
    t_option['missile_type'] = 'NORMAL'
	
	t_option['scale'] = self.m_resScale
	t_option['count'] = 1
	t_option['dir_add'] = 0

	-- "effect" : {}
    t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes

    t_option['lua_param'] = {}
    t_option['lua_param']['value1'] = self.m_jumpHeight
	t_option['lua_param']['value2'] = self.m_explosionRes
	t_option['lua_param']['value3'] = self.m_explosionSize
	t_option['lua_param']['value4'] = self.m_delayTime

	-----------------------------------------------------------------------------------

	-- t_option['cbFunction']은 atkCallback으로 충돌해야 발생하므로 도착하자마자 터지도록 추가 액션을 넣는다.

	self.m_missileOption = t_option
end

-------------------------------------
-- function fireMissile
-------------------------------------
function CommonMissile_High:fireMissile()
	if (not self.m_target) then return end

    local world = self.m_world
	local t_option = self.m_missileOption
	
	-- 같은 시점에서의 반복 공격
	for i = 1, t_option['count'] do
		local missile = world.m_missileFactory:makeMissile(t_option)

        -- 미사일의 충돌처리를 막기 위한 처리...
        missile.bFixedAttack = false
        
		t_option['dir'] = t_option['dir'] + t_option['dir_add']
	end
end

-------------------------------------
-- function makeMissileInstance
-------------------------------------
function CommonMissile_High:makeMissileInstance(owner, t_skill, t_data)
	local common_missile = CommonMissile_High()
	common_missile:initCommonMissile(owner, t_skill, t_data)
	common_missile:setMissile()
	common_missile:changeState('attack')
	
	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
