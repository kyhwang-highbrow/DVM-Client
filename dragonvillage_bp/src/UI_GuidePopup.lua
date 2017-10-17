local PARENT = UI

-- 도울말 TAB 종류
local L_GUIDE_LIST = {}
table.insert(L_GUIDE_LIST, 'attr')

-------------------------------------
-- class UI_GuidePopup
-------------------------------------
UI_GuidePopup = class(PARENT, ITopUserInfo_EventListener:getCloneTable(), {
        m_currTab = 'string',
        m_maxPage = 'number',
        m_currPage = 'number',

        m_lUICache = 'UI',
        m_currUI = 'UI',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GuidePopup:init(tab_name)
    local vars = self:load('guide_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- '닫기' 버튼
	if vars['closeBtn'] then
	    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
	end
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_GuidePopup')

    self:initUI()
    self:initButton()
    self:refresh()

    tab_name = (tab_name or L_GUIDE_LIST[1])
    self:changeTab(tab_name)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_GuidePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_GuidePopup'
    self.m_bVisible = false
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GuidePopup:initUI()
    self.m_lUICache = {}
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GuidePopup:initButton()
    local vars = self.vars

    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end)
end

-------------------------------------
-- function getPageUI
-------------------------------------
function UI_GuidePopup:getPageUI(page_ui_name)
    if (not self.m_lUICache[page_ui_name]) then
        local ui = UI()
        ui:load(page_ui_name)
        self.vars['contentsNode']:addChild(ui.root)
        self.m_lUICache[page_ui_name] = ui
    end

    return self.m_lUICache[page_ui_name]
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GuidePopup:refresh()
    if (not self.m_currTab) then
        return
    end
    
    if (not self.m_currPage) then
        return
    end

    if (self.m_currUI) then
        self.m_currUI.root:setVisible(false)
        self.m_currUI = nil
    end

    local page_ui_name = self:getPageUIName(self.m_currTab, self.m_currPage)
    self.m_currUI = self:getPageUI(page_ui_name)
    self.m_currUI.root:setVisible(true)

    -- 이전, 다음 버튼
    self.vars['prevBtn']:setVisible(1 < self.m_currPage)
    self.vars['prevLabel']:setVisible(1 < self.m_currPage)
    
    self.vars['nextBtn']:setVisible(self.m_currPage < self.m_maxPage)
    self.vars['nextLabel']:setVisible(self.m_currPage < self.m_maxPage)
end

-------------------------------------
-- function changeTab
-------------------------------------
function UI_GuidePopup:changeTab(tab)
    if (self.m_currTab == tab) then
        return
    end

    self.m_currTab = tab
    self.m_maxPage = self:checkMaxPage(tab)
    self.m_currPage = nil

    self:changePage(1)
end

-------------------------------------
-- function checkMaxPage
-- @brief 해당하는 Tab(탭)의 max_page를 계산
-------------------------------------
function UI_GuidePopup:checkMaxPage(tab_name)
    local max_page = 0

    -- 도움말의 한 탭이 10페이지를 넘지 않는다는 가정
    for i=1, 10 do
        -- ui파일명을 얻어옴
        local page_ui_name = self:getPageUIName(tab_name, i)

        -- UIManager의 함수를 통해 ui가 존재하는지 확인(캐싱의 기능도 있음)
        local ui_file = getUIFile(page_ui_name, true)

        if ui_file then
            max_page = i
        else
            break
        end
    end

    return max_page
end

-------------------------------------
-- function getPageUIName
-- @brief Tab(탭)과 Page로 ui파일명을 생성
-- ex) res/guid_attr_01.ui ~ res/guid_attr_02.ui
-------------------------------------
function UI_GuidePopup:getPageUIName(tab_name, page)
    local page_ui_name = string.format('guide_%s_%.2d.ui', tab_name, page)
    return page_ui_name
end

-------------------------------------
-- function changePage
-------------------------------------
function UI_GuidePopup:changePage(curr_page)
    if (self.m_currPage == curr_page) then
        return
    end

    self.m_currPage = curr_page

    self:refresh()
end

-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_GuidePopup:click_prevBtn()
    if (1 < self.m_currPage) then
        self:changePage(self.m_currPage - 1)
    end
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GuidePopup:click_nextBtn()
    if (self.m_currPage < self.m_maxPage) then
        self:changePage(self.m_currPage + 1)
    end
end

-------------------------------------
-- function MakeGuidePopup
-------------------------------------
function MakeGuidePopup(type)

    local exist = false
    for i,v in pairs(L_GUIDE_LIST) do
        if (type == v) then
            exist = true
            break
        end
    end

    if (not exist) then
        UIManager:toastNotificationRed('"' .. type .. '"도움말 미구현')
        return nil
    end

    return UI_GuidePopup(type)
end


--@CHECK
UI:checkCompileError(UI_GuidePopup)