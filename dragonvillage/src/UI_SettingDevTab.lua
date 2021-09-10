-------------------------------------
-- function init_devTab
-------------------------------------
function UI_Setting:init_devTab()
    local vars = self.vars
    vars['fpsBtn']:registerScriptTapHandler(function() self:click_fpsBtn() end)
    vars['invenBtn']:registerScriptTapHandler(function() self:click_invenBtn() end)
    vars['allClearBtn']:registerScriptTapHandler(function() self:click_allClearBtn() end)
    
	vars['legendDragonBtn']:registerScriptTapHandler(function() self:click_allDragonBtn(5) end)
	vars['removeDragonBtn']:registerScriptTapHandler(function() self:click_removeDragonBtn() end)

    vars['allSlimeBtn']:registerScriptTapHandler(function() self:click_allSlimeBtn() end)
    vars['allFruitBtn']:registerScriptTapHandler(function() self:click_allFruitBtn() end)
    vars['allMaterialBtn']:registerScriptTapHandler(function() self:click_allMaterialBtn() end)
    vars['allRuneBtn']:registerScriptTapHandler(function() self:click_allRuneBtn() end)
    vars['selectRuneBtn']:registerScriptTapHandler(function() self:click_selectRuneBtn() end)
    vars['allStaminaBtn']:registerScriptTapHandler(function() self:click_allStaminaBtn() end)
    vars['allCostumeBtn']:registerScriptTapHandler(function() self:click_allCostumeBtn() end)
    vars['allEggBtn']:registerScriptTapHandler(function() self:click_allEggBtn() end)
    
    vars['addFpBtn']:registerScriptTapHandler(function() self:click_addFpBtn() end)
    vars['addRpBtn']:registerScriptTapHandler(function() self:click_addRpBtn() end)
    vars['uidCopyBtn']:registerScriptTapHandler(function() self:click_uidCopyBtn() end)
    vars['soundModuleBtn']:registerScriptTapHandler(function() self:click_soundModuleBtn() end)
    vars['benchmarkBtn']:registerScriptTapHandler(function() self:click_benchmarkBtn() end)
    vars['clanCacheResetBtn']:registerScriptTapHandler(function() self:click_clanCacheResetBtn() end)
    vars['setUidBtn']:registerScriptTapHandler(function() self:click_setUidBtn() end)
    vars['dayNightChangeBtn']:registerScriptTapHandler(function() self:click_changeDayNightBtn() end)
    vars['popupCacheResetBtn']:registerScriptTapHandler(function() self:click_popupCacheResetBtn() end)
    vars['lobbyGuideResetBtn']:registerScriptTapHandler(function() self:click_lobbyGuideResetBtn() end)
    vars['colosseumOldBtn']:registerScriptTapHandler(function() self:click_colosseumOldBtn() end)
    vars['colosseumTestBtn']:registerScriptTapHandler(function() self:click_colosseumTestBtn() end)
    vars['dailyInitBtn']:registerScriptTapHandler(function() self:click_dailyInitBtn() end)
    vars['eggSimulBtn']:registerScriptTapHandler(function() self:click_eggSimulBtn() end)
    vars['translationViewerBtn']:registerScriptTapHandler(function() self:click_translationViewerBtn() end)
    vars['presetDeckBtn']:registerScriptTapHandler(function() self:click_presetDeckBtn() end)
    
    vars['testCodeBtn']:registerScriptTapHandler(function() UI_SettingTestCode() end)
    
    vars['videoMakerBtn']:registerScriptTapHandler(function() 
        require('UI_VideoMaker')
        UI_VideoMaker()
    end)

    self:refresh_devTap()
end

-------------------------------------
-- function click_fpsBtn
-- @brief fps 출력
-------------------------------------
function UI_Setting:click_fpsBtn()
    local value = g_settingData:get('fps')
    g_settingData:applySettingData(not value, 'fps')
    g_settingData:applySetting()
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
    ui_network:setParam('stage', 'all')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true) -- 통신 실패 시 취소 가능 여부
    ui_network:setReuse(false) -- 재사용 여부
    ui_network:request()
end

-------------------------------------
-- function click_allDragonBtn
-- @brief 해당 태생등급 드래곤 추가
-------------------------------------
function UI_Setting:click_allDragonBtn(birthgrade)
    local uid = g_userData:get('uid')
    local table_dragon = TABLE:get('dragon')
    local t_list = {}
    for did,t_dragon in pairs(table_dragon) do
        if (t_dragon['birthgrade'] == birthgrade) then
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
-- function click_removeDragonBtn
-- @brief 1레벨 드래곤 모두 판매
-------------------------------------
function UI_Setting:click_removeDragonBtn()
    local uid = g_userData:get('uid')

	local function check_func(doid)
		local struct_dragon = g_dragonsData:getDragonDataFromUid(doid)
		
		if (not struct_dragon) then
			return false
		end

		-- 1렙 체크
		if (struct_dragon:getLv() > 1) then
			return false
		end

		-- 리더로 설정된 드래곤인지 체크
		if g_dragonsData:isLeaderDragon(doid) then
			return false
		end

		-- 콜로세움 정보  확인
		if g_colosseumData then
			local struct_user_info = g_colosseumData:getPlayerColosseumUserInfo() -- return : StructUserInfoColosseum
			if struct_user_info then
				-- 공격 덱
				local l_pvp_atk = struct_user_info:getAtkDeck_dragonList(true) -- param : use_doid
				if table.find(l_pvp_atk, doid) then
					return false
				end

				-- 방어 덱
				local l_pvp_def =struct_user_info:getDefDeck_dragonList(true) -- param : use_doid
				if table.find(l_pvp_def, doid) then
					return false
				end
			end
		end

		return true
	end

	--local l_remove_doid = {}
    local str_dragons = ''
	local dragon_dic = g_dragonsData:getDragonsList()
    local total_count = table.count(dragon_dic)
    local cur_count = 0


    for oid,v in pairs(dragon_dic) do
		if (check_func(oid)) then
			--table.insert(l_remove_doid, oid)
            str_dragons = str_dragons .. oid

            if (cur_count < total_count) then
                str_dragons = str_dragons .. ','
            end
		end
    end

    str_dragons = str_dragons:sub(1, -2)


    local ui_network = UI_Network()
    ui_network:setReuse(true)
    ui_network:setUrl('/dragons/del')
    ui_network:setParam('uid', uid)
	
	local msg = '드래곤 삭제 중...'
    ui_network:setLoadingMsg(msg)

    do_work = function(ret)
        ui_network:setParam('doid', str_dragons)
        ui_network:request()

        --[[
        local doid = l_remove_doid[1]
    
        if doid then
            table.remove(l_remove_doid, 1)

            ui_network:setParam('doid', doid)
            ui_network:request()
        else
            ui_network:close()
            UIManager:toastNotificationGreen('1레벨 드래곤 삭제!')
            UIManager:toastNotificationGreen('정상적인 적용을 위해 재시작을 권장합니다.')
        end

        if (ret and ret['deleted_dragon_ids']) then
            for _, doid in pairs(ret['deleted_dragon_ids']) do
                g_dragonsData:delDragonData(doid)
            end
        end]]
    end
    ui_network:setSuccessCB(function()
        ui_network:close()
        UIManager:toastNotificationGreen('1레벨 드래곤 삭제!')
        UIManager:toastNotificationGreen('정상적인 적용을 위해 재시작을 권장합니다.')
    end)
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
-- function click_selectRuneBtn
-- @brief 선택하여 룬 추가
-------------------------------------
function UI_Setting:click_selectRuneBtn()
    require('UI_RuneSelectDevApiPopup')
    UI_RuneSelectDevApiPopup()
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
            local api  
            -- 클랜던전은 update api로 충전이 안됨.
            if (key == 'cldg' or key == 'event_st') then
                api = '/users/manage'
                ui_network:setParam('act', 'update')
                ui_network:setParam('key', 'staminas')
                ui_network:setParam('value', key .. ',' .. 100)
            else
                api = '/users/update'
                ui_network:setParam('act', 'increase')
                ui_network:setParam('staminas', key .. ',' .. 100)
            end

            ui_network:setUrl(api)
            ui_network:setParam('uid', uid)
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
-- function click_allCostumeBtn
-- @brief 모든 코스튬 추가
-------------------------------------
function UI_Setting:click_allCostumeBtn()
    local l_costume_list = {}
    local table_stamina_info = TABLE:get('tamer_costume')
    for k,v in pairs(table_stamina_info) do
        table.insert(l_costume_list, k)
    end

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        while (0 < #l_costume_list) do
            co:work()
            local uid = g_userData:get('uid')

            local function success_cb(ret)
                if ret['user'] then
                    g_serverData:applyServerData(ret['user'], 'user')
                end
                g_topUserInfo:refreshData()
                co.NEXT()
            end

            local key = l_costume_list[1]
            table.remove(l_costume_list, 1)

            local ui_network = UI_Network()            
            local api = '/users/manage'
            ui_network:setParam('act', 'update')
            ui_network:setParam('key', 'costumes')
            ui_network:setParam('value', key .. ',' .. 1)
            ui_network:setUrl(api)
            ui_network:setParam('uid', uid)
            ui_network:setSuccessCB(function(ret) success_cb(ret) end)
            ui_network:setRevocable(false)
            ui_network:request()
            if co:waitWork() then return end
        end

        UIManager:toastNotificationGreen('모든 코스튬 추가!')
        co:close()
    end

    Coroutine(coroutine_function)
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
    if g_settingData:get('fps') then
        vars['fpsLabel']:setString('ON')
    else
        vars['fpsLabel']:setString('OFF')
    end

    -- new sound module
    local engine_mode = g_settingData:get('sound_module') or cc.SimpleAudioEngine:getInstance():getEngineMode()
    if engine_mode == 1 then
        vars['soundModuleLabel']:setString('ON')
    else
        vars['soundModuleLabel']:setString('OFF')
    end

    -- colosseum test
    if g_settingData:get('colosseum_test_mode') then
        vars['colosseumTestLabel']:setString('ON')
    else
        vars['colosseumTestLabel']:setString('OFF')
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

    SDKManager:copyOntoClipBoard(tostring(uid))
    UIManager:toastNotificationGreen(Str('UID를 복사하였습니다.'))
end

-------------------------------------
-- function click_soundModuleBtn
-- @brief 신규 사운드 모듈 적용
-------------------------------------
function UI_Setting:click_soundModuleBtn()
    local value = 1 - cc.SimpleAudioEngine:getInstance():getEngineMode()

    g_settingData:applySettingData(value, 'sound_module')
    g_settingData:applySetting()

    self:refresh_devTap()
end

-------------------------------------
-- function click_benchmarkBtn
-- @brief 벤치마크
-------------------------------------
function UI_Setting:click_benchmarkBtn()
    if true then
        self:unityAdsTest00()
        return
    end

    BenchmarkManager:getInstance()
    g_benchmarkMgr:setBenchmarkJson()
    g_benchmarkMgr:startStage()
end

-------------------------------------
-- function click_clanCacheResetBtn
-- @brief 클랜 캐시 초기화
-------------------------------------
function UI_Setting:click_clanCacheResetBtn()
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        UINavigator:closeClanUI()
        UIManager:toastNotificationRed(Str('클랜 캐시 정보가 초기화되었습니다.'))
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/manage/clan_reset')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function click_setUidBtn
-- @brief UID 설정
-------------------------------------
function UI_Setting:click_setUidBtn()
    local edit_box = UI_SimpleEditBoxPopup()
    edit_box:setPopupTitle(Str(''))
    edit_box:setPopupDsc(Str('UID 설정'))
    edit_box:setPlaceHolder(Str('UID를 입력하세요.'))
    edit_box:setMaxLength(50)

    local function confirm_cb(str)
        if (not str) or (str == '') then
            UIManager:toastNotificationRed('UID를 입력하세요.')
            return false
        end

        if (str == g_userData:get('uid')) then
            UIManager:toastNotificationRed('현재 UID와 동일합니다.')
            return false
        end

        return true
    end
    edit_box:setConfirmCB(confirm_cb)

    local function close_cb()
        if (edit_box.m_retType == 'ok') then
            local uid = edit_box.m_str

            if (confirm_cb(uid) == false) then
                return
            end

            g_localData:applyLocalData(uid, 'local', 'uid')
            --[[
            -- settingData에 있는 기록 삭제
            if (g_settingData) then
                g_settingData:resetSettingData()
            end
            --]]

            if (g_settingDeckData) then
                g_settingDeckData:resetAncientBestDeck()
            end

            CppFunctions:restart()
        end
    end
    edit_box:setCloseCB(close_cb)
end

-------------------------------------
-- function click_popupCacheResetBtn
-- @brief 낮/밤 교체
-------------------------------------
function UI_Setting:click_changeDayNightBtn()
    SKIP_CHECK_DAY_OR_NIGHT = true
    USE_NIGHT = not USE_NIGHT
    SceneLobby(true):runScene()
end

-------------------------------------
-- function click_popupCacheResetBtn
-- @brief 팝업 캐시 리셋
-------------------------------------
function UI_Setting:click_popupCacheResetBtn()
    local str_uid = g_userData:get('uid') and tostring(g_userData:get('uid')) or ''
    local weidel_offer_save_key = 'lobby_weidel_package_notice_' .. str_uid
    g_settingData:clearDataList('event_full_popup')
    g_settingData:applySettingData(-1, 'lobby_ingame_notice')
    g_settingData:applySettingData(-1, weidel_offer_save_key)
    UIManager:toastNotificationGreen('팝업 캐시가 초기화되었습니다!')
end

-------------------------------------
-- function click_lobbyGuideResetBtn
-- @brief 팝업 캐시 리셋
-------------------------------------
function UI_Setting:click_lobbyGuideResetBtn()
    g_settingData:clearDataList('lobby_guide_seen')
    LobbyGuideData:getInstance():clearLobbyGuideDataFile()
    LobbyPopupData:getInstance():clearLobbyPopupDataFile()
    UIManager:toastNotificationGreen('마을 도움말이 초기화되었습니다!')
end

-------------------------------------
-- function click_colosseumOldBtn
-- @brief 기존 콜로세움 진입
-------------------------------------
function UI_Setting:click_colosseumOldBtn()
	UINavigator:goTo('colosseum_old')
end

-------------------------------------
-- function click_colosseumTestBtn
-- @brief 콜로세움 테스트 모드
-------------------------------------
function UI_Setting:click_colosseumTestBtn()
	local value = g_settingData:get('colosseum_test_mode')
    g_settingData:applySettingData(not value, 'colosseum_test_mode')
    g_settingData:applySetting()
    self:refresh_devTap()
end

-------------------------------------
-- function click_dailyInitBtn
-- @brief 일일 초기화 
-------------------------------------
function UI_Setting:click_dailyInitBtn()
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        UIManager:toastNotificationGreen('초기화 성공~ 로비 재진입 또는 재시작 해주세요.')
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/manage/init_user')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', 'daily')
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function click_presetDeckBtn
-- 사전 설정된 덱
-------------------------------------
function UI_Setting:click_presetDeckBtn()
    local edit_box = UI_SimpleEditBoxPopup()
    edit_box:setPopupTitle(Str(''))
    edit_box:setPopupDsc(Str('고정 덱 설정'))
    edit_box:setPlaceHolder(Str('설정할 덱 이름을 입력하시오'))
    edit_box:setMaxLength(100)

    local function confirm_cb(str)
        if (isNullOrEmpty(str)) then
            UIManager:toastNotificationRed('잘못된 덱 이름 입력 :: ' .. tostring(str))
            return false
        end

        return true
    end

    edit_box:setConfirmCB(confirm_cb)

    local function close_cb()
        if (edit_box.m_retType == 'ok') then
            local deck_str = edit_box.m_str

            if (isNullOrEmpty(deck_str) == true) then
                UIManager:toastNotificationRed('입력한 덱 이름이 없어서 default로 저장합니다.')
            end

            if (confirm_cb(deck_str) == false) then return end

            -- 유저 ID
            local uid = g_userData:get('uid')

            -- 네트워크 통신
            local ui_network = UI_Network()
            ui_network:setUrl('/manage/set_preset_deck')
            ui_network:setParam('uid', uid)
            ui_network:setParam('deck_name', deck_str)

            ui_network:setMethod('POST')
            ui_network:setSuccessCB(success_cb)
            ui_network:setFailCB(fail_cb)
            ui_network:setRevocable(true)
            ui_network:setReuse(false)
            ui_network:request()

        end
    end

    edit_box:setCloseCB(close_cb)
end

-------------------------------------
-- function click_eggSimulBtn
-------------------------------------
function UI_Setting:click_eggSimulBtn()
    --UI_EggSimulator()
    UI_ClanWarLobby()
end

-------------------------------------
-- function click_translationViewerBtn
-------------------------------------
function UI_Setting:click_translationViewerBtn()
    UI_TranslationViewer()
end


-------------------------------------
-- function testFunction_cafebazaarFontTest
-- @brief 카페 바자(이란) 빌드에서 폰트 적용 확인
-- @sgkim 2019.09.24
-------------------------------------
function UI_Setting:testFunction_cafebazaarFontTest()
    ccdisplay('UI_Setting:testFunction_cafebazaarFontTest()')

    local ui = UI()
    ui:load('popup_01.ui')

    local vars = ui.vars
    vars['dscLabel']:setVisible(false)
    vars['cancelBtn']:setVisible(false)
    vars['okBtn']:setVisible(false)

    vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)

    local root = ui.root
    local text = '시스텐 폰트 테스트'
    text = 'زبان در حال حاضر در اماده سازی است'
    local font = 'font/iran.ttf'
    local fontSize = 40
    local dimensions = cc.size(1000, 100)
    local hAlignment = cc.TEXT_ALIGNMENT_CENTER
    local vAlignment = cc.VERTICAL_TEXT_ALIGNMENT_CENTER

    local start_pos_y = 150
    local interval_pos_y = 50

    -- 시스템 폰트 라벨 생성
    do
        font = ''
        local idx = 1
        local label = cc.Label:createWithSystemFont(text, font, fontSize, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end

    -- 시스템 폰트 라벨 생성
    do
        font = 'font/common_font_01.ttf'
        local idx = 2
        local label = cc.Label:createWithSystemFont(text, font, fontSize, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end

    -- 시스템 폰트 라벨 생성
    do
        font = 'font/iran.ttf'
        local idx = 3
        local label = cc.Label:createWithSystemFont(text, font, fontSize, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end


    text = '다람쥐 헌 쳇바퀴에 타고파. 12345'
    -- 시스템 폰트 라벨 생성
    do
        font = ''
        local idx = 4
        local label = cc.Label:createWithSystemFont(text, font, fontSize, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end

    -- 시스템 폰트 라벨 생성
    do
        font = 'font/common_font_01.ttf'
        local idx = 5
        local label = cc.Label:createWithSystemFont(text, font, fontSize, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end

    -- 시스템 폰트 라벨 생성
    do
        font = 'font/iran.ttf'
        local idx = 6
        local label = cc.Label:createWithSystemFont(text, font, fontSize, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end


    UIManager:open(ui, UIManager.SCENE)
end

-------------------------------------
-- function testFunction_cafebazaarFontTest_TTF
-- @brief 카페 바자(이란) 빌드에서 폰트 적용 확인
-- @sgkim 2019.09.24
-------------------------------------
function UI_Setting:testFunction_cafebazaarFontTest_TTF()
    ccdisplay('UI_Setting:testFunction_cafebazaarFontTest_TTF()')

    local ui = UI()
    ui:load('popup_01.ui')

    local vars = ui.vars
    vars['dscLabel']:setVisible(false)
    vars['cancelBtn']:setVisible(false)
    vars['okBtn']:setVisible(false)

    vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)

    local root = ui.root
    local text = '시스텐 폰트 테스트'
    text = 'زبان در حال حاضر در اماده سازی است'
    local font = 'font/iran.ttf'
    local fontSize = 40
    local stroke_tickness = 0
    local dimensions = cc.size(1000, 100)
    local hAlignment = cc.TEXT_ALIGNMENT_CENTER
    local vAlignment = cc.VERTICAL_TEXT_ALIGNMENT_CENTER

    local start_pos_y = 150
    local interval_pos_y = 50

    -- 시스템 폰트 라벨 생성
    do
        font = ''
        local idx = 1
        local label = cc.Label:createWithTTF(text, font, fontSize, stroke_tickness, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end

    -- 시스템 폰트 라벨 생성
    do
        font = 'font/common_font_01.ttf'
        local idx = 2
        local label = cc.Label:createWithTTF(text, font, fontSize, stroke_tickness, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end

    -- 시스템 폰트 라벨 생성
    do
        font = 'font/iran.ttf'
        local idx = 3
        local label = cc.Label:createWithTTF(text, font, fontSize, stroke_tickness, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end


    text = '다람쥐 헌 쳇바퀴에 타고파. 12345'
    -- 시스템 폰트 라벨 생성
    do
        font = ''
        local idx = 4
        local label = cc.Label:createWithTTF(text, font, fontSize, stroke_tickness, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end

    -- 시스템 폰트 라벨 생성
    do
        font = 'font/common_font_01.ttf'
        local idx = 5
        local label = cc.Label:createWithTTF(text, font, fontSize, stroke_tickness, dimensions, hAlignment, vAlignment)
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end

    -- 시스템 폰트 라벨 생성
    do
        font = 'font/iran.ttf'
        local idx = 6
        if label then
            label:setPositionY(start_pos_y - ((idx - 1) * interval_pos_y))
            label:setDockPoint(cc.p(0.5, 0.5))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            root:addChild(label, 100)
        end
    end


    UIManager:open(ui, UIManager.SCENE)
end


-------------------------------------
-- function testFunction_AdmobMediation
-- @brief Admob Mediation에 Tapjoy 네트워크 추가 테스트
-- @sgkim 2019.10.08
-------------------------------------
function UI_Setting:testFunction_AdmobMediation()
    local ad_type = AD_TYPE['TEST']

    local function result_cb(ret, info)
        ccdisplay('ret : ' .. tostring(ret))
        ccdisplay('info : ' .. tostring(info))

        -- 광고 시청 완료 -> 보상 처리
        if (ret == 'finish') then

        -- 광고 시청 취소
        elseif (ret == 'cancel') then

        -- 광고 에러
        elseif (ret == 'error') then

        end
    end

    ccdisplay('UI_Setting:testFunction_AdmobMediation()')
    AdSDKSelector:showByAdType(ad_type, result_cb)
end