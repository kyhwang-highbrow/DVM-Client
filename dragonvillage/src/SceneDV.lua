DV_SCENE_ACTIVE = false

-------------------------------------
-- class SceneDV
-------------------------------------
SceneDV = class(PerpleScene, {
		m_lSpineAni = {},
		m_gridNode = 'nodeGrid',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneDV:init()
    self.m_bShowTopUserInfo = false
	self.m_lSpineAni = {}
	self.m_gridNode = cc.NodeGrid:create()
    self.m_scene:addChild(self.m_gridNode, 1)
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneDV:onEnter()
    PerpleScene.onEnter(self)
    g_currScene:addKeyKeyListener(self)
	--self:doUpdate()

    --self:scenarioTest()
	--self:penlightTest()

    self:glCallsTest()
end

-------------------------------------
-- function glCallsTest
-------------------------------------
function SceneDV:glCallsTest()
    local function update() 
        local drawnBatches = cc.Director:getInstance():getDrawnBatches()
        cclog('drawnBatches : ' .. drawnBatches)
    end
    self.m_scene:scheduleUpdateWithPriorityLua(update, 0)
end

-------------------------------------
-- function doUpdate
-------------------------------------
function SceneDV:doUpdate()
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
    ani:setScale(0.4)
    ani:setPosition(x, y)
	table.insert(self.m_lSpineAni, ani)
	self.m_gridNode:addChild(ani.m_node)
end

-------------------------------------
-- function setMonsterDragon
-------------------------------------
function SceneDV:setMonsterDragon(res_name, x, y)
    local scale = 1

    local ani = MakeAnimator(res_name)
    ani:setScale(scale)
    ani:setFlip(true)
	ani:setPosition(x, y)
    ani:changeAni('attack', true)
    table.insert(self.m_lSpineAni, ani)
	self.m_gridNode:addChild(ani.m_node, 1)

    local slotList = ani:getSlotList()
    for i, slotName in ipairs(slotList) do
        if startsWith(slotName, 'effect_') then
            --ani.m_node:setSlotGLProgramName(slotName, cc.SHADER_POSITION_TEXTURE_COLOR)
            ani.m_node:setVisibleSlot(slotName, false)
        end
    end

    local shader = ShaderCache:getShader(SHADER_DARK)
    ani.m_node:setGLProgram(shader)
    ani.m_node:useBonePosition('monstereye_1')
    ani.m_node:useBonePosition('monstereffect')

    do
        -- 안광
        local effect_eye = MakeAnimator('res/effect/effect_monsterdragon/effect_monsterdragon_eye.vrp')
        effect_eye:changeAni('idle', true)
        ani.m_node:addChild(effect_eye.m_node)

        -- 이펙트
        local effect1 = MakeAnimator('res/effect/effect_monsterdragon/effect_monsterdragon_b.vrp')
        effect1:setScale(scale)
        effect1:changeAni('idle', true)
        self.m_gridNode:addChild(effect1.m_node, 0)

        -- 이펙트
        local effect2 = MakeAnimator('res/effect/effect_monsterdragon/effect_monsterdragon_f.vrp')
        effect2:changeAni('idle', true)
        ani.m_node:addChild(effect2.m_node)
            
        self.m_scene:scheduleUpdateWithPriorityLua(function(dt)
            local pos = ani.m_node:getBonePosition('monstereye_1')
            effect_eye.m_node:setPosition(pos.x, pos.y)

            pos = ani.m_node:getBonePosition('monstereffect')
            effect1.m_node:setPosition(-pos.x + 900, pos.y + 350)
            effect2.m_node:setPosition(pos.x, pos.y)

        end)
    end
end

-------------------------------------
-- function onKeyReleased
-------------------------------------
function SceneDV:onKeyReleased(keyCode, event)
	if keyCode == KEY_A then
        --local json_name = 'res/character/dragon/godaeshinryong_light_03/godaeshinryong_light_03.json'
        local json_name = 'res/character/dragon/orpheusdragon_earth_03/orpheusdragon_earth_03.json'
        self:setAni(json_name, 400, 350)
		self:setMonsterDragon(json_name, 900, 350)

    elseif keyCode == KEY_Z then
        local duration = 1
        local sequence = cc.Sequence:create(
            cca.getShaky3D(2, 1),
            cc.DelayTime:create(duration)
        )
        self.m_gridNode:runAction(cc.RepeatForever:create(sequence))

    elseif keyCode == KEY_C then
        self.m_gridNode:stopAllActions()

	elseif keyCode == KEY_S then
		local rand_x = math_random(100, 900)
		local rand_y = math_random(200, 600)
		local res_name = 'res/effect/skill_thunder_cloud/skill_thunder_cloud_fire.vrp'
		self:setAni(res_name, rand_x, rand_y)

	elseif keyCode == KEY_Q then
		self:shaderTest_sample()
	elseif keyCode == KEY_W then
		self:shaderTest_blur()
	elseif keyCode == KEY_E then
		self:shaderTest_gray()
	elseif keyCode == KEY_P then 
		self:effect3DTest()
	elseif keyCode == KEY_F then
		for i, v in pairs(self.m_lSpineAni) do
			v:release()
		end
		self.m_lSpineAni = {}

    elseif keyCode == KEY_1 then
		local animator = MakeAnimator('res/character/monster/boss_gdragon_fire/boss_gdragon_head_fire.json')
        animator:setPosition(200, 200)
		self.m_scene:addChild(animator.m_node)

        animator:changeAni('casting', true)

        local shader = ShaderCache:getShader(SHADER_DARK)
        animator.m_node:setGLProgram(shader)

        local slotList = animator:getSlotList()
        cclog('slotList = ' .. luadump(slotList))
        
        for i, slotName in ipairs(slotList) do
            if startsWith(slotName, 'effect_') then
                animator.m_node:setSlotGLProgramName(slotName, cc.SHADER_POSITION_TEXTURE_COLOR)
            end
        end

    elseif keyCode == KEY_2 then
		local animator = MakeAnimator('res/character/monster/boss_drake_water/boss_drake_water.json')
        animator:setPosition(400, 200)
		self.m_scene:addChild(animator.m_node)

        animator:changeAni('skill_3', true)

        local shader = ShaderCache:getShader(SHADER_CHARACTER_DAMAGED)
        animator.m_node:setGLProgram(shader)

        for i = 1, 11 do
            animator.m_node:setSlotGLProgramName(string.format('boss_drake_water_effect_%02d', i), cc.SHADER_POSITION_TEXTURE_COLOR)
        end
        animator.m_node:setSlotGLProgramName('boss_drake_water_effect_9', cc.SHADER_POSITION_TEXTURE_COLOR)

    elseif keyCode == KEY_3 then
		local animator = MakeAnimator('res/character/monster/boss_spider_queen_fire/boss_spider_queen_fire.json')
        animator:setPosition(400, 200)
		self.m_scene:addChild(animator.m_node)

        animator:changeAni('idle', true)

        local shader = ShaderCache:getShader(SHADER_CHARACTER_DAMAGED)
        animator.m_node:setGLProgram(shader)

        animator.m_node:setSlotGLProgramName('effect_01', cc.SHADER_POSITION_TEXTURE_COLOR)

        local slotList = animator:getSlotList()
        --cclog('slotList = ' .. luadump(slotList))

    elseif keyCode == KEY_4 then
        do
            local res_name = 'res/bg/ocean2/ocean2.vrp'
            local animator = MakeAnimator(res_name)
            animator:setPosition(0, 0)
            animator:setScale(0.8)
            animator:changeAni('layer_1_b', true)
		    self.m_scene:addChild(animator.m_node, 0)
        end
        do
            local res_name = 'res/bg/ocean2/ocean2.vrp'
            local animator = MakeAnimator(res_name)
            animator:setPosition(700, 800)
            animator:setScale(0.8)
            animator:changeAni('layer_3_a', true)
		    self.m_gridNode:addChild(animator.m_node)
        end
        
    elseif (keyCode == KEY_UP_ARROW) then
        self:setTimeScale(10)
        
        local motionStreak = cc.MotionStreak:create(0.5, -1, 50, cc.c3b(255, 255, 255), 'res/effect/motion_streak/motion_streak_fire.png')
        motionStreak:setPosition(100, 100)
        motionStreak:setBezierMode(true)
        if (color) then
		    motionStreak:setColor(color)
	    end

        self.m_scene:addChild(motionStreak)

        local course = 1
        local bezier = getBezier(1200, 600, 100, 100, course)

        motionStreak:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.05),
            --cc.BezierBy:create(0.5, bezier, true),
            cc.JumpTo:create(0.5, cc.p(1200, 600), 300, 1, true),
            cc.RemoveSelf:create()
        ))
        
    elseif (keyCode == KEY_DOWN_ARROW) then
        self:setTimeScale(1)
        
        local motionStreak = cc.MotionStreak:create(0.5, -1, 50, cc.c3b(255, 255, 255), 'res/effect/motion_streak/motion_streak_fire.png')
        motionStreak:setPosition(100, 100)
	    if (color) then
		    motionStreak:setColor(color)
	    end

        self.m_scene:addChild(motionStreak)

        local course = 1
        local bezier = getBezier(1200, 600, 100, 100, course)

        motionStreak:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.05),
            --cc.BezierBy:create(0.5, bezier),
            cc.JumpTo:create(0.5, cc.p(1200, 600), 300, 1),
            cc.RemoveSelf:create()
        ))

	end
end

-------------------------------------
-- function tableViewTDDevelopment
-------------------------------------
function SceneDV:tableViewTDDevelopment()

    -- fps를 활용할 수 있도록
    cc.Director:getInstance():setDisplayStats(true)

    -- 세이브파일에 저장된 유저데이터를 사용하기 위해서 초기화
    LocalData:getInstance()
    ServerData:getInstance()

    -- 테이블뷰의 부모노드 생성
    local parent_node = cc.Scale9Sprite:create('res/ui/frames/base_frame_0101.png')
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
    local parent_node = cc.Scale9Sprite:create('res/ui/frames/base_frame_01.png')
    parent_node:setDockPoint(cc.p(0, 0.5))
    parent_node:setAnchorPoint(cc.p(0, 0.5))
    self.m_scene:addChild(parent_node)
    parent_node:setNormalSize(800, 600)

    -- 자식노드 생성
    local sprite = cc.Sprite:create('res/ui/frames/base_frame_0101.png')
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
	local shader = ShaderCache:getShader(SHADER_BLUR)
	for i, ani in pairs(self.m_lSpineAni) do 
		ani.m_node:setGLProgram(shader)
		ani.m_node:getGLProgramState():setUniformVec2('resolution', cc.p(100, 100))
		ani.m_node:getGLProgramState():setUniformFloat('blurRadius', 2.0)
		ani.m_node:getGLProgramState():setUniformFloat('sampleNum', 5.0)
	end
end

-------------------------------------
-- function shaderTest_sample
-------------------------------------
function SceneDV:shaderTest_gray()
	local shader = ShaderCache:getShader(SHADER_GRAY)
	for i, ani in pairs(self.m_lSpineAni) do 
		ani.m_node:setGLProgram(shader)
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

-------------------------------------
-- function effect3DTest
-------------------------------------
function SceneDV:effect3DTest()
	local scr_size = cc.Director:getInstance():getWinSize()
	--local action = cc.Ripple3D:create(3, {width = 32, height = 24}, scr_size, 200, 4, 160)
	local action = cc.Shaky3D:create(3, {width = 10, height = 10}, 5, false)
	self.m_gridNode:runAction(action)
end

-------------------------------------
-- function testChatTableView
-------------------------------------
function SceneDV:testChatTableView()
    local uic_node = UIC_Node:create()
    uic_node:setNormalSize(600, 500)
    uic_node:initGLNode()
    self.m_scene:addChild(uic_node.m_node)

	local chat_table_view = UIC_ChatTableView(uic_node.m_node)

    local function create_func()
    end

    chat_table_view.m_defaultCellSize = cc.size(246 + 10, 364)
    chat_table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    chat_table_view:setCellUIClass(UIC_ChatTableViewCell, create_func)
    chat_table_view:setItemList({1,2,3,4,5})
end

-------------------------------------
-- function socketTest
-------------------------------------
function SceneDV:socketTest()
    local ip = 'dv-test.perplelab.com'
    local port = '9013'

    local tcp = socket.tcp()
    tcp:settimeout(3)
    
    local __succ, __status = tcp:connect(ip, port)

    --'connection refused'

    ccdump(__succ)
    ccdump(__status)

    --tcp:close()
    --tcp:send()
    --tcp:shutdown()
    --tcp:receive()
end

-------------------------------------
-- function scenarioTest
-------------------------------------
function SceneDV:scenarioTest()
    local l_scenario = {
        'scenario_sample',
        'scenario_01_12_finish',
        'scenario_intro_start_goni',
        'scenario_intro_start_nuri',
        'scenario_intro_finish_nuri',
        'scenario_intro_finish_goni',
        'scenario_01_08_start',
        'scenario_01_08_finish',
        'scenario_01_12_start',
        'scenario_01_12_finish',
        'scenario_01_04_start',
        'scenario_01_04_finish',
    }

    local doPlay = nil
    doPlay = function()
        if l_scenario[1] then
            local scenario_name = l_scenario[1]
            local ui = UI_ScenarioPlayer(scenario_name)
            ui:setCloseCB(doPlay)
            ui:next()
            table.remove(l_scenario, 1)
        end
    end

    doPlay()
end

-------------------------------------
-- function penlightTest
-------------------------------------
function SceneDV:penlightTest()
	require 'plSample'
	require 'plSample_test'

	for var, func in pairs(plSample) do
		if (pl.stringx.startswith(var, 'test_')) then
			if (type(func) == 'function') then
				print ('###################' .. var .. '######################')
				func()
			end
		end
	end
end

-------------------------------------
-- function webViewTest
-------------------------------------
function SceneDV:webViewTest()
    if isWin32() then return end 
    local url = 'http://cafe.naver.com'
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local webview = ccexp.WebView:create()
    webview:setAnchorPoint(cc.p(0, 0))
    webview:setContentSize(visibleSize.width, visibleSize.height)
    webview:loadURL(url)
    webview:setBounces(false)
    webview:setScalesPageToFit(true)
    self.m_scene:addChild(webview)
end

-------------------------------------
-- function videoPlayerTest
-------------------------------------
function SceneDV:videoPlayerTest()
    if isWin32() then return end 
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local videoPlayer = ccexp.VideoPlayer:create()
    videoPlayer:setAnchorPoint(cc.p(0, 0))
    videoPlayer:setContentSize(visibleSize.width, visibleSize.height)
    videoPlayer:setFileName("video/kakao_splash.mp4") -- test res
    self.m_scene:addChild(videoPlayer)
    videoPlayer:play()

    local bStart = false
    local function update_func(dt)
        if not bStart and videoPlayer:isPlaying() then
            cclog('video play start')
            bStart = true
        end

        if bStart and not videoPlayer:isPlaying() then
            cclog('video play end')
            videoPlayer:unscheduleUpdate()
        end
    end

    videoPlayer:scheduleUpdateWithPriorityLua(function(dt) update_func(dt) end, 0)   
end

-------------------------------------
-- function richLabelTest
-------------------------------------
function SceneDV:richLabelTest()
    -- 글자가 잘보이게 프레임배경 생성
    local bubble = cc.Scale9Sprite:create('res/ui/frames/adventure_map_reward_0101.png')
    bubble:setDockPoint(CENTER_POINT)
    bubble:setAnchorPoint(CENTER_POINT)
    bubble:setContentSize(500, 300)
    bubble:setPosition(0, 0)
    self.m_scene:addChild(bubble)

    local str = '{@BLACK}15초마다 생명력이 가장 낮은 아군 2명{@RED}에게 공격력의 {@MUSTARD}200%{@BLACK} 만큼 생명력 회복'
    
    -- rich 생성 
    local rich_label = UIC_RichLabel()
    rich_label:setString(str)
    rich_label:setFontSize(20)
    rich_label:setDimension(284, 154)
    rich_label:setPosition(0, 0)
    rich_label:setDockPoint(CENTER_POINT)
    rich_label:setAnchorPoint(CENTER_POINT)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    self.m_scene:addChild(rich_label.m_node)
    
    -- rich label 영역 그리기
    rich_label:initGLNode()
end