local PARENT = UI


-------------------------------------
-- class UI_RuneCard_Gacha
-------------------------------------
UI_RuneCard_Gacha = class(PARENT, {
        m_tRuneData = 'StructRuneObject',
        m_runeCard = 'UI_RuneCard',
        m_animator = 'Animator', -- 룬 카드 오픈 관련 애니메이터
        m_bIsOpen = 'boolean', -- 현재 룬 카드가 오픈되었는지        
        
        -----------------------------------------------------
        m_openCB = 'function', -- 룬 카드 오픈한 뒤 콜백될 함수
        m_clickCB = 'function', -- 룬 카드 오픈한 뒤 콜백될 함수

    })

-------------------------------------
-- function init
-- @param t_rune_data : StructRuneObject
-------------------------------------
function UI_RuneCard_Gacha:init(t_rune_data)
    self:load('rune_gacha_animator.ui')
    
    self.m_bIsOpen = false
    self.m_tRuneData = t_rune_data
    self.m_openCB = nil
    self.m_clickCB = nil

    self:initUI()

    -- 스파인 애니메이터 생성
    self:makeRuneOpenAnimator()
end

-------------------------------------
-- function setOpenCB
-- @param open_cb : 카드 오픈할 때 호출되는 콜백
-------------------------------------
function UI_RuneCard_Gacha:setOpenCB(open_cb)
    self.m_openCB = open_cb
end

-------------------------------------
-- function setClickCB
-- @param click_cb : 오픈된 카드 클릭할 때 호출되는 콜백
-------------------------------------
function UI_RuneCard_Gacha:setClickCB(click_cb)
    self.m_clickCB = click_cb
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneCard_Gacha:initUI()
    local vars = self.vars
    
    -- 룬 카드 생성
    local t_rune_data = self.m_tRuneData
    local rune_card = UI_RuneCard(t_rune_data)
    rune_card.root:setVisible(true) -- 카드가 오픈되면 visible -> true
    self.m_runeCard = rune_card
    rune_card.vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
    vars['runeNode']:addChild(rune_card.root, 2)
end

-------------------------------------
-- function makeRuneOpenAnimator
-------------------------------------
function UI_RuneCard_Gacha:makeRuneOpenAnimator()
    local vars = self.vars

    -- 카드 오픈 관련 애니메이션 설정
    local res_name = 'res/ui/spine/rune_gacha/rune_gacha.json'
    local animator = MakeAnimator(res_name)
    animator:setIgnoreLowEndMode(true)
    animator:changeAni('idle', true)

    self.m_animator = animator
    vars['runeNode']:addChild(animator.m_node, 3)
end

-------------------------------------
-- function isOpen
-------------------------------------
function UI_RuneCard_Gacha:isOpen()
   return self.m_bIsOpen
end

-------------------------------------
-- function click_clickBtn
-------------------------------------
function UI_RuneCard_Gacha:click_clickBtn()
    -- 이미 열린 경우 패스
    if (self.m_bIsOpen == true) then
        if (self.m_clickCB) then
            self.m_clickCB()
        end

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
        local fade_out = cc.EaseInOut:create(cc.FadeOut:create(duration), 2)
        animator.m_node:runAction(fade_out)
        animator:setAnimationPause(true)

        if (self.m_openCB) then
            self.m_openCB() 
        end
    end
    
    local grade = self.m_tRuneData['grade'] - 5
    animator:changeAni(string.format('flip_%02d', grade), false)
    animator:addAniHandler(function() finish_cb() end)
end
