local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_AttrTowerMenuScene
-------------------------------------
UI_AttrTowerMenuScene = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function UI_AttrTowerMenuScene:init()
    local vars = self:load('attr_tower_menu.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AttrTowerMenuScene')

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_AttrTowerMenuScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AttrTowerMenuScene'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('시험의 탑')
    self.m_staminaType = 'tower'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AttrTowerMenuScene:initUI()
    local vars = self.vars
	
    local l_attr = {'fire', 'water', 'earth', 'light', 'dark'}

    for i, attr in ipairs(l_attr) do
        local ui = UI_AttrTowerMenuItem(attr)
        vars['itemNode'..i]:addChild(ui.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AttrTowerMenuScene:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AttrTowerMenuScene:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AttrTowerMenuScene:click_exitBtn()
   cclog('UI_AttrTowerMenuScene:click_exitBtn()')
   self:close()
end

--@CHECK
UI:checkCompileError(UI_AttrTowerMenuScene)