local PARENT = UI_DragonCard_Gacha


-------------------------------------
-- class UI_DragonCard_Flip
-------------------------------------
UI_DragonCard_Flip = class(PARENT, {
    })


-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonCard_Flip:initUI()
    local vars = self.vars
    
    -- 드래곤 카드 생성
    local t_dragon_data = self.m_tDragonData
    local dragon_card = UI_DragonCard(t_dragon_data)
    self.m_dragonCard = dragon_card
    dragon_card.root:setSwallowTouch(false)
    vars['runeNode']:removeAllChildren()
    vars['runeNode']:addChild(dragon_card.root, 2)
    vars['runeNode']:setVisible(false) -- 카드가 오픈되면 visible -> true
end

-------------------------------------
-- function makeDragonOpenAnimator
-------------------------------------
function UI_DragonCard_Flip:makeDragonOpenAnimator()
    local vars = self.vars

    -- 카드 오픈 관련 애니메이션 설정
    local res_name = 'res/ui/spine/dragon_gacha/dragon_gacha.json'
    local animator = MakeAnimator(res_name)
    animator:setIgnoreLowEndMode(true)
    animator:changeAni('idle', true)
    animator:setMix('hold', 'flip_1', 0.2)
    animator:setMix('hold', 'flip_3', 0.2)
    animator:setMix('hold', 'flip_4', 0.2)
    self.m_animator = animator
    --vars['skipBtn']:removeAllChildren()
    vars['skipBtn']:addChild(animator.m_node)

    
    local effect_res_name = 'res/ui/a2d/card_summon/card_summon.vrp'
    local effect_animator = MakeAnimator(effect_res_name)
    effect_animator:setIgnoreLowEndMode(true)
    effect_animator:changeAni('hero', true)
    effect_animator.m_node:setScale(1.7)
    self.m_effectAnimator = effect_animator

    vars['runeNode']:addChild(effect_animator.m_node, 3)
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonCard_Gacha:rewind()
    self.m_bIsOpen = false
    self:initUI()
    self:makeDragonOpenAnimator()
end

-------------------------------------
-- function isOpen
-------------------------------------
function UI_DragonCard_Flip:isOpen()
    return self.m_bIsOpen
end

-------------------------------------
-- function isClose
-- @brief 닫힌 경우, 
-- @return 열리고 있거나 열린 상태는 False 반환
-------------------------------------
function UI_DragonCard_Flip:isClose()
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
function UI_DragonCard_Flip:openCard(b_do_open_cb)
    local vars = self.vars
    
    if (self.m_bIsOpen == true) then
        return
    end

    if (self.m_openConditionFunc) then
        if (self.m_openConditionFunc() == false) then
            return
        end
    end

    local animator = self.m_animator
    ---- 열리고 있는 도중인 경우 패스
    if (string.find(animator.m_currAnimation, 'flip')) then
        return
    end

    -- 카드를 뒤집는 애니메이션이 끝나면 드래곤 카드를 오픈 
    -- 전설 등급 이상의 드래곤 카드가 오픈된 이후에도 애니메이션이 이펙트 등으로 남아 있어
    -- 해당하는 경우에는 하드 코딩으로 self.m_openFinishCB을 실행한다.
    local function finish_cb(b_do_finish_cb)
        self.m_bIsOpen = true

        local duration = 0.2
        local fade_out = cc.EaseInOut:create(cc.FadeOut:create(duration), 1)
        animator.m_node:runAction(fade_out)
        animator:setAnimationPause(true)

        SoundMgr:playEffect('EFFECT', 'reward')

        vars['runeNode']:setVisible(true)
        if (self.m_openFinishCB) and (b_do_open_cb == true) and (b_do_finish_cb == true) then
            self.m_openFinishCB() 
        end
    end
    
    if (self.m_openStartCB) and (b_do_open_cb == true) then
        self.m_openStartCB() 
    end

    animator:changeAni('flip_1', false)
    animator:addAniHandler(function() finish_cb(true) end)
    return self.m_bIsOpen
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UI_DragonCard_Flip:click_skipBtn()
    self:openCard(true)
end