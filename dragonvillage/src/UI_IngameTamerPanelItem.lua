local PARENT = class(UI, IEventListener:getCloneTable())

local ACTIVE_ACTION__TAG = 100

-------------------------------------
-- class UI_IngameTamerPanelItem
-------------------------------------
UI_IngameTamerPanelItem = class(PARENT, {
        m_world = 'GameWorld',
        m_tamer = 'Tamer',
        m_bVisible = 'boolean',
        m_menuPosX = 'number',
        m_menuPosY = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameTamerPanelItem:init(world, tamer)
    self.m_world = world
    self.m_tamer = tamer
    
    local vars = self:load('ingame_tamer_panel_new.ui', false, true, true)
    self.m_bVisible = true
    self.m_menuPosX = vars['panelMenu']:getPositionX()
    self.m_menuPosY = vars['panelMenu']:getPositionY()

    tamer:addListener('touch_began', self)
    tamer:addListener('touch_ended', self)
    
    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameTamerPanelItem:initUI()
    local tamer = self.m_tamer
    local vars = self.vars
        
    do -- 테이머 아이콘
        -- 코스튬 적용
        local icon
        if (tamer.m_costumeData) then
            local costume_id = tamer.m_costumeData:getCid()
            icon = IconHelper:getTamerProfileIconWithCostumeID(costume_id)
        else
            icon = IconHelper:makeTamerReadyIcon(tamer.m_tamerID)
        end

        if icon then
            icon:setDockPoint(CENTER_POINT)
            icon:setAnchorPoint(CENTER_POINT)
            vars['tamerNode']:addChild(icon)
        end
    end
    --[[
	do -- 테이머 스킬 아이콘
        local skill_indivisual_info = tamer:getSkillIndivisualInfo('active')
        local t_skill = skill_indivisual_info:getSkillTable()

        if (t_skill) then
            local res = t_skill['res_icon']
            local icon = cc.Sprite:create(res)
		    if (icon) then
			    icon:setDockPoint(CENTER_POINT)
			    icon:setAnchorPoint(CENTER_POINT)
			    vars['tamerSkillNode1']:addChild(icon)
		    end
        end
	end
    ]]--
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_IngameTamerPanelItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_IngameTamerPanelItem:refresh()
end

-------------------------------------
-- function toggleVisibility
-------------------------------------
function UI_IngameTamerPanelItem:toggleVisibility()
    local vars = self.vars
    self.m_bVisible = (not self.m_bVisible)

    local duration = 0.3

    if (self.m_bVisible) then
        vars['panelMenu']:setVisible(true)
		local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(self.m_menuPosX, self.m_menuPosY)), 2)
        vars['panelMenu']:stopAllActions()
        vars['panelMenu']:runAction(move_action)
    else
		local move_action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(self.m_menuPosX, -150)), 2)
		local seq_action = cc.Sequence:create(move_action, cc.Hide:create())
        vars['panelMenu']:stopAllActions()
        vars['panelMenu']:runAction(seq_action)
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function UI_IngameTamerPanelItem:onEvent(event_name, t_event, ...)
    if (event_name == 'touch_began') then
        self:onTouchBegan(t_event)

    elseif (event_name == 'touch_ended') then
        self:onTouchEnded(t_event)

    end
end

-------------------------------------
-- function onTouchBegan
-- @brief
-------------------------------------
function UI_IngameTamerPanelItem:onTouchBegan(t_event)
    local vars = self.vars

    local location = t_event['location']
    --local node = vars['tamerSkillNode1']
    local node = vars['tamerSkilllLockSprite']

    local node_pos = node:convertToNodeSpace(location)
    local size = node:getContentSize()
    local half_size = (size['width'] / 2)
    local distance = math_distance(size['width'] / 2, size['height'] / 2, node_pos['x'], node_pos['y'])
    if (distance <= half_size) then
        t_event['touch'] = true
        cca.uiReactionSlow(vars['panelMenu'])
    end
end

-------------------------------------
-- function onTouchEnded
-- @brief
-------------------------------------
function UI_IngameTamerPanelItem:onTouchEnded(t_event)
    local vars = self.vars

    local location = t_event['location']
    --local node = vars['tamerSkillNode1']
    local node = vars['tamerSkilllLockSprite']
    
    local node_pos = node:convertToNodeSpace(location)
    local size = node:getContentSize()
    local half_size = (size['width'] / 2)
    local distance = math_distance(size['width'] / 2, size['height'] / 2, node_pos['x'], node_pos['y'])
    if (distance <= half_size) then
        t_event['touch'] = true
        
        self:click_tamerSkillBtn()
    end
end

-------------------------------------
-- function click_tamerSkillBtn
-------------------------------------
function UI_IngameTamerPanelItem:click_tamerSkillBtn()
	local world = self.m_world
	local tamer = self.m_tamer
	local vars = self.vars

    -- 조작 가능 상태인지 확인
    if (not world:isPossibleControl()) then
        UIManager:toastNotificationRed(Str('지금은 사용 할 수 없습니다.'))
        return
    end

	if (tamer:isPossibleActiveSkill()) then
        vars['tamerSkillVisual']:setVisible(false)
        vars['tamerSkilllLockSprite']:setVisible(true)
		
        world.m_gameActiveSkillMgr:addWork(tamer, nil, nil, 'click')
	else
		UIManager:toastNotificationRed(Str('더 이상 사용 할 수 없습니다.'))
	end
end

-------------------------------------
-- function setTemporaryPause
-------------------------------------
function UI_IngameTamerPanelItem:setTemporaryPause(pause)
    local tamer = self.m_tamer
    local vars = self.vars

    if (pause) then
        vars['tamerSkillVisual']:setVisible(false)
    else
        vars['tamerSkillVisual']:setVisible(tamer.m_bActiveSKillUsable)
    end 
end