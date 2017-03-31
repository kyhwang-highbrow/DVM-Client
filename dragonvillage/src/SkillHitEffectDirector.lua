-------------------------------------
-- class SkillHitEffectDirector
-- @breif 스킬을 사용할 때 나오는 연출 및 효과 관리 
-- 연출 : 히트 콤보 및 다중 히트 버프 연출
-- 효과 : 스킬 쿨다운 감소 
-------------------------------------
SkillHitEffectDirector = class(IEventDispatcher:getCloneClass(), {
	m_owner = 'character',
    --m_mHitTargets = 'table', -- 히트되었던 타켓
	
	m_hitCount = 'num',
	m_inGameUI = 'UI_Game',
	m_animator = 'A2D',
    m_bonusText = 'string',
    
	m_isExhibit1st = 'bool',
	m_isExhibit2nd = 'bool',
})

-------------------------------------
-- function init
-------------------------------------
function SkillHitEffectDirector:init(owner)
	self.m_owner = owner
    --self.m_mHitTargets = {}
	self.m_inGameUI = g_gameScene.m_inGameUI
	self.m_animator = nil
    self.m_bonusText = nil
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
	self:displayHitCnt()
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

    self.m_inGameUI.vars['hitBonusLabel']:setVisible(self.m_bonusText ~= nil)
    if (self.m_bonusText) then
        self.m_inGameUI.vars['hitBonusLabel']:setString(self.m_bonusText)
    end
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

-------------------------------------
-- function setAddText
-------------------------------------
function SkillHitEffectDirector:setAddText(str)
    self.m_bonusText = str
end


--================================================

local PARENT = UI

-------------------------------------
-- class SkillHitEffectDirector
-- @breif
-------------------------------------
SkillHitEffectDirector = class(PARENT, {
        m_hitCount = 'number',
        m_bonusText = 'string',

        m_rightNode = '',
        m_leftNode = '',

        m_bEndSkill = 'boolean',
        m_bEndAction = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillHitEffectDirector:init(owner, bonus_desc)
    self.m_hitCount = 0
    self.m_bonusText = nil
    self.m_bEndSkill = false
    self.m_bEndAction = true

    local vars = self:load('ingame_hit.ui')

    local hit_node
    if bonus_desc then
        vars['bonusLabel']:setString(bonus_desc)
        vars['bonusMenu']:setVisible(true)
        vars['normalMenu']:setVisible(false)
        hit_node = vars['bonusHitNode']

        self.m_rightNode = vars['bonusRightNode']
        self.m_leftNode = vars['bonusLeftNode']
    else
        vars['bonusMenu']:setVisible(false)
        vars['normalMenu']:setVisible(true)
        hit_node = vars['normalHitNode']

        self.m_rightNode = vars['normalRightNode']
        self.m_leftNode = vars['bonusLeftNode'] -- 일반은 왼쪽 노드가 없음
    end

    do
        local label = cc.Label:createWithBMFont('res/font/hit_bonus.fnt', '')
        label:setDockPoint(cc.p(1, 0.5))
        label:setAnchorPoint(cc.p(1, 0.5))
        label:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        hit_node:addChild(label)
        vars['hitLabel'] = label
    end

    self.root:setDockPoint(cc.p(0.5, 1))
    self.root:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:setPosition(0, -180)
    g_gameScene.m_inGameUI.root:addChild(self.root)

    self.root:setVisible(false)

    -- 하위 UI가 모두 opacity값을 적용되도록
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(true) end)
end

-------------------------------------
-- function doWork
-------------------------------------
function SkillHitEffectDirector:doWork(desc)
    local vars = self.vars
    self.m_hitCount = self.m_hitCount + 1

    if (self.m_hitCount == 1) then
        self.root:setVisible(true)
        local width = 400
        local duration = 3

        self.m_bEndAction = false
        
        local action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(-width/2, 0)), 0.2)
        self.m_rightNode:setPositionX(width/2)
        self.m_rightNode:runAction(action)

        local action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(width/2, 0)), 0.2)
        self.m_leftNode:setPositionX(-width/2)
        self.m_leftNode:runAction(action)

        local function finish_cb()
            self.m_bEndAction = true
            self:checkRelease()
        end
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.Hide:create(), cc.CallFunc:create(finish_cb)))
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration * 2 / 3), cc.FadeOut:create(duration * 1 / 3)))
    end


    local hit_label = vars['hitLabel']
    hit_label:setString(tostring(self.m_hitCount))
    hit_label:setScale(1.4)
    hit_label:stopAllActions()
    hit_label:runAction(cc.ScaleTo:create(0.15, 1))
end

-------------------------------------
-- function onEnd
-------------------------------------
function SkillHitEffectDirector:onEnd()
    self.m_bEndSkill = true
    self:checkRelease()
    --self.root:removeFromParent()
end

-------------------------------------
-- function checkRelease
-------------------------------------
function SkillHitEffectDirector:checkRelease()
    if self.m_bEndSkill and self.m_bEndAction then
        self.root:removeFromParent()
    end
end