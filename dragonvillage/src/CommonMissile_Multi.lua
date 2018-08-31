local PARENT = CommonMissile

-------------------------------------
-- class CommonMissile_Multi
-------------------------------------
CommonMissile_Multi = class(PARENT, {
		m_lTargetList = 'Character list',
		m_multiCnt = 'num',
		m_maxMultiCnt = 'num'
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile_Multi:init(file_name, body)
end

-------------------------------------
-- function initCommonMissile
-------------------------------------
function CommonMissile_Multi:initCommonMissile(owner, t_skill, t_data)
	PARENT.initCommonMissile(self, owner, t_skill, t_data)
	
	-- 멀티 발사 갯수
	self.m_maxFireCnt = 3
	
	-- 타겟 리스트 생성
	self.m_lTargetList = table.getRandomList(self.m_lTarget, self.m_maxFireCnt)
end

-------------------------------------
-- function setMissile
-------------------------------------
function CommonMissile_Multi:setMissile()	
	if (not self.m_target) then return end
	local t_option = {}
    
	-- 수정 X
	t_option['owner'] = self.m_owner
    t_option['pos_x'] = self.m_attackPos.x
    t_option['pos_y'] = self.m_attackPos.y
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['bFixedAttack'] = true
    t_option['object_key'] = self.m_owner:getMissilePhysGroup()

	-- 수정 가능 부분
	-----------------------------------------------------------------------------------
    t_option['missile_res_name'] = self.m_missileRes 
    t_option['attr_name'] = self.m_owner:getAttribute()
    
	t_option['physics_body'] = {0, 0, 20}
	t_option['offset'] = {0, 0}

	t_option['movement'] ='guide'
    t_option['missile_type'] = 'NORMAL'
	
	t_option['scale'] = self.m_resScale
	t_option['count'] = 1
	t_option['speed'] = self.m_missileSpeed
	t_option['h_limit_speed'] = 2000
    t_option['angular_velocity'] = 0
	t_option['dir_add'] = 0
	t_option['no_rotate'] = true

	-- "effect" : {}
    t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes
	t_option['effect']['afterimage'] = true

	-----------------------------------------------------------------------------------
	
	-- 멀티샷을 위해서 재정의 되어야 하는 부분
	--[[
	t_option['target'] = nil
	t_option['dir'] = self:getDir()
	t_option['rotation'] = t_option['dir']
	t_option['visual'] = ?
	]]

	self.m_missileOption = t_option
end

-------------------------------------
-- function setMultiShot
-------------------------------------
function CommonMissile_Multi:setMultiShot(t_option)
	local idx = self.m_fireCnt + 1

	t_option['target'] = self.m_lTargetList[idx]

	t_option['dir'] = self:getDir(t_option['target'])

	t_option['visual'] = 'missile_0' .. idx
end

-------------------------------------
-- function fireMissile
-------------------------------------
function CommonMissile_Multi:fireMissile()
	if (not self.m_target) then return end

    local world = self.m_world
	local t_option = self.m_missileOption
	self:setMultiShot(t_option)

	-- 같은 시점에서의 반복 공격
	for i = 1, t_option['count'] do
		world.m_missileFactory:makeMissile(t_option)
		t_option['dir'] = t_option['dir'] + t_option['dir_add']
	end
end

-------------------------------------
-- function makeMissileInstance
-------------------------------------
function CommonMissile_Multi:makeMissileInstance(owner, t_skill, t_data)
	local common_missile = CommonMissile_Multi()
	common_missile:initCommonMissile(owner, t_skill, t_data)
	common_missile:setMissile()
	common_missile:changeState('attack')
	
	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
