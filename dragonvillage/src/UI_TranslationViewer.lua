local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_TranslationViewer
-------------------------------------
UI_TranslationViewer = class(PARENT, {
        m_values = 'table',
        m_index = 'number',
        m_bCheckFormatStr = 'bool',
        m_tHeaderInfo = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_TranslationViewer:init()
    local vars = self:load('translation_viewer.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_TranslationViewer')

    -- @UI_ACTION
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TranslationViewer:initUI()
    local vars = self.vars
    self.m_index = 1
    self.m_values = {}
    self.m_tHeaderInfo = {}
    self.m_bCheckFormatStr = false
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TranslationViewer:initButton()
    local vars = self.vars
    
    -- index입력하는 edit box
    local function editBoxTextEventHandle(strEventName,pSender)
        if (strEventName == "return") then
            local msg = pSender:getText()
            local num = tonumber(msg)
            if (num == nil) then
                UIManager:toastNotificationRed('Please enter an integer.')
                vars['editBox']:setText(tostring(self.m_index))
            else
                self.m_index = num
                self:refresh()
            end
        end
    end
    vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)

    -- format
    vars['formatBtn'] = UIC_CheckBox(vars['formatBtn'].m_node, vars['formatSprite'], self.m_bCheckFormatStr)
    local function change_cb(checked)
        self.m_bCheckFormatStr = checked
        self:refresh()
    end
    vars['formatBtn']:setChangeCB(change_cb)


    vars['loadBtn']:registerScriptTapHandler(function() self:click_loadBtn() end)
    vars['minusBtn']:registerScriptTapHandler(function() self.m_index = self.m_index - 1; self:refresh() end)
    vars['plusBtn']:registerScriptTapHandler(function() self.m_index = self.m_index + 1; self:refresh() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function getHeaderIndex
-------------------------------------
function UI_TranslationViewer:getHeaderIndex(key)
    local t_header_info = (self.m_tHeaderInfo or {})
    return t_header_info[key] or 1
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TranslationViewer:refresh()
    local vars = self.vars

    
    self.m_index = (self.m_index or 1)

    local index_index = self:getHeaderIndex('index')
    local index_en = self:getHeaderIndex('en')
    local index_fa = self:getHeaderIndex('fa')

    local t_row = nil
    for i,v in ipairs(self.m_values) do
        if self.m_index == tonumber(v[index_index]) then
            t_row = v
        end
    end
    
    local en_str = ''
    local fa_str = ''

    if t_row then
        en_str = self:makeUsable(t_row[index_en] or '')
        fa_str = self:makeUsable(t_row[index_fa] or '')
    else
        local is_empty = (table.count(self.m_values) == 0)
        if (not is_empty) then
            UIManager:toastNotificationRed('invalid index! ' .. tostring(self.m_index))
        end
    end

    if (self.m_bCheckFormatStr == true) then
        en_str = formatMessage(en_str, 'fmt_text_01', 'fmt_text_02', 'fmt_text_03', 'fmt_text_04', 'fmt_text_05', 'fmt_text_06', 'fmt_text_07', 'fmt_text_08', 'fmt_text_09', 'fmt_text_10')
        fa_str = formatMessage(fa_str, 'fmt_text_01', 'fmt_text_02', 'fmt_text_03', 'fmt_text_04', 'fmt_text_05', 'fmt_text_06', 'fmt_text_07', 'fmt_text_08', 'fmt_text_09', 'fmt_text_10')
    end

    local vars = self.vars
    vars['label01']:setString(en_str)
    vars['label02']:setString(fa_str)
    vars['richLabel01']:setString(en_str)
    vars['richLabel02']:setString(fa_str)
    vars['editBox']:setText(tostring(self.m_index))
end


-------------------------------------
-- function click_loadBtn
-------------------------------------
function UI_TranslationViewer:click_loadBtn()

    local sheet_id = '1pvv-j5YbZoVsMU8yNa5JOJpo4Ng3hStkZcM38Wbyrbs'
    local sheet_range = 'work'
    local api_key = 'AIzaSyBGQcRbLRzya2PcNFOGMOcdOxjQBMWd7OA'
    local api_url = formatMessage('https://sheets.googleapis.com/v4/spreadsheets/{1}/values/{2}?key={3}', sheet_id, sheet_range, api_key)

    -- 성공 콜백
    local function success_cb(ret)
        UIManager:toastNotificationGreen('Translation sheet loaded.')
        self.m_values = ret['values']

        self.m_tHeaderInfo = {}
        if self.m_values[1] then
            for i,v in pairs(self.m_values[1]) do
                self.m_tHeaderInfo[v] = i
            end
        end
        self:refresh()
    end

    -- 실패 콜백
    local function fail_cb()
        ccdump(ret)
        cclog(debug.traceback())
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setFullUrl(api_url)
    ui_network:setSuccessCB(success_cb)
    --ui_network:setFailCB(fail_cb) -- 실패 콜백을 등록하지 않으면 기본 오류 팝업을 띄움
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:setMethod('GET')
    ui_network:setSKipDefaultParams(true)
    ui_network:setHmac(false)
    --ui_network:hideLoading()
    ui_network:request()
end

-------------------------------------
-- function makeUsable
-- @brief LuaUtility.lua - util.encodeString() 함수의 역
-------------------------------------
function UI_TranslationViewer:makeUsable(id)
    id = id:gsub('\\n', '\n')
    id = id:gsub('\\t', '\t')
    id = id:gsub("\'", "'")
    id = id:gsub('\"', '"')
    return id
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_TranslationViewer:click_closeBtn()
    self:close()
end