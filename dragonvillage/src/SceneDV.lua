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
	self:doUpdate()
end

-------------------------------------
-- function doUpdate
-------------------------------------
function SceneDV:doUpdate()
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
	if keyCode == KEY_A then
		local rand_x = math_random(100, 900)
		local rand_y = math_random(200, 600)
		local json_name = 'res/character/dragon/spine_earth_01/spine_earth_01.json'
		self:setAni(json_name, rand_x, rand_y)

	elseif keyCode == KEY_S then
		local rand_x = math_random(100, 900)
		local rand_y = math_random(200, 600)
		local res_name = 'res/effect/skill_thunder_cloud/skill_thunder_cloud_fire.vrp'
		self:setAni(res_name, rand_x, rand_y)
	
	elseif keyCode == KEY_D then
		local rand_x = math_random(100, 900)
		local rand_y = math_random(200, 600)
		local json_name = 'res/ui/icon/cha/lightningdragon_03.png'
		self:setAni(json_name, rand_x, rand_y)

	elseif keyCode == KEY_Q then
		self:shaderTest_sample()
	elseif keyCode == KEY_W then
		self:shaderTest_blur()
	elseif keyCode == KEY_E then
		self:shaderTest_a2d()

	elseif keyCode == KEY_F then
		for i, v in pairs(self.m_lSpineAni) do
			v:release()
		end
		self.m_lSpineAni = {}
	end
end

-------------------------------------
-- function tableViewTDDevelopment
-------------------------------------
function SceneDV:tableViewTDDevelopment()

    -- fps를 활용할 수 있도록
    cc.Director:getInstance():setDisplayStats(true)

    -- 세이브파일에 저장된 유저데이터를 사용하기 위해서 초기화
    ServerData:getInstance()

    -- 테이블뷰의 부모노드 생성
    local parent_node = cc.Scale9Sprite:create('res/ui/frame/base_frame_01.png')
    parent_node:setDockPoint(cc.p(0.5, 0.5))
    parent_node:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_scene:addChild(parent_node)
    parent_node:setNormalSize(800, 600)

    -- 아이템 리스트
    local item_list = g_dragonsData:getDragonsList()

    -- 생성 시 함수
    local function create_func(ui, data)
    end

    local stopwatch = Stopwatch()
    stopwatch:start()

    -- 테이블뷰 생성 TD
    local table_view = UIC_TableViewTD(parent_node)
    table_view.m_cellSize = cc.size(150, 150)
    table_view.m_nItemPerCell = 4
    table_view:setCellUIClass(UI_DragonCard, create_func)
    table_view:setItemList(item_list)

    stopwatch:stop()
    stopwatch:print()

    local item_count = table_view:getItemCount()
    cclog(item_count)
end

-------------------------------------
-- function dockPointTest
-------------------------------------
function SceneDV:dockPointTest()
    cclog('## SceneDV:dockPointTest()')

    -- 부모노드 생성
    local parent_node = cc.Scale9Sprite:create('res/ui/frame/base_frame_01.png')
    parent_node:setDockPoint(cc.p(0, 0.5))
    parent_node:setAnchorPoint(cc.p(0, 0.5))
    self.m_scene:addChild(parent_node)
    parent_node:setNormalSize(800, 600)

    -- 자식노드 생성
    local sprite = cc.Sprite:create('res/ui/frame/base_frame_01.png')
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    parent_node:addChild(sprite)


    local width, height = parent_node:getNormalSize()
    local func = function(value)
        parent_node:setNormalSize(value, height)
        parent_node:setUpdateChildrenTransform()

        --[[
        local stencil = node:getStencil()
        stencil:clear()
        local rectangle = {}
		local white = cc.c4b(1,1,1,1)
		table.insert(rectangle, cc.p(0, 0))
		table.insert(rectangle, cc.p(value or 0, 0))
		table.insert(rectangle, cc.p(value or 0, height or 0))
		table.insert(rectangle, cc.p(0,height or 0))
		stencil:drawPolygon(
				rectangle
				, 4
				, white
				, 1
				, white
		)
        node:setPosition(0, 0)
        vars['bgSprite']:setPosition(0, 0)
        vars['bgSprite']:retain()
        vars['bgSprite']:removeFromParent()
        node:addChild(vars['bgSprite'])
        vars['bgSprite']:release()

        --]]
    end

    local tween = cc.ActionTweenForLua:create(10, width, 200, func)
    action = cc.EaseInOut:create(tween, 2)
    --action:setTag(TAG_CELL_WIDTH_TO)
    parent_node:runAction(action)
end

-------------------------------------
-- function expandTest
-------------------------------------
function SceneDV:expandTest()
    local ui = UI_DragonTrainSlot_ListItem({})
    self.m_scene:addChild(ui.root)
    ui.vars['clickBtn']:registerScriptTapHandler(function() ui:setExpand((not ui.m_bExpanded), 0.15)  end)
end

-------------------------------------
-- function shaderTest_sample
-------------------------------------
function SceneDV:shaderTest_sample()
	local shader = ShaderCache:getShader(SHADER_CHARACTER_DAMAGED)
	for i, ani in pairs(self.m_lSpineAni) do 
		ani.m_node:setGLProgram(shader)
	end
end

-------------------------------------
-- function shaderTest_blur
-------------------------------------
function SceneDV:shaderTest_blur()
	local shader = ShaderCache:getShader(SHADER_MAP_BLUR)
	for i, ani in pairs(self.m_lSpineAni) do 
		ani.m_node:setGLProgram(shader)
		ani.m_node:getGLProgramState():setUniformVec2('resolution', cc.p(100, 100))
		ani.m_node:getGLProgramState():setUniformFloat('blurRadius', 2.0)
		ani.m_node:getGLProgramState():setUniformFloat('sampleNum', 5.0)
	end
end

-------------------------------------
-- function shaderTest
-------------------------------------
function SceneDV:shaderTest_a2d()
	for i, ani in pairs(self.m_lSpineAni) do 
		if ani.m_type == ANIMATOR_TYPE_VRP then 
			ani.m_node:setCustomShader(5,2)
		end
	end
end