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
    self:refresh_cnt()
    self:refresh_happy()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest:refresh_cnt()
    local vars = self.vars

    -- 드래곤 수
    local curr_cnt = self.m_territory:getCurrDragonCnt()
    local max_cnt = ServerData_Forest:getInstance():getMaxDragon()
    vars['inventoryLabel']:setString(string.format('%d / %d', curr_cnt, max_cnt))
end

-------------------------------------
-- function refresh_happy
-------------------------------------
function UI_Forest:refresh_happy()
    local vars = self.vars

    -- 만족도 바
    local happy_pnt = ServerData_Forest:getInstance():getHappy()
    vars['giftLabel']:setString(string.format('%d %%', happy_pnt/10))
    vars['giftGauge']:runAction(cc.ProgressTo:create(0.5, happy_pnt/10))
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
    local ui = UI_Forest_ChangePopup()

    -- 교체 했을 때만 체크
    ui:setChangeCB(function()
        -- 드래곤 다시 생성
        self.m_territory:initDragons()
    end)

    -- 닫을때 항상 체크
    ui:setCloseCB(function()
        self:refresh_cnt()
    end)
end

-------------------------------------
-- function click_levelupBtn
-------------------------------------
function UI_Forest:click_levelupBtn()
    local t_stuff_object = self.m_territory:getStuffObjectTable()
    UI_Forest_StuffListPopup(t_stuff_object)
end

-------------------------------------
-- function click_helpBtn
-------------------------------------
function UI_Forest:click_helpBtn()
    self.vars['helpNode']:runAction(cc.ToggleVisibility:create())
end
