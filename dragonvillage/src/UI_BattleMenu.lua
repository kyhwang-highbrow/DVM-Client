local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_BattleMenu
-------------------------------------
UI_BattleMenu = class(PARENT, {
     })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_BattleMenu:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_BattleMenu'
    self.m_bVisible = true
    self.m_titleStr = Str('전투')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenu:init()
    local vars = self:load('battle_menu.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_BattleMenu')

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
function UI_BattleMenu:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BattleMenu:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BattleMenu:initButton()
    local vars = self.vars
    vars['nestBtn']:registerScriptTapHandler(function() self:click_nestBtn() end)
    vars['colosseumBtn']:registerScriptTapHandler(function() self:click_colosseumBtn() end)
    vars['secretBtn']:registerScriptTapHandler(function() self:click_secretBtn() end)
    vars['raidBtn']:registerScriptTapHandler(function() self:click_raidBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BattleMenu:refresh()
end

-------------------------------------
-- function click_nestBtn
-------------------------------------
function UI_BattleMenu:click_nestBtn()
    local request_nest_dungeon_info
    local request_nest_dungeon_stage_list
    local replace_scene

    -- 네스트 던전 리스트 정보 얻어옴
    request_nest_dungeon_info = function()
        g_nestDungeonData:requestNestDungeonInfo(request_nest_dungeon_stage_list)
    end

    -- 네스트 던전 스테이지 리스트 얻어옴
    request_nest_dungeon_stage_list = function()
        g_nestDungeonData:requestNestDungeonStageList(replace_scene)
    end

    -- 네스트 던전 씬으로 전환
    replace_scene = function()
        local scene = SceneNestDungeon()
        scene:runScene()
    end

    request_nest_dungeon_info()
end

-------------------------------------
-- function click_colosseumBtn
-------------------------------------
function UI_BattleMenu:click_colosseumBtn()
    local scene = SceneColosseum()
    scene:runScene()
end

-------------------------------------
-- function click_secretBtn
-------------------------------------
function UI_BattleMenu:click_secretBtn()
    UIManager:toastNotificationRed('"비밀 던전"은 준비 중입니다.')
end

-------------------------------------
-- function click_raidBtn
-------------------------------------
function UI_BattleMenu:click_raidBtn()
    UIManager:toastNotificationRed('"레이드"는 준비 중입니다.')
end

--@CHECK
UI:checkCompileError(UI_BattleMenu)
