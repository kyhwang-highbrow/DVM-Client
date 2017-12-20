local PARENT = UI

-------------------------------------
-- class UI_QuickPopup
-------------------------------------
UI_QuickPopup = class(PARENT, {
        m_loadingUI = 'UI_TitleSceneLoading',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_QuickPopup:init()
    local vars = self:load('quick_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_QuickPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_QuickPopup:initUI()
    local vars = self.vars

    -- 대사를 하는 캐릭터 통통 튀게
    cca.pickMePickMe(vars['characterNode'])
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_QuickPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end)
    vars['homeBtn']:registerScriptTapHandler(function() UINavigator:goTo('lobby') end)

    -- 버튼 핸들러 등록과 컨텐츠 락 처리를 겸함
    local l_content = {'adventure', 'exploration', 'nest_evo_stone', 'nest_tree', 'nest_nightmare', 'secret_relation', 'colosseum', 'ancient', 'forest', 'clan', 'attr_tower'}
    for i, content in ipairs(l_content) do
        local is_content_lock, req_user_lv = g_contentLockData:isContentLock(content)
        if (is_content_lock) then
            if (vars[content .. 'LockSprite']) then
                vars[content .. 'LockSprite']:setVisible(true)
            end
            
            if (vars[content .. 'LockLabel']) then
                vars[content .. 'LockLabel']:setString(Str('레벨 {1}', req_user_lv))
            end
            
            vars[content .. 'Btn']:setEnabled(false)
        else
            vars[content .. 'Btn']:setVisible(true)
            vars[content .. 'Btn']:registerScriptTapHandler(function() UINavigator:goTo(content) end)
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


    vars['clanBtn']:setVisible(true)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_QuickPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_QuickPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_settingBtn
-------------------------------------
function UI_QuickPopup:click_settingBtn()
    UI_Setting()
end