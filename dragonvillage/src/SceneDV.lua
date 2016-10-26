DV_SCENE_ACTIVE = false

-------------------------------------
-- class SceneDV
-------------------------------------
SceneDV = class(PerpleScene, {
    })

-------------------------------------
-- function init
-------------------------------------
function SceneDV:init()
    self.m_bShowTopUserInfo = false
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneDV:onEnter()
    PerpleScene.onEnter(self)

    --self:spineTest()
    self:bezierTest()
end

function bezierat(a, b, c, d, t)
    return (math_pow(1-t,3) * a + 
            3*t*(math_pow(1-t,2))*b + 
            3*math_pow(t,2)*(1-t)*c +
            math_pow(t,3)*d );
end

-------------------------------------
-- function bezierTest
-------------------------------------
function SceneDV:bezierTest()
    --bezierat(1, 2, 3, 4, 5, 6)

    local sprite = cc.Sprite:create('res/missile/missile_developing.png')
    self.m_scene:addChild(sprite)

    local bezier1 = {
        cc.p(000, 500),
        cc.p(700, 300),
        cc.p(1000, 0),
    }

    local bezier = cc.BezierTo:create(1, bezier1)
    sprite:runAction(bezier)


    for time=0, 1, 0.05 do
        local xa = 0
        local xb = bezier1[1]['x']
        local xc = bezier1[2]['x']
        local xd = bezier1[3]['x']

        local ya = 0
        local yb = bezier1[1]['y']
        local yc = bezier1[2]['y']
        local yd = bezier1[3]['y']

        local x = bezierat(xa, xb, xc, xd, time)
        local y = bezierat(ya, yb, yc, yd, time)

        cclog(time)

        cclog(x, y)

        local sprite = cc.Sprite:create('res/missile/missile_developing.png')
        sprite:setPosition(x, y)
        self.m_scene:addChild(sprite)
    end
end




-------------------------------------
-- function spineTest
-------------------------------------
function SceneDV:spineTest()
    local json_name = 'res/character/dragon/godaeshinryong_03/godaeshinryong_03.json'
    local atlas_name = 'res/character/dragon/godaeshinryong_03/godaeshinryong_03.atlas'
    local spine = sp.SkeletonAnimation:create(json_name, atlas_name, 1)

    spine:setSkin('goblingirl')

    spine:setAnimation(0, 'attack', true)
    spine:setAnchorPoint(cc.p(0.5, 0.5))
    spine:setDockPoint(cc.p(0.5, 0.5))
    spine:setPosition(0, -200)
    
    self.m_scene:addChild(spine)  

    spine:setBoneRotation('bone44', 90)
    spine:setBoneRotation('bone44', 0, 1.6)
    --spine:setBoneRotation('bone44', 90)
    spine:setMix('attack', 'idle', 0.5)

    spine:registerSpineEventHandler(function()
        spine:setAnimation(0, 'idle', true)
        spine:setToSetupPose()
        spine:update(0)
    end, sp.EventType.ANIMATION_COMPLETE)

    --[[
    spine:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function(node)
        --node:setSkin('goblin')
        --spine:setBoneRotation('head', 0)
        node:setAnimation(0, 'idle', true)
        node:setToSetupPose()
    end)))
    --]]

    spine:setScaleX(-1)

    --[[
    local function checkAction(dt)
        spine:setBoneRotation('head', 90)
        spine:update(0)

    end
    self.m_scene:scheduleUpdateWithPriorityLua(checkAction, 0)
    --]]
end