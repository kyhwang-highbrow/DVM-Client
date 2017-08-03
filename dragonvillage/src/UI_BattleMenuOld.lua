local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_BattleMenuOld
-------------------------------------
UI_BattleMenuOld = class(PARENT, {
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_BattleMenuOld:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_BattleMenuOld'
    self.m_bVisible = true
    self.m_titleStr = Str('전투')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuOld:init()
    local vars = self:load('battle_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BattleMenuOld')

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
function UI_BattleMenuOld:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattleMenuOld:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BattleMenuOld:initButton()
    local vars = self.vars
    vars['colosseumBtn']:registerScriptTapHandler(function() self:click_colosseumBtn() end)
    vars['towerBtn']:registerScriptTapHandler(function() self:click_towerBtn() end)

    -- 콜로세움 잠금 처리
    local is_content_lock, req_user_lv = g_contentLockData:isContentLock('colosseum')
    if (is_content_lock == true) then
        local ui = UI_ContentLock:create(req_user_lv)
        vars['colosseumBtn']:addChild(ui.root)
    end

    -- 고대의 탑 잠금 처리
    local is_content_lock, req_user_lv = g_contentLockData:isContentLock('ancient')
    if (is_content_lock == true) then
        local ui = UI_ContentLock:create(req_user_lv)
        vars['towerBtn']:addChild(ui.root)
    end
    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BattleMenuOld:refresh()
end

-------------------------------------
-- function click_colosseumBtn
-- @brief 콜로세움 진입 버튼
-------------------------------------
function UI_BattleMenuOld:click_colosseumBtn()
    if g_contentLockData:checkContentLock('colosseum') then
        g_colosseumData:goToColosseum()
    end
end

-------------------------------------
-- function click_towerBtn
-- @brief 고대의 탑 진입 버튼
-------------------------------------
function UI_BattleMenuOld:click_towerBtn()
    if g_contentLockData:checkContentLock('ancient') then
        g_ancientTowerData:goToAncientTowerScene()
    end
end

--@CHECK
UI:checkCompileError(UI_BattleMenuOld)
