local PARENT = UI

-------------------------------------
-- class UI_StartIntro
-------------------------------------
UI_StartIntro = class(PARENT,{
        m_cbFinish = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_StartIntro:init(intro_callback)
    self.m_cbFinish = intro_callback

    self.root = cc.Node:create()
    self.root:setDockPoint(CENTER_POINT)
    self.root:setAnchorPoint(CENTER_POINT)
    UIManager:open(self, UIManager.NORMAL)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    self:playIntro()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StartIntro:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StartIntro:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_StartIntro:refresh()
end

-------------------------------------
-- function playIntro
-------------------------------------
function UI_StartIntro:playIntro()
    local intro = AnimatorVrp('res/ui/a2d/intro/intro.vrp')
    local l_play = intro:getVisualList()

    local play_func
    play_func = function(idx)
        if (idx == #l_play) then self:finish() return end

        intro:changeAni(l_play[idx], false)
        intro:addAniHandler(function() play_func(idx + 1) end)
    end
    
    play_func(1)

    self.root:addChild(intro.m_node)
end

-------------------------------------
-- function finish
-------------------------------------
function UI_StartIntro:finish()
    if self.m_cbFinish then
        self.m_cbFinish()
    end
end

--@CHECK
UI:checkCompileError(UI_StartIntro)
