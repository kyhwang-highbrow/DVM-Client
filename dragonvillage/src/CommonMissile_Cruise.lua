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
    if (self.m_owner.phys_key == 'hero') then
        t_option['object_key'] = 'missile_h'
    else
        t_option['object_key'] = 'missile_e'
    end

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
	
	t_option['scale'] = 1
	t_option['count'] = 1
	t_option['period'] = 0.2
	t_option['speed'] = 200
	t_option['h_limit_speed'] = 2000
	t_option['accel'] = 5000
	t_option['accel_delay'] = 0.5
    t_option['angular_velocity'] = 0
	t_option['dir_add'] = 0

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

	local t_option = self.m_missileOption
	if (self.m_maxFireCnt) and (self.m_maxFireCnt > 1) then 
		t_option['dir'] = t_option['dir'] + 10
		t_option['rotation'] = t_option['dir']
	end
end

-------------------------------------
-- function makeInstance
-------------------------------------
function CommonMissile_Cruise:makeInstance(owner, t_skill)
	local common_missile = CommonMissile_Cruise()
	common_missile:initCommonMissile(owner, t_skill)
	common_missile:setMissile()
	common_missile:changeState('attack')
	
	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
