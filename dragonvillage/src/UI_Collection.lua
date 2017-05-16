local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Collection
-------------------------------------
UI_Collection = class(PARENT, {
        m_mTabUI = 'map',

        -- refresh 체크 용도
        m_collectionLastChangeTime = 'timestamp',
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Collection:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Collection'
    self.m_bVisible = true
    self.m_titleStr = Str('도감')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_Collection:init()
    local vars = self:load('collection.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Collection')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()

    self.m_collectionLastChangeTime = g_collectionData:getLastChangeTimeStamp()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Collection:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Collection:initUI()
    local vars = self.vars

    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Collection:initButton()
    local vars = self.vars

    -- 콜랙션 포인트 보상 확인
    vars['collectionPointBtn']:registerScriptTapHandler(function() self:click_collectionPointBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Collection:refresh()
    local vars = self.vars

    do -- 콜랙션 포인트 임시 초기값
        vars['titleLabel']:setString(Str(g_collectionData:getTamerTitle()))
        vars['collectionPointLabel']:setString(comma_value(g_collectionData:getCollectionPoint()))
    end
end

-------------------------------------
-- function click_collectionPointBtn
-- @brief 콜랙션 포인트 보상 확인 버튼
-------------------------------------
function UI_Collection:click_collectionPointBtn()
    local ui = UI_CollectionPointReward()
    
    local function close_cb()
        self:checkRefresh()
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_Collection:initTab()
    self.m_mTabUI = {}
    self.m_mTabUI['dragon'] = UI_CollectionTabDragon(self)
	self.m_mTabUI['grade'] = UI_CollectionTabGrade(self)

    local vars = self.vars
    self:addTab('dragon', vars['dragonBtn'], vars['dragonListNode'])
    self:addTab('grade', vars['gradeBtn'], vars['gradeListNode'])

    self:setTab('dragon')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_Collection:onChangeTab(tab, first)
    if self.m_mTabUI[tab] then
        self.m_mTabUI[tab]:onEnterTab(first)
    end
end

-------------------------------------
-- function checkRefresh
-- @brief 도감 데이터가 변경되었는지 확인 후 변경되었으면 갱신
-------------------------------------
function UI_Collection:checkRefresh()
    local is_changed = g_collectionData:checkChange(self.m_collectionLastChangeTime)

    if is_changed then
        self.m_collectionLastChangeTime = g_collectionData:getLastChangeTimeStamp()
        self:refresh()
    end
end

--@CHECK
UI:checkCompileError(UI_Collection)
