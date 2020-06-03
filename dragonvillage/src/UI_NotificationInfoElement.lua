local PARENT = ITableViewCell:getCloneClass()

local info_element_max_width = 500


-------------------------------------
-- class UI_NotificationInfoElement
-------------------------------------
UI_NotificationInfoElement = class(PARENT, {
        root = '',
        vars = '',

        m_width = 'number',
        m_height = 'number',
        m_contentWidth = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_NotificationInfoElement:init()
    self.root = cc.Menu:create()
    --self.root:setNormalSize(150, 150)
    self.root:setDockPoint(CENTER_POINT)
    self.root:setAnchorPoint(CENTER_POINT)
    self.root:setPosition(0, 0)

    self.vars = {}

    local sprite = cc.Scale9Sprite:create('res/ui/frames/temp/base_frame_08.png')
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    sprite:setRelativeSizeAndType(cc.size(0, 0), 3, true)
    sprite:setColor(cc.c3b(0, 0, 0))
    sprite:setOpacity(255 * 0.8)
    self.root:addChild(sprite)

    self:setIcon()

    self.m_contentWidth = 0
end

-------------------------------------
-- function setElementSize
-------------------------------------
function UI_NotificationInfoElement:setElementSize(width, height)
    self.root:setNormalSize(width, height)

    self.m_width = width
    self.m_height = height
end

-------------------------------------
-- function setIcon
-------------------------------------
function UI_NotificationInfoElement:setIcon(res)
    res = res or 'res/ui/icons/buff_dsc_icon.png'
    local icon = cc.Sprite:create(res)
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    icon:setDockPoint(cc.p(0, 1))
    icon:setPosition(22, -15)
    self.root:addChild(icon)
end

-------------------------------------
-- function makeRichLabel
-------------------------------------
function UI_NotificationInfoElement:makeRichLabel(text)
    local font_size = 16
    local dimensions_width = info_element_max_width - 40
    local dimensions_height = 600
    local align_h = cc.TEXT_ALIGNMENT_LEFT
    local align_v = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    local dock_point = cc.p(0, 1)
    local is_limit_message = false

    -- RichLabel상에서의 width, height를 얻어온다.
    local rich_label = UIC_RichLabel()
    rich_label:setString(text)
    rich_label:setFontSize(font_size)
    rich_label:setDimension(dimensions_width, dimensions_height)
    rich_label:setAlignment(align_h, align_v)
    rich_label:setDockPoint(dock_point)
    rich_label:setAnchorPoint(cc.p(0, 0.5))

    return rich_label
end

-------------------------------------
-- function makeContentRichLabel
-------------------------------------
function UI_NotificationInfoElement:makeContentRichLabel(text)
    local font_size = 16
    local dimensions_width = info_element_max_width - 40
    local dimensions_height = 600
    local align_h = cc.TEXT_ALIGNMENT_LEFT
    local align_v = cc.VERTICAL_TEXT_ALIGNMENT_TOP
    local dock_point = cc.p(0, 1)
    local is_limit_message = false

    -- RichLabel상에서의 width, height를 얻어온다.
    local rich_label = UIC_RichLabel()
    rich_label:setString(text)
    rich_label:setFontSize(font_size)
    rich_label:setDimension(dimensions_width, dimensions_height)
    rich_label:setAlignment(align_h, align_v)
    rich_label:setDockPoint(dock_point)
    rich_label:setAnchorPoint(dock_point)

    return rich_label
end


-------------------------------------
-- function setTitleText
-------------------------------------
function UI_NotificationInfoElement:setTitleText(text)
    local rich_label = self:makeRichLabel(text)
    rich_label.m_root:setPosition(40, -15)
    self.root:addChild(rich_label.m_root)

    self.m_contentWidth = math_max(self.m_contentWidth, 40 + rich_label:getStringWidth() + 22)

    self:setElementSize(info_element_max_width, 30)
end

-------------------------------------
-- function setDescText
-------------------------------------
function UI_NotificationInfoElement:setDescText(text)
    local rich_label = self:makeContentRichLabel(text)
    rich_label.m_root:setPosition(40, -15 - 15)
    self.root:addChild(rich_label.m_root)

    self.m_contentWidth = math_max(self.m_contentWidth, 40 + rich_label:getStringWidth() + 22)

    self:setElementSize(info_element_max_width, 30 + (rich_label:getStringHeight() + 5))
end




-------------------------------------
-- function sampleCode
-------------------------------------
function UI_NotificationInfoElement:sampleCode(self)

    local pos_y = 0
    local height = 0
    local margin = 5

    local ui = UI_NotificationInfoElement()
    ui:setTitleText('{@SKILL_NAME}[베스트프렌드 접속 버프] {@WHITE}(뀨뀨뀨, 김 성 구 접속 중)')
    ui:setDescText('{@DEEPSKYBLUE}[베스트프렌드의 응원] {@SKILL_DESC}경험치 +3%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%')
    self.m_scene:addChild(ui.root)
    ui.root:setPositionY(pos_y)

    height = ui.m_height
    pos_y = pos_y - (height/2) - margin

    local ui = UI_NotificationInfoElement()
    ui:setTitleText('{@SKILL_NAME}[친구 드래곤 사용 버프] {@SKILL_DESC}체력 +500')
    ui:setDescText('{@DEEPSKYBLUE}[베스트프렌드의 응원] {@SKILL_DESC}경험치 +3%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%')
    self.m_scene:addChild(ui.root)
    height = ui.m_height
    pos_y = pos_y - (height/2)
    ui.root:setPosition(0, pos_y)
    pos_y = pos_y - (height/2) - margin

    local ui = UI_NotificationInfoElement()
    ui:setTitleText('{@SKILL_NAME}[친구 드래곤 사용 버프] {@SKILL_DESC}체력 +500')
    ui:setDescText('{@DEEPSKYBLUE}[베스트프렌드의 응원] {@SKILL_DESC}경험치 +3%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%')
    self.m_scene:addChild(ui.root)
    height = ui.m_height
    pos_y = pos_y - (height/2)
    ui.root:setPosition(0, pos_y)
    pos_y = pos_y - (height/2) - margin

    
    --ui.root:setPosition(0, pos_y/2 - (ui.m_height/2) - 5)
end