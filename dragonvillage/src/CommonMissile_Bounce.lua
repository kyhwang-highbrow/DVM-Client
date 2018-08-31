local PARENT = CommonMissile

-------------------------------------
-- class CommonMissile_Bounce
-------------------------------------
CommonMissile_Bounce = class(PARENT, {
		m_maxCount = '',
		m_jumpHeight = '',
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile_Bounce:init(file_name, body)
end

-------------------------------------
-- function initCommonMissile
-------------------------------------
function CommonMissile_Bounce:initCommonMissile(owner, t_skill, t_data)
	PARENT.initCommonMissile(self, owner, t_skill, t_data)
	
	-- 특수 변수
	self.m_jumpHeight = SkillHelper:getValid(t_skill['val_1'], 100)
	self.m_maxCount = SkillHelper:getValid(t_skill['val_2'], 1)
end

-------------------------------------
-- function setMissile
-------------------------------------
function CommonMissile_Bounce:setMissile()	
	local t_option = {}
    
	-- 수정 X
	t_option['owner'] = self.m_owner
	t_option['target'] = self.m_target
    t_option['target_list'] = self.m_lTarget
    t_option['pos_x'] = self.m_attackPos.x
    t_option['pos_y'] = self.m_attackPos.y
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['object_key'] = self.m_owner:getMissilePhysGroup()

	-- 수정 가능 부분
	-----------------------------------------------------------------------------------
	
	t_option['dir'] = 0 --getDegree(self.m_attackPos.x, self.m_attackPos.y, self.m_target.m_homePosX, self.m_target.m_homePosY) or self:getDefaultDir()
	t_option['rotation'] = t_option['dir']

    t_option['missile_res_name'] = self.m_missileRes -- 테이블에서 가져오나 하드코딩 가능 
    t_option['attr_name'] = self.m_owner:getAttribute()
    
	t_option['physics_body'] = {0, 0, 0}
	t_option['offset'] = {0, 0}

	t_option['movement'] ='lua_bounce' 
    t_option['missile_type'] = 'PASS'
    t_option['disable_body'] = true
	
	t_option['scale'] = self.m_resScale
	t_option['count'] = 1
	t_option['dir_add'] = 0

	-- "effect" : {}
    t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes

	t_option['lua_param'] = {}
    t_option['lua_param']['value1'] = self.m_jumpHeight
	t_option['lua_param']['value2'] = self.m_maxCount
	-----------------------------------------------------------------------------------

	self.m_missileOption = t_option
end

-------------------------------------
-- function makeMissileInstance
-------------------------------------
function CommonMissile_Bounce:makeMissileInstance(owner, t_skill, t_data)
	local common_missile = CommonMissile_Bounce()
	common_missile:initCommonMissile(owner, t_skill, t_data)
	common_missile:setMissile()
	common_missile:changeState('attack')
	
	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
