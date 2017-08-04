-------------------------------------
-- function init_devTab
-------------------------------------
function UI_Setting:init_devTab()
    local vars = self.vars
    vars['fpsBtn']:registerScriptTapHandler(function() self:click_fpsBtn() end)
    vars['invenBtn']:registerScriptTapHandler(function() self:click_invenBtn() end)
    vars['allClearBtn']:registerScriptTapHandler(function() self:click_allClearBtn() end)
    vars['allDragonBtn']:registerScriptTapHandler(function() self:click_allDragonBtn() end)
    vars['allSlimeBtn']:registerScriptTapHandler(function() self:click_allSlimeBtn() end)
    vars['allFruitBtn']:registerScriptTapHandler(function() self:click_allFruitBtn() end)
    vars['allMaterialBtn']:registerScriptTapHandler(function() self:click_allMaterialBtn() end)
    vars['allRuneBtn']:registerScriptTapHandler(function() self:click_allRuneBtn() end)
    vars['allStaminaBtn']:registerScriptTapHandler(function() self:click_allStaminaBtn() end)
    vars['testCodeBtn']:registerScriptTapHandler(function() self:click_testCodeBtn() end)
    vars['testCodeBtn2']:registerScriptTapHandler(function() self:click_testCodeBtn2() end)
    vars['allEggBtn']:registerScriptTapHandler(function() self:click_allEggBtn() end)
    vars['addFpBtn']:registerScriptTapHandler(function() self:click_addFpBtn() end)
    vars['addRpBtn']:registerScriptTapHandler(function() self:click_addRpBtn() end)
    vars['uidCopyBtn']:registerScriptTapHandler(function() self:click_uidCopyBtn() end)
    vars['soundModuleBtn']:registerScriptTapHandler(function() self:click_soundModuleBtn() end)
    self:refresh_devTap()
end

-------------------------------------
-- function click_fpsBtn
-- @brief fps 출력
-------------------------------------
function UI_Setting:click_fpsBtn()
    local value = g_serverData:get('local', 'fps')
    g_serverData:applyServerData(not value, 'local', 'fps')
    g_serverData:applySetting()
    self:refresh_devTap()
end

-------------------------------------
-- function click_allClearBtn
-- @brief 모든 스테이지 오픈
-------------------------------------
function UI_Setting:click_allClearBtn()
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        UIManager:toastNotificationGreen('모든 스테이지 오픈!')
        UIManager:toastNotificationGreen('정상적인 적용을 위해 재시작을 권장합니다.')
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/manage/stage_clear')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', GAME_MODE_ADVENTURE) -- 모험모드를 뜻함
    ui_network:setParam('stage', 'all')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true) -- 통신 실패 시 취소 가능 여부
    ui_network:setReuse(false) -- 재사용 여부
    ui_network:request()
end

-------------------------------------
-- function click_allDragonBtn
-- @brief 모든 드래곤 추가
-------------------------------------
function UI_Setting:click_allDragonBtn()
    local uid = g_userData:get('uid')
    local table_dragon = TABLE:get('dragon')
    local t_list = {}
    for did,t_dragon in pairs(table_dragon) do
        --if (t_dragon['test'] == 1) then
            table.insert(t_list, did)
        --end
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
-- function click_allSlimeBtn
-- @brief 모든 슬라임 추가
-------------------------------------
function UI_Setting:click_allSlimeBtn()
    local uid = g_userData:get('uid')

    -- 아이템 테이블의 type이 slime인 행들을 읽어서 슬라임 추가
    local table_item = TableItem()
    local t_list = table_item:filterList('type', 'slime')

    local do_work

    local ui_network = UI_Network()
    ui_network:setReuse(true)
    ui_network:setUrl('/slimes/add')
    ui_network:setParam('uid', uid)

    do_work = function(ret)
        local t_data = t_list[1]
        
        if t_data then
            local item_id = t_data['item']
            local slime_id = t_data['did']
            table.remove(t_list, 1)
            local msg = '"' .. table_item:getValue(item_id, 't_name') .. '" 추가 중...'
            ui_network:setLoadingMsg(msg)
            ui_network:setParam('sid', slime_id)

            -- 아이템 테이블의 등급과 진화도로 슬라임을 추가
            ui_network:setParam('grade', t_data['grade'])
            ui_network:setParam('evolution', t_data['evolution'])
            ui_network:request()
        else
            ui_network:close()
            UIManager:toastNotificationGreen('모든 슬라임 추가!')
            UIManager:toastNotificationGreen('정상적인 적용을 위해 재시작을 권장합니다.')
            --self.m_bRestart = true
        end

        if ret and ret['slimes'] then
            g_slimesData:applySlimeData_list(ret['slimes'])
        end
    end
    ui_network:setSuccessCB(do_work)
    do_work()
end

-------------------------------------
-- function click_allFruitBtn
-- @brief 모든 열매 추가
-------------------------------------
function UI_Setting:click_allFruitBtn()
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
function UI_Setting:click_allMaterialBtn()
    local uid = g_userData:get('uid')

    local table_item = TableItem()
    local l_evolution_stone = table_item:filterTable('type', 'evolution_stone')
    local t_list = {}
    for id,_ in pairs(l_evolution_stone) do
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
            local name = table_item:getValue(id, 't_name')
            local msg = '"' .. name .. '" 추가 중...'
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
function UI_Setting:click_allRuneBtn()
    local uid = g_userData:get('uid')
    local t_list = TableItem:getRuneItemIDList()
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
            local msg = '"' .. tostring(id) .. '룬" 추가 중...'
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
-- function click_allStaminaBtn
-- @brief 모든 입장권 추가
-------------------------------------
function UI_Setting:click_allStaminaBtn()
    local l_stamina_list = {}
    local table_stamina_info = TABLE:get('table_stamina_info')
    for i,v in pairs(table_stamina_info) do
        table.insert(l_stamina_list, i)
    end

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        while (0 < #l_stamina_list) do
            co:work()
            local uid = g_userData:get('uid')

            local function success_cb(ret)
                if ret['user'] then
                    g_serverData:applyServerData(ret['user'], 'user')
                end
                g_topUserInfo:refreshData()
                co.NEXT()
            end

            local key = l_stamina_list[1]
            table.remove(l_stamina_list, 1)

            local ui_network = UI_Network()
            ui_network:setUrl('/users/update')
            ui_network:setParam('uid', uid)
            ui_network:setParam('act', 'increase')
            ui_network:setParam('staminas', key .. ',' .. 100)
            ui_network:setSuccessCB(function(ret) success_cb(ret) end)
            ui_network:setRevocable(false)
            ui_network:request()
            if co:waitWork() then return end
        end

        UIManager:toastNotificationGreen('모든 입장권 추가!')
        co:close()
    end

    Coroutine(coroutine_function)
end

-------------------------------------
-- function click_testCodeBtn
-- @brief 테스트 코드
-------------------------------------
function UI_Setting:click_testCodeBtn()
    ccdisplay('진동 테스트')
    cc.SimpleAudioEngine:getInstance():playVibrate(1000)
end

-------------------------------------
-- function click_testCodeBtn2
-- @brief 테스트 코드
-------------------------------------
function UI_Setting:click_testCodeBtn2()
    ccdisplay('로컬푸시 테스트, 앱 종료후 5초 뒤에 푸시가 옵니다.')
    PUSH_TEST = true
end

-------------------------------------
-- function click_allEggBtn
-- @brief 모든 알 추가
-------------------------------------
function UI_Setting:click_allEggBtn()
    local uid = g_userData:get('uid')
    local table_item = TableItem()
    local l_egg_list = table_item:filterList('type', 'egg')
    local t_list = {}
    for i,v in ipairs(l_egg_list) do
        local egg_id = v['item']
        table.insert(t_list, egg_id)
    end
    local do_work

    local ui_network = UI_Network()
    ui_network:setReuse(true)
    ui_network:setUrl('/users/manage')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'increase')
    ui_network:setParam('key', 'eggs')

    do_work = function(ret)
        local id = t_list[1]
        
        if id then
            table.remove(t_list, 1)
            local name = table_item:getValue(id, 't_name')
            local msg = '"' .. name .. '" 추가 중...'
            ui_network:setLoadingMsg(msg)
            ui_network:setParam('value', tostring(id) .. ',' .. tostring(1))
            ui_network:request()
        else
            ui_network:close()
            UIManager:toastNotificationGreen('모든 알 추가!')
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
-- function click_addFpBtn
-- @brief 우정포인트 100 추가
-------------------------------------
function UI_Setting:click_addFpBtn()
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:applyServerData(ret['user'], 'user')
        UIManager:toastNotificationGreen('우정포인트 100 증가!')
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/manage')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'increase')
    ui_network:setParam('key', 'fp')
    ui_network:setParam('value', 100)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(nil)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function click_addRpBtn
-- @brief 모든 인연 포인트 우편 발송
-------------------------------------
function UI_Setting:click_addRpBtn()
    local uid = g_userData:get('uid')
    local table_item = TableItem()
    local l_item_list = table_item:filterList('type', 'relation_point')
    local t_list = {}
    for i,v in ipairs(l_item_list) do
        local item_id = v['item']
        table.insert(t_list, item_id)
    end
    local do_work

    local ui_network = UI_Network()
    ui_network:setReuse(true)
    ui_network:setUrl('/manage/send_mail')
    ui_network:setParam('uid', uid)

    do_work = function(ret)
        local id = t_list[1]
        
        if id then
            table.remove(t_list, 1)
            local name = table_item:getValue(id, 't_name')
            local msg = '"' .. name .. '" 발송 중...'
            ui_network:setLoadingMsg(msg)
            ui_network:setParam('itemid', tostring(id) .. ';' .. tostring(100))
            ui_network:request()
        else
            ui_network:close()
            UIManager:toastNotificationGreen('모든 인연포인트 우편 발송!')
        end
    end
    ui_network:setSuccessCB(do_work)
    do_work()
end

-------------------------------------
-- function refresh_devTap
-- @brief "개발" 탭
-------------------------------------
function UI_Setting:refresh_devTap()
    local vars = self.vars

    -- fps
    if g_serverData:get('local', 'fps') then
        vars['fpsLabel']:setString('ON')
    else
        vars['fpsLabel']:setString('OFF')
    end

    -- new sound module
    if g_serverData:get('local', 'new_sound_module') then
        vars['soundModuleLabel']:setString('ON')
    else
        vars['soundModuleLabel']:setString('OFF')
    end
end

-------------------------------------
-- function click_invenBtn
-------------------------------------
function UI_Setting:click_invenBtn()
    UI_InvenDevApiPopup()
end

-------------------------------------
-- function click_uidCopyBtn
-------------------------------------
function UI_Setting:click_uidCopyBtn()
    if (not isWin32()) then return end
     
    local vars = self.vars
    local uid = g_userData:get('uid')

    PerpSocial:SDKEvent('clipboard_setText', tostring(uid), '', function() end)
    UIManager:toastNotificationGreen(Str('UID를 복사하였습니다.'))
end

-------------------------------------
-- function click_soundModuleBtn
-- @brief 신규 사운드 모듈 적용
-------------------------------------
function UI_Setting:click_soundModuleBtn()
    local value = g_serverData:get('local', 'new_sound_module')
    g_serverData:applyServerData(not value, 'local', 'new_sound_module')
    g_serverData:applySetting()
    self:refresh_devTap()
end