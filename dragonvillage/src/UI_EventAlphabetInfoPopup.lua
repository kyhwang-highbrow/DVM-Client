local PARENT = UI

-------------------------------------
-- class UI_EventAlphabetInfoPopup
-- @brief 알파벳 이벤트에서 알파벳 아이템 획득처 안내 팝업
-------------------------------------
UI_EventAlphabetInfoPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventAlphabetInfoPopup:init()
    local vars = self:load('alphabet_event_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventAlphabetInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventAlphabetInfoPopup:initUI()
    local vars = self.vars
    
    local scroll_node = vars['eventScrollNode']
    local scroll_menu = vars['eventScrollMenu']

    -- ScrollView 사이즈 설정 (ScrollNode 사이즈)
    local size = scroll_node:getContentSize()
    local scroll_view = cc.ScrollView:create()
    scroll_view:setNormalSize(size)
    scroll_node:setSwallowTouch(false)
    scroll_node:addChild(scroll_view)

    -- ScrollView 에 달아놓을 컨텐츠 사이즈(ScrollMenu)
    local target_size = scroll_menu:getContentSize()
    scroll_view:setContentSize(target_size)
    scroll_view:setDockPoint(CENTER_POINT)
    scroll_view:setAnchorPoint(CENTER_POINT)
    scroll_view:setPosition(ZERO_POINT)
    scroll_view:setTouchEnabled(true)

    -- ScrollMenu를 부모에서 분리하여 ScrollView에 연결
    -- 분리할 부모가 없을 때 에러 없음
    scroll_menu:removeFromParent()
    scroll_view:addChild(scroll_menu)

    -- 스크롤 초기 위치를 위한 계산
    local container_node = scroll_view:getContainer()
    local size_y = size.height - target_size.height
    
    container_node:setPositionY(size_y)
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventAlphabetInfoPopup:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    local l_content_list = {}
    table.insert(l_content_list, 'gold_dungeon')
    table.insert(l_content_list, 'adventure')
    table.insert(l_content_list, 'nest_tree')
    table.insert(l_content_list, 'nest_evo_stone')
    table.insert(l_content_list, 'ancient_ruin')
    table.insert(l_content_list, 'nest_nightmare')
    table.insert(l_content_list, 'secret_relation')
    table.insert(l_content_list, 'rune_guardian')

    for i,v in pairs(l_content_list) do
        if vars[v .. 'Btn'] then
            vars[v .. 'Btn']:registerScriptTapHandler(function() UINavigator:goTo(v) end)
        end
    end
    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventAlphabetInfoPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_EventAlphabetInfoPopup)
