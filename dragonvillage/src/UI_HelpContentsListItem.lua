local PARENT = UI

-------------------------------------
-- class UI_Help
-------------------------------------
UI_HelpContentsListItem = class(PARENT,{
        m_contentName = 'string',    
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HelpContentsListItem:init(content_name)
    local vars = self:load('help_contents_open_item.ui')
    self.m_contentName = content_name

    -- backkey ����
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HelpContentsListItem')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HelpContentsListItem:initUI()
    local vars = self.vars
    local content_name = self.m_contentName -- adventure.ui
    content_name = string.gsub(content_name, '.ui', '') -- adventure
    -- ��� ���� ���� �߸� ©���� ����ó����
    -- �Ŀ� �ٽ� ó���ؾ���
    if (content_name == 'ancient_n') then
        content_name = 'ancient_ruin'
    end

    local table_contents =  TABLE:get('table_content_help')
    local t_contents = table_contents[content_name]

    -- ������ �̸�
    local content_name = t_contents['t_name']
    vars['contentsLabel']:setString(Str(content_name))

    -- ������ �̹���
    local res = t_contents['res']
    local contents_icon = cc.Sprite:create(res)
    if (contents_icon) then
        vars['contentsNode']:addChild(contents_icon)
        contents_icon:setPositionX(75)
        contents_icon:setPositionY(75)
    end

    -- ������ ����
    local content_desc = t_contents['help_desc']
    vars['infoLabel']:setString(Str(content_desc))
end