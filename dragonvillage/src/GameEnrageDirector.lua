local PARENT = UI

-------------------------------------
-- class GameEnrageDirector
-- @breif
-------------------------------------
GameEnrageDirector = class(PARENT, {
        m_count = 'number',
        m_duration = 'number',

        m_rightNode = '',
        m_leftNode = '',
    })

-------------------------------------
-- function init
-------------------------------------
function GameEnrageDirector:init()
    self.m_count = 0
    self.m_duration = 3
    
    local vars = self:load('ingame_enrage.ui')

    self.m_leftNode = vars['leftNode']
    self.m_rightNode = vars['rightNode']

    local scr_size = cc.Director:getInstance():getWinSize()
    self.root:setPosition(0, 0)
    g_gameScene.m_viewLayer:addChild(self.root)

    self.root:setVisible(false)

    -- 하위 UI가 모두 opacity값을 적용되도록
    self:setOpacityChildren(true)
end

-------------------------------------
-- function doWork
-------------------------------------
function GameEnrageDirector:doWork()
    local vars = self.vars
    self.m_count = self.m_count + 1

    do
        self.root:stopAllActions()
        self.root:setVisible(true)
        local width = 400
        local duration = self.m_duration

        if (self.m_rightNode) then
            --[[
            local action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(-width/2, 0)), 0.2)
            self.m_rightNode:setPositionX(width/2)
            self.m_rightNode:stopAllActions()
            self.m_rightNode:runAction(action)
            ]]--
            self.m_rightNode:setPositionX(0)
        end

        if (self.m_leftNode) then
            --[[
            local action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(width/2, 0)), 0.2)
            self.m_leftNode:setPositionX(-width/2)
            self.m_leftNode:stopAllActions()
            self.m_leftNode:runAction(action)
            ]]--
            self.m_rightNode:setPositionX(0)
        end

        self.root:runAction(cc.Sequence:create(cc.FadeIn:create(duration * 0.5 / 3), cc.DelayTime:create(duration * 2 / 3), cc.FadeOut:create(duration * 0.5 / 3)))
    end
    
    do -- 광폭화 라벨
        local scale = 0.85

        vars['enrageLabel']:setString(Str('광폭화') .. Str('{1}단계', self.m_count))
        vars['enrageLabel']:setScale(scale * 1.5)
        vars['enrageLabel']:runAction(cc.ScaleTo:create(0.15, scale))
    end
end