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
    -- 고대 유적 던전 잘못 짤려서 예외처리함
    -- 후에 다시 처리해야함
    if (content_name == 'ancient_n') then
        content_name = 'ancient_ruin'
    end

    local table_contents =  TABLE:get('table_content_help')
    local t_contents = table_contents[content_name]

    -- 컨텐츠 이름
    local content_name = t_contents['t_name']
    vars['contentsLabel']:setString(Str(content_name))

    -- 컨텐츠 이미지
    local res = t_contents['res']
    local contents_icon = cc.Sprite:create(res)
    if (contents_icon) then
        vars['contentsNode']:addChild(contents_icon)
        contents_icon:setPositionX(75)
        contents_icon:setPositionY(75)
    end

    -- 컨텐츠 설명
    local content_desc = t_contents['t_help_desc']
    vars['infoLabel']:setString(Str(content_desc))

    -- 스크린 샷
    local screen_shot_res = t_contents['screenshot']
    local sprite = cc.Sprite:create(screen_shot_res)
    local entire_content_height = 0
    
    -- 스크린 샷 있을 경우
    if (sprite) then
        sprite:setDockPoint(CENTER_POINT)
        sprite:setAnchorPoint(CENTER_POINT)
        vars['screenNode']:addChild(sprite)
        
        -- 글자수에 따라 스크롤 메뉴 세로 크기를 늘림
        -- 전체 컨테이너 세로 길이는 스크린샷 + 글자 크기
        local label_height = vars['infoLabel']:getStringHeight() * 1.5
        local content_height = 360
        entire_content_height = label_height + content_height
        vars['infoLabel2']:setVisible(false)
        vars['infoLabel']:setVisible(true)
    
    -- 스크린 샷 없을 경우
    else
        -- 글자수에 따라 스크롤 메뉴 세로 크기를 늘림
        vars['infoLabel']:setVisible(false)
        vars['infoLabel2']:setVisible(true)
        vars['infoLabel2']:setString(Str(content_desc))
        local label_height = vars['infoLabel2']:getStringHeight() * 1.5
        entire_content_height = label_height
    end

    -- 컨테이너에 세로크기 적용
    local ori_size = vars['scrollMenu']:getContentSize()
    ori_size['height'] = entire_content_height
    vars['scrollMenu']:setContentSize(ori_size)

    -- 스크롤
    -- ScrollNode, ScrollMenu 둘 다 있어야 동작 가능
    local scroll_node = vars['scrollNode']
    local scroll_menu = vars['scrollMenu']

    -- ScrollView 사이즈 설정 (ScrollNode 사이즈)
    local size = scroll_node:getContentSize()
    local scroll_view = cc.ScrollView:create()
    scroll_view:setNormalSize(size)
    scroll_node:setSwallowTouch(false)
    scroll_node:addChild(scroll_view)

    -- ScrollView 에 달아놓을 컨텐츠 사이즈(ScrollMenu)
    local target_size = scroll_menu:getContentSize()
    scroll_view:setDockPoint(cc.p(0.5, 1.0))
    scroll_view:setAnchorPoint(cc.p(0.5, 1.0))

    scroll_view:setContentSize(target_size)
    scroll_view:setPosition(ZERO_POINT)
    scroll_view:setTouchEnabled(true)

    -- ScrollMenu를 부모에서 분리하여 ScrollView에 연결
    -- 분리할 부모가 없을 때 에러 없음
    scroll_menu:removeFromParent()
    scroll_view:addChild(scroll_menu)

    local size_y = size.height - target_size.height
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)


    local container_node = scroll_view:getContainer()
    local size_y = size.height - target_size.height
    
    -- 초기위치 설정 
    container_node:setPositionY(size_y)
end