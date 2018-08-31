local PARENT = CommonMissile

-------------------------------------
-- class CommonMissile_Release
-------------------------------------
CommonMissile_Release = class(PARENT, {
		m_count = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile_Release:init(file_name, body)
end

-------------------------------------
-- function initCommonMissile
-------------------------------------
function CommonMissile_Release:initCommonMissile(owner, t_skill, t_data)
	PARENT.initCommonMissile(self, owner, t_skill, t_data)

	-- release 탄은 한번에 발사한 것으로 고정
	self.m_maxFireCnt = 1
	self.m_count = t_skill['hit']
end

-------------------------------------
-- function setMissile
-------------------------------------
function CommonMissile_Release:setMissile()
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
	
	t_option['dir'] = 0
	t_option['rotation'] = t_option['dir']

    t_option['missile_res_name'] = self.m_missileRes -- 테이블에서 가져오나 하드코딩 가능 
    t_option['attr_name'] = self.m_owner:getAttribute()
    
	t_option['physics_body'] = {0, 0, 20}
	t_option['offset'] = {0, 0}

	t_option['movement'] ='guidtarget' 
    t_option['missile_type'] = 'NORMAL'
	
	t_option['scale'] = self.m_resScale
	t_option['count'] = 2
	t_option['speed'] = self.m_missileSpeed
	t_option['accel'] = 2000
	t_option['h_limit_speed'] = 10000
	t_option['accel_delay'] = 1
    t_option['angular_velocity'] = 0
	--t_option['dir_add'] = 90

	-- "effect" : {}
    t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes
	t_option['effect']['afterimage'] = true

	-----------------------------------------------------------------------------------

	self.m_missileOption = t_option
end

-------------------------------------
-- function fireMissile
-- @breif 여기서는 재정의 해서 사용
-------------------------------------
function CommonMissile_Release:fireMissile()
	local world = self.m_world
	local t_option = self.m_missileOption
	
	local dir_set = nil 

	if self.m_owner.m_bLeftFormation then
		dir_set = {225, 135}
    else
        dir_set = {45, 315}
    end

	-- 같은 시점에서의 반복 공격
	for i = 1, self.m_count do 
		for j = 1, t_option['count'] do
			t_option['dir'] = (dir_set[j] + (math_pow(-1, j) * 15 * (i - 1)))
			world.m_missileFactory:makeMissile(t_option)
		end
		--t_option['accel'] = t_option['accel'] - 500
		t_option['accel_delay'] = t_option['accel_delay'] + 0.2
	end
end

-------------------------------------
-- function makeMissileInstance
-------------------------------------
function CommonMissile_Release:makeMissileInstance(owner, t_skill, t_data)
	local common_missile = CommonMissile_Release()
	common_missile:initCommonMissile(owner, t_skill, t_data)
	common_missile:setMissile()
	common_missile:changeState('attack')
	
	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
