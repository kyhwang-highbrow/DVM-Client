local PARENT = UI

local FONT_SIZE = 20
local MIN_WIDTH = 60
local MAX_WIDTH = 600
local MIN_HEIGHT = 70
local MAX_HEIGHT = 200

-------------------------------------
-- class UI_Tooltip_Skill
-------------------------------------
UI_Tooltip_Skill = class(PARENT, {
        m_bubbleImage = 'cc.Scale9Sprite',
        m_richLabel = 'RichLabel',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Tooltip_Skill:init(x, y, text, skip_touch_layer)
    self.root = cc.Node:create()
    self.root:setDockPoint(cc.p(0.5, 0.5))
    self.root:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_bubbleImage = cc.Scale9Sprite:create('res/ui/frame_03.png')
    self.m_bubbleImage:setDockPoint(cc.p(0.5, 0.5))
    self.m_bubbleImage:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_bubbleImage:setContentSize(600, 100)
    self.m_bubbleImage:setPosition(x, y)
    self.root:addChild(self.m_bubbleImage)

    local rich_label = self:makeRichLabel(text)
    self.m_richLabel = rich_label
    self.m_bubbleImage:addChild(rich_label.m_root)

    self.vars = {}

    UIManager:open(self, UIManager.TOOLTIP)

    if (not skip_touch_layer) then
        self:makeTouchLayer(self.root)
    end

    self:doActionReset()
    self:doAction()
end

-------------------------------------
-- function doActionReset
-------------------------------------
function UI_Tooltip_Skill:doActionReset()
    PARENT.doActionReset(self)

    self.m_bubbleImage:setScale(0)
end

-------------------------------------
-- function doAction
-------------------------------------
function UI_Tooltip_Skill:doAction(complete_func, no_action)
    PARENT.doAction(self, complete_func, no_action)


    local scale_action = cc.ScaleTo:create(0.2, 1)
    local secuence = cc.Sequence:create(cc.EaseBackInOut:create(scale_action))
        --cc.DelayTime:create(3),
        --cc.EaseBackInOut:create(cc.ScaleTo:create(0.2, 0)),
        --cc.CallFunc:create(function() self:close() end))

    self.m_bubbleImage:stopAllActions()
    self.m_bubbleImage:runAction(secuence)
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function UI_Tooltip_Skill:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self.onTouch(self, touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self.onTouch(self, touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self.onTouch(self, touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self.onTouch(self, touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouch
-------------------------------------
function UI_Tooltip_Skill.onTouch(self, touch, event)
    self:close()
    return true
end

-------------------------------------
-- function makeRichLabel
-------------------------------------
function UI_Tooltip_Skill:makeRichLabel(text)
    local font_size = FONT_SIZE
    local dimensions_width = MAX_WIDTH - FONT_SIZE
    local dimensions_height = MAX_HEIGHT
    local align_h = TEXT_H_ALIGN_LEFT
    local align_v = TEXT_V_ALIGN_CENTER
    local dock_point = cc.p(0.5, 0.5)
    local is_limit_message = false

    -- RichLabel상에서의 width, height를 얻어온다.
    local rich_label = RichLabel(text, font_size, dimensions_width, dimensions_height, align_h, align_v, dock_point, is_limit_message)
    local width = rich_label:getStringWidth()
    local height = rich_label:getStringHeight()

    -- 적절한 ToolTip의 크기를 얻어온다.
    width = math_clamp(width, MIN_WIDTH, MAX_WIDTH)
    height = math_clamp(height + FONT_SIZE, MIN_HEIGHT, MAX_HEIGHT)

    -- 배경 이미지의 ContentSize를 갱신한다.
    self.m_bubbleImage:setContentSize(width + FONT_SIZE, height)

    -- 조절된 사이즈로 RichLabel을 생성한다.
    rich_label = RichLabel(text, font_size, width, height, align_h, align_v, dock_point, is_limit_message)

   return rich_label
end

-------------------------------------
-- function autoPositioning
-------------------------------------
function UI_Tooltip_Skill:autoPositioning(node)
    -- UI클래스의 root상 위치를 얻어옴
    local local_pos = convertToAnoterParentSpace(node, self.root)
    local pos_x = local_pos['x']
    local pos_y = local_pos['y']

    do -- X축 위치 지정
        local width = self.m_richLabel:getStringWidth() + 100
        local scr_size = cc.Director:getInstance():getWinSize()
        if (pos_x < 0) then
            local min_x = -(scr_size['width'] / 2)
            local left_pos = pos_x - (width/2)
            if (left_pos < min_x) then
                pos_x = min_x + (width/2)
            end
        else
            local max_x = (scr_size['width'] / 2)
            local right_pos = pos_x + (width/2)
            if (max_x < right_pos) then
                pos_x = max_x - (width/2)
            end
        end
    end

    do -- Y축 위치 지정
        -- 화면상에 보이는 Y스케일을 얻어옴
        local transform = node.m_node:getNodeToWorldTransform()
        local scale_y = transform[5 + 1]

        -- tooltip의 위치를 위쪽으로 표시할지 아래쪽으로 표시할지 결정
        local bounding_box = node:getBoundingBox()
        local anchor_y = 0.5
        if (pos_y < 0) then
            pos_y = pos_y + (bounding_box['height'] * scale_y / 2) + 10
            anchor_y = 0
        else
            pos_y = pos_y - (bounding_box['height'] * scale_y / 2) - 10
            anchor_y = 1
        end

        -- 위, 아래의 위치에 따라 anchorPoint 설정
        self.m_bubbleImage:setAnchorPoint(cc.p(0.5, anchor_y))
    end

    -- 위치 설정
    self.m_bubbleImage:setPosition(pos_x, pos_y)
end

-------------------------------------
-- function autoRelease
-------------------------------------
function UI_Tooltip_Skill:autoRelease(duration)
    local duration = duration or 3
    local action = cc.Sequence:create(cc.DelayTime:create(duration), cc.FadeOut:create(1), cc.CallFunc:create(function() self:close() end))
    self.root:runAction(action)
end

-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_Tooltip_Skill:getSkillDescStr(char_type, skill_id, skill_type)
    local t_skill
        
    if (char_type == 'tamer') then
        t_skill = TableTamerSkill():getTamerSkill(skill_id)

    else
        local table_name = char_type .. '_skill'    
        local table_skill = TABLE:get(table_name)
        t_skill = table_skill[skill_id]

    end
    
    local skill_type = skill_type or t_skill['chance_type']

    local skill_type_str = ''
    if (skill_type == 'basic') then
        skill_type_str = Str('(기본공격)')

    elseif (skill_type == 'basic_turn') or (skill_type == 'basic_rate') then
        skill_type_str = Str('(일반)')

    elseif (skill_type == 'passive') then
        skill_type_str = Str('(패시브)')

    elseif (skill_type == 'active') then
        skill_type_str = Str('(액티브)')

    elseif (skill_type == 'manual') then
        skill_type_str = Str('(메뉴얼)')

    else
		-- @TODO 테이머 스킬은 skill_type 이 없는데.. 
        skill_type_str = Str('(테이머 스킬)')
    end

    local desc = IDragonSkillManager:getSkillDescPure(t_skill)

    local str = '{@SKILL_NAME} ' .. t_skill['t_name'] .. skill_type_str .. '\n {@SKILL_DESC}' .. desc
    return str
end