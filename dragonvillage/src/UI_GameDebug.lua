local UI_GAMEDEBUG_WIDTH = 350

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
function UI_GameDebug:init(world)
	self.m_world =  world

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
        local node = cc.Scale9Sprite:create(rect, 'res/ui/temp/frame_debug_01.png')
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setDockPoint(cc.p(0.5, 0.5))
        node:setRelativeSizeAndType(cc.size(0, 0), 3, false)
        self.root:addChild(node)
        self.vars['bgNode'] = node
    end

    do -- 테이블 뷰 노드
        local node = cc.Node:create()
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setDockPoint(cc.p(0.5, 0.5))
        node:setRelativeSizeAndType(cc.size(-50, -30), 3, false)
        self.vars['bgNode']:addChild(node)
        self.vars['tableViewNode'] = node
    end

    do -- 열고 닫는 버튼
        local node = cc.MenuItemImage:create('res/ui/temp/btn_debug_01.png', 'res/ui/temp/btn_debug_02.png', 1)
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
            local sprite = cc.Sprite:create('res/ui/temp/btn_debug_03.png')
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
    local size_width, size_height = (UI_GAMEDEBUG_WIDTH - 30), 64

    local function create_func(data)
        local ui = UIC_ChatTableViewCell(data)

        local cell_menu = ui.root
        cell_menu:setDockPoint(cc.p(0.5, 0.5))
        cell_menu:setAnchorPoint(cc.p(0.5, 0.5))
        cell_menu:setNormalSize(size_width, size_height)
        cell_menu:setPosition(0, 0)
        cell_menu:setSwallowTouch(true)

        if data['cb1'] then
            local node = cc.MenuItemImage:create('res/ui/buttons/64_base_btn_0101.png', 'res/ui/buttons/64_base_btn_0102.png', 1)
            node:setDockPoint(cc.p(1, 0.5))
            node:setPositionX(-40)
            node:setAnchorPoint(cc.p(0.5, 0.5))
            local uic_button = UIC_Button(node)
            uic_button:registerScriptTapHandler(function()
                data['cb1'](self, data, 1)
            end)
            cell_menu:addChild(node)
        end

        if data['cb2'] then
            local node = cc.MenuItemImage:create('res/ui/buttons/64_base_btn_0101.png', 'res/ui/buttons/64_base_btn_0102.png', 1)
            node:setDockPoint(cc.p(0, 0.5))
            node:setPositionX(40)
            node:setAnchorPoint(cc.p(0.5, 0.5))
            local uic_button = UIC_Button(node)
            uic_button:registerScriptTapHandler(function()
                data['cb2'](self, data, 2)
            end)
            cell_menu:addChild(node)
        end

        do -- label 생성
            -- left 0, center 1, right 2
            local label = cc.Label:createWithTTF(data['str'] or 'label', Translate:getFontPath(), 20, 2, cc.size(size_width, size_height), 1, 1)
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            cell_menu:addChild(label)
            data['label'] = label
        end

        if data['cb'] then
            data['cb']()
        end

        return ui
    end

    local node = self.vars['tableViewNode']
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(size_width, size_height)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(create_func)

    -- 디버깅 아이템 설정
    local item_info = {}

	do -- 웨이브 클리어 
        local item = {}
		item['str'] = '웨이브 클리어'
        item['cb1'] = function()
			self.m_world:removeAllEnemy()
        end
        table.insert(item_info, item)
    end

	do -- 스테이지 성공
        local item = {}
		item['str'] = '스테이지 성공'
        item['cb1'] = function()
			self.m_world.m_gameState:changeState(GAME_STATE_SUCCESS)
        end
        table.insert(item_info, item)
    end

	do -- 체력 표시 
        local item = {}
		item['str'] = '체력 표시'
        item['cb1'] = function()
			local set_data = not g_constant:get('DEBUG', 'DISPLAY_UNIT_HP')
			g_constant:set(set_data, 'DEBUG', 'DISPLAY_UNIT_HP')
        end
        table.insert(item_info, item)
    end
	
	do -- 실드 표시 
        local item = {}
		item['str'] = '실드 표시'
        item['cb1'] = function()
			local set_data = not g_constant:get('DEBUG', 'DISPLAY_SHIELD_HP')
			g_constant:set(set_data, 'DEBUG', 'DISPLAY_SHIELD_HP')
        end
        table.insert(item_info, item)
    end

	do -- 플레이어 무적
        local item = {}
        item['cb1'] = UI_GameDebug.playerInvincible
		item['str'] = self:getInvincibleStr()
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
        if self.m_world.m_physWorld then
            local item = {}
            item['cb1'] = UI_GameDebug.physDebugButton

            item['cb'] = function()
                local cb = function(debug_on)
                    if item['label'] then
                        if debug_on then
                            item['label']:setString('피격박스 ON')
                        else
                            item['label']:setString('피격박스 OFF')
                        end
                    end
                end

                self.m_world.m_physWorld:addDebugChangeCB(self, cb)
            end

            table.insert(item_info, item)
        end
    end
    
    -- 적 마나 및 드래그 쿨타임 표시
    --if (self.m_world.m_gameMode == GAME_MODE_COLOSSEUM or self.m_world.m_gameMode == GAME_MODE_ARENA) then
    if isExistValue(self.m_world.m_gameMode, GAME_MODE_COLOSSEUM, GAME_MODE_ARENA, GAME_MODE_ARENA_NEW, GAME_MODE_CHALLENGE_MODE) then
        local item = {}
        item['cb1'] = UI_GameDebug.enemyManaCooldownButton
        if cc.Director:getInstance():isDisplayStats() then
            item['str'] = '적 마나 및 쿨타임 표시 ON'
        else
            item['str'] = '적 마나 및 쿨타임 표시 OFF'
        end

        table.insert(item_info, item)
    end

    do -- FPS on/off
        local item = {}
        item['cb1'] = UI_GameDebug.fpsButton
        if cc.Director:getInstance():isDisplayStats() then
            item['str'] = 'FPS ON'
        else
            item['str'] = 'FPS OFF'
        end

        table.insert(item_info, item)
    end

	do -- Realtime Debug on/off
        local item = {}
        item['cb1'] = UI_GameDebug.realtimeDebugButton
		if g_constant:get('DEBUG', 'DISPLAY_DEBUG_INFO') then
            item['str'] = 'Memory ON'
        else
            item['str'] = 'Memory OFF'
        end

        table.insert(item_info, item)
    end
	
    do -- 화면 크기
        local item = {}
        item['cb1'] = UI_GameDebug.worldScaleButton
        item['cb2'] = UI_GameDebug.worldScaleButton

        item['cb'] = function()
            local cb = function(scale)
                if item['label'] then
                    item['label']:setString('월드 크기 X ' .. tostring(scale))
                end
            end

            self.m_world:addWorldScaleChangeCB(self, cb)
        end

        table.insert(item_info, item)
    end

    do -- 화면 밝기
        if self.m_world.m_mapManager then
            local item = {}
            item['cb1'] = UI_GameDebug.brightnessButton
            item['cb2'] = UI_GameDebug.brightnessButton  
            item['str'] = '배경 밝기 ' .. self.m_world.m_mapManager.m_colorScale .. ' %'

            table.insert(item_info, item)
        end
    end

    do -- Time Sacle
        if self.m_world.m_gameTimeScale then
            local item = {}
            item['cb1'] = UI_GameDebug.timeScaleButton
            item['cb2'] = UI_GameDebug.timeScaleButton
            item['str'] = '게임 배속 X ' .. self.m_world.m_gameTimeScale:getBase()

            table.insert(item_info, item)
        end
    end

	do -- BG effect change
        local item = {}
        item['cb1'] = UI_GameDebug.nigthmareBgButton
        item['cb2'] = UI_GameDebug.nigthmareBgButton
		item['str'] = '배경효과 off'

        table.insert(item_info, item)
    end

    table_view:setItemList(item_info)
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

    local world = self.m_world
    local scale = world.m_worldScale + add_scale
    world:changeWorldScale(scale)
end


-------------------------------------
-- function brightnessButton
-------------------------------------
function UI_GameDebug.brightnessButton(self, item, idx)
    local map_mgr = self.m_world.m_mapManager

    local add_scale = nil
    if (idx == 1) then
        add_scale = 10
        if (100 <= map_mgr.m_colorScale) then
            add_scale = (-map_mgr.m_colorScale)
        end
    elseif (idx == 2) then
        add_scale = -10
        if (map_mgr.m_colorScale <= 0) then
            add_scale = 100
        end
    end
    
    map_mgr.m_colorScale = math_clamp(map_mgr.m_colorScale + add_scale, 0, 100)
    
    local rgb = 255 * (map_mgr.m_colorScale / 100)
    map_mgr:tintTo(rgb, rgb, rgb, 0.5)

    item['label']:setString('배경 밝기 ' .. map_mgr.m_colorScale .. ' %')

    if (map_mgr.m_colorScale <= 0) then
        self.m_world.m_mapManager.m_node:setVisible(false)
    else
        self.m_world.m_mapManager.m_node:setVisible(true)
    end
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

    local scale = self.m_world.m_gameTimeScale:getBase() + add_scale
    self.m_world.m_gameTimeScale:setBase(scale)

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
	local direct_str = l_direction[direct_type] .. direct_stregth

	self.m_world.m_mapManager.m_node:stopAllActions()
	self.m_world.m_mapManager:setDirecting(direct_str)
    item['label']:setString('배경효과 : ' .. direct_str)
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

    local phys_world = self.m_world.m_physWorld
    local debug = (not phys_world.m_bDebug)
    phys_world:setDebug(debug)
end

-------------------------------------
-- function enemyManaCooldownButton
-------------------------------------
function UI_GameDebug.enemyManaCooldownButton(self, item, idx)
    local set_data = not g_constant:get('DEBUG', 'DISPLAY_ENEMY_MANA_COOLDOWN')
    g_constant:set(set_data, 'DEBUG', 'DISPLAY_ENEMY_MANA_COOLDOWN')

    local world = self.m_world

    do
        local group_key = world:getPCGroup()
        local unit_group = world.m_mUnitGroup[group_key]
        if (unit_group) then
            if (set_data) then
                unit_group:getMana():bindUI(nil)
            else
                unit_group:getMana():bindUI(world.m_inGameUI)
            end
        end
    end

    do
        local group_key = world:getOpponentPCGroup()
        local unit_group = world.m_mUnitGroup[group_key]
        if (unit_group) then
            if (set_data) then
                unit_group:getMana():bindUI(world.m_inGameUI)
            else
                unit_group:getMana():bindUI(nil)
            end
        end
    end

    if (set_data) then
        item['label']:setString('적 마나 및 쿨타임 표시 ON')
    else
        item['label']:setString('적 마나 및 쿨타임 표시 OFF')
    end
end

-------------------------------------
-- function fpsButton
-------------------------------------
function UI_GameDebug.fpsButton(self, item, idx)
    cc.Director:getInstance():setDisplayStats(not cc.Director:getInstance():isDisplayStats())

    if cc.Director:getInstance():isDisplayStats() then
        item['label']:setString('FPS ON')
    else
        item['label']:setString('FPS OFF')
    end
end

-------------------------------------
-- function realtimeDebugButton
-------------------------------------
function UI_GameDebug.realtimeDebugButton(self, item, idx)
	local set_data = not g_constant:get('DEBUG', 'DISPLAY_DEBUG_INFO')
    g_constant:set(set_data, 'DEBUG', 'DISPLAY_DEBUG_INFO')

	if UIManager.m_debugUI then
		UIManager.m_debugUI.m_debugLayer:setVisible(g_constant:get('DEBUG', 'DISPLAY_DEBUG_INFO'))
	end

	if g_constant:get('DEBUG', 'DISPLAY_DEBUG_INFO') then
        item['label']:setString('Memory ON')
    else
        item['label']:setString('Memory OFF')
    end
end

-------------------------------------
-- function playerInvincible
-------------------------------------
function UI_GameDebug.playerInvincible(self, item, idx)
	-- 무적 상태를 1 증가 시킨후 set
	local invincible_state = g_constant:get('DEBUG', 'INVINCIBLE_STATE') + 1
    g_constant:set(invincible_state, 'DEBUG', 'INVINCIBLE_STATE')

	-- 4보다 크다면 다시 1로 되돌린다.
	if (invincible_state > 4) then
		g_constant:set(1, 'DEBUG', 'INVINCIBLE_STATE')
		invincible_state = 1
	end

	-- 각 state 별 무적 처리
	if (invincible_state == 1) then
		g_constant:set(false, 'DEBUG', 'PLAYER_INVINCIBLE')
		g_constant:set(false, 'DEBUG', 'ENEMY_INVINCIBLE')
	elseif (invincible_state == 2) then
		g_constant:set(true, 'DEBUG', 'PLAYER_INVINCIBLE')
		g_constant:set(false, 'DEBUG', 'ENEMY_INVINCIBLE')
	elseif (invincible_state == 3) then
		g_constant:set(false, 'DEBUG', 'PLAYER_INVINCIBLE')
		g_constant:set(true, 'DEBUG', 'ENEMY_INVINCIBLE')
	else
		g_constant:set(true, 'DEBUG', 'PLAYER_INVINCIBLE')
		g_constant:set(true, 'DEBUG', 'ENEMY_INVINCIBLE')
	end

	-- 문구
	item['label']:setString(self:getInvincibleStr(invincible_state))
end

-------------------------------------
-- function getInvincibleStr
-- @TODO 임시
-------------------------------------
function UI_GameDebug:getInvincibleStr(invincible_state)
	local invincible_state = invincible_state or g_constant:get('DEBUG', 'INVINCIBLE_STATE')
	if (invincible_state == 1) then
		return '무적 OFF'
	elseif (invincible_state == 2) then
		return '플레이어 무적 ON'
	elseif (invincible_state == 3) then
		return 'AI 무적 ON'
	else
		return '전부 무적 ON'
	end
end
	