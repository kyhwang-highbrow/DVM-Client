local PARENT = UIC_DragonAnimator

-------------------------------------
-- class UIC_DragonAnimatorDirector
-------------------------------------
UIC_DragonAnimatorDirector = class(PARENT, {
        m_topEffect = 'Animator',
        m_bottomEffect = 'Animator',

        m_skipBtnCnt = 'number', -- 두 번 터치를 해야 스킵이 되도록
        m_dragonAppearCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_DragonAnimatorDirector:init()
    local vars = self.vars
    self:setTalkEnable(false)

	self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UIC_DragonAnimatorDirector:initUI()
	local res_name = 'res/ui/a2d/dragon_upgrade_fx/dragon_upgrade_fx.vrp'
    self.m_topEffect = MakeAnimator(res_name)
    self.m_bottomEffect = MakeAnimator(res_name)

    self.vars['topEffectNode']:addChild(self.m_topEffect.m_node)
    self.vars['bottomEffectNode']:addChild(self.m_bottomEffect.m_node)
end

-------------------------------------
-- function initButton
-------------------------------------
function UIC_DragonAnimatorDirector:initButton()
    self.vars['skipBtn']:registerScriptTapHandler(function() self:click_skipBtn() end)
end


-------------------------------------
-- function setDragonAnimator
-------------------------------------
function UIC_DragonAnimatorDirector:setDragonAnimator(did, evolution, flv)
    PARENT.setDragonAnimator(self, did, evolution, flv)
    self.m_animator:setVisible(false)
end

-------------------------------------
-- function setDragonAppearCB
-------------------------------------
function UIC_DragonAnimatorDirector:setDragonAppearCB(cb)
    self.m_dragonAppearCB = cb
end

-------------------------------------
-- function startDirecting
-------------------------------------
function UIC_DragonAnimatorDirector:startDirecting()
    local vars = self.vars
    
	self.m_bottomEffect:setVisible(false)
    self.vars['skipBtn']:setVisible(true)
    self.m_skipBtnCnt = 0

    self.m_topEffect:changeAni('top_appear')
    self.m_topEffect:addAniHandler(function() self:appearDragonAnimator()end)
end

-------------------------------------
-- function appearDragonAnimator
-------------------------------------
function UIC_DragonAnimatorDirector:appearDragonAnimator()
    local vars = self.vars
    self.m_topEffect:changeAni('top_disappear', false)
    
    self.m_bottomEffect:setVisible(true)
    self.m_bottomEffect:changeAni('bottom_idle', false)
    self.m_bottomEffect:addAniHandler(function()
            self.m_bottomEffect:changeAni('bottom_idle', true)
        end)

    self.m_animator:setVisible(true)
    vars['skipBtn']:setVisible(false)

    if self.m_dragonAppearCB then
        self.m_dragonAppearCB()
    end
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UIC_DragonAnimatorDirector:click_skipBtn()
    self.m_skipBtnCnt = (self.m_skipBtnCnt + 1)
    if (self.m_skipBtnCnt >= 2) then
        self:appearDragonAnimator()
    end
end