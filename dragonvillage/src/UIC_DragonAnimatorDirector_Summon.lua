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
        m_bLegend = 'boolean',
        m_bMyth = 'boolean',
        m_dragonName = 'string',

        m_rarityEffect = 'Animator', -- 소환시에 텍스트 애니메이터 추가

        m_ownerUI = 'UI_GachaResult_Dragon',

        m_bActingAnimation = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:init(owner_ui)
    self.m_ownerUI = owner_ui
end

-------------------------------------
-- function initUI
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:initUI()
    Translate:a2dTranslate('ui/a2d/summon/summon_cut.plist')
	local res_name = 'res/ui/a2d/summon/summon.vrp'
    self.m_topEffect = MakeAnimator(res_name)
    self.m_bottomEffect = MakeAnimator(res_name)
    self.m_rarityEffect = MakeAnimator(res_name)

    self.m_topEffect:setIgnoreLowEndMode(true) -- 저사양 모드 무시
    self.m_bottomEffect:setIgnoreLowEndMode(true) -- 저사양 모드 무시
    self.m_rarityEffect:setIgnoreLowEndMode(true) -- 저사양 모드 무시

    self.vars['topEffectNode']:addChild(self.m_topEffect.m_node)
    self.vars['bottomEffectNode']:addChild(self.m_bottomEffect.m_node)
    self.vars['rarityNode']:addChild(self.m_rarityEffect.m_node)
end

-------------------------------------
-- function setDragonAnimator
-- @ brief 연출 종료후 나타날 드래곤 리소스 생성
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:setDragonAnimator(did, evolution, flv)
    --did = 120221 --번고
    --did = 121752 --데스락

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
    self.m_rarityEffect:setVisible(false)
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

    local appear_idx = math.min(self.m_currStep, 4)
    local idle_idx = math.min(self.m_currStep, 5)

	local appear_ani = string.format('appear_%02d', appear_idx)
	self.m_topEffect:changeAni(appear_ani)

	self.m_topEffect:addAniHandler(function() 
		local idle_ani = string.format ('idle_%02d', idle_idx)
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

	-- 사운드 재생 (확정 뽑기도 나옴)
	SoundMgr:playEffect('UI', 'ui_egg_break')

    -- 확정 등급 뽑기는 연출 재생 안함 - 클릭시 바로 결과
    local is_fix = TableSummonGacha:isFixSummon(self.m_eggID)
    if (is_fix) then
        self:appearDragonAnimator()
        local grade = TableSummonGacha:getMinGrade(self.m_eggID)
        
        -- 5등급 전설 알은 누리 연출 보여줌 
        if (grade >= 5) then
            self.m_currStep = 1
        else 
            return
        end
    end

    local ani_limit = self.m_bRareSummon and 6 or 3
    self.m_aniNum = math.min(self.m_currStep, ani_limit)

    local crack_ani
    if (self.m_bRareSummon) then
        crack_ani = string.format('crack_high_%02d', self.m_aniNum)
    else
        crack_ani = string.format('crack_%02d', self.m_aniNum)
    end
	
    if (self.m_aniNum == 3 and self.m_bMyth) then
        self.m_topEffect:changeAni('crack_high_03', false)
	    self.m_topEffect:addAniHandler(function()
            self.m_topEffect:changeAni('crack_high_04', false)
            self.m_bAnimate = true
	        self.m_topEffect:addAniHandler(function()
		        if (self.m_currStep > self.m_maxStep) then
                    self:checkMaxGradeEffect()
		        else
			        self:directingIdle()
		        end
                self.m_bAnimate = false
	        end)
            self.m_currStep = self.m_currStep + 1
        end)
    else
        if (self.m_currStep ~= 4 and self.m_currStep ~= 6) then
            self.m_topEffect:changeAni(crack_ani, false)
        end

        self.m_bAnimate = true
	    self.m_topEffect:addAniHandler(function()
		    if (self.m_currStep > self.m_maxStep) then
                self:checkMaxGradeEffect()
		    else
			    self:directingIdle()
		    end
            self.m_bAnimate = false
	    end)
    end
end

-------------------------------------
-- function checkMaxGradeEffect
-- @brief 5성인 경우 애니메이션 추가
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:checkMaxGradeEffect()
    if (self.m_bMyth) then
        SoundMgr:playEffect('UI', 'ui_egg_legend')
        self.m_topEffect:changeAni('crack_high_06', false)
        self.m_topEffect:addAniHandler(function()
            self:appearDragonAnimator()
        end)
    elseif (self.m_bLegend) then
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
        cur_grade = math.min(TableDragon:getValue(did, 'birthgrade'), 5)
        self.m_dragonName = TableDragon:getValue(did, 'type')
    end

    self.m_bLegend = rarity == 'legend'
    self.m_bMyth = rarity == 'myth'

    -- 뽑기 연출에만 eggID set
    if (self.m_eggID) then
        local min_grade = TableSummonGacha:getMinGrade(self.m_eggID)
        -- 뽑은 용의 등급에서 소환 가능한 최소 등급을 뺀 만큼만 클릭가능함
        self.m_maxStep = cur_grade - min_grade + 1
        self.m_maxStep = math_max(self.m_maxStep, 1)
    else
        self.m_maxStep = 3
    end

    if (self.m_bMyth) then
        self.m_maxStep = 5
    end

	-- 전설등급의 경우 추가 연출을 붙여준다
	if (self.m_bLegend or self.m_bMyth) then
		self:setCutSceneImg()
	end
end

-------------------------------------
-- function appearDragonAnimator
-- @brief top_appear연출 호출하고 드래곤 등장시킴
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:appearDragonAnimator(finish_cb)
    local scene_callback = finish_cb

    function after_appear_cut_cb()
        PARENT.appearDragonAnimator(self)
        self:show_textAnimation(scene_callback)

        self.vars['touchNode']:setVisible(false)
    end

    if (self.m_ownerUI and self.m_ownerUI.m_bSkipClicked) then
        self.m_topEffect:setVisible(false)
        self:showMythAnimation(after_appear_cut_cb)
    else
        self.m_topEffect:changeAni('top_appear', false)
        self.m_topEffect:addAniHandler(function()
            self:showMythAnimation(after_appear_cut_cb)
        end)
    end
end

-------------------------------------
-- function appearDragonAnimator
-- @brief top_appear연출 호출하고 드래곤 등장시킴
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:showMythAnimation(finish_cb)
    local animator
    local dragon_appear_cut_res
    local is_skip_activated = self.m_ownerUI and self.m_ownerUI.vars['skipBtn']:isVisible() or true

    if (not isNullOrEmpty(self.m_dragonName) and self.m_bMyth) and (self.m_ownerUI and not self.m_ownerUI:isShownAppearAnimation(self.m_did)) then
        self.vars['skipBtn']:setVisible(false)
        if (self.m_ownerUI) then 
            self.m_ownerUI.vars['skipBtn']:setVisible(false) 
            self.m_ownerUI.vars['okBtn']:setVisible(false) 
        
        end

        local file_name = string.format('appear_%s', self.m_dragonName)
        dragon_appear_cut_res = string.format('res/dragon_appear/%s/%s.json', file_name, file_name)
        animator = MakeAnimator(dragon_appear_cut_res)

        --번역
        Translate:a2dTranslate(dragon_appear_cut_res)
    else
        self.vars['skipBtn']:setVisible(true)
        if (self.m_ownerUI) then 
            self.m_ownerUI.vars['skipBtn']:setVisible(true) 
            self.m_ownerUI.vars['okBtn']:setVisible(true)
        end
    end

    if (animator and animator.m_node) then
        if (self.m_ownerUI and self.m_ownerUI.m_animatedDragonIdTable) then
            self.m_ownerUI.m_animatedDragonIdTable[self.m_did] = true
        end

        self.m_bActingAnimation = true

        animator.m_node:setGlobalZOrder(animator.m_node:getGlobalZOrder() + 2)

        animator:setIgnoreLowEndMode(true) -- 저사양 모드 무시

	    local cut_node = self.vars['topEffectNode']

	    if (cut_node) then cut_node:addChild(animator.m_node) end

        animator:changeAni('appear', false)
	    -- 사운드 재생 
        local file_name = string.format('appear_%s', self.m_dragonName)
	    SoundMgr:playEffect('VOICE', file_name)

        -- 라벨만들기
	    local label = cc.Label:createWithTTF(0, 
            Translate:getFontPath(), 
            30, 
            1, 
            cc.size(600, 100), 
            1, 1)

        local str
        local uic_label = UIC_LabelTTF(label)
        uic_label:setPosition(0, -230)
        uic_label:setDockPoint(CENTER_POINT)
        uic_label:setAnchorPoint(CENTER_POINT)
        uic_label:setColor(COLOR['white'])
        uic_label:setString('')
        animator.m_node:addChild(uic_label.m_node)
        str = TableDragonPhrase():getValue(self.m_did, 't_dragon_appear')
        if (not str) then str = '' end
        --uic_label:setString(Str(str))

        local typing_label = MakeTypingEffectLabel(uic_label)
        typing_label.m_node:setGlobalZOrder(animator.m_node:getGlobalZOrder() + 5)
        typing_label:setDueTime(2.5)

        local function act_text()
            typing_label:setString(Str(str))
            typing_label.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(5.1), cc.FadeOut:create(0.2), cc.RemoveSelf:create()))
        end

        typing_label.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(0.9), cc.CallFunc:create(function() act_text() end)))

        local function end_animation()
            animator:setVisible(false)
            if (self.m_ownerUI) then 
                self.m_ownerUI.vars['skipBtn']:setVisible(is_skip_activated) 
                self.m_ownerUI.vars['okBtn']:setVisible(true)
            end

            if finish_cb then finish_cb() else after_appear_cut_cb() end
        end

        animator:addAniHandler(function()
            animator:changeAni('idle', false)
            animator:addAniHandler(function()
                if (animator:hasAni('end')) then
                    animator:changeAni('end', false)
                end
	        end)

            animator:addAniHandler(function()
                end_animation()
                self.m_bActingAnimation = false
            end)
	    end)

    else
        self.vars['skipBtn']:setVisible(true)
        if (self.m_ownerUI) then 
            self.m_ownerUI.vars['skipBtn']:setVisible(true) 
            self.m_ownerUI.vars['okBtn']:setVisible(true)
        end

        if finish_cb then finish_cb() else after_appear_cut_cb() end
    end

end

-------------------------------------
-- function show_textAnimation
-- @brief 소환시에만 텍스트 연출 추가
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:show_textAnimation()
    local did = self.m_did
    local birth_grade
    if TableSlime:isSlimeID(did) then
        birth_grade = TableSlime:getValue(did, 'birthgrade')
    else
        birth_grade = TableDragon:getValue(did, 'birthgrade')
    end

    if (birth_grade >= 3) then
        local ani_num = math_max((birth_grade - 1), 1) -- 1 ~ 4
        local ani_appear = string.format('text_appear_%02d', ani_num)
        local ani_idle = string.format('text_idle_%02d', ani_num)

        local text_effect = self.m_rarityEffect
        text_effect:setVisible(true)
        text_effect:changeAni(ani_appear, false)
        text_effect:addAniHandler(function()
		    text_effect:changeAni(ani_idle, true)
	    end)
    end
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
    self:show_textAnimation()
end

-------------------------------------
-- function bindEgg
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:bindEgg(egg_id, egg_res)
	if (not egg_id) then
		return
	end
    if (not egg_res) or (egg_res == '') then
        egg_res = 'res/item/egg/egg_common_unknown/egg_common_unknown.vrp'
    end

    --번역
    Translate:a2dTranslate( egg_res )

    self.m_eggID = egg_id
    self.m_bRareSummon = TableSummonGacha:isRareSummon(egg_id)

    local animator = MakeAnimator(egg_res)
    animator:setIgnoreLowEndMode(true) -- 저사양 모드 무시
    animator:changeAni('egg')
    self.m_topEffect.m_node:bindVRP('egg', animator.m_node)
end