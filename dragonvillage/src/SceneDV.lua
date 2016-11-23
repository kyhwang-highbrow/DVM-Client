DV_SCENE_ACTIVE = false

-------------------------------------
-- class SceneDV
-------------------------------------
SceneDV = class(PerpleScene, {
		m_lSpineAni = {},
    })

-------------------------------------
-- function init
-------------------------------------
function SceneDV:init()
    self.m_bShowTopUserInfo = false
	self.m_lSpineAni = {}
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneDV:onEnter()
    PerpleScene.onEnter(self)
	g_currScene:addKeyKeyListener(self)
	self.m_scene:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
	cc.Director:getInstance():setDisplayStats(true)
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
-- function updateUnit
-- @param dt
-------------------------------------
function SceneDV:update(dt)
	PerpleScene.update(self, dt)
	for i, v in pairs(self.m_lSpineAni) do
		cclog('ani #'..i)
		for i = 1, 10000 do
			local temp = i * 3 + 10 - 99
		end
		
	end
end

-------------------------------------
-- function setAni
-------------------------------------
function SceneDV:setAni(res_name, x, y)
	local ani = MakeAnimator(res_name)
	ani:setPosition(x, y)
	table.insert(self.m_lSpineAni, ani)
	self.m_scene:addChild(ani.m_node)
end

-------------------------------------
-- function onKeyReleased
-------------------------------------
function SceneDV:onKeyReleased(keyCode, event)
	if keyCode == KEY_F then
		local rand_x = math_random(0, 960)
		local rand_y = math_random(0, 500)
		local json_name = 'res/missile/missile_arrow/missile_arrow.png'
		self:setAni(json_name, rand_x, rand_y)

	elseif keyCode == KEY_S then
		local rand_x = math_random(0, 960)
		local rand_y = math_random(0, 500)
		local json_name = 'res/character/dragon/spine_earth_01/spine_earth_01.json'
		self:setAni(json_name, rand_x, rand_y)

	elseif keyCode == KEY_D then
		local rand_x = math_random(0, 960)
		local rand_y = math_random(0, 500)
		local res_name = 'res/missile/missile_giantdragon_basic_fire/missile_giantdragon_basic_fire.vrp'
		self:setAni(res_name, rand_x, rand_y)

	elseif keyCode == KEY_A then
		for i, v in pairs(self.m_lSpineAni) do
			v:release()
		end
		self.m_lSpineAni = {}
	end
end