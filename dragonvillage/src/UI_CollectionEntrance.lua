local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_CollectionEntrance
-------------------------------------
UI_CollectionEntrance = class(PARENT, {})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_CollectionEntrance:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_CollectionEntrance'
    self.m_bVisible = true
    self.m_titleStr = Str('도감')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionEntrance:init()
    local vars = self:load('collection_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_CollectionEntrance')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_CollectionEntrance:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionEntrance:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionEntrance:initButton()
    local vars = self.vars

    vars['collectionBtn']:registerScriptTapHandler(function() self:click_collectionBtn() end)
    vars['buffBtn']:registerScriptTapHandler(function() self:click_buffBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionEntrance:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_collectionBtn
-------------------------------------
function UI_CollectionEntrance:click_collectionBtn()
	g_collectionData:openCollectionPopup()
end

-------------------------------------
-- function click_buffBtn
-- @brief
-------------------------------------
function UI_CollectionEntrance:click_buffBtn()
    UI_CollectionStoryPopup()
end

--@CHECK
UI:checkCompileError(UI_CollectionEntrance)
