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
	self.m_uiName = '없음'
    self.m_lHideUIList = {}
    self.vars_key = {}
end

-------------------------------------
-- function load
-------------------------------------
function UI:load(url, isPermanent, keep_z_order, use_sprite_frames)
    self.m_resName = url
    self.root, self.vars = UILoader.load(self, url, keep_z_order, use_sprite_frames)
	if isPermanent then
		UILoader.setPermanent(url)
	end
    return self.vars
end

-------------------------------------
-- function load_keepZOrder
-------------------------------------
function UI:load_keepZOrder(url, isPermanent)
    local keep_z_order = true
    local use_sprite_frames = false
    return self:load(url, isPermanent, true, use_sprite_frames)
end

-------------------------------------
-- function load_useSpriteFrames
-------------------------------------
function UI:load_useSpriteFrames(url, isPermanent)
    local keep_z_order = false
    local use_sprite_frames = true


    --local file_name = url:match('([^/]+)$')
    local file_name = getFileName(url)
    local res = string.format('res/ui/a2d/%s/%s.plist', file_name, file_name)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(res)

    return self:load(url, isPermanent, keep_z_order, use_sprite_frames)
end

-------------------------------------
-- function setCloseCB
-------------------------------------
function UI:setCloseCB(func)
    self.m_closeCB = func
end

-------------------------------------
-- function close
-------------------------------------
function UI:close()
    if self.closed then
        cclog('attempted to close twice')
        cclog(debug.traceback())
        return
    end
    self.closed = true
    self:onClose()

    if self.m_closeCB then
        self.m_closeCB()
    end

    UIManager:close(self)
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
    layerColor:setRelativeSizeAndType(cc.size(1280, 960), 1, false)
    layerColor:runAction(cc.Sequence:create(cc.CallFunc:create(func), cc.FadeOut:create(duration), cc.CallFunc:create(finish_func), cc.RemoveSelf:create()))
    self.root:addChild(layerColor, 100)
end

-------------------------------------
-- function sceneFadeOutAction
-- @brief Scene 전환 페이드인 효과
-------------------------------------
function UI:sceneFadeOutAction()
    local layerColor = cc.LayerColor:create( cc.c4b(0,0,0,0) )
    layerColor:setDockPoint(cc.p(0.5, 0.5))
    layerColor:setAnchorPoint(cc.p(0.5, 0.5))
    layerColor:setRelativeSizeAndType(cc.size(1280, 960), 1, false)
    layerColor:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.RemoveSelf:create()))
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