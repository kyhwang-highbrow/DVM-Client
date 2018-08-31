local PARENT = CommonMissile

-------------------------------------
-- class CommonMissile_Straight
-------------------------------------
CommonMissile_Straight = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile_Straight:init(file_name, body)
end

-------------------------------------
-- function setMissile
-------------------------------------
function CommonMissile_Straight:setMissile()	
	if (not self.m_target) then return end
	local t_option = {}
    
	-- 수정 X
	t_option['owner'] = self.m_owner
	--t_option['target'] = self.m_target
    t_option['pos_x'] = self.m_attackPos.x
    t_option['pos_y'] = self.m_attackPos.y
    t_option['attack_damage'] = self.m_activityCarrier
	--t_option['bFixedAttack'] = true
    t_option['object_key'] = self.m_owner:getMissilePhysGroup()

	-- 수정 가능 부분
	-----------------------------------------------------------------------------------
	
	t_option['dir'] = self:getDir()
	t_option['rotation'] = t_option['dir']

    t_option['missile_res_name'] = self.m_missileRes -- 테이블에서 가져오나 하드코딩 가능 
    t_option['attr_name'] = self.m_owner:getAttribute()
    
	t_option['physics_body'] = {0, 0, 20}
	t_option['offset'] = {0, 0}

	t_option['movement'] ='normal' 
    t_option['missile_type'] = 'NORMAL'
	
	t_option['scale'] = self.m_resScale
	t_option['count'] = 1
	t_option['speed'] = self.m_missileSpeed
	t_option['h_limit_speed'] = 2000
    t_option['angular_velocity'] = 0
	t_option['dir_add'] = 0

	-- "effect" : {}
    t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes

	-----------------------------------------------------------------------------------

	self.m_missileOption = t_option
end

-------------------------------------
-- function makeMissileInstance
-------------------------------------
function CommonMissile_Straight:makeMissileInstance(owner, t_skill, t_data)
	local common_missile = CommonMissile_Straight()
	common_missile:initCommonMissile(owner, t_skill, t_data)
	common_missile:setMissile()
	common_missile:changeState('attack')
	
	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
