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

		m_skillInfo = 'DragonSkillIndivisualInfo',
        m_oldSkillInfo = 'DragonSkillIndivisualInfo',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Tooltip_Indicator:init()
    -- 오른쪽 아래를 기준으로 하여 x, y를 산정한다
	self.root = cc.Node:create()
    self.root:setDockPoint(cc.p(0, 0))
    self.root:setAnchorPoint(cc.p(0, 0))
	
    self.m_bubbleImage = cc.Scale9Sprite:create('res/ui/temp/frame_03.png')
    self.m_bubbleImage:setDockPoint(cc.p(0, 0))
    self.m_bubbleImage:setAnchorPoint(cc.p(0, 0))
    self.m_bubbleImage:setContentSize(600, 150)
    self.root:addChild(self.m_bubbleImage)

    for i = 1, 2 do
        local rich_label = self:makeRichLabel('')
        rich_label:setPosition(10, - 10 - LABEL_GAP * (i - 1))
        self.m_bubbleImage:addChild(rich_label.m_root)
        self['m_richLabel' .. i] = rich_label
    end
	
    UIManager:open(self, UIManager.TOOLTIP)
end

-------------------------------------
-- function init_data
-------------------------------------
function UI_Tooltip_Indicator:init_data(dragon)
    -- active skill info를 꺼내옴
	self.m_skillInfo = dragon:getSkillIndivisualInfo('active')

    -- 현재 skill_info 스킬아이디와 드래곤의 액티브스킬 아이디를 비교하여 다르다면
    -- 스킬 강화 된것으로 보고 강화되기전 스킬을 꺼내온다.
    local curr_skill_id = self.m_skillInfo:getSkillID()
    local active_skill_id = dragon.m_charTable['skill_active']
    if (curr_skill_id ~= active_skill_id) then
        self.m_oldSkillInfo = dragon:getSkillInfoByID(active_skill_id)
    end
end

-------------------------------------
-- function displayData
-- @brief public으로 사용
-------------------------------------
function UI_Tooltip_Indicator:displayData()
    local skill_info = self.m_skillInfo
    local old_skill_info = self.m_oldSkillInfo
    
    local idx = 1
    local skill_desc = nil

    -- 강화로 덮어씌워진 스킬이 있다면 그 스킬의 텍스트를 1번에 놓는다.
    if (old_skill_info) then
        skill_desc = self:getPrettyDesc(old_skill_info) 
        self:setSkillText(idx, skill_desc)
        idx = idx + 1
    end

    -- 본래 스킬의 텍스트를 다음 idx에 놓는다.
    skill_desc = self:getPrettyDesc(skill_info)
    self:setSkillText(idx, skill_desc)
end

-------------------------------------
-- function setSkillText
-------------------------------------
function UI_Tooltip_Indicator:setSkillText(idx, text)
    local rich_label = self['m_richLabel' .. idx]
    rich_label:setString(text)
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

    local scale_action = cc.ScaleTo:create(1.0, 1)
    local secuence = cc.EaseElasticOut:create(scale_action, 1.5)

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
	rich_label:setAnchorPoint(cc.p(0, 1))

    return rich_label
end

-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_Tooltip_Indicator:getPrettyDesc(skill_info)
	-- 1. 스킬 이름
    local skill_type_str = skill_info:getSkillName()
    	
	-- 2. 스킬 설명
    local desc = skill_info:getSkillDesc()

	-- 3. rich_text
    local str = string.format('{@SKILL_NAME}%s {@default}: %s', skill_type_str, desc)

    return str
end

-------------------------------------
-- function show
-------------------------------------
function UI_Tooltip_Indicator:show()
    self:doActionReset()
    self:doAction()
    self.root:setVisible(true)
end

-------------------------------------
-- function hide
-------------------------------------
function UI_Tooltip_Indicator:hide()
    self.m_skillInfo = nil
    self.m_oldSkillInfo = nil
    self.m_richLabel1:setString('')
    self.m_richLabel2:setString('')

    self.root:setVisible(false)
end

-------------------------------------
-- function setRelativePosY
-------------------------------------
function UI_Tooltip_Indicator:setRelativePosY(hero_pos_y)
    -- 영웅 위치에 따라 y좌표 고정
    local y = 0
	if (hero_pos_y >= 0)  then 
		y = 20
	else
		y = 500
	end

    self.root:setPositionY(y)
end

-------------------------------------
-- function updateRelativePosX
-------------------------------------
function UI_Tooltip_Indicator:updateRelativePosX(touch_pos_x)
    -- 터치 좌표에 따라 X이동
	local x = 0 
	if (touch_pos_x > CRITERIA_RESOLUTION_X/2) then
		x = 20
	else
		x = 650
	end

    -- 변화가 있는 경우에만 이동
    if (self.root:getPositionX() ~= x) then
        self.root:stopAllActions()
	    self.root:setPositionX(x)
        cca.uiReactionSlow(self.root, 1, 1, 0.9)
    end
end