-------------------------------------
-- class SkillHitEffectDirector
-- @breif 스킬을 사용할 때 나오는 연출 및 효과 관리 
-- 연출 : 히트 콤보 및 다중 히트 버프 연출
-- 효과 : 스킬 쿨다운 감소 
-------------------------------------
SkillHitEffectDirector = class(IEventDispatcher:getCloneClass(), {
	m_owner = 'character',
    m_mHitTargets = 'table', -- 히트되었던 타켓
	
	m_hitCount = 'num',
	m_inGameUI = 'UI_Game',
	m_animator = 'A2D',

	m_isExhibit1st = 'bool',
	m_isExhibit2nd = 'bool',
})

-------------------------------------
-- function init
-------------------------------------
function SkillHitEffectDirector:init(owner)
	self.m_owner = owner
    self.m_mHitTargets = {}
	self.m_inGameUI = g_gameScene.m_inGameUI
	self.m_animator = nil
	self.m_hitCount = 0
	self.m_isExhibit1st = false
	self.m_isExhibit2nd = false

    -- 이벤트 리스너 등록
    if (self.m_owner.m_world.m_tamerSpeechSystem) then
        self:addListener('skill_combo_1', self.m_owner.m_world.m_tamerSpeechSystem)
        self:addListener('skill_combo_2', self.m_owner.m_world.m_tamerSpeechSystem)
    end
end

-------------------------------------
-- function doWork
-- @brief 필요한 행위들을 묶어서 실행.. public으로 사용
-------------------------------------
function SkillHitEffectDirector:doWork(target)
    --if (self.m_mHitTargets[target]) then return end
    --self.m_mHitTargets[target] = true

	self:addHit()

    -- 17.02.23 인게임 개선 사항에서 콤보 표시 및 보너스 삭제
	--self:displayHitCnt()
	--self:displayComboBuff()
end

-------------------------------------
-- function addHit
-------------------------------------
function SkillHitEffectDirector:addHit()
	self.m_hitCount = self.m_hitCount + 1
end

-------------------------------------
-- function displayHitCombo
-- @brief 스킬 hit count 연출
-------------------------------------
function SkillHitEffectDirector:displayHitCnt()
	self.m_owner.m_world.m_shakeMgr:shakeBySpeed(math_random(335-20, 335+20), math_random(500, 1500))
    --SoundMgr:playEffect('EFFECT', 'option_thunderbolt_3')

    self.m_inGameUI.vars['hitLabel']:setString(self.m_hitCount)
    self.m_inGameUI.vars['hitNode']:setVisible(true)
    self.m_inGameUI.vars['hitNode']:stopAllActions()

    self.m_inGameUI.vars['hitNode']:setScale(1.4)
    self.m_inGameUI.vars['hitNode']:setOpacity(255)
    self.m_inGameUI.vars['hitNode']:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1), cc.FadeOut:create(0.5), cc.Hide:create()))
end

-------------------------------------
-- function displayHitCombo
-- @brief 스킬 hit count 연출
-------------------------------------
function SkillHitEffectDirector:displayComboBuff()
	local count = self.m_hitCount
	local combo_name = nil

	-- 1. 조건 불충족시 탈출
	if (count < 3) then return end
	if (count > 2) and (count < 5) and(self.m_isExhibit1st) then return end
	if (count > 4) and (self.m_isExhibit2nd) then return end

	-- 2. hit 수에 따라 visual 변경
	if (count > 4) then 
		combo_name = '40percent_combo'
		self.m_isExhibit2nd = true
		self:applyCooltimeBuff()
	else
		combo_name = '20percent_combo'
		self.m_isExhibit1st = true
		self:applyCooltimeBuff()
	end

	if self.m_animator then
		self.m_animator:changeAni(combo_name, false)
	else
		self.m_animator = AnimatorHelper:makeInstanceHitComboffect(combo_name)

		-- 3. 각 비율에 대응하기 위해서 위치를 상단 - 100으로 고정 2를 나누는 것은 중앙 y좌표가 0이기 때문
		local visibleSize = cc.Director:getInstance():getVisibleSize()
		self.m_animator:setPosition(0, visibleSize.height/2 - 100)

		self.m_inGameUI.root:addChild(self.m_animator.m_node)
	end
end


-------------------------------------
-- function applyCooltimeBuff
-------------------------------------
function SkillHitEffectDirector:applyCooltimeBuff()
    --[[
	local timer = self.m_owner.m_activeSkillTimer
	local cooltime = self.m_owner.m_activeSkillCoolTime
	local cooltime_buff_rate = g_constant:get('INGAME', 'COOLTIME_BUFF_RATE')
	self.m_owner.m_activeSkillTimer = timer + (cooltime * cooltime_buff_rate)
    ]]--
end

-------------------------------------
-- function onEnd
-- @brief 스킬 종료시 호출됨
-------------------------------------
function SkillHitEffectDirector:onEnd()
    if self.m_isExhibit2nd then
        self:dispatch('skill_combo_2', {}, self.m_owner)
    elseif self.m_isExhibit1st then
        self:dispatch('skill_combo_1', {}, self.m_owner)
    end
end
