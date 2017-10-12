local PARENT = UIC_DragonAnimatorDirector

-------------------------------------
-- class UIC_DragonAnimatorDirector_Summon
-------------------------------------
UIC_DragonAnimatorDirector_Summon = class(PARENT, {
		m_lDirectingList = 'list',
		m_currStep = 'num',
        m_maxStep = 'num',
        m_aniNum = 'num',

        m_eggID = 'num',
        m_bAnimate = 'boolean',
        m_bRareSummon = 'boolean', -- 고등급용 소환
        m_bLegend= 'boolean', 
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
	self.m_bAnimate = false

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

    -- 소환 연출 재생 안함
    if (not self.m_eggID) then 
        self:appearDragonAnimator()
        return
    end

    -- 확정 등급 뽑기는 연출 재생 안함 - 클릭시 바로 결과
    local is_fix = TableSummonGacha:isFixSummon(self.m_eggID)
    if (is_fix) then
        self:appearDragonAnimator()
        local grade = TableSummonGacha:getMinGrade(self.m_eggID)
        
        -- 5등급 전설 알은 누리 연출 보여줌 
        if (grade == 5) then
            self.m_currStep = 1
        else 
            return
        end
    end

    self.m_aniNum = self.m_currStep

    local crack_ani
    if (self.m_bRareSummon) then
        crack_ani = string.format('crack_high_%02d', self.m_currStep)
    else
        crack_ani = string.format('crack_%02d', self.m_currStep)
    end

	self.m_topEffect:changeAni(crack_ani, false)
    self.m_bAnimate = true
	self.m_topEffect:addAniHandler(function()
		if (self.m_currStep > self.m_maxStep) then
            self:checkMaxGradeEffect()
		else
			self:directingIdle()
		end
        self.m_bAnimate = false
	end)

	SoundMgr:playEffect('UI', 'ui_egg_break')
end

-------------------------------------
-- function checkMaxGradeEffect
-- @brief 5성인 경우 애니메이션 추가
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:checkMaxGradeEffect()
    if (self.m_bLegend) then
        SoundMgr:playEffect('UI', 'ui_egg_legend')
        self.m_topEffect:changeAni('crack_high_04', false)
        self.m_topEffect:addAniHandler(function()
            self:appearDragonAnimator()
        end)
    else
        self:appearDragonAnimator()
    end
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
    local cur_grade
    if TableSlime:isSlimeID(did) then
        rarity = TableSlime:getValue(did, 'rarity')
        cur_grade = TableSlime:getValue(did, 'birthgrade')
    else
        rarity = TableDragon:getValue(did, 'rarity')
        cur_grade = TableDragon:getValue(did, 'birthgrade')
    end

    -- 뽑기 연출에만 eggID set
    if (self.m_eggID) then
        local min_grade = TableSummonGacha:getMinGrade(self.m_eggID)
        -- 뽑은 용의 등급에서 소환 가능한 최소 등급을 뺀 만큼만 클릭가능함
        self.m_maxStep = cur_grade - min_grade + 1
        self.m_maxStep = math_max(self.m_maxStep, 1)
    else
        self.m_maxStep = 3
    end
    self.m_bLegend = false

	-- 전설등급의 경우 추가 연출을 붙여준다
	if (rarity == 'legend') then
        self.m_bLegend = true
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
    -- 알 애니메이션일 경우 입렵 받지 않도록 수정
    if (self.m_bAnimate) then 
        return
    end

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


-------------------------------------
-- function bindEgg
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:bindEgg(egg_id, egg_res)
    if (not egg_res) or (egg_res == '') then
        egg_res = 'res/item/egg/egg_common_unknown/egg_common_unknown.vrp'
    end

    self.m_eggID = egg_id
    self.m_bRareSummon = TableSummonGacha:isRareSummon(egg_id)

    local animator = MakeAnimator(egg_res)
    animator:changeAni('egg')
    self.m_topEffect.m_node:bindVRP('egg', animator.m_node)
end