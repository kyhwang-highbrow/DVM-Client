local PARENT = UI

-------------------------------------
---@class UI_LanguagePopup : UI
-------------------------------------
UI_LanguagePopup = class(PARENT, {
    m_selectedLang = 'string', -- 선택된 언어
    m_tvd = 'UIC_TableViewTD', -- 언어 리스트
    m_needRestart = 'boolean', -- 언어 변경 시 재시작 필요 여부
})

-------------------------------------
---@function init
-- @param user : User
-------------------------------------
function UI_LanguagePopup:init(need_restart)
    self.m_uiName = 'UI_LanguagePopup'
    self.m_selectedLang = g_localData:getLang()
    self.m_needRestart = true -- 보통은 게임을 다시 시작해야 한다.
    if (need_restart == false) then
        self.m_needRestart = false
    end
end

-------------------------------------
---@function init_after
-------------------------------------
function UI_LanguagePopup:init_after()
    self:load('setting_language.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_LanguagePopup')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initTableView()
    self:refresh()
end

-------------------------------------
---@function initUI
-------------------------------------
function UI_LanguagePopup:initUI()
    local vars = self.vars
    local map = TableLanguageConfig.getInstance():getStructLanguageMap()
end

-------------------------------------
---@function initTableView
-------------------------------------
function UI_LanguagePopup:initTableView()
    local vars = self.vars

    local node = vars['cellListNode']
    require('UI_LanguageItem')

    local idx = 1
    local selected_idx = 1
    local function create_cb(ui, data)
        -- 선택된 것 표시
        local is_selected = (self.m_selectedLang == data:getLanguageCode())

        if is_selected == true then
            selected_idx = idx
        end

        idx = idx + 1        
        ui.vars['onBtn']:setVisible((is_selected == true))   
        ui.vars['offBtn']:setVisible((is_selected == false))
        ui.vars['offBtn']:registerScriptTapHandler(function() self:click_langBtn(data) end)
    end
    
    local table_view = UIC_TableViewTD(node)
    table_view.m_nItemPerCell = 4
    --table_view.m_marginFinish = 200
    --table_view.m_refreshDuration = 0

    table_view.m_cellSize = cc.size(260, 76)
    table_view:setCellUIClass(UI_LanguageItem, create_cb)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    
    local item_list = Translate:getActiveLangList()
    table_view:setItemList(item_list, true)
    table_view:relocateContainerFromIndex(selected_idx)

    cclog('현재 가용 언어 갯수', table.count(item_list))

--[[     table_view:makeAllItemUICoroutine(function()
        local relocate_idx = 1
        for idx, item in ipairs(item_list) do
            if (item:getLanguageCode() == self.m_selectedLang) then
                relocate_idx = idx
                break
            end
        end
        table_view:relocateContainerFromIndex(relocate_idx, true)
    end) ]]

    self.m_tvd = table_view
end

-------------------------------------
---@function initButton
-------------------------------------
function UI_LanguagePopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
---@function refresh
-------------------------------------
function UI_LanguagePopup:refresh()
    local vars = self.vars
end

-------------------------------------
---@function click_langBtn
---@brief 언어 버튼
-------------------------------------
function UI_LanguagePopup:click_langBtn(struct_lang)
    local before_lang = g_localData:getLang()
    local after_lang = struct_lang:getLanguageCode()
    local display_name = struct_lang:getLanguageFullDisplayName()

    -- 이미 해당 언어
    if (before_lang == after_lang) then
        return
    end

    local function ok_func()
        g_localData:setLang(after_lang)

        if (self.m_needRestart == true) then
            CppFunctions:restart()
        else
            Translate:load(after_lang)
            self:click_closeBtn()
        end
    end

    local sub_msg = ''
    -- 재시작 필요
    if (self.m_needRestart == true) then
        sub_msg = Str('언어 변경 시 게임을 다시 시작합니다. 진행하겠습니까?')
    else
        sub_msg = Str('이후에도 설정에서 게임 언어를 변경할 수 있습니다.')
    end

    MakeSimplePopup2(POPUP_TYPE.YES_NO, display_name, sub_msg, ok_func)
end

-------------------------------------
---@function click_closeBtn
-------------------------------------
function UI_LanguagePopup:click_closeBtn()
    self:close()
end

--[[ 
-------------------------------------
---@function openIfFirstLanguageCheck
-------------------------------------
function UI_LanguagePopup:openIfFirstLanguageCheck(next_func)
    local language_verification_complete = g_localData:isLangVerificationComplete()
    if (language_verification_complete == true) then
        SafeFuncCall(next_func)
        return
    end
    g_localData:setLangVerificationComplete(true)

    local game_lang = Translate:getGameLang()
    local device_lang = Translate:getDeviceLang()

    -- 언어가 같은 경우 skip
    if (game_lang == device_lang) then
        SafeFuncCall(next_func)
        return
    end

    local ui = UI_LanguagePopup(false)
    ui:setCloseCB(next_func)
    return ui
end ]]