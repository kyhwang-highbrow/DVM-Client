-------------------------------------
-- class UI
-------------------------------------
UI = class({
    root = 'cc.Menu'
    , vars = 'table'
    , parent = 'UI'
    , closed = 'boolean'
    , actions = 'table'           -- 각 노드별 액션 정보를 가짐(type, delay, duration ...)
    , action_duration = 'number'  -- 모든 노드들의 액션 수행 시간(delay + duration)
    , enable = 'boolean'          -- 액션중에는 enable false
    , do_action_enter = 'boolean'
    , do_action_exit = 'boolean'

    , m_resName = ''
    , m_closeCB = 'function'
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
end

-------------------------------------
-- function load
-------------------------------------
function UI:load(url, isPermanent)
    self.m_resName = url
    self.root, self.vars = UILoader.load(self, url)
	if isPermanent then
		UILoader.setPermanent(url)
	end
    return self.vars
end

-------------------------------------
-- function setParent
-------------------------------------
function UI:setParent(parent)
    if not isInstanceOf(parent, UI) then
        error('ui parent is not instance of UI')
    end
    if parent.root == nil then
        error('parent not loaded yet')
    end

    self.parent = parent
    self.parent.root:retain()
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
end

-------------------------------------
-- function doActionReset
-------------------------------------
function UI:doActionReset()
    if not self.do_action_enter then
        return
    end

    if self.actions then
        local visibleSize = cc.Director:getInstance():getVisibleSize()

        for i,v in ipairs(self.actions) do
            if v.type  == UI_ACTION_TYPE_LEFT then
                v.node:setPositionX(v.pos_x - visibleSize.width)
            elseif v.type  == UI_ACTION_TYPE_RIGHT then
                v.node:setPositionX(v.pos_x + visibleSize.width)
            elseif v.type  == UI_ACTION_TYPE_TOP then
                v.node:setPositionY(v.pos_y + visibleSize.height)
            elseif v.type  == UI_ACTION_TYPE_BOTTOM then
                v.node:setPositionY(v.pos_y - visibleSize.height)
            elseif v.type == UI_ACTION_TYPE_SCALE then
                v.node:setScale(0)
            elseif v.type == UI_ACTION_TYPE_OPACITY then
                v.node:setOpacity(0)
            elseif v.type == UI_ACTION_TYPE_OPACITY_R then
                v.node:setOpacity(255)
            end
        end
    end

    self.enable = false
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
function UI:doAction(complete_func, no_action)
    local no_action = (no_action or false) or not self.do_action_enter
    if no_action then
        self:doActionResetCancel()
    end
    self:doAction_(false, complete_func, nil, no_action)
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
        for i,v in ipairs(self.actions) do
            v.node:stopActionByTag(UI_ACTION_TAG)
            if v.type  == UI_ACTION_TYPE_LEFT or v.type  == UI_ACTION_TYPE_RIGHT or v.type  == UI_ACTION_TYPE_TOP or v.type  == UI_ACTION_TYPE_BOTTOM then
                local action = UI_MakeAction(v.delay, cc.MoveTo:create(v.duration * rate, cc.p(v.pos_x, v.pos_y)))
                v.node:runAction( action )

            elseif v.type == UI_ACTION_TYPE_SCALE then
                local action = UI_MakeAction(v.delay, cc.ScaleTo:create(v.duration * rate, v.scale_x, v.scale_y))
                v.node:runAction( action )                

            elseif v.type == UI_ACTION_TYPE_OPACITY then
                local action = UI_MakeAction(v.delay, cc.FadeTo:create(v.duration * rate, v.opacity))
                v.node:runAction( action )

            elseif v.type == UI_ACTION_TYPE_OPACITY_R then
                local action = UI_MakeAction(v.delay, cc.FadeTo:create(v.duration * rate, v.opacity))
                v.node:runAction( action )

            end
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

