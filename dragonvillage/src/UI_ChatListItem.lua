local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ChatListItem
-------------------------------------
UI_ChatListItem = class(PARENT, {
        m_tItemData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatListItem:init(chat_content)
    --[[
    local vars = self:load('empty.ui')

    self.root:setNormalSize(100, 100)

    --self.root:setDockPoint(cc.p(0.5, 0))
    --self.root:setAnchorPoint(cc.p(0.5, 0))

    self:initUI()
    self:initButton()
    self:refresh()

    local rich_label = UIC_RichLabel()
    local text = chat_content['nickname'] .. '(' .. chat_content['uid'] .. ') : '  .. chat_content['message']


    -- label의 속성들
    rich_label:setString(text)
    rich_label:setFontSize(20)
    rich_label:setDimension(1200, 50)
    --rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    rich_label:enableOutline(cc.c4b(0, 0, 0, 127), 3)
    rich_label:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)

    -- Node의 기본 속성들 (UIC_Node 참고)
    rich_label:setDockPoint(cc.p(0.5, 0.5))
    rich_label:setAnchorPoint(cc.p(0.5, 0.5))
    --rich_label:setScale(1)
    --rich_label:setRotation(45)

    self.root:addChild(rich_label.m_node)
    --]]
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChatListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChatListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChatListItem:refresh()
end

-------------------------------------
-- function getItemHeight
-------------------------------------
function UI_ChatListItem:getItemHeight()
    return 30
end