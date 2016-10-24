local PARENT = CommonMissile

-------------------------------------
-- class CommonMissile_Release
-------------------------------------
CommonMissile_Release = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile_Release:init(file_name, body)
end

-------------------------------------
-- function fireMissile
-------------------------------------
function CommonMissile_Release:fireMissile()
    local t_option = {}
    
	-- 수정 X
	t_option['owner'] = self.m_owner
	t_option['target'] = self.m_target
    t_option['pos_x'] = self.m_owner.pos.x
    t_option['pos_y'] = self.m_owner.pos.y
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['bFixedAttack'] = true
    if (self.m_owner.phys_key == 'hero') then
        t_option['object_key'] = 'missile_h'
    else
        t_option['object_key'] = 'missile_e'
    end

	-- 1번탄
	-- 수정 가능 부분 
	-----------------------------------------------------------------------------------
	
	t_option['dir'] = 135 
	t_option['rotation'] = t_option['dir']

    t_option['missile_res_name'] = self.m_missileRes -- 테이블에서 가져오나 하드코딩 가능 
    t_option['attr_name'] = self.m_owner:getAttribute()
    
	t_option['physics_body'] = {0, 0, 20}
	t_option['offset'] = {0, 0}

	t_option['movement'] ='guidtarget' 
    t_option['missile_type'] = 'NORMAL'
	
	t_option['scale'] = 1
	t_option['count'] = 1
	t_option['period'] = 0
	t_option['speed'] = 800
	t_option['h_limit_speed'] = 2000
	t_option['accel_delay'] = 0.5
    t_option['angular_velocity'] = 0
	t_option['dir_add'] = 0

	-- "effect" : {}
    t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes
	t_option['effect']['afterimage'] = true

	-----------------------------------------------------------------------------------

	-- 2번탄
	local t_option2 = clone(t_option)
	-- 수정 가능 부분 
	-----------------------------------------------------------------------------------

	t_option2['dir'] = 225
	t_option2['rotation'] = t_option2['dir']

	--[[
    t_option2['missile_res_name'] = 'res/missile/missile_arrow/missile_arrow.png' --self.m_missileRes -- 테이블에서 가져오나 하드코딩 가능 
    t_option2['attr_name'] = self.m_owner:getAttribute()
    
	t_option2['physics_body'] = {0, 0, 20}
	t_option2['offset'] = {0, 0}
			
	t_option2['movement'] ='guidtarget' 
    t_option2['missile_type'] = 'NORMAL'
			
	t_option2['scale'] = 1
	t_option2['count'] = 1
	t_option2['period'] = 0
	t_option2['speed'] = 300
	t_option2['h_limit_speed'] = 2000
	t_option2['accel_delay'] = 0.5
    t_option2['angular_velocity'] = 0
	t_option2['dir_add'] = 0
			
	-- "effe2ct" : {}
    t_option2['effect'] = {}
    t_option2['effect']['motion_streak'] = self.m_motionStreakRes
	t_option2['effect']['afterimage'] = true
	]]
	-----------------------------------------------------------------------------------


	-- 발사 
    local world = self.m_world
    world.m_missileFactory:makeMissile(t_option)
	world.m_missileFactory:makeMissile(t_option2)
end

-------------------------------------
-- function makeInstance
-------------------------------------
function CommonMissile_Release:makeInstance(owner, t_skill)
	local common_missile = CommonMissile_Release()
	common_missile:initCommonMissile(owner, t_skill)
	common_missile:changeState('attack')
	
	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
