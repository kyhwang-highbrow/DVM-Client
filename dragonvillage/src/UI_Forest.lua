local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Forest
-------------------------------------
UI_Forest = class(PARENT,{
        m_territory = 'ForestTerritory',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Forest:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Forest'
    self.m_titleStr = Str('드래곤의 숲')
    self.m_uiBgm = 'bgm_lobby'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_bShowChatBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_Forest:init()
    local vars = self:load('forest.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Forest')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest:initUI()
    local vars = self.vars
    local territory = ForestTerritory(vars['cameraNode'])
    self.m_territory = territory
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest:initButton()
    local vars = self.vars
    vars['testBtn1']:registerScriptTapHandler(function() self:click_testBtn1() end)
    vars['testBtn2']:registerScriptTapHandler(function() self:click_testBtn2() end)
    vars['testBtn3']:registerScriptTapHandler(function() self:click_testBtn3() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Forest:click_exitBtn()
    SceneLobby():runScene()
end

-------------------------------------
-- function click_testBtn1
-------------------------------------
function UI_Forest:click_testBtn1()
    ccdisplay('click_testBtn1')
    self.m_territory:changeDragon_Random()
end

-------------------------------------
-- function click_testBtn2
-------------------------------------
function UI_Forest:click_testBtn2()
    ccdisplay('click_testBtn2')
end

-------------------------------------
-- function click_testBtn3
-------------------------------------
function UI_Forest:click_testBtn3()
    ccdisplay('click_testBtn3')
end
