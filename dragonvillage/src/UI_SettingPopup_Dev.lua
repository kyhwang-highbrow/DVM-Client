-------------------------------------
-- function init_Dev
-------------------------------------
function UI_SettingPopup:init_Dev()
    local vars = self.vars
    vars['fpsBtn']:registerScriptTapHandler(function() self:click_fpsBtn() end)
    vars['allClearBtn']:registerScriptTapHandler(function() self:click_allClearBtn() end)
    vars['allDragonBtn']:registerScriptTapHandler(function() self:click_allDragonBtn() end)
end

-------------------------------------
-- function click_fpsBtn
-- @brief fps 출력
-------------------------------------
function UI_SettingPopup:click_fpsBtn()
    local value = g_serverData:get('local', 'fps')
    g_serverData:applyServerData(not value, 'local', 'fps')
    g_serverData:applySetting()
    self:refresh()
end

-------------------------------------
-- function click_allClearBtn
-- @brief 모든 스테이지 오픈
-------------------------------------
function UI_SettingPopup:click_allClearBtn()
    g_adventureData:allStageClear()
    UIManager:toastNotificationGreen('모든 스테이지 오픈!')
    self.m_bRestart = true
end

-------------------------------------
-- function click_allDragonBtn
-- @brief 모든 드래곤 추가
-------------------------------------
function UI_SettingPopup:click_allDragonBtn()
    local uid = g_userData:get('uid')
    local table_dragon = TABLE:get('dragon')
    local t_list = {}
    for did,t_dragon in pairs(table_dragon) do
        if (t_dragon['test'] == 1) then
            table.insert(t_list, did)
        end
    end
    local do_work

    local ui_network = UI_Network()
    ui_network:setReuse(true)
    ui_network:setUrl('/dragons/add')
    ui_network:setParam('uid', uid)

    do_work = function(ret)
        local did = t_list[1]
        
        if did then
            table.remove(t_list, 1)
            local msg = '"' .. table_dragon[did]['t_name'] .. '"드래곤 추가 중...'
            ui_network:setLoadingMsg(msg)
            ui_network:setParam('did', did)
            ui_network:request()
        else
            ui_network:close()
            UIManager:toastNotificationGreen('모든 드래곤 추가!')
            self.m_bRestart = true
        end
    end
    ui_network:setSuccessCB(do_work)
    do_work()
end

-------------------------------------
-- function refresh_devTap
-- @brief "개발" 탭
-------------------------------------
function UI_SettingPopup:refresh_devTap()
    local vars = self.vars

    -- fps
    if g_serverData:get('local', 'fps') then
        vars['fpsLabel']:setString('ON')
    else
        vars['fpsLabel']:setString('OFF')
    end
end