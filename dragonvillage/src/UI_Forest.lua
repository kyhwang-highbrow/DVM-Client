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
    local vars = self:load('dragon_forest.ui')
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
    self.m_territory:setUI(self)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest:initButton()
    local vars = self.vars

    vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
    vars['changeBtn']:registerScriptTapHandler(function() self:click_changeBtn() end)
    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest:refresh()
    local vars = self.vars

    -- 드래곤 수
    local curr_cnt = self.m_territory:getCurrDragonCnt()
    local max_cnt = 20
    vars['inventoryLabel']:setString(string.format('%d / %d', curr_cnt, max_cnt))

    -- 만족도
    self:refresh_happy()
end

-------------------------------------
-- function refresh_happy
-------------------------------------
function UI_Forest:refresh_happy()
    local vars = self.vars

    -- 만족도 바
    local happy_pnt = ServerData_Forest:getInstance():getHappy()
    vars['giftLabel']:setString(string.format('%d %%', happy_pnt/10))
    vars['giftGauge']:runAction(cc.ProgressTo:create(0.5, happy_pnt/1000))
    vars['boxVisual']:changeAni('gift_box_tap', false)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Forest:click_exitBtn()
    SceneLobby():runScene()
end

-------------------------------------
-- function click_changeBtn
-------------------------------------
function UI_Forest:click_changeBtn()
    ccdisplay('click_changeBtn')
    self.m_territory:changeDragon_Random()
end

-------------------------------------
-- function click_levelupBtn
-------------------------------------
function UI_Forest:click_levelupBtn()
    ccdisplay('click_levelupBtn')
end

-------------------------------------
-- function click_helpBtn
-------------------------------------
function UI_Forest:click_helpBtn()
    self.vars['helpNode']:runAction(cc.ToggleVisibility:create())
end
