local PARENT = UI

-------------------------------------
-- class SkillHitEffectDirector
-- @breif
-------------------------------------
SkillHitEffectDirector = class(PARENT, {
        m_hitCount = 'number',
        m_bonusText = 'string',

        m_rightNode = '',
        m_leftNode = '',

        m_bEndSkill = 'boolean',
        m_bEndAction = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillHitEffectDirector:init(owner, bonus_desc)
    self.m_hitCount = 0
    self.m_bonusText = nil
    self.m_bEndSkill = false
    self.m_bEndAction = true

    local vars = self:load('ingame_hit.ui')

    local hit_node
    if bonus_desc then
        vars['bonusLabel']:setString(bonus_desc)
        vars['bonusMenu']:setVisible(true)
        vars['normalMenu']:setVisible(false)
        hit_node = vars['bonusHitNode']

        self.m_rightNode = vars['bonusRightNode']
        self.m_leftNode = vars['bonusLeftNode']
    else
        vars['bonusMenu']:setVisible(false)
        vars['normalMenu']:setVisible(true)
        hit_node = vars['normalHitNode']

        self.m_rightNode = vars['normalRightNode']
        self.m_leftNode = vars['bonusLeftNode'] -- 일반은 왼쪽 노드가 없음
    end

    do
        local label = cc.Label:createWithBMFont('res/font/hit_bonus.fnt', '')
        label:setDockPoint(cc.p(1, 0.5))
        label:setAnchorPoint(cc.p(1, 0.5))
        label:setAlignment(cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        hit_node:addChild(label)
        vars['hitLabel'] = label
    end

    self.root:setDockPoint(cc.p(0.5, 1))
    self.root:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:setPosition(0, -160)
    owner.m_world.m_inGameUI.root:addChild(self.root)

    self.root:setVisible(false)

    -- 하위 UI가 모두 opacity값을 적용되도록
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(true) end)
end

-------------------------------------
-- function doWork
-------------------------------------
function SkillHitEffectDirector:doWork(desc)
    if self.m_bEndSkill and self.m_bEndAction then
        return
    end

    local vars = self.vars
    self.m_hitCount = self.m_hitCount + 1

    if (self.m_hitCount == 1) then
        self.root:setVisible(true)
        local width = 400
        local duration = 3

        self.m_bEndAction = false
        
        local action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(-width/2, 0)), 0.2)
        self.m_rightNode:setPositionX(width/2)
        self.m_rightNode:runAction(action)

        local action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(width/2, 0)), 0.2)
        self.m_leftNode:setPositionX(-width/2)
        self.m_leftNode:runAction(action)

        local function finish_cb()
            self.m_bEndAction = true
            self:checkRelease()
        end
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.Hide:create(), cc.CallFunc:create(finish_cb)))
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration * 2.5 / 3), cc.FadeOut:create(duration * 0.5 / 3)))
    end


    local hit_label = vars['hitLabel']
    hit_label:setString(tostring(self.m_hitCount))
    hit_label:setScale(1.4)
    hit_label:stopAllActions()
    hit_label:runAction(cc.ScaleTo:create(0.15, 1))
end

-------------------------------------
-- function onEnd
-------------------------------------
function SkillHitEffectDirector:onEnd()
    self.m_bEndSkill = true
    self:checkRelease()
end

-------------------------------------
-- function checkRelease
-------------------------------------
function SkillHitEffectDirector:checkRelease()
    if self.m_bEndSkill and self.m_bEndAction then
        self.root:removeFromParent()
    end
end