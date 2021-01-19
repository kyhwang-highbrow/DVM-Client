local PARENT = UI


-------------------------------------
-- class UI_DragonCard_Gacha
-------------------------------------
UI_DragonCard_Gacha = class(PARENT, {
        m_tDragonData = 'StructDragonObject',
        m_dragonCard = 'UI_DragonCard',
        m_animator = 'Animator', -- 드래곤 카드 오픈 관련 애니메이터
        m_effectAnimator = 'Animator', -- 전설 등급 드래곤인 경우 오픈한 뒤에 반짝반짝 이펙트
        m_bIsOpen = 'boolean', -- 현재 드래곤 카드가 오픈되었는지        
        
        -----------------------------------------------------
        m_openCB = 'function', -- 드래곤 카드 오픈한 뒤 콜백될 함수
        m_clickCB = 'function', -- 드래곤 카드 오픈한 뒤 콜백될 함수

    })

-------------------------------------
-- function init
-- @param t_dragon_data : StructDragonObject
-------------------------------------
function UI_DragonCard_Gacha:init(t_dragon_data)
    self:load('rune_gacha_animator.ui')
    
    self.m_bIsOpen = false
    self.m_tDragonData = t_dragon_data
    self.m_openCB = nil
    self.m_clickCB = nil

    self:initUI()
    self:initButton()

    -- 스파인 애니메이터 생성
    self:makeDragonOpenAnimator()
end

-------------------------------------
-- function setOpenCB
-- @param open_cb : 카드 오픈할 때 호출되는 콜백
-------------------------------------
function UI_DragonCard_Gacha:setOpenCB(open_cb)
    self.m_openCB = open_cb
end

-------------------------------------
-- function setClickCB
-- @param click_cb : 오픈된 카드 클릭할 때 호출되는 콜백
-------------------------------------
function UI_DragonCard_Gacha:setClickCB(click_cb)
    self.m_clickCB = click_cb
    self.m_dragonCard.vars['clickBtn']:registerScriptTapHandler(function() click_cb() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonCard_Gacha:initUI()
    local vars = self.vars
    
    -- 드래곤 카드 생성
    local t_dragon_data = self.m_tDragonData
    local dragon_card = UI_DragonCard(t_dragon_data)
    self.m_dragonCard = dragon_card
    dragon_card.root:setSwallowTouch(false)
    vars['runeNode']:addChild(dragon_card.root, 2)
    vars['runeNode']:setVisible(false) -- 카드가 오픈되면 visible -> true
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonCard_Gacha:initButton()
    local vars = self.vars
    
	vars['skipBtn']:registerScriptTapHandler(function() self:click_skipBtn() end)
	vars['skipBtn']:registerScriptPressHandler(function() self:click_skipBtn() end)
end

-------------------------------------
-- function makeDragonOpenAnimator
-------------------------------------
function UI_DragonCard_Gacha:makeDragonOpenAnimator()
    local vars = self.vars

    -- 카드 오픈 관련 애니메이션 설정
    local res_name = 'res/ui/spine/dragon_gacha/dragon_gacha.json'
    local animator = MakeAnimator(res_name)
    animator:setIgnoreLowEndMode(true)
    animator:changeAni('idle', true)
    animator:setMix('hold', 'flip_1', 0.2)
    animator:setMix('hold', 'flip_2', 0.2)
    self.m_animator = animator
    vars['skipBtn']:addChild(animator.m_node)

    local struct_dragon = self.m_tDragonData
    local rarity = struct_dragon:getRarity()
    if (isExistValue(rarity, 'hero', 'legend')) then
        local effect_res_name = 'res/ui/a2d/card_summon/card_summon.vrp'
        local effect_animator = MakeAnimator(effect_res_name)

        effect_animator:setIgnoreLowEndMode(true)
        if (rarity == 'legend') then
			effect_animator:changeAni('summon_regend', true)
		else
			effect_animator:changeAni('summon_hero', true)
		end
        effect_animator.m_node:setScale(1.7)
        self.m_effectAnimator = effect_animator
        vars['runeNode']:addChild(effect_animator.m_node, 3)
    end
end

-------------------------------------
-- function isOpen
-------------------------------------
function UI_DragonCard_Gacha:isOpen()
    return self.m_bIsOpen
end

-------------------------------------
-- function isClose
-- @brief 닫힌 경우, 
-- @return 열리고 있거나 열린 상태는 False 반환
-------------------------------------
function UI_DragonCard_Gacha:isClose()
    if (self.m_bIsOpen) then
        return false
    end

    if (string.find(self.m_animator.m_currAnimation, 'flip')) then
        return false
    end

    return true
end

-------------------------------------
-- function openCard
-- @param b_do_open_cb : open CB를 동작시킬것인지
-------------------------------------
function UI_DragonCard_Gacha:openCard(b_do_open_cb)
    local vars = self.vars
    
    if (self.m_bIsOpen == true) then
        return
    end
   
    local animator = self.m_animator

    ---- 열리고 있는 도중인 경우 패스
    if (string.find(animator.m_currAnimation, 'flip')) then
        return
    end

     -- 카드를 뒤집는 애니메이션이 끝나면 룬 카드를 오픈 
    local function finish_cb()
        self.m_bIsOpen = true

        local duration = 0.2
        local fade_out = cc.EaseInOut:create(cc.FadeOut:create(duration), 1)
        animator.m_node:runAction(fade_out)
        animator:setAnimationPause(true)

        vars['runeNode']:setVisible(true)
        if (self.m_openCB) and (b_do_open_cb == true) then
            self.m_openCB() 
        end
    end
    
    local rarity = self.m_tDragonData:getRarity()
    local ani_idx = (rarity == 'legend') and 2 or 1
    animator:changeAni(string.format('flip_%d', ani_idx), false)
    animator:addAniHandler(function() finish_cb() end)

    return self.m_bIsOpen
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UI_DragonCard_Gacha:click_skipBtn()
    local vars = self.vars

    -- 이미 열린 경우 패스
    if (self.m_bIsOpen == true) then
        return
    end
    
    local animator = self.m_animator

    ---- 열리고 있는 도중인 경우 패스
    if (string.find(animator.m_currAnimation, 'flip')) then
        return
    end

    -- 카드를 뒤집는 애니메이션이 끝나면 룬 카드를 오픈 
    local function finish_cb()
        self.m_bIsOpen = true

        local duration = 0.2
        local fade_out = cc.EaseInOut:create(cc.FadeOut:create(duration), 1)
        animator.m_node:runAction(fade_out)
        animator:setAnimationPause(true)

        vars['runeNode']:setVisible(true)

        if (self.m_openCB) then
            self.m_openCB() 
        end
    end
    
    local rarity = self.m_tDragonData:getRarity()
    local ani_idx = (rarity == 'legend') and 2 or 1
    animator:changeAni(string.format('flip_%d', ani_idx), false)
    animator:addAniHandler(function() finish_cb() end)
end
