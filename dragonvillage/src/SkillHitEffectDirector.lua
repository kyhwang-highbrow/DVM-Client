SkillHitEffectDirector = class({
	m_hitCount = 'num',
	m_inGameUI = 'UI_Game',
	
	m_isExhibit1st = 'bool',
	m_isExhibit2nd = 'bool',
})

-------------------------------------
-- function init
-------------------------------------
function SkillHitEffectDirector:init()
	self.m_inGameUI = g_gameScene.m_inGameUI
	self.m_hitCount = 0
	self.m_isExhibit1st = false
	self.m_isExhibit2nd = false
end

-------------------------------------
-- function doWork
-- @brief 필요한 행위들을 묶어서 실행..
-------------------------------------
function SkillHitEffectDirector:doWork()
	self:addHit()
	self:displayHitCnt()
	self:displayComboBuff()
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
	ShakeDir2(math_random(335-20, 335+20), math_random(500, 1500))
    SoundMgr:playEffect('EFFECT', 'option_thunderbolt_3')

    g_gameScene.m_inGameUI.vars['hitLabel']:setString(self.m_hitCount)
    g_gameScene.m_inGameUI.vars['hitNode']:setVisible(true)
    g_gameScene.m_inGameUI.vars['hitNode']:stopAllActions()

    g_gameScene.m_inGameUI.vars['hitNode']:setScale(1.4)
    g_gameScene.m_inGameUI.vars['hitNode']:setOpacity(255)
    g_gameScene.m_inGameUI.vars['hitNode']:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1), cc.FadeOut:create(0.5), cc.Hide:create()))
end

-------------------------------------
-- function displayHitCombo
-- @brief 스킬 hit count 연출
-------------------------------------
function SkillHitEffectDirector:displayComboBuff(count)
	local count = self.m_hitCount
	local combo_name = nil

	-- 1. 조건 불충족시 탈출
	if (count < 3) then return end
	if (count > 2) and (count < 5) and(self.m_isExhibit1st) then return end
	if (count > 4) and (self.m_isExhibit2nd) then return end

	-- 2. hit 수에 따라 visual 변경
	if (count > 5) then 
		combo_name = '40percent_combo'
		self.m_isExhibit2nd = true
	else
		combo_name = '20percent_combo'
		self.m_isExhibit1st = true
	end

	local animator = AnimatorHelper:makeInstanceHitComboffect(combo_name)
	--[[
	animator:addAniHandler(function()
		animator:release()
	end)
	]]
	local visibleSize = cc.Director:getInstance():getVisibleSize()
	animator:setPosition(0, visibleSize.height/2 - 100)

	self.m_inGameUI.root:addChild(animator.m_node)
end