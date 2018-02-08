local PARENT = UI

-------------------------------------
-- class UI_QuickPopupNew
-------------------------------------
UI_QuickPopupNew = class(PARENT, {
        m_loadingUI = 'UI_TitleSceneLoading',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_QuickPopupNew:init()
    local vars = self:load('quick_popup_new.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_QuickPopupNew'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_QuickPopupNew')

    self:initUI()
    self:initButton()
    self:refresh()

    -- @UI_ACTION (포지션 바꾼후 액션)
    self:doActionReset()
    self:doAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_QuickPopupNew:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_QuickPopupNew:initButton()
    local vars = self.vars
    self:init_adventureBtn()
    self:init_dungeonBtn()
    self:init_competitionBtn()

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['homeBtn']:registerScriptTapHandler(function() UINavigator:goTo('lobby') end)

    -- 하단
    vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end)
    vars['forestBtn']:registerScriptTapHandler(function() self:click_forestBtn() end) -- 드래곤의숲
    vars['clanBtn']:registerScriptTapHandler(function() self:click_clanBtn() end) -- 클랜 버튼
end

-------------------------------------
-- function init_adventureBtn
-------------------------------------
function UI_QuickPopupNew:init_adventureBtn()
    local vars = self.vars
    local l_content = {}
    table.insert(l_content, 'home') -- 로비 버튼은 여기 추가
    table.insert(l_content, 'adventure')
    table.insert(l_content, 'exploration')
    self:checkLockContent(l_content)
    self:adjustPosX(l_content)
end

-------------------------------------
-- function init_dungeonBtn
-------------------------------------
function UI_QuickPopupNew:init_dungeonBtn()
    local vars = self.vars
    local l_content = {}
    table.insert(l_content, 'nest_tree')
    table.insert(l_content, 'nest_evo_stone')

    -- 클랜 던전은 클랜 가입시에만 오픈, 한국서버에서만 오픈
    if (not g_clanData:isClanGuest()) and (g_localData:isKoreaServer()) then
         table.insert(l_content, 'clan_raid')
    end

    table.insert(l_content, 'nest_nightmare')
    table.insert(l_content, 'secret_relation')
    self:checkLockContent(l_content)
    self:adjustPosX(l_content)
end

-------------------------------------
-- function init_competitionBtn
-------------------------------------
function UI_QuickPopupNew:init_competitionBtn()
    local vars = self.vars
    local l_content = {}
    table.insert(l_content, 'ancient')
    -- 시험의탑 오픈된 경우에만 노출
    if (g_attrTowerData:isContentOpen()) then
        table.insert(l_content, 'attr_tower')
    end
    table.insert(l_content, 'colosseum')
    self:checkLockContent(l_content)
    self:adjustPosX(l_content)
end

-------------------------------------
-- function checkLockContent
-------------------------------------
function UI_QuickPopupNew:checkLockContent(l_content)
    local vars = self.vars
    for i, content in ipairs(l_content) do
        local is_content_lock, req_user_lv = g_contentLockData:isContentLock(content)
        if (is_content_lock) then
            vars[content .. 'Btn']:setVisible(true)
            if (vars[content .. 'LockSprite']) then
                vars[content .. 'LockSprite']:setVisible(true)
            end
            
            if (vars[content .. 'LockLabel']) then
                vars[content .. 'LockLabel']:setString(Str('레벨 {1}', req_user_lv))
            end

            cca.reserveFunc(vars[content .. 'Btn'], 0.5, function()
                vars[content .. 'Btn']:setEnabled(false)
            end)
        else
            vars[content .. 'Btn']:setVisible(true)
            vars[content .. 'Btn']:registerScriptTapHandler(function() 
                self:goTo(content) 
            end)
        end

        -- 베타 버튼 표시
        local beta_label = vars[content .. 'BetaLabel']
        if beta_label then
            if g_contentLockData:isContentBeta(content) then
                beta_label:setVisible(true) 
            else
                beta_label:setVisible(false)
            end
        end
    end
end

-------------------------------------
-- function adjustPosX
-------------------------------------
function UI_QuickPopupNew:adjustPosX(l_content)
    local vars = self.vars
    local padding_x = 184
    local total_cnt = #l_content
    local start_x = -(total_cnt/2 * padding_x - padding_x/2)

    for i, content in ipairs(l_content) do
        local pos_x = start_x + (i - 1) * padding_x 
        vars[content .. 'Btn']:setPositionX(pos_x)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_QuickPopupNew:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_QuickPopupNew:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_settingBtn
-------------------------------------
function UI_QuickPopupNew:click_settingBtn()
    UI_Setting()
end

-------------------------------------
-- function goTo
-------------------------------------
function UI_QuickPopupNew:goTo(content)
    self:close()
    UINavigator:goTo(content)
end

-------------------------------------
-- function click_forestBtn
-- @brief 드래곤 숲
-------------------------------------
function UI_QuickPopupNew:click_forestBtn()
    self:goTo('forest')
end

-------------------------------------
-- function click_clanBtn
-- @brief 클랜 버튼
-------------------------------------
function UI_QuickPopupNew:click_clanBtn()
    self:goTo('clan')
end