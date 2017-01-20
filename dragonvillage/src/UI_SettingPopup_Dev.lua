-------------------------------------
-- function init_Dev
-------------------------------------
function UI_SettingPopup:init_Dev()
    local vars = self.vars
    vars['fpsBtn']:registerScriptTapHandler(function() self:click_fpsBtn() end)
    vars['allClearBtn']:registerScriptTapHandler(function() self:click_allClearBtn() end)
    vars['allDragonBtn']:registerScriptTapHandler(function() self:click_allDragonBtn() end)
    vars['allFruitBtn']:registerScriptTapHandler(function() self:click_allFruitBtn() end)
    vars['allMaterialBtn']:registerScriptTapHandler(function() self:click_allMaterialBtn() end)
    vars['allRuneBtn']:registerScriptTapHandler(function() self:click_allRuneBtn() end)
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
    UIManager:toastNotificationGreen('정상적인 적용을 위해 재시작을 권장합니다.')
    --self.m_bRestart = true
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
            UIManager:toastNotificationGreen('정상적인 적용을 위해 재시작을 권장합니다.')
            --self.m_bRestart = true
        end

        if (ret and ret['dragons']) then
            for _,t_dragon in pairs(ret['dragons']) do
                g_dragonsData:applyDragonData(t_dragon)
            end
        end
    end
    ui_network:setSuccessCB(do_work)
    do_work()
end

-------------------------------------
-- function click_allFruitBtn
-- @brief 모든 열매 추가
-------------------------------------
function UI_SettingPopup:click_allFruitBtn()
    local uid = g_userData:get('uid')
    local table_fruit = TABLE:get('fruit')
    local t_list = {}
    for id,_ in pairs(table_fruit) do
        table.insert(t_list, id)
    end
    local do_work

    local ui_network = UI_Network()
    ui_network:setReuse(true)
    ui_network:setUrl('/users/manage')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'increase')
    ui_network:setParam('key', 'fruits')

    do_work = function(ret)
        local id = t_list[1]
        
        if id then
            table.remove(t_list, 1)
            local msg = '"' .. table_fruit[id]['t_name'] .. '" 추가 중...'
            ui_network:setLoadingMsg(msg)
            ui_network:setParam('value', tostring(id) .. ',' .. tostring(100))
            ui_network:request()
        else
            ui_network:close()
            UIManager:toastNotificationGreen('모든 열매 추가!')
            UIManager:toastNotificationGreen('정상적인 적용을 위해 재시작을 권장합니다.')
            --self.m_bRestart = true

            -- 한 번에 저장
            if (ret and ret['user']) then
                g_serverData:applyServerData(ret['user'], 'user')
            end
        end
    end
    ui_network:setSuccessCB(do_work)
    do_work()
end

-------------------------------------
-- function click_allMaterialBtn
-- @brief 모든 진화 재료 추가
-------------------------------------
function UI_SettingPopup:click_allMaterialBtn()
    local uid = g_userData:get('uid')
    local table_evolution_stone = TABLE:get('evolution_item')
    local t_list = {}
    for id,_ in pairs(table_evolution_stone) do
        table.insert(t_list, id)
    end
    local do_work

    local ui_network = UI_Network()
    ui_network:setReuse(true)
    ui_network:setUrl('/users/manage')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'increase')
    ui_network:setParam('key', 'evolution_stones')

    do_work = function(ret)
        local id = t_list[1]
        
        if id then
            table.remove(t_list, 1)
            local msg = '"' .. table_evolution_stone[id]['t_name'] .. '" 추가 중...'
            ui_network:setLoadingMsg(msg)
            ui_network:setParam('value', tostring(id) .. ',' .. tostring(100))
            ui_network:request()
        else
            ui_network:close()
            UIManager:toastNotificationGreen('모든 진화재료 추가!')
            UIManager:toastNotificationGreen('정상적인 적용을 위해 재시작을 권장합니다.')
            --self.m_bRestart = true

            -- 한 번에 저장
            if (ret and ret['user']) then
                g_serverData:applyServerData(ret['user'], 'user')
            end
        end
    end
    ui_network:setSuccessCB(do_work)
    do_work()
end

-------------------------------------
-- function click_allRuneBtn
-- @brief 모든 룬 추가
-------------------------------------
function UI_SettingPopup:click_allRuneBtn()
    local uid = g_userData:get('uid')
    local table_rune = TableRune()
    local t_list = {}
    for id,_ in pairs(table_rune.m_orgTable) do
        table.insert(t_list, id)
    end
    local do_work

    local ui_network = UI_Network()
    ui_network:setReuse(true)
    ui_network:setUrl('/runes/add')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)

    do_work = function(ret)
        local id = t_list[1]
        
        if id then
            table.remove(t_list, 1)
            local msg = '"' .. table_rune:getValue(id, 't_name') .. '" 추가 중...'
            ui_network:setLoadingMsg(msg)
            --ui_network:setParam('value', tostring(id) .. ',' .. tostring(2))
            ui_network:setParam('rid', tostring(id))
            ui_network:request()
        else
            ui_network:close()
            UIManager:toastNotificationGreen('모든 룬 추가!')
            UIManager:toastNotificationGreen('정상적인 적용을 위해 재시작을 권장합니다.')
            --self.m_bRestart = true
        end

        if (ret and ret['runes']) then
            g_runesData:applyRuneData_list(ret['runes'])
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