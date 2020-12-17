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
-- @param open_cb : 룬 카드 오픈한 뒤 콜백될 함수
-- @param click_cb : 오픈된 룬 카드를 클릭할 때 콜백될 함수
-------------------------------------
function UI_RuneCard_Gacha:init(t_rune_data, open_cb, click_cb)
    self:load('rune_gacha_animator.ui')
    
    self.m_bIsOpen = false
    self.m_tRuneData = t_rune_data
    self.m_openCB = open_cb
    self.m_clickCB = click_cb

    self:initUI()
    self:initButton()

    -- 스파인 애니메이터 생성
    self:makeRuneOpenAnimator()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneCard_Gacha:initUI()
    local vars = self.vars
    
    -- 룬 카드 생성
    local t_rune_data = self.m_tRuneData
    local rune_card = UI_RuneCard(t_rune_data)
    rune_card.root:setVisible(false) -- 카드가 오픈되면 visible -> true
    self.m_runeCard = rune_card
    vars['runeNode']:addChild(rune_card.root)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneCard_Gacha:initButton()
    local btn = self.vars['skipBtn']
    btn:setVisible(true)
    btn:registerScriptTapHandler(function() self:click_skipBtn() end)
end

-------------------------------------
-- function makeRuneOpenAnimator
-------------------------------------
function UI_RuneCard_Gacha:makeRuneOpenAnimator()
    -- 연출 관련 애니메이션 프레임캐시에 등록
    Translate:a2dTranslate('ui/a2d/summon/summon_cut.plist')

    -- 카드 오픈 관련 애니메이션 설정
    local res_name = 'res/ui/a2d/summon/summon.vrp'
    local animator = MakeAnimator(res_name)
    animator:setIgnoreLowEndMode(true)
    animator:setScale(0.4)
    animator:changeAni('appear_01', true)

    self.m_animator = animator
    self.root:addChild(animator.m_node, 3)
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
function UI_RuneCard_Gacha:click_skipBtn()
    -- 이미 열린 경우 패스
    if (self.m_bIsOpen == true) then
        return
    end

    ---- 열리고 있는 도중인 경우 패스
    local animator = self.m_animator
    if (isExistValue(animator.m_currAnimation, 'crack_high_01', 'crack_high_02')) then
        return
    end

    -- 카드를 뒤집는 애니메이션이 끝나면 룬 카드를 오픈 
    local function finish_cb()
        self.m_bIsOpen = true
        animator:setVisible(false)
        self.vars['skipBtn']:setVisible(false)
        self.m_runeCard.root:setVisible(true)

        if (self.m_openCB) then
            self.m_openCB() 
        end
    end
    
    local grade = self.m_tRuneData['grade'] - 5
    cclog(string.format('crack_high_%02d', grade))
    animator:changeAni(string.format('crack_high_%02d', grade))
    animator:addAniHandler(function() finish_cb() end)
end
