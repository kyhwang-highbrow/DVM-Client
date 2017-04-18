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

    self.m_topEffect = MakeAnimator('res/ui/a2d/dragon_upgrade_fx/dragon_upgrade_fx.vrp')

    self.m_bottomEffect = MakeAnimator('res/ui/a2d/dragon_upgrade_fx/dragon_upgrade_fx.vrp')

    vars['topEffectNode']:addChild(self.m_topEffect.m_node)
    vars['bottomEffectNode']:addChild(self.m_bottomEffect.m_node)

    vars['skipBtn']:registerScriptTapHandler(function() 
            self.m_skipBtnCnt = (self.m_skipBtnCnt + 1)
            if (self.m_skipBtnCnt >= 2) then
                self:appearDragonAnimator()
            end
        end)
end

-------------------------------------
-- function start
-------------------------------------
function UIC_DragonAnimatorDirector:start()
    local vars = self.vars

    self.m_topEffect:changeAni('top_appear')
    self.m_topEffect:addAniHandler(function() self:appearDragonAnimator()end)

    self.m_bottomEffect:changeAni('bottom_appear', false)
    self.m_bottomEffect:addAniHandler(function()
            self.m_bottomEffect:changeAni('bottom_idle', true)
        end)

    self.vars['skipBtn']:setVisible(true)

    self.m_skipBtnCnt = 0
end

-------------------------------------
-- function setDragonAnimator
-------------------------------------
function UIC_DragonAnimatorDirector:setDragonAnimator(did, evolution, flv)
    PARENT.setDragonAnimator(self, did, evolution, flv)
    self.m_animator:setVisible(false)

    self:start()
end

-------------------------------------
-- function appearDragonAnimator
-------------------------------------
function UIC_DragonAnimatorDirector:appearDragonAnimator()
    local vars = self.vars
    self.m_topEffect:changeAni('top_disappear', false)
    self.m_bottomEffect:changeAni('bottom_idle', true)
    self.m_animator:setVisible(true)
    vars['skipBtn']:setVisible(false)

    if self.m_dragonAppearCB then
        self.m_dragonAppearCB()
    end
end

-------------------------------------
-- function setDragonAppearCB
-------------------------------------
function UIC_DragonAnimatorDirector:setDragonAppearCB(cb)
    self.m_dragonAppearCB = cb
end