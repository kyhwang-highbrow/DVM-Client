-------------------------------------
-- class UI
-------------------------------------
UI = class({
    root = 'cc.Menu'
    , vars = 'table'
    , vars_key = 'table'
    , closed = 'boolean'
    , actions = 'table'           -- 각 노드별 액션 정보를 가짐(type, delay, duration ...)
    , action_duration = 'number'  -- 모든 노드들의 액션 수행 시간(delay + duration)
    , enable = 'boolean'          -- 액션중에는 enable false
    , do_action_enter = 'boolean'
    , do_action_exit = 'boolean'

    , m_resName = ''
	, m_uiName = ''				-- m_uiName을 참조하는 부분에서 ITopUserInfo_EventListener를 다중상속하지 않은 경우 에러발생하므로 에러나지 않도록 추가함
    , m_closeCB = 'function'
    , m_lHideUIList = 'list'

	, m_isLabelVerified = 'boolean',	-- ui label 검증 여부


    m_elapsedTime = 'number', -- self.root:scheduleUpdateWithPriorityLua(dt)에서 dt의 누적값
    m_interval = 'number', -- m_updateCallback의 주기
    m_updateCallback = 'function',  -- self.root:scheduleUpdateWithPriorityLua()에 전달될 함수
})

-------------------------------------
-- function init
------------------------------------- 
function UI:init()
    self.closed = false
    self.enable = true
    self.do_action_enter = true
    self.do_action_exit = true
	
	self.m_resName = 'not loaded ui'
	self.m_uiName = 'untitled'
    self.m_lHideUIList = {}
    self.vars_key = {}

	self.m_isLabelVerified = false

    self.m_elapsedTime = 0
    self.m_interval = 0
end

-------------------------------------
-- function load
-- @param url
-- @param is_permanent 캐시를 지우지 않게됨
-- @param keep_z_order 해당 ui의 각 node에 load한 순서대로 z_order를 부여
-- @param use_sprite_frames 해당 ui는 spriteFrame에서 리소스를 가져온다.
-------------------------------------
function UI:load(url, is_permanent, keep_z_order, use_sprite_frames)
    self.m_resName = url
    self.root, self.vars = UILoader.load(self, url, keep_z_order, use_sprite_frames)
	if is_permanent then
		UILoader.setPermanent(url)
	end

    -- 라벨 영역 검사
    if (IS_TEST_MODE()) and (CppFunctions:isWin32()) and (Translate:isNeedTranslate()) then
        self:autoDelayedVerifier(2)
    end

    return self.vars
end

-------------------------------------
-- function load_keepZOrder
-------------------------------------
function UI:load_keepZOrder(url, is_permanent)
    local keep_z_order = true
    local use_sprite_frames = false
    return self:load(url, is_permanent, true, use_sprite_frames)
end

-------------------------------------
-- function load_useSpriteFrames
-------------------------------------
function UI:load_useSpriteFrames(url, is_permanent)
    local keep_z_order = false
    local use_sprite_frames = true


    --local file_name = url:match('([^/]+)$')
    local file_name = getFileName(url)
    local res = string.format('res/ui/a2d/%s/%s.plist', file_name, file_name)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(res)

    return self:load(url, is_permanent, keep_z_order, use_sprite_frames)
end

-------------------------------------
-- function setCloseCB
-------------------------------------
function UI:setCloseCB(func)
    self.m_closeCB = func
end

-------------------------------------
-- function isClosed
-------------------------------------
function UI:isClosed()
    return self.closed
end

-------------------------------------
-- function close
-------------------------------------
function UI:close(value)
    if self.closed then
        cclog('attempted to close twice')
        cclog(debug.traceback())
        return
    end
    self.closed = true
    self:onClose()

    UIManager:close(self)

    if self.m_closeCB then
        self.m_closeCB(value)
    end
end



-------------------------------------
-- function closeWithoutCB
-------------------------------------
function UI:closeWithoutCB()
	self.m_closeCB = nil
	self:close()
end

-------------------------------------
-- function safeClose
-------------------------------------
function UI:safeClose()
    if self:isClosed() then
        return
    end

    self:close()
end

-------------------------------------
-- function closeWithAction
-- @brief doActionReverse를 간편하게 사용할 수 있는 함수
-------------------------------------
function UI:closeWithAction()
	self:doActionReverse(function() self:close() end, 0.5, false)
end

-------------------------------------
-- function onClose
-------------------------------------
function UI:onClose(...)
    g_currScene:removeBackKeyListener(self)
end

-------------------------------------
-- function UI_ACTION CONSTANT
-------------------------------------
UI_ACTION_TAG = 1000
UI_ACTION_FINISH_TAG = 1001
UI_ACTION_TYPE_LEFT = 1
UI_ACTION_TYPE_RIGHT = 2
UI_ACTION_TYPE_TOP = 3
UI_ACTION_TYPE_BOTTOM = 4
UI_ACTION_TYPE_SCALE = 5
UI_ACTION_TYPE_OPACITY = 6
UI_ACTION_TYPE_OPACITY_R = 7

-------------------------------------
-- function addAction
-------------------------------------
function UI:addAction(node, type, delay, duration)
    if self.actions == nil then
        self.actions = {}
    end

    -- 중복된 노드는 삭제
    for i,v in ipairs(self.actions) do
        if v.node == node then
            table.remove(self.actions, i)
            break
        end
    end

    local action_duration = duration + delay
    if self.action_duration == nil or self.action_duration < action_duration then
        self.action_duration = action_duration
    end

    local t_action = {node=node, type=type, duration=duration, delay=delay, pos_x=node:getPositionX(), pos_y=node:getPositionY(), scale_x=node:getScaleX(), scale_y=node:getScaleY(), opacity=node:getOpacity()}
    table.insert(self.actions, t_action)

    return t_action
end

-------------------------------------
-- function stopAllUIActions
-- @brief 동작 중인 UI ACTION 모두 정지
-------------------------------------
function UI:stopAllUIActions()
    if (not self.actions) then
        return
    end

    for _,t_action_data in ipairs(self.actions) do
        local node = t_action_data['node']
        if node then
            -- 동작 중인 UI ACTION 정지
            node:stopActionByTag(UI_ACTION_TAG)
        end
    end
end

-------------------------------------
-- function doActionReset
-------------------------------------
function UI:doActionReset()
    if not self.do_action_enter then
        return
    end

    if self.actions then
        for _,t_action_data in ipairs(self.actions) do
            self:doActionReset_(t_action_data)
        end
    end

    self.enable = false
end

-------------------------------------
-- function doActionReset_
-------------------------------------
function UI:doActionReset_(t_action_data)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local type = t_action_data['type']
    local node = t_action_data['node']

    if type == UI_ACTION_TYPE_LEFT then
        node:setPositionX(t_action_data['pos_x'] - visibleSize['width'])
    elseif type == UI_ACTION_TYPE_RIGHT then
        node:setPositionX(t_action_data['pos_x'] + visibleSize['width'])
    elseif type == UI_ACTION_TYPE_TOP then
        node:setPositionY(t_action_data['pos_y'] + visibleSize['height'])
    elseif type == UI_ACTION_TYPE_BOTTOM then
        node:setPositionY(t_action_data['pos_y'] - visibleSize['height'])
    elseif type == UI_ACTION_TYPE_SCALE then
        node:setScale(0)
    elseif type == UI_ACTION_TYPE_OPACITY then
        node:setOpacity(0)
    elseif type == UI_ACTION_TYPE_OPACITY_R then
        node:setOpacity(255)
    end
end

-------------------------------------
-- function doActionResetCancel
-------------------------------------
function UI:doActionResetCancel()
    if not self.do_action_enter then
        return
    end

    if self.actions then
        local visibleSize = cc.Director:getInstance():getVisibleSize()

        for i,v in ipairs(self.actions) do
            if v.type  == UI_ACTION_TYPE_LEFT then
                v.node:setPositionX(v.pos_x)
            elseif v.type  == UI_ACTION_TYPE_RIGHT then
                v.node:setPositionX(v.pos_x)
            elseif v.type  == UI_ACTION_TYPE_TOP then
                v.node:setPositionY(v.pos_y)
            elseif v.type  == UI_ACTION_TYPE_BOTTOM then
                v.node:setPositionY(v.pos_y)
            elseif v.type == UI_ACTION_TYPE_SCALE then
                v.node:setScale(1)
            elseif v.type == UI_ACTION_TYPE_OPACITY then
                v.node:setOpacity(255)
            elseif v.type == UI_ACTION_TYPE_OPACITY_R then
                v.node:setOpacity(0)
            end
        end
    end

    self.enable = false
end

-------------------------------------
-- function UI_MakeAction
-------------------------------------
function UI_MakeAction(delay, action)
    local ease_action = cc.EaseInOut:create(action, 2)
    local sequence_action = cc.Sequence:create( cc.DelayTime:create(delay), ease_action )
    sequence_action:setTag(UI_ACTION_TAG)
    return sequence_action
end

-------------------------------------
-- function doAction
-------------------------------------
function UI:doAction(complete_func, no_action, rate)
    local no_action = (no_action or false) or not self.do_action_enter
    if no_action then
        self:doActionResetCancel()
    end
    self:doAction_(false, complete_func, rate, no_action)
end

-------------------------------------
-- function doActionReverse
-------------------------------------
function UI:doActionReverse(complete_func, rate, no_action)
    local no_action = (no_action or false) or not self.do_action_exit
    self:doAction_(true, complete_func, rate, no_action)
end

-------------------------------------
-- function doAction_
-------------------------------------
function UI:doAction_(is_reverse, complete_func, rate, no_action)
    local is_reverse = is_reverse or false
    local rate = rate or 1
    local no_action = no_action or false

    local finish_function = function()
        
        if complete_func then
            complete_func()
        end

        if not is_reverse then
            -- 진입시 입력을 막기 위한 임시 처리
            self.root:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    self.enable = true
                end)
            ))
        end
    end

    if self.actions == nil or no_action then
        finish_function()
        return
    end

    if is_reverse then
        
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        for i,v in ipairs(self.actions) do
            v.node:stopActionByTag(UI_ACTION_TAG)
            local reverse_delay = (self.action_duration - (v.delay+v.duration)) * rate

            if v.type  == UI_ACTION_TYPE_LEFT then
                local action = UI_MakeAction(reverse_delay, cc.MoveTo:create(v.duration * rate, cc.p(v.pos_x - visibleSize.width, v.pos_y)))
                v.node:runAction( action )
            elseif v.type  == UI_ACTION_TYPE_RIGHT then
                local action = UI_MakeAction(reverse_delay, cc.MoveTo:create(v.duration * rate, cc.p(v.pos_x + visibleSize.width, v.pos_y)))
                v.node:runAction( action )
            elseif v.type  == UI_ACTION_TYPE_TOP then
                local action = UI_MakeAction(reverse_delay, cc.MoveTo:create(v.duration * rate, cc.p(v.pos_x, v.pos_y + visibleSize.height)))
                v.node:runAction( action )
            elseif v.type  == UI_ACTION_TYPE_BOTTOM then
                local action = UI_MakeAction(reverse_delay, cc.MoveTo:create(v.duration * rate, cc.p(v.pos_x, v.pos_y - visibleSize.height)))
                v.node:runAction( action )

            elseif v.type == UI_ACTION_TYPE_SCALE then
                local action = UI_MakeAction(reverse_delay, cc.ScaleTo:create(v.duration * rate, 0, 0))
                v.node:runAction( action )

            elseif v.type == UI_ACTION_TYPE_OPACITY then
                local action = UI_MakeAction(reverse_delay, cc.FadeTo:create(v.duration * rate, 0))
                v.node:runAction( action )

            elseif v.type == UI_ACTION_TYPE_OPACITY_R then
                local action = UI_MakeAction(reverse_delay, cc.FadeTo:create(v.duration * rate, 255))
                v.node:runAction( action )

            end
        end
    else
        for _,t_action_data in ipairs(self.actions) do
            self:doAction_Indivisual(t_action_data, rate)
        end
    end

    self.root:stopActionByTag(UI_ACTION_FINISH_TAG)
    
    local duration = (self.action_duration or 0) * rate
    local sequence_action = cc.Sequence:create(cc.DelayTime:create(duration + 0.05), cc.CallFunc:create(finish_function))
    sequence_action:setTag(UI_ACTION_FINISH_TAG)
    self.root:runAction( sequence_action )

    self.enable = false
end

-------------------------------------
-- function doAction_Indivisual
-------------------------------------
function UI:doAction_Indivisual(t_action_data, rate)
    local rate = (rate or 1)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local type = t_action_data['type']
    local node = t_action_data['node']
    local delay = t_action_data['delay']
    local duration = t_action_data['duration']

    node:stopActionByTag(UI_ACTION_TAG)

    if isExistValue(type, UI_ACTION_TYPE_LEFT, UI_ACTION_TYPE_RIGHT, UI_ACTION_TYPE_TOP, UI_ACTION_TYPE_BOTTOM) then
        local action = UI_MakeAction(delay, cc.MoveTo:create(duration * rate, cc.p(t_action_data['pos_x'], t_action_data['pos_y'])))
        node:runAction( action )

    elseif type == UI_ACTION_TYPE_SCALE then
        local action = UI_MakeAction(delay, cc.ScaleTo:create(duration * rate, t_action_data['scale_x'], t_action_data['scale_y']))
        node:runAction( action )                

    elseif type == UI_ACTION_TYPE_OPACITY then
        local action = UI_MakeAction(delay, cc.FadeTo:create(duration * rate, t_action_data['opacity']))
        node:runAction( action )

    elseif type == UI_ACTION_TYPE_OPACITY_R then
        local action = UI_MakeAction(delay, cc.FadeTo:create(duration * rate, t_action_data['opacity']))
        node:runAction( action )

    end
end

-------------------------------------
-- function bgLayerColorOff
-------------------------------------
local bgLayerOpacity = 0
function UI:bgLayerColorOff(duration)
    if self.vars['bgLayerColor'] then
        bgLayerOpacity = self.vars['bgLayerColor']:getOpacity()
        --self.vars['bgLayerColor']:setOpacity(0)
        self.vars['bgLayerColor']:runAction( cc.FadeTo:create(duration or 0.5, 0) )
    end
end

-------------------------------------
-- function bgLayerColorOn
-------------------------------------
function UI:bgLayerColorOn(duration)
    if self.vars['bgLayerColor'] then
        if bgLayerOpacity ~= 0 then
            --self.vars['bgLayerColor']:setOpacity(bgLayerOpacity)
            self.vars['bgLayerColor']:runAction( cc.FadeTo:create(duration or 0.5, bgLayerOpacity) )
        end
    end
end

-------------------------------------
-- function sceneFadeInAction
-- @brief Scene 전환 페이드인 효과
-------------------------------------
function UI:sceneFadeInAction(func, finish_func, duration)
    func = (func or function() end)
    finish_func = (finish_func or function() end)
    duration = (duration or 0.25)

    local layerColor = cc.LayerColor:create( cc.c4b(0,0,0,255) )
    layerColor:setDockPoint(cc.p(0.5, 0.5))
    layerColor:setAnchorPoint(cc.p(0.5, 0.5))
    layerColor:setRelativeSizeAndType(cc.size(MAX_RESOLUTION_X, MAX_RESOLUTION_Y), 1, false)
    layerColor:runAction(cc.Sequence:create(cc.CallFunc:create(func), cc.FadeOut:create(duration), cc.CallFunc:create(finish_func), cc.RemoveSelf:create()))
    self.root:addChild(layerColor, 100)
end

-------------------------------------
-- function sceneFadeOutAction
-- @brief Scene 전환 페이드인 효과
-------------------------------------
function UI:sceneFadeOutAction(finish_func)
    finish_func = (finish_func or function() end)
    local layerColor = cc.LayerColor:create( cc.c4b(0,0,0,0) )
    layerColor:setDockPoint(cc.p(0.5, 0.5))
    layerColor:setAnchorPoint(cc.p(0.5, 0.5))
    layerColor:setRelativeSizeAndType(cc.size(MAX_RESOLUTION_X, MAX_RESOLUTION_Y), 1, false)
    layerColor:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.CallFunc:create(finish_func), cc.RemoveSelf:create()))
    self.root:addChild(layerColor, 100)
end

-------------------------------------
-- function sceneFadeOutAndCallFunc
-- @brief Scene 전환 페이드인 효과
-------------------------------------
function UI:sceneFadeOutAndCallFunc(func)
    self:sceneFadeOutAction()
    
    local ui = UI()
    ui:load('empty.ui')
    local bNotBlendBGLayer = true
    UIManager:open(ui, UIManager.POPUP, bNotBlendBGLayer)
    ui.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(func), cc.CallFunc:create(function() ui:close() end)))
end

-------------------------------------
-- function setOpacityChildren
-- @brief 하위 UI가 모두 opacity값을 적용되도록
-------------------------------------
function UI:setOpacityChildren(b)
    doAllChildren(self.root, function(node) node:setCascadeOpacityEnabled(b) end)
end

-------------------------------------
-- function setVisible
-------------------------------------
function UI:setVisible(b)
    self.root:setVisible(b)
end

-------------------------------------
-- function isVisible
-------------------------------------
function UI:isVisible()
    return self.root:isVisible()
end

-------------------------------------
-- function initUI
-- @brief 순수가상함수
-------------------------------------
function UI:initUI()
end

-------------------------------------
-- function initButton
-- @brief 순수가상함수
-------------------------------------
function UI:initButton()
end

-------------------------------------
-- function refresh
-- @brief 순수가상함수
-------------------------------------
function UI:refresh()
end

 -------------------------------------
-- function onDestroyUI
-- @breif
-------------------------------------
function UI:onDestroyUI()
end

-------------------------------------
-- function checkCompileError
-- @breif 클래스 순수가상함수 재정의 여부 검사
-------------------------------------
function UI:checkCompileError(classDef)
	if (isWin32() == false) then
		return
	end
   
	local l_error = {}

	if (UI.initUI == classDef.initUI) then			table.insert(l_error, 'initUI') end
	if (UI.initButton == classDef.initButton) then	table.insert(l_error, 'initButton') end
	if (UI.refresh == classDef.refresh) then		table.insert(l_error, 'refresh') end

	if (#l_error > 0) then
		print('----------------------------------------')
		print('[Class \"' .. getClassName(classDef) .. '\"] ERROR!! 재정의되지 않은 순수가상함수 존재!!')
		for _,v in ipairs(l_error) do
			print('function : ' .. v)
		end
		print('----------------------------------------')
		error('Compile Error !')
	end
 end

-------------------------------------
-- function checkVarsKey
-- @breif UI를 갱신해야할 때 값이 변했는지 체크하기 위한 함수
-------------------------------------
function UI:checkVarsKey(name, key)

    -- vars에 존재하지 않으면 false
    if (not self.vars[name]) then
        return false
    end

    -- key값이 다를 경우에만 return true
    if (self.vars_key[name] ~= key) then
        self.vars_key[name] = key
        return true
    end

    return false
    
end

-------------------------------------
-- function verifyLabelSize
-- @breif Label size 초과 판단
-------------------------------------
function UI:verifyLabelSize()
    cclog('\n\n')
    cclog('#### Start verifing label size ##')
    cclog('## UI : ' .. self.m_uiName)
    cclog('## .ui : ' .. self.m_resName)

    for _, node in pairs(self.vars) do
        if (isInstanceOf(node, UIC_LabelTTF)) then
            local ret = node:verifySize()
			if (ret) then
				cclog(node:getString())
			end
        end
    end

    cclog('#### End verifing\n')
end

-------------------------------------
-- function autoDelayedVerifier
-- @breif 자동으로 n초 후 라벨 영역 검사를 한다
-------------------------------------
function UI:autoDelayedVerifier(_delay)
	if (self.m_isLabelVerified) then
		return
	end

	self.m_isLabelVerified = true

    local node = cc.Node:create()
    local delay = _delay or 1
    self.root:addChild(node)

    local timer = 0
    local function update_func(dt)
        timer = timer + dt
        if (timer > delay) then
            self:verifyLabelSize()
            node:unscheduleUpdate()
        end
    end
    node:scheduleUpdateWithPriorityLua(function(dt) update_func(dt) end, 0)
end

-------------------------------------
-- function setSwallowTouch
-- @breif 자동으로 n초 후 라벨 영역 검사를 한다
-------------------------------------
function UI:setSwallowTouch()
    self.root:setSwallowTouch(false)
end

-------------------------------------
-- function scheduleUpdate
---@param update_cb function
---@param interval number | nil
-------------------------------------
function UI:scheduleUpdate(update_cb, interval, immediate)
    if isFunction(update_cb) then
        if isNumber(interval) then
            self.m_interval = interval
        end
        
        self.m_updateCallback = update_cb
        self.root:scheduleUpdateWithPriorityLua(function(dt) self:update_callback(dt) end, 0)

        if (immediate == true) then
            self:update(interval)
        end
    end
end

-------------------------------------
-- function update_callback
---@param dt number
-------------------------------------
function UI:update_callback(dt)
    self.m_elapsedTime = self.m_elapsedTime + dt

    if (self.m_elapsedTime < self.m_interval) then
        return
    else        
        self.m_elapsedTime = 0
    end    

    if (isFunction(self.m_updateCallback) == true) then
        self.m_updateCallback(dt)
    end
end

-------------------------------------
-- function unschedule
-------------------------------------
function UI:unschedule()
    self.root:unscheduleUpdate()
    self.m_interval = 0
    self.m_elapsedTime = 0
    self.m_updateCallback = nil
end

-------------------------------------
-- virtual function onFocusing
-- @brief UI가 focus되었을 때 (화면상 최상단에 표시되었을 때)
-------------------------------------
function UI:onFocusing(is_first)
end

-------------------------------------
-- virtual function onFocusingOut
-- @brief UI가 focus out되었을 때 (화면상 최상단에 표시되었다가 가려질 때)
-------------------------------------
function UI:onFocusingOut()
end

-------------------------------------
-- function isFocusing
-- @brief 해당 UI가 포커싱 중이라면 true 반환
-------------------------------------
function UI:isFocusing()
    return (self == UIManager:getFocusUI())
end
