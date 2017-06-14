local PARENT = UIC_DragonAnimatorDirector

-------------------------------------
-- class UIC_DragonAnimatorDirector_Summon
-------------------------------------
UIC_DragonAnimatorDirector_Summon = class(PARENT, {
		m_lDirectingList = 'list',
		m_currStep = 'num',
		m_maxStep = 'num',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:init()
end

-------------------------------------
-- function initUI
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:initUI()
	local res_name = 'res/ui/a2d/summon/summon.vrp'
    self.m_topEffect = MakeAnimator(res_name)
    self.m_bottomEffect = MakeAnimator(res_name)

    self.vars['topEffectNode']:addChild(self.m_topEffect.m_node)
    self.vars['bottomEffectNode']:addChild(self.m_bottomEffect.m_node)
end

-------------------------------------
-- function setDragonAnimator
-- @ brief 연출 종료후 나타날 드래곤 리소스 생성
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:setDragonAnimator(did, evolution, flv)
    PARENT.setDragonAnimator(self, did, evolution, flv)

	-- did를 받아 
    self:makeRarityDirecting(did)
end

-------------------------------------
-- function startDirecting
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:startDirecting()
    local vars = self.vars

	-- 연출 세팅
    self.m_bottomEffect:setVisible(false)
    self.vars['skipBtn']:setVisible(true)
    self.m_currStep = 1
	
	-- 연출 시작
	self:directingIdle()
end

-------------------------------------
-- function directingIdle
-- @brief 단계별 appear + idle 연출 재생
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:directingIdle()
	self.vars['touchNode']:setVisible(true)

	local appear_ani = string.format('appear_%02d', self.m_currStep)
	self.m_topEffect:changeAni(appear_ani)

	self.m_topEffect:addAniHandler(function() 
		local idle_ani = string.format ('idle_%02d', self.m_currStep)
		self.m_topEffect:changeAni(idle_ani, true)
	end)
end

-------------------------------------
-- function directingContinue
-- @brief 단계별 crack 연출 재생
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:directingContinue()
	self.vars['touchNode']:setVisible(false)

	local crack_ani = string.format('crack_%02d', self.m_currStep)
	self.m_topEffect:changeAni(crack_ani, false)
	self.m_topEffect:addAniHandler(function()
		if (self.m_currStep > self.m_maxStep) then
			self:appearDragonAnimator()
		else
			self:directingIdle()
		end
	end)
end

-------------------------------------
-- function setCutSceneImg
-- @brief 전설 등급 드래곤 등작할 시에 나오는 컷씬을 위해 [누리]를 붙임.
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:setCutSceneImg()
	local cut_node = self.m_topEffect.m_node:getSocketNode('cut')

	if (cut_node) then
		local t_tamer = TableTamer():get(110002)
		local illustration_res = t_tamer['res']
		local illustration_animator = MakeAnimator(illustration_res)
		illustration_animator:changeAni('idle', true)
		cut_node:addChild(illustration_animator.m_node)
	end
end

-------------------------------------
-- function makeRarityDirecting
-- @brief 진화 단계에 따라 연출을 조정한다.
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:makeRarityDirecting(did)

    local rarity
    if TableSlime:isSlimeID(did) then
        rarity = TableSlime:getValue(did, 'rarity')
    else
        rarity = TableDragon:getValue(did, 'rarity')
    end

	self.m_maxStep = dragonRarityStrToNum(rarity)

	-- 전설등급의 경우 추가 연출을 붙여준다
	if (rarity == 'legend') then
		self:setCutSceneImg()
	end
end

-------------------------------------
-- function appearDragonAnimator
-- @brief top_appear연출 호출하고 드래곤 등장시킴
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:appearDragonAnimator()
	self.m_topEffect:changeAni('top_appear', false)
	self.m_topEffect:addAniHandler(function()
		PARENT.appearDragonAnimator(self)
	end)
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:click_skipBtn()
	-- 마지막 스텝일 경우 입력을 받지 않는다.
	if (self.m_currStep > self.m_maxStep) then
		return
	end

	self:directingContinue()
	self.m_currStep = self.m_currStep + 1
end

-------------------------------------
-- function forceSkipDirecting
-- @brief skip을 강제할때 필요한 세팅을 하고 드래곤을 등장 시킨다.
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:forceSkipDirecting()
	self.vars['touchNode']:setVisible(false)

	self.m_currStep = self.m_maxStep + 1

	-- top_appear연출 생략을 위해 부모함수 호출
	PARENT.appearDragonAnimator(self)
end