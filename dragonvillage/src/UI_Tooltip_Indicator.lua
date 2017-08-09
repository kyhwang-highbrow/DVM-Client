local PARENT = UI

local FONT_SIZE = 20
local MIN_WIDTH = 200
local MAX_WIDTH = 600
local MIN_HEIGHT = 70
local MAX_HEIGHT = 200

local LABEL_GAP = 65

-------------------------------------
-- class UI_Tooltip_Indicator
-------------------------------------
UI_Tooltip_Indicator = class(PARENT, {
        m_bubbleImage = 'cc.Scale9Sprite',
        m_richLabel1 = 'UIC_RichLabel',
		m_richLabel2 = 'UIC_RichLabel',
		m_richLabel3 = 'UIC_RichLabel',

		m_lSkillDataList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Tooltip_Indicator:init()
    -- 오른쪽 아래를 기준으로 하여 x, y를 산정한다
	self.root = cc.Node:create()
    self.root:setDockPoint(cc.p(0, 0))
    self.root:setAnchorPoint(cc.p(0, 0))
	
    self.m_bubbleImage = cc.Scale9Sprite:create('res/ui/frame_03.png')
    self.m_bubbleImage:setDockPoint(cc.p(0, 0))
    self.m_bubbleImage:setAnchorPoint(cc.p(0, 0))
    self.m_bubbleImage:setContentSize(0, 0)
    self.root:addChild(self.m_bubbleImage)

    for i = 1, 2 do
        local rich_label = self:makeRichLabel(' ')
        self.m_bubbleImage:addChild(rich_label.m_root)
        self['m_richLabel' .. i] = rich_label
    end
	
    UIManager:open(self, UIManager.TOOLTIP)
end

-------------------------------------
-- function init_data
-------------------------------------
function UI_Tooltip_Indicator:init_data(hero)
	self.m_lSkillDataList = {}

	self.m_lSkillDataList['active'] = hero:getSkillIndivisualInfo('active')
end

-------------------------------------
-- function displayData
-- @brief public으로 사용
-------------------------------------
function UI_Tooltip_Indicator:displayData()
	local idx = 1
	for i, v in pairs(self.m_lSkillDataList) do
		local t_skill = v.m_tSkill
		local is_activated = (v.m_skillLevel > 0)
		local str = self:getSkillDescStr(t_skill, is_activated)
        self:setSkillText(idx, str)
		idx = idx + 1
	end
end

-------------------------------------
-- function setSkillText
-------------------------------------
function UI_Tooltip_Indicator:setSkillText(idx, text)
    local rich_label = self['m_richLabel' .. idx]

    rich_label:setString(text)
    
	-- 위치는 왼쪽 위에서 10, 10 띈 후 일정 간격 씩 내려옴
	rich_label.m_root:setPosition(10, - 10 - LABEL_GAP * (idx - 1) )
	rich_label.m_root:setAnchorPoint(cc.p(0, 1))
    	
    -- 배경 이미지의 ContentSize를 갱신한다. 갭 * 갯수 + 여유분
    self.m_bubbleImage:setContentSize(600, LABEL_GAP * idx + 20)
end

-------------------------------------
-- function doActionReset
-------------------------------------
function UI_Tooltip_Indicator:doActionReset()
    PARENT.doActionReset(self)

    self.m_bubbleImage:setScale(0)
end

-------------------------------------
-- function doAction
-------------------------------------
function UI_Tooltip_Indicator:doAction(complete_func, no_action)
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
-- function makeRichLabel
-------------------------------------
function UI_Tooltip_Indicator:makeRichLabel(text)
	local rich_label = UIC_RichLabel()
    rich_label:setString(text)
    rich_label:setFontSize(FONT_SIZE)
    rich_label:setDimension(MAX_WIDTH - FONT_SIZE, MAX_HEIGHT)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
	rich_label:setDockPoint(cc.p(0, 1))
    rich_label:setAnchorPoint(CENTER_POINT)
	rich_label:setPosition(0, 0)

    return rich_label
end

-------------------------------------
-- function autoPositioning
-------------------------------------
function UI_Tooltip_Indicator:autoPositioning(node)
    local x, y = node:getPosition()
    local parent = node:getParent()
    local bounding_box = node:getBoundingBox()

    local world_pos = node:convertToWorldSpaceAR(cc.p(x, y))
    local local_pos = self.root:convertToNodeSpaceAR(world_pos)

    local pos_x = local_pos['x']
    local pos_y = local_pos['y']
    local anchor_x = 0.5
    local anchor_y = 0.5

    -- X축 위치 지정
    local width = self.m_richLabel:getStringWidth()
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

    -- Y축 위치 지정
    if (pos_y < 0) then
        pos_y = pos_y + (bounding_box['height'] / 2)
        anchor_y = 0
    else
        pos_y = pos_y - (bounding_box['height'] / 2)
        anchor_y = 1
    end

    self.m_bubbleImage:setAnchorPoint(cc.p(anchor_x, anchor_y))
    self.m_bubbleImage:setPosition(pos_x, pos_y)

    --self.m_bubbleImage:setPosition(node_pos['x'], node_pos['y'])
end

-------------------------------------
-- function autoRelease
-------------------------------------
function UI_Tooltip_Indicator:autoRelease(duration)
    local duration = duration or 3
    local action = cc.Sequence:create(cc.DelayTime:create(duration), cc.FadeOut:create(1), cc.CallFunc:create(function() self:close() end))
    self.root:runAction(action)
end

-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_Tooltip_Indicator:getSkillDescStr(t_skill, is_activated)
	local name_color = is_activated and '{@SKILL_NAME}' or '{@GRAY}'
	local text_color = is_activated and '{@WHITE}' or '{@GRAY}'

	-- 1. 스킬 이름
    local skill_type_str = t_skill['t_name']
    	
	-- 2. 스킬 설명
    local desc = DragonSkillCore.getSkillDescPure(t_skill)
	desc = string.gsub(desc, '@SKILL_DESC', '@WHITE')

	-- 3. rich_text
    local str = name_color .. skill_type_str .. ' : ' .. text_color .. desc

    return str
end

-------------------------------------
-- function setVisible
-------------------------------------
function UI_Tooltip_Indicator:setVisible(b)
    self.root:setVisible(b)
end