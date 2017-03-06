local PARENT = SkillAoERound

-------------------------------------
-- class SkillAoERound_Alien
-------------------------------------
SkillAoERound_Alien = class(PARENT, {
		m_isReleaseSE = 'bool',
		m_isStartZoom = 'bool',
		m_isZoomAndSlow = 'bool',
		m_zoomTimer = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoERound_Alien:init(file_name, body, ...)    
end
 
-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoERound_Alien:init_skill(attack_count, range, aoe_res, is_release_se)
    PARENT.init_skill(self, attack_count, range, aoe_res, nil)

	-- 멤버 변수
	self.m_isReleaseSE = is_release_se
	self.m_isZoomAndSlow = false
	self.m_isStartZoom = false
	self.m_zoomTimer = 0
end

-------------------------------------
-- function doSpecailEffect_onAppear
-------------------------------------
function SkillAoERound_Alien:doSpecailEffect_onAppear()
	self.m_isStartZoom = true
	local vitual_char = {pos = self.pos}
	self.m_world.m_gameCamera:setTarget(vitual_char, {time = 0.05})

end

-------------------------------------
-- function doSpecailEffect
-- @Overridding
-------------------------------------
function SkillAoERound_Alien:doSpecailEffect()
	if not (self.m_isReleaseSE) then return end

	-- 적을 맞출 횟수
	local release_cnt = #(self:findTarget())
	
	-- 동료 리스트
	local l_fellow = table.sortRandom(self.m_owner:getFellowList())
	
	-- 해제
	for i = 1, release_cnt do 
		for _, fellow in pairs(l_fellow) do 
			if StatusEffectHelper:releaseHarmfulStatusEffect(fellow) then 
				-- 로직화 할수 없는것들은 별도로 테이블에 담고 처리 하는것도 괜찮을것같다
				table.insert(self.m_tSpecialTarget, fellow)
				local owner_pos = self.m_owner.pos
				EffectMotionStreak(self.m_world, owner_pos.x, owner_pos.y, fellow.pos.x, fellow.pos.y, RES_SE_MS)
				break
			end
		end
	end
end

-------------------------------------
-- function update
-------------------------------------
function SkillAoERound_Alien:update(dt)
	-- n초 후에 줌앤슬로우 시작
	if (self.m_isStartZoom) then
		self.m_zoomTimer = self.m_zoomTimer + dt
		if (self.m_zoomTimer > 0.85) then
			self:startZoomAndSlow()
			self.m_zoomTimer = 0
			self.m_isStartZoom = false
		end
	end
	
	-- n초 후에 줌앤슬로우 종료
	if (self.m_isZoomAndSlow) then
		self.m_zoomTimer = self.m_zoomTimer + dt
		if (self.m_zoomTimer > 0.05) then
            -- 원상 복구
            self.m_world.m_gameTimeScale:set(1)
            self.m_world.m_gameCamera:reset()
		end
	end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function update
-------------------------------------
function SkillAoERound_Alien:startZoomAndSlow()
	-- 카메라 줌인 + 슬로우
	local timeScale = 0.05
	self.m_world.m_gameTimeScale:set(timeScale)
	self.m_isZoomAndSlow = true 
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound_Alien:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
    local range = t_skill['val_1']		  -- 공격 반경
	local is_release_se = (t_skill['val_2'] == 1) -- 상태효과 해제 여부
	
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스
	local aoe_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)		-- 개별 타겟 이펙트 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoERound_Alien(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, range, aoe_res, is_release_se)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        world.m_gameHighlight:addMissile(skill)
    end
end
