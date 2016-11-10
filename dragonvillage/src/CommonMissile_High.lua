local PARENT = CommonMissile

-------------------------------------
-- class CommonMissile_High
-------------------------------------
CommonMissile_High = class(PARENT, {
		m_jumpHeight = 'num',
		m_explosionSize = 'num',
		m_explosionRes = 'str',
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile_High:init(file_name, body)
end

-------------------------------------
-- function initCommonMissile
-------------------------------------
function CommonMissile_High:initCommonMissile(owner, t_skill)
	PARENT.initCommonMissile(self, owner, t_skill)
	
	-- 특수 변수
	local attr = self.m_owner.m_charTable['attr'] or ''
	self.m_jumpHeight = t_skill['val_1']
	self.m_explosionSize = t_skill['val_2']
	self.m_explosionRes  = string.gsub(t_skill['res_3'], '@', attr)
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

	self.m_activityCarrier.m_skillCoefficient = 0	-- high angle 탄은 미사일이 데미지를 주지 않는다.
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['bFixedAttack'] = true

    if (self.m_owner.phys_key == 'hero') then
        t_option['object_key'] = 'missile_h'
    else
        t_option['object_key'] = 'missile_e'
    end

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

	-----------------------------------------------------------------------------------

	-- t_option['cbFunction']은 atkCallback으로 충돌해야 발생하므로 도착하자마자 터지도록 추가 액션을 넣는다.
	t_option['lua_param']['value2'] = function() 
		if (self.m_explosionRes == 'x') then
			self.m_explosionRes = nil
		end
		local attr = self.m_owner.m_charTable['attr'] or ''
		self.m_activityCarrier.m_skillCoefficient = (self.m_powerRate / 100) -- 폭발 시점에서 데미지 전달
		self.m_owner.m_activityCarrier = self.m_activityCarrier
		self.m_owner.m_world.m_missileFactory:makeInstantMissile(self.m_explosionRes, 'center_idle', self.m_target.m_homePosX, self.m_target.m_homePosY, self.m_explosionSize, self.m_owner, {attr_name = attr})
		self:changeState('dying')
	end

	self.m_missileOption = t_option
end

-------------------------------------
-- function makeMissileInstance
-------------------------------------
function CommonMissile_High:makeMissileInstance(owner, t_skill)
	local common_missile = CommonMissile_High()
	common_missile:initCommonMissile(owner, t_skill)
	common_missile:setMissile()
	common_missile:changeState('attack')
	
	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
