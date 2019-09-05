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

    -- ��ũ�� ��
    local screen_shot_res = t_contents['screenshot']
    local sprite = cc.Sprite:create(screen_shot_res)
    if (sprite) then
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        vars['screenNode']:addChild(sprite)
        
        -- ���ڼ��� ���� ��ũ�� �޴� ���� ũ�⸦ �ø�
        local label_height = vars['infoLabel']:getStringHeight() * 1.5
        local content_height = 360
        local ori_size = vars['scrollMenu']:getContentSize()
        ori_size['height'] = label_height + content_height
        vars['scrollMenu']:setContentSize(ori_size)
    else
        vars['infoLabel']:setPositionY(154)
        return
    end

    -- ��ũ��
    -- ScrollNode, ScrollMenu �� �� �־�� ���� ����
    local scroll_node = vars['scrollNode']
    local scroll_menu = vars['scrollMenu']

    -- ScrollView ������ ���� (ScrollNode ������)
    local size = scroll_node:getContentSize()
    local scroll_view = cc.ScrollView:create()
    scroll_view:setNormalSize(size)
    scroll_node:setSwallowTouch(false)
    scroll_node:addChild(scroll_view)

    -- ScrollView �� �޾Ƴ��� ������ ������(ScrollMenu)
    local target_size = scroll_menu:getContentSize()
    scroll_view:setDockPoint(cc.p(0.5, 1.0))
    scroll_view:setAnchorPoint(cc.p(0.5, 1.0))
    scroll_view:setContentSize(target_size)
    scroll_view:setPosition(ZERO_POINT)
    scroll_view:setTouchEnabled(true)

    -- ScrollMenu�� �θ𿡼� �и��Ͽ� ScrollView�� ����
    -- �и��� �θ� ���� �� ���� ����
    scroll_menu:removeFromParent()
    scroll_view:addChild(scroll_menu)

    local size_y = size.height - target_size.height
    local container_node = scroll_view:getContainer()
    -- ��Ŀ���� pos_y �ø���ŭ �� �÷���
    size_y = size_y + vars['infoLabel']:getStringHeight() * 1.5 * 0.2
    
    container_node:setPositionY(size_y)
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
end