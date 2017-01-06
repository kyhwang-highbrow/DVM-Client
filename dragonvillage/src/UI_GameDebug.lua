local UI_GAMEDEBUG_WIDTH = 300

-------------------------------------
-- class UI_GameDebug
-- @brief 인게임에서 실시간으로 각종 설정을 할 수 있도록 하는 UI생성
-------------------------------------
UI_GameDebug = class(UI,{
        m_bShow = 'boolean',    -- 보여지고 있는 상태(기본은 화면 왼쪽에 숨겨있음)
        m_width = 'number',     -- UI 넓이
        m_height = 'number',    -- UI 높이

		m_world = 'GameWorld',

		m_directStrength = 'num', -- 배경 이펙트 에서 사용
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GameDebug:init()
	self.m_world =  g_gameScene.m_gameWorld

    -- UI의 크기 지정(높이는 화면의 높이)
    local scr_size = cc.Director:getInstance():getWinSize()
    self.m_width = UI_GAMEDEBUG_WIDTH
    self.m_height = scr_size.height

    -- root 메뉴 생성
    local node = cc.Menu:create()
    node:setAnchorPoint(cc.p(0, 0.5))
    node:setDockPoint(cc.p(0, 0.5))
    node:setPosition(0, 0)
    node:setNormalSize(self.m_width, self.m_height)
    self.root = node

    -- 변수 초기화
    self.vars = {}
	self.m_directStrength = 0 

    do -- UI아래쪽은 터치되지 않도록 임의 버튼 생성
        local node = cc.MenuItemImage:create(EMPTY_PNG, nil, nil, 1)
        node:setContentSize(self.m_width, self.m_height)
        node:setDockPoint(cc.p(0.5, 0.5))
        node:setAnchorPoint(cc.p(0.5, 0.5))
        self.root:addChild(node)
    end

    do -- 배경
        local rect = cc.rect(0, 0, 0, 0)
        local node = cc.Scale9Sprite:create(rect, 'res/ui/frame_debug_01.png')
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setDockPoint(cc.p(0.5, 0.5))
        node:setRelativeSizeAndType(cc.size(0, 0), 3, false)
        self.root:addChild(node)
        self.vars['bgNode'] = node
    end

    do -- 열고 닫는 버튼
        local node = cc.MenuItemImage:create('res/ui/btn_debug_01.png', 'res/ui/btn_debug_02.png', 1)
        node:setDockPoint(cc.p(1, 0.5))
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setPosition(10, 0)
        --node:setScale(0.7)
        node:setScale(1)
        local uic_button = UIC_Button(node)
        uic_button:registerScriptTapHandler(function() self:showDebugUI(not self.m_bShow) end)
        self.root:addChild(node)
        self.vars['openButton'] = node

        do
            local sprite = cc.Sprite:create('res/ui/btn_debug_03.png')
            sprite:setDockPoint(cc.p(0.5, 0.5))
            sprite:setAnchorPoint(cc.p(0.5, 0.5))
            node:addChild(sprite)
        end
    end

    -- 테이블 뷰 생성
    self:makeTableView()

    -- UI를 숨김 상태로 변경
    self.m_bShow = false
    self.root:setPositionX(-self.m_width)
    self:showDebugUI(false)
end

-------------------------------------
-- function showDebugUI
-------------------------------------
function UI_GameDebug:showDebugUI(show)
    self.m_bShow = show

    self.vars['openButton']:stopAllActions()
    self.root:stopAllActions()
    local duration = 0.3

    if show then
        self.vars['bgNode']:setVisible(true)
        self.root:runAction(cc.MoveTo:create(duration, cc.p(0, 0)))
        self.vars['openButton']:runAction(cc.RotateTo:create(duration, 0))
    else
        self.root:runAction(cc.Sequence:create(cc.MoveTo:create(duration, cc.p(-self.m_width, 0)), cc.CallFunc:create(function() self.vars['bgNode']:setVisible(false) end)))
        self.vars['openButton']:runAction(cc.RotateTo:create(duration, 180))
    end
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_GameDebug:makeTableView()
    local tableView = cc.TableView:create(cc.size(self.m_width-40, self.m_height-50))
    local node = TableViewTD.create(tableView)
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setPosition(0, -8)

    node:setBounceable(true)
    node:setDirection(1) -- 0=HORIZONTAL, 1=VERTICAL 가로인지 세로인지 여부
    node:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) -- 위에서부터 정렬
    node:setDelegate()
    self.vars['bgNode']:addChild(node)

    -- 셀 추가
	local size_width, size_height = 260, 50 
    node:setCellInfo(1, cc.size(size_width, size_height))
    node:setItemInfo({}, function(tParam)

        local cell_node = cc.Node:create()
        cell_node:setNormalSize(size_width, size_height)
        cell_node:setPosition(0, 0)
        tParam.cell:addChild(cell_node)

        local cell_menu = cc.Menu:create()
        cell_menu:setDockPoint(cc.p(0.5, 0.5))
        cell_menu:setAnchorPoint(cc.p(0.5, 0.5))
        cell_menu:setNormalSize(size_width, size_height)
        cell_menu:setPosition(0, 0)
        cell_menu:setSwallowTouch(true)
        cell_node:addChild(cell_menu)

        local item = tParam['item']
        if item['cb1'] then
            local node = cc.MenuItemImage:create('res/ui/btn_debug_04.png', 'res/ui/btn_debug_05.png', 1)
            node:setDockPoint(cc.p(1, 0.5))
            node:setPositionX(-40)
            node:setAnchorPoint(cc.p(0.5, 0.5))
            node:setRotation(180)
            local uic_button = UIC_Button(node)
            uic_button:registerScriptTapHandler(function()
                item['cb1'](self, item, 1)
            end)
            cell_menu:addChild(node)
        end

        if item['cb2'] then
            local node = cc.MenuItemImage:create('res/ui/btn_debug_04.png', 'res/ui/btn_debug_05.png', 1)
            node:setDockPoint(cc.p(1, 0.5))
            node:setPositionX(-(40 + 67))
            node:setAnchorPoint(cc.p(0.5, 0.5))
            local uic_button = UIC_Button(node)
            uic_button:registerScriptTapHandler(function()
                item['cb2'](self, item, 2)
            end)
            cell_menu:addChild(node)
        end

        do -- label 생성
            -- left 0, center 1, right 2
            local label = cc.Label:createWithTTF(item['str'] or 'label', 'res/font/common_font_01.ttf', 15, 2, cc.size(250, 100), 0, 1)
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            cell_menu:addChild(label)
            item['label'] = label
        end

        if item['cb'] then
            item['cb']()
        end

    end)
    node:update()

    -- 디버깅 아이템 설정
    local item_info = {}

	do -- 웨이브 클리어 
        local item = {}
		item['str'] = Str('웨이브 클리어')
        item['cb1'] = function()
			self.m_world:killAllEnemy()
        end
        table.insert(item_info, item)
    end

	do -- 스테이지 성공
        local item = {}
		item['str'] = Str('스테이지 성공')
        item['cb1'] = function()
			self.m_world.m_gameState:changeState(GAME_STATE_SUCCESS)
        end
        table.insert(item_info, item)
    end

	do -- 체력 표시 
        local item = {}
		item['str'] = Str('체력 표시')
        item['cb1'] = function()
			DISPLAY_UNIT_HP = not DISPLAY_UNIT_HP
        end
        table.insert(item_info, item)
    end

    do -- 저사양모드
        local item = {}
        item['cb1'] = UI_GameDebug.lowEndModeButton
        if isLowEndMode() then
            item['str'] = '저사양모드 ON'
        else
            item['str'] = '저사양모드 OFF'
        end

        table.insert(item_info, item)
    end

    do -- 피격박스 on/off
        if g_gameScene.m_gameWorld.m_physWorld then
            local item = {}
            item['cb1'] = UI_GameDebug.physDebugButton

            item['cb'] = function()
                local cb = function(debug_on)
                    if item['label'] then
                        if debug_on then
                            item['label']:setString(Str('피격박스 ON'))
                        else
                            item['label']:setString(Str('피격박스 OFF'))
                        end
                    end
                end

                g_gameScene.m_gameWorld.m_physWorld:addDebugChangeCB(self, cb)
            end

            table.insert(item_info, item)
        end
    end

    do -- FPS on/off
        local item = {}
        item['cb1'] = UI_GameDebug.fpsButton
        if cc.Director:getInstance():isDisplayStats() then
            item['str'] = Str('FPS ON')
        else
            item['str'] = Str('FPS OFF')
        end

        table.insert(item_info, item)
    end

	do -- Realtime Debug on/off
        local item = {}
        item['cb1'] = UI_GameDebug.realtimeDebugButton
        if DISPLAY_DEBUG_INFO then
            item['str'] = Str('Memory ON')
        else
            item['str'] = Str('Memory OFF')
        end

        table.insert(item_info, item)
    end
	
    do -- 화면 크기
        local item = {}
        item['cb1'] = UI_GameDebug.worldScaleButton
        item['cb2'] = UI_GameDebug.worldScaleButton
        --item['str'] = Str('월드 크기 X 1')

        item['cb'] = function()
            local cb = function(scale)
                if item['label'] then
                    item['label']:setString(Str('월드 크기 X ' .. tostring(scale)))
                end
            end

            g_gameScene.m_gameWorld:addWorldScaleChangeCB(self, cb)
        end

        table.insert(item_info, item)
    end

    do -- 화면 밝기
        if g_gameScene.m_gameWorld.m_mapManager then
            local item = {}
            item['cb1'] = UI_GameDebug.brightnessButton
            item['cb2'] = UI_GameDebug.brightnessButton  
            item['str'] = '배경 밝기 ' .. g_gameScene.m_gameWorld.m_mapManager.m_colorScale .. ' %'

            table.insert(item_info, item)
        end
    end

    do -- Time Sacle
        if g_gameScene.m_gameWorld.m_gameTimeScale then
            local item = {}
            item['cb1'] = UI_GameDebug.timeScaleButton
            item['cb2'] = UI_GameDebug.timeScaleButton
            item['str'] = '게임 배속 X ' .. g_gameScene.m_gameWorld.m_gameTimeScale:getBase()

            table.insert(item_info, item)
        end
    end

	do -- BG effect change
        local item = {}
        item['cb1'] = UI_GameDebug.nigthmareBgButton
        item['cb2'] = UI_GameDebug.nigthmareBgButton
		item['str'] = '악몽던전 배경효과 : ' .. self.m_directStrength

        table.insert(item_info, item)
    end

    node:setItemInfo(item_info)
    node:update()
end

-------------------------------------
-- function worldScaleButton
-------------------------------------
function UI_GameDebug.worldScaleButton(self, item, idx)

    local add_scale = nil
    if (idx == 1) then
        add_scale = 0.1
    elseif (idx == 2) then
        add_scale = -0.1
    end

    local world = g_gameScene.m_gameWorld
    local scale = world.m_worldScale + add_scale
    world:changeWorldScale(scale)
    --item['label']:setString(Str('월드 크기 X ' .. tostring(scale)))
end


-------------------------------------
-- function brightnessButton
-------------------------------------
function UI_GameDebug.brightnessButton(self, item, idx)

    local add_scale = nil
    if (idx == 1) then
        add_scale = 10
    elseif (idx == 2) then
        add_scale = -10
    end

    local map_mgr = g_gameScene.m_gameWorld.m_mapManager
    map_mgr.m_colorScale = math_clamp(map_mgr.m_colorScale + add_scale, 0, 100)
    
    local rgb = 255 * (map_mgr.m_colorScale / 100)
    map_mgr:tintTo(rgb, rgb, rgb, 0.5)

    item['label']:setString('배경 밝기 ' .. map_mgr.m_colorScale .. ' %')
end

-------------------------------------
-- function timeScaleButton
-------------------------------------
function UI_GameDebug.timeScaleButton(self, item, idx)

    local add_scale = nil
    if (idx == 1) then
        add_scale = 0.1
    elseif (idx == 2) then
        add_scale = -0.1
    end

    local scale = g_gameScene.m_gameWorld.m_gameTimeScale:getBase() + add_scale
    g_gameScene.m_gameWorld.m_gameTimeScale:setBase(scale)

    item['label']:setString('게임 배속 X ' .. scale)
end

-------------------------------------
-- function nigthmareBgButton
-------------------------------------
function UI_GameDebug.nigthmareBgButton(self, item, idx)
    local add_value = nil
    if (idx == 1) then
        add_value = 1
    elseif (idx == 2) then
        add_value = -1
    end

    local strength = self.m_directStrength + add_value

	if (strength > 20) then
		strength = 1
	elseif (strength < 1) then
		strength = 20
	end
	self.m_directStrength = strength

	local l_direction = {'shaky', 'ripple', 'nightmare_shaky', 'nightmare_ripple'}
	local direct_type = math_ceil(strength / 5)
	local direct_stregth = (strength - ((direct_type - 1) * 5))

	g_gameScene.m_gameWorld.m_mapManager.m_node:stopAllActions()
	g_gameScene.m_gameWorld.m_mapManager:setDirecting(l_direction[direct_type] .. direct_stregth)
    item['label']:setString('악몽던전 배경효과 : ' .. strength)
end

-------------------------------------
-- function lowEndModeButton
-------------------------------------
function UI_GameDebug.lowEndModeButton(self, item, idx)
    local low_end_mode = (not isLowEndMode())
    setLowEndMode(low_end_mode)

    if low_end_mode then
        item['label']:setString('저사양모드 ON')
    else
        item['label']:setString('저사양모드 OFF')
    end
end

-------------------------------------
-- function physDebugButton
-------------------------------------
function UI_GameDebug.physDebugButton(self, item, idx)

    local phys_world = g_gameScene.m_gameWorld.m_physWorld
    local debug = (not phys_world.m_bDebug)
    phys_world:setDebug(debug)
end

-------------------------------------
-- function fpsButton
-------------------------------------
function UI_GameDebug.fpsButton(self, item, idx)
    cc.Director:getInstance():setDisplayStats(not cc.Director:getInstance():isDisplayStats())

    if cc.Director:getInstance():isDisplayStats() then
        item['label']:setString(Str('FPS ON'))
    else
        item['label']:setString(Str('FPS OFF'))
    end
end

-------------------------------------
-- function fpsButton
-------------------------------------
function UI_GameDebug.realtimeDebugButton(self, item, idx)
    DISPLAY_DEBUG_INFO = not DISPLAY_DEBUG_INFO
	if UIManager.m_debugUI then
		UIManager.m_debugUI.m_debugLayer:setVisible(DISPLAY_DEBUG_INFO)
	end

    if DISPLAY_DEBUG_INFO then
        item['label']:setString(Str('Memory ON'))
    else
        item['label']:setString(Str('Memory OFF'))
    end
end
