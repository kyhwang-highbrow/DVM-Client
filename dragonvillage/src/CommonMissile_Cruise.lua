local PARENT = CommonMissile

-------------------------------------
-- class CommonMissile_Cruise
-------------------------------------
CommonMissile_Cruise = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile_Cruise:init(file_name, body)
end

-------------------------------------
-- function setMissile
-------------------------------------
function CommonMissile_Cruise:setMissile()
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

	t_option['dir'] = 90 
	t_option['rotation'] = t_option['dir']
	
    t_option['missile_res_name'] = self.m_missileRes -- 테이블에서 가져오나 하드코딩 가능 
    t_option['attr_name'] = self.m_owner:getAttribute()

    t_option['physics_body'] = {0, 0, 30}
	t_option['offset'] = {0, 30}

	t_option['movement'] ='guidtarget' 
    t_option['missile_type'] = 'NORMAL'
	
	t_option['scale'] = self.m_resScale
	t_option['count'] = 1
	t_option['speed'] = self.m_missileSpeed
	t_option['h_limit_speed'] = 2000
	t_option['accel'] = 10000
	t_option['accel_delay'] = 1
    t_option['angular_velocity'] = 0
	t_option['dir_add'] = 10

    t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes
	
	-----------------------------------------------------------------------------------
	
	self.m_missileOption = t_option
end

-------------------------------------
-- function fireMissile
-------------------------------------
function CommonMissile_Cruise:fireMissile()
	PARENT.fireMissile(self)

	local add_dir = nil 

	if self.m_owner.m_bLeftFormation then
		add_dir = 10
    else
        add_dir = -10
    end

	local t_option = self.m_missileOption
	if (self.m_maxFireCnt) and (self.m_maxFireCnt > 1) then 
		t_option['dir'] = t_option['dir'] + add_dir
		t_option['rotation'] = t_option['dir']
	end
end

-------------------------------------
-- function makeMissileInstance
-------------------------------------
function CommonMissile_Cruise:makeMissileInstance(owner, t_skill, t_data)
	local common_missile = CommonMissile_Cruise()
	common_missile:initCommonMissile(owner, t_skill, t_data)
	common_missile:setMissile()
	common_missile.m_maxFireCnt = 3
	common_missile:changeState('attack')
	
	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
