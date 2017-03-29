-------------------------------------
-- class UI_AdventureChapterSelectPopup
-------------------------------------
UI_AdventureChapterSelectPopup = class(UI, ITopUserInfo_EventListener:getCloneTable(), {
        m_beginChapter = 'number',
        m_cbFunction = 'function',
     })

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_AdventureChapterSelectPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AdventureChapterSelectPopup'
    self.m_bVisible = false
    self.m_bUseExitBtn = true
end


-------------------------------------
-- function init
-------------------------------------
function UI_AdventureChapterSelectPopup:init(chapter)
    self.m_beginChapter = chapter

    local vars = self:load('chapter_select_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AdventureChapterSelectPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AdventureChapterSelectPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AdventureChapterSelectPopup:initUI()
    self:init_tableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdventureChapterSelectPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdventureChapterSelectPopup:refresh()
end

-------------------------------------
-- function init_tableView
-- @brief 테이블뷰 초기화
-------------------------------------
function UI_AdventureChapterSelectPopup:init_tableView()
    local list_table_node = self.vars['btnNode']

    local l_chapter_list = {}
    for i=1, MAX_ADVENTURE_CHAPTER do
        l_chapter_list[i] = i
    end

    -- 생성 콜백 함수
    local function create_func(item)
        local ui = item['ui']

        ui.m_cbDifficultyBtn = function(chapter, difficulty)
            self:close()
            if self.m_cbFunction then
                self.m_cbFunction(chapter, difficulty)
            end
        end
    end

    -- 클릭 콜백 함수
    local function click_dragon_item(item)
        local chapter = item['unique_id']
    
        local root = item['ui'].vars['root']
        if root then
            root:setScale(0.9)
            root:stopAllActions()
            root:runAction(cc.ScaleTo:create(0.3, 1))
        end

        local is_open = g_adventureData:isOpenGlobalChapter(chapter)

        if is_open then
            self:close()
            if self.m_cbFunction then
                local difficulty = g_adventureData:getChapterOpenDifficulty(chapter)
                self.m_cbFunction(chapter, difficulty)
            end
        end
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.HORIZONTAL)
    table_view_ext:setCellInfo(400, 430)
    table_view_ext:setItemUIClass(UI_AdventureChapterButton, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo(l_chapter_list)
    table_view_ext:update()

    -- 테이블뷰 클래스를 수정해야함... orz
    --table_view_ext.m_tableViewTD:moveToPosition(self.m_beginChapter)
end

--@CHECK
UI:checkCompileError(UI_AdventureChapterSelectPopup)
