local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_TranslationViewer
-------------------------------------
UI_TranslationViewer = class(PARENT, {
        m_values = 'table',
        m_index = 1,
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
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TranslationViewer:initButton()
    local vars = self.vars
    
    vars['loadBtn']:registerScriptTapHandler(function() self:click_loadBtn() end)
    vars['minusBtn']:registerScriptTapHandler(function() self.m_index = self.m_index - 1; self:refresh() end)
    vars['plusBtn']:registerScriptTapHandler(function() self.m_index = self.m_index + 1; self:refresh() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TranslationViewer:refresh()
    local vars = self.vars

    
    self.m_index = (self.m_index or 1)

    local t_row = nil
    for i,v in ipairs(self.m_values) do
        if self.m_index == tonumber(v[1]) then
            t_row = v
        end
    end
     ccdump(t_row)
    
    local en_str = ''
    local fa_str = ''

    if t_row then
        en_str = self:makeUsable(t_row[2] or '')
        fa_str = self:makeUsable(t_row[3] or '')
    else
        UIManager:toastNotificationRed('invalid index! ' .. tostring(self.m_index))
    end


    if true then
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
-- 파라미터 셋팅
    local t_data = {}

    local sheet_id = '1pvv-j5YbZoVsMU8yNa5JOJpo4Ng3hStkZcM38Wbyrbs'
    local sheet_range = 'work'
    local api_key = 'AIzaSyBGQcRbLRzya2PcNFOGMOcdOxjQBMWd7OA'
    local api_url = formatMessage('https://sheets.googleapis.com/v4/spreadsheets/{1}/values/{2}?key={3}', sheet_id, sheet_range, api_key)

    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = api_url
    t_request['method'] = 'GET'
    t_request['skip_default_params'] = true
    t_request['data'] = t_data

    local function success_func(ret)
        --ccdump(ret)
        --cclog(debug.traceback())
        self.m_values = ret['values']
        self:refresh()
    end

    local function fail_func(ret)        
        ccdump(ret)
        cclog(debug.traceback())
    end

    -- 성공 시 콜백 함수
    t_request['success'] = success_func

    -- 실패 시 콜백 함수
    t_request['fail'] = fail_func

    -- 네트워크 통신
    Network:SimpleRequest(t_request)
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