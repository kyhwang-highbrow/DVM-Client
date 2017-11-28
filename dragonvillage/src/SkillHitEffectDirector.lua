local PARENT = UI

-------------------------------------
-- class SkillHitEffectDirector
-- @breif
-------------------------------------
SkillHitEffectDirector = class(PARENT, {
        m_hero = '',
        m_hitCount = 'number',
        m_totalDamage = 'number',
        
        m_rightNode = '',
        m_leftNode = '',

        m_bEndSkill = 'boolean',
        m_bEndAction = 'boolean',

        m_temporaryPause = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillHitEffectDirector:init(owner)
    self.m_hero = owner
    self.m_hitCount = 0
    self.m_totalDamage = 0
    self.m_bEndSkill = false
    self.m_bEndAction = true

    self.m_temporaryPause = false

    local vars = self:load('ingame_hit_new.ui')

    local hit_node = vars['hitNode']

    self.m_leftNode = vars['leftNode']
    self.m_rightNode = vars['rightNode']
    
    local scr_size = cc.Director:getInstance():getWinSize()
    self.root:setPosition(0, scr_size['height'] / 2 - 160)
    g_gameScene.m_viewLayer:addChild(self.root)

    self.root:setVisible(false)

    -- 하위 UI가 모두 opacity값을 적용되도록
    self:setOpacityChildren(true)
end

-------------------------------------
-- function doWork
-------------------------------------
function SkillHitEffectDirector:doWork(count, damage)
    if self.m_bEndSkill and self.m_bEndAction then
        return
    end

    local vars = self.vars
    self.m_hitCount = self.m_hitCount + 1

    local damage = math_floor(damage)

    if (self.m_hitCount == 1) then
        self.root:setVisible(true)
        local width = 400
        local duration = 3

        self.m_bEndAction = false
        
        if (self.m_rightNode) then
            local action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(-width/2, 0)), 0.2)
            self.m_rightNode:setPositionX(width/2)
            self.m_rightNode:runAction(action)
        end

        if (self.m_leftNode) then
            local action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(width/2, 0)), 0.2)
            self.m_leftNode:setPositionX(-width/2)
            self.m_leftNode:runAction(action)
        end

        local function finish_cb()
            self.m_bEndAction = true
            self:checkRelease()
        end
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.Hide:create(), cc.CallFunc:create(finish_cb)))
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration * 2.5 / 3), cc.FadeOut:create(duration * 0.5 / 3)))
    end
    
    do -- 히트 수 라벨 생성
        if (vars['hitLabel']) then
            vars['hitLabel']:removeFromParent(true)
            vars['hitLabel'] = nil
        end

        local scale = 0.8
        local label = self:makeDamageNumber(tostring(self.m_hitCount), cc.c3b(0, 240, 255), scale)
        label:setDockPoint(cc.p(1, 0.5))
        label:setAnchorPoint(cc.p(1, 0.5))

        vars['hitNode']:addChild(label)
        vars['hitLabel'] = label

        label:setScale(scale * 1.5)
        label:runAction(cc.ScaleTo:create(0.15, scale))
    end

    do -- 데미지 라벨 생성
        if (vars['damageLabel']) then
            vars['damageLabel']:removeFromParent(true)
            vars['damageLabel'] = nil
        end

        local scale = 1
        local label = self:makeDamageNumber(tostring(damage), cc.c3b(255, 210, 0), scale)
        label:setDockPoint(cc.p(1, 0.5))
        label:setAnchorPoint(cc.p(1, 0.5))

        vars['damageNode']:addChild(label)
        vars['damageLabel'] = label

        label:setScale(scale * 1.5)
        label:runAction(cc.ScaleTo:create(0.15, scale))
    end
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

-------------------------------------
-- function makeDamageNumber
-------------------------------------
function SkillHitEffectDirector:makeDamageNumber(damage, color, scale)
    local x_offset = 0
    local str = comma_value(damage)
    local length = #str
    local damage_node = cc.Node:create()
    for i = 1, #str do
        local v = str:sub(i, i)
        local sprite = nil
        if (v == ',') then  -- comma
            sprite = self:createWithSpriteFrameName('ingame_damage_comma.png')
        else                -- number
            sprite = self:createWithSpriteFrameName('ingame_damage_'.. v.. '.png')
        end

        sprite:setPosition(x_offset, 0)
        sprite:setColor(color)
        sprite:setScale(scale)
        damage_node:addChild(sprite)
        x_offset = x_offset + (sprite:getContentSize()['width'])
    end
    
    damage_node:setPosition(-(x_offset/2), 0)
    damage_node:setCascadeOpacityEnabled(true)
    return damage_node
end

-------------------------------------
-- function createWithSpriteFrameName
-------------------------------------
function SkillHitEffectDirector:createWithSpriteFrameName(res_name)
	local sprite = cc.Sprite:createWithSpriteFrameName(res_name)
    if (not sprite) then
        -- @E.T.
		g_errorTracker:appendFailedRes(res_name)

        cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_damage/ingame_damage.plist')
        sprite = cc.Sprite:createWithSpriteFrameName(res_name)
    end

	sprite:setDockPoint(CENTER_POINT)
	sprite:setAnchorPoint(CENTER_POINT)
	return sprite
end