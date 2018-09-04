local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_GoldDungeonScene
-------------------------------------
UI_GoldDungeonScene = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GoldDungeonScene:init()
    local vars = self:load('gold_dungeon_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_GoldDungeonScene')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    --self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_GoldDungeonScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_GoldDungeonScene'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('황금 던전')
    self.m_uiBgm = 'bgm_lobby'

    -- 입장권 타입 설정
    self.m_staminaType = TableDrop:getStageStaminaType(EVENT_GOLD_STAGE_ID)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GoldDungeonScene:initUI()
    local vars = self.vars
    vars['staminaLabel']:setString('1')
    vars['totalTicketLabel']:setString(Str('입장권은 매일 {1}개까지 충전됩니다.', 2))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GoldDungeonScene:initButton()
    local vars = self.vars
    vars['dungeonBtn']:registerScriptTapHandler(function() self:click_dungeonBtn() end)
    --vars['dungeonInfoBtn']:registerScriptTapHandler(function() self:click_dungeonInfoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GoldDungeonScene:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_GoldDungeonScene:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_dungeonBtn
-- @brief 던전 입장
-------------------------------------
function UI_GoldDungeonScene:click_dungeonBtn()
    UI_ReadySceneNew(EVENT_GOLD_STAGE_ID)
end

-------------------------------------
-- function click_dungeonInfoBtn
-- @brief 황금 던전 설명 팝업
-------------------------------------
function UI_GoldDungeonScene:click_dungeonInfoBtn()
    UI_EventGoldDungeonPopup()
end


--@CHECK
UI:checkCompileError(UI_GoldDungeonScene)
