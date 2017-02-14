local PARENT = Entity

-------------------------------------
-- class CommonMissile
-- @brief 공용탄을 쏘기 위한 클래스, 일종의 간이 미사일런처 
-------------------------------------
CommonMissile = class(PARENT, {
		m_owner = 'Character',
		m_target = 'Charater',

		m_missileRes = 'str',
		m_motionStreakRes = 'str',
		m_resScale = 'num',

		m_powerRate = 'num',
		m_activityCarrier = 'AttackDamage',

		m_lStatusEffectStr = '',

		m_targetType = '', -- target_type 필드, 상대 선택 규칙
        m_attackPos = 'number', -- 캐릭터의 중심을 기준으로 실제 공격이 시작 지점

		m_missileOption = 'table',
		m_missileTimer = 'time',
		m_missileFireTerm = 'time',
		m_fireCnt = 'num',
		m_maxFireCnt = 'num',
		m_missileSpeed = 'num',
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile:init(file_name, body)
end

-------------------------------------
-- function initCommonMissile
-------------------------------------
function CommonMissile:initCommonMissile(owner, t_skill)
    -- 변수 초기화
	self.m_owner = owner
	
	local attr = owner:getAttributeForRes()
	self.m_missileRes = string.gsub(t_skill['res_1'], '@', attr)
	self.m_motionStreakRes = string.gsub(t_skill['res_2'], '@', attr)
	self.m_resScale = t_skill['res_scale']

	self.m_powerRate = t_skill['power_rate']
	self.m_lStatusEffectStr = {t_skill['status_effect_1'], t_skill['status_effect_2']}
	self.m_targetType = t_skill['target_type']
	self.m_maxFireCnt = t_skill['hit']
	self.m_fireCnt = 0

	-- 탄 속도
	if (not t_skill['val_3']) or (t_skill['val_3'] == 0) then
		self.m_missileSpeed = 1000
	else
		self.m_missileSpeed = t_skill['val_3']
	end

	self.m_target = self:getRandomTargetByRule()
	self.m_missileTimer = 0

	self:initActvityCarrier()
	self:initState()
	self:initAttackPos()

	-- resource 체크 
	if (not self.m_missileRes) or (self.m_missileRes == 'x') then
		error('공통탄 .. ' ..  t_skill['type'] .. ' .. 리소스 없음')
	end
	if (self.m_motionStreakRes == 'x') then 
		self.m_motionStreakRes = nil 
	end
end

-------------------------------------
-- function initActvityCarrier
-------------------------------------
function CommonMissile:initActvityCarrier()    
    -- 공격력 계산을 위해
    self.m_activityCarrier = self.m_owner:makeAttackDamageInstance()
    self.m_activityCarrier.m_skillCoefficient = (self.m_powerRate / 100)
	
	-- 상태효과도 담음
    self.m_activityCarrier:insertStatusEffectRate(self.m_lStatusEffectStr)
	
	-- 타격 이벤트에서 일반탄인지 구분할 때 사용
	self.m_activityCarrier:setAttackType('basic') 
end

-------------------------------------
-- function initState
-------------------------------------
function CommonMissile:initState()    
    self:addState('attack', CommonMissile.st_attack, nil, true)
    self:addState('dying', function(owner, dt) return true end, nil, true, 3)
end

-------------------------------------
-- function getRandomTargetByRule()
-- @brief 테이블 target_type 에 따른 랜덤한 타겟 선택 
-------------------------------------
function CommonMissile:getRandomTargetByRule()
    local l_target = self.m_owner:getTargetListByType(self.m_targetType)
    local target = nil

	for i, v in pairs(l_target) do 
		-- @TODO 추가된 캐릭터 일단 제외
		if (not v.m_isSlaveCharacter) then 
			target = v
			break
		end
	end

    if (not target) then
	    cclog('Common Missile : Can not find target')
    end

    return target
end

-------------------------------------
-- function getDir()
-------------------------------------
function CommonMissile:getDir()
	if (not self.m_target) then 
		return self:getDefaultDir() 
	end
	return getDegree(self.m_attackPos.x, self.m_attackPos.y, self.m_target.m_homePosX, self.m_target.m_homePosY) or self:getDefaultDir()
end

-------------------------------------
-- function getDefaultDir()
-- @brief 타겟을 못가져왔을 때 
-------------------------------------
function CommonMissile:getDefaultDir()
	cclog('-- 공용탄 타겟을 못찾아 기본 발사각 0 or 180 으로 발사합니다.')
    if self.m_owner.m_bLeftFormation then   
		return 0
    else                            
		return 180
    end
end

-------------------------------------
-- function initAttackPosOffset
-- @brief 캐릭터의 중심을 기준으로 실제 공격이 시작 지점 설정
-------------------------------------
function CommonMissile:initAttackPos()
    -- 1. 초기화
	local pos_x = self.m_owner.pos.x
	local pos_y = self.m_owner.pos.y
	self.m_attackPos = {x = pos_x, y = pos_y}

	-- 2. attack event 가져옴
    local animator = self.m_owner.m_animator
    local l_event_data = animator:getEventList('attack', 'attack')

	-- 2-1. attack event 못가져오면 탈출
    if (not l_event_data[1]) then
        return
    end

	-- 3. 부여된 값 가져옴
    local string_value = l_event_data[1]['stringValue']

	-- 3-1. 못가져오면 탈출
    if (not string_value) or (string_value == '') then
        return
    end

	-- 4. 정리
    local l_str = seperate(string_value, ',') or {0, 0}
    local scale = animator:getScale()
    local offset_x = (l_str[1] * scale)
    local offset_y = (l_str[2] * scale)

	-- 5. offset 진영에 따라 가감
	if self.m_owner.m_bLeftFormation then   
		pos_x = pos_x + offset_x
		pos_y = pos_y + offset_y
    else                            
		pos_x = pos_x - offset_x
		pos_y = pos_y + offset_y
    end

	-- 6. 조정된 값 저장
	self.m_attackPos = {x = pos_x, y = pos_y}
end
-------------------------------------
-- function setMissile
-------------------------------------
function CommonMissile:setMissile()
	error('KMS - 공용탄은 자식클래스에서 탄을 정의합니다.')
end

-------------------------------------
-- function fireMissile
-------------------------------------
function CommonMissile:fireMissile()
	if (not self.m_target) then return end

    local world = self.m_world
	local t_option = self.m_missileOption
	
	-- 같은 시점에서의 반복 공격
	for i = 1, t_option['count'] do
		world.m_missileFactory:makeMissile(t_option)
		t_option['dir'] = t_option['dir'] + t_option['dir_add']
	end
end

-------------------------------------
-- function st_attack
-------------------------------------
function CommonMissile.st_attack(owner, dt)
	-- 1. missile timer 따로 계산
	owner.m_missileTimer = owner.m_missileTimer + dt
    
	-- 2. state 시작시 처리 작업
	if (owner.m_stateTimer == 0) then
		-- 1일 경우 바로 발사후 종료
		if (owner.m_maxFireCnt == 1) then
			owner:fireMissile()

		-- 값이 있을 경우 기준 시간을 나눠서 간격을 구한다.
		elseif (owner.m_maxFireCnt) then 
			owner.m_missileFireTerm = FIRE_LIMIT_TIME / owner.m_maxFireCnt
			owner.m_missileTimer = owner.m_missileFireTerm
		end
		--cclog('common missile : ' .. owner.m_owner.pos.x .. ', ' .. owner.m_owner.pos.y, '///', owner.m_target.m_homePosX .. ', ' ..  owner.m_target.m_homePosY)  
	end

	-- 3. 발사 
	if (owner.m_missileFireTerm) then 
		if (owner.m_missileTimer >= owner.m_missileFireTerm) and (owner.m_maxFireCnt > owner.m_fireCnt) then
			owner:fireMissile()
			owner.m_missileTimer = owner.m_missileTimer - owner.m_missileFireTerm
			owner.m_fireCnt = owner.m_fireCnt + 1
		end
	end
	
	-- 4. 탈출 조건 : 기준 시간 경과 또는 발사수가 1
	if (owner.m_stateTimer >= FIRE_LIMIT_TIME) or (owner.m_maxFireCnt == 1) then 
		owner:changeState('dying')
        return true
    end

    return false
end

-------------------------------------
-- function makeMissileInstance
-------------------------------------
function CommonMissile:makeMissileInstance(owner, t_skill)
	local common_missile = CommonMissile()
	common_missile:initCommonMissile(owner, t_skill)
	common_missile:setMissile()

	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
