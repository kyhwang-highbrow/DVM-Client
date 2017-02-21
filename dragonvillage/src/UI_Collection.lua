local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Collection
-------------------------------------
UI_Collection = class(PARENT, {
        m_mTabUI = 'map',
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

    do -- 콜랙션 포인트 임시 초기값
        vars['titleLabel']:setString(Str('마스터 테이머'))
        vars['collectionPointLabel']:setString(comma_value(5000))
    end
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

end

-------------------------------------
-- function click_collectionPointBtn
-- @brief 콜랙션 포인트 보상 확인 버튼
-------------------------------------
function UI_Collection:click_collectionPointBtn()
end


-------------------------------------
-- function initTab
-------------------------------------
function UI_Collection:initTab()
    self.m_mTabUI = {}
    self.m_mTabUI['dragon'] = UI_CollectionTabDragon(self)
    self.m_mTabUI['unit'] = UI_CollectionTabUnit(self)

    local vars = self.vars
    self:addTab('dragon', vars['dragonBtn'], vars['dragonMenu'])
    self:addTab('unit', vars['unitBtn'], vars['unitListNode'])
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

--@CHECK
UI:checkCompileError(UI_Collection)
