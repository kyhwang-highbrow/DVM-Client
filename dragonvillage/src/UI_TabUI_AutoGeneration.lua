local PARENT = class(UI, ITabUI:getCloneTable(), ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_TabUI_AutoGeneration
-------------------------------------
UI_TabUI_AutoGeneration = class(PARENT,{
        m_uiDepth = 'number',
        m_structTabUI = 'StructTabUI',
        m_useTopInfo = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_TabUI_AutoGeneration:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = self.m_useTopInfo['ui_name']
    self.m_titleStr = self.m_useTopInfo['ui_title']
end

-------------------------------------
-- function init
-------------------------------------
function UI_TabUI_AutoGeneration:init(ui_name, is_root, ui_depth, struct_tab_ui, use_top_info)
    self.m_uiName = 'UI_TabUI_AutoGeneration (' .. ui_name .. ')'
    self.m_useTopInfo = use_top_info

    if (use_top_info) then
        self:useUserTopInfo(use_top_info['useInfo'])
    else
        self:useUserTopInfo(false)
    end

    local vars = self:load(ui_name)
    self.m_structTabUI = struct_tab_ui or StructTabUI()
    if is_root then
        UIManager:open(self, UIManager.SCENE)

        -- backkey 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_TabUI_AutoGeneration')
        self.m_uiDepth = 1
    else
        self.m_uiDepth = ui_depth
    end

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    -- UI load 이후 외부 세팅
    self.m_structTabUI:setAfter(ui_name, self)
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TabUI_AutoGeneration:initUI()
    local vars = self.vars
    self:initTab()
    self:initScroll()
end

-------------------------------------
-- function initScroll
-------------------------------------
function UI_TabUI_AutoGeneration:initScroll()
    local vars = self.vars
    for lua_name,v in pairs(vars) do
        
        -- [UI규정] Scroll 루아 변수명 ex) clanScrollNode, clanSrollMenu (접두어 동일)
        if (pl.stringx.endswith(lua_name, 'ScrollNode')) then        
            local scroll_name = pl.stringx.rpartition(lua_name,'ScrollNode')                        -- ex) clan + ScrollNode 로 접두어 분리
            self:makeScroll(vars[scroll_name .. 'ScrollMenu'], vars[scroll_name .. 'ScrollNode'])   -- ex) clan + SrollMenu 가 있을 거라고 판단(규정상)
        end
    end
end

-------------------------------------
-- function makeScroll
-------------------------------------
function UI_TabUI_AutoGeneration:makeScroll(scroll_menu, scroll_node)
    local vars = self.vars
   
    -- ScrollNode, ScrollMenu 둘 다 있어야 동작 가능
    if (not scroll_node or not scroll_menu) then
        return
    end

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

    -- ScrollMenu와 화면 길이 비교(가로/세로)
    local container_node = scroll_view:getContainer()
    local size_x = size.width - target_size.width
    local size_y = size.height - target_size.height
    
    -- ScrollMenu이 화면보다 (가로/세로)로 긴지 판단
    -- 스크롤 방향, 초기위치 설정 
    if (math_abs(size_x) > math_abs(size_y)) then
        container_node:setPositionY(size_x)
        scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    else
        container_node:setPositionY(size_y)
        scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    end
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TabUI_AutoGeneration:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TabUI_AutoGeneration:refresh()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_TabUI_AutoGeneration:initTab()
    local vars = self.vars

    local default_tab_y = nil
    local default_tab_x = nil
    local default_tab_name = nil

    for lua_name,node in pairs(vars) do
        -- [UI규정] TabBtn/TabMenu/TabLabel 가 모두 있어야 탭 생성 가능 ex) clanTabBtn/clanTabMenu/clanTabLabel
        if (pl.stringx.endswith(lua_name, 'TabBtn')) then
            -- TabBtn에서 접두어 분리하여 TabMenu/TabLabel 찾기
            local tab_name = pl.stringx.rpartition(lua_name,'TabBtn')

            local valid = true

            -- 탭 버튼
            if (not vars[tab_name .. 'TabBtn']) then
                valid = false
            end

            -- 탭 라벨
            if (not vars[tab_name .. 'TabLabel']) then
                valid = false
            end

            -- 탭 메뉴
            if (not vars[tab_name .. 'TabMenu']) then
                valid = false
            end

            if (valid == true) then
                self:addTabAuto(tab_name, vars, vars[tab_name .. 'TabMenu'])

                -- 지정된 탭이 없다면 가장 윗 쪽/왼 쪽 탭을 default로 하기 위해 계산
                if (not default_tab_name) or (default_tab_y < node:getPositionY()) or (default_tab_x > node:getPositionX()) then
                    default_tab_name = tab_name
                    default_tab_y = node:getPositionY()
                    default_tab_x = node:getPositionX()
                end
                
            end
        end
    end

    -- 외부에서 설정된 초기 탭이 있다면
    local initial_tab = self.m_structTabUI:getDefaultTab(self.m_uiDepth)
    if not (initial_tab and self:existTab(initial_tab)) then
        initial_tab = nil
    end   

    if initial_tab then
        -- depth에 따른 탭 default 설정 
        self:setTab(self.m_structTabUI:getDefaultTab(self.m_uiDepth))

    elseif default_tab_name then
        self:setTab(default_tab_name)
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_TabUI_AutoGeneration:onChangeTab(tab, first)
    local tab_name = tab
    local vars = self.vars

    if (first == true) then
        local ui = self:makeChildMenu(tab_name)
        if ui then
            vars[tab_name .. 'TabMenu']:addChild(ui.root)
        end
    end
end

-------------------------------------
-- function makeChildMenu
-------------------------------------
function UI_TabUI_AutoGeneration:makeChildMenu(tab_name)
    local vars = self.vars
    
    -- 새로운 UI가 생기는 시점이기 때문에 depth 추가
    local ui_depth = (self.m_uiDepth + 1)
    
    -- 하위 UI는 같은 접두사를 써서 구별(UIMaker에서 만들 때)
    local prefix = self.m_structTabUI:getPrefix()
    local ui_name = prefix .. tab_name .. '.ui'

    -- 외부에서 UI 만드는 함수 설정 했을 경우
    local ui = self.m_structTabUI:makeChildMenu(ui_name, ui_depth)
    if ui then
        return ui
    end

    -- 외부에서 UI 만드는 함수 설정 안 했을 경우, .ui 파일에서 찾아 생성
    -- [UI규정] UI 파일 이름 형식 : prefix_tabname.ui   ex) help_clan_level.ui
    if LuaBridge:isFileExist('res/' .. ui_name) then
        local ui = UI_TabUI_AutoGeneration(ui_name, false, ui_depth, self.m_structTabUI) -- ui_name, is_root, ui_depth, struct_tab_ui
        return ui
    end

    return nil
end



-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_TabUI_AutoGeneration:click_exitBtn()
	

   self:close()

end


--@CHECK
UI:checkCompileError(UI_TabUI_AutoGeneration)
