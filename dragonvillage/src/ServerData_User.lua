-------------------------------------
---@class ServerData_User
---@return ServerData_User
-------------------------------------
ServerData_User = class({
        m_serverData = 'ServerData',
        m_tDeviceInfo = 'table',
        m_dropInfo = 'table',
        -- device_info_json은 android에서 아래와 같은 형태로 넘어옴
        -- 2017-17-08-24 sgkim
        --{
        --    ['OS_VERSION']='3.10.61-11396000';
        --    ['DISPLAY']='NRD90M.N920SKSU2DQE1';
        --    ['MANUFACTURER']='samsung';
        --    ['VERSION_SDK_INT']=24;
        --    ['desc']='samsung SM-N920S(Android 7.0, API 24)';
        --    ['VERSION_RELEASE']='7.0';
        --    ['DEVICE']='noblelteskt';
        --    ['BOARD']='universal7420';
        --    ['VERSION_INCREMENTAL']='N920SKSU2DQE1';
        --    ['BRAND']='samsung';
        --}
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_User:init(server_data)
    self.m_serverData = server_data

    self.m_dropInfo = {}
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_User:get(...)
    return self.m_serverData:get('user', ...)
end

-------------------------------------
-- function getRef
-------------------------------------
function ServerData_User:getRef(...)
    return self.m_serverData:getRef('user', ...)
end

-------------------------------------
-- function applyServerData
-------------------------------------
function ServerData_User:applyServerData(data, ...)
    return self.m_serverData:applyServerData(data, 'user', ...)
end

-------------------------------------
-- function getFruitList
-- @brief 보유중인 열매 리스트 리턴(가방에서 사용)
-------------------------------------
function ServerData_User:getFruitList(is_all)
    local is_all = is_all or false
    local l_fruis = self:getRef('fruits')

    -- key가 item_id(=fruit_id)이고 value가 count인 리스트 생성
    local l_ret = {}
    for i,v in pairs(l_fruis) do
        local fruit_id = tonumber(i)
        local count = v

        local t_data = {}
        t_data['fid'] = fruit_id
        t_data['count'] = count
        if (count > 0) then
            table.insert(l_ret, t_data)
        end
    end

    -- 소유하지 않은 열매도 count 0으로 만듬
    if (is_all) then    
        l_ret = self:makeEmptyData(l_ret, 'fruit')
    end

    return l_ret
end

-------------------------------------
-- function getFruitCount
-- @brief 보유중인 열매 갯수 리턴
-------------------------------------
function ServerData_User:getFruitCount(fruit_id)
    local fruit_id = tostring(fruit_id)
    local count = self:get('fruits', fruit_id) or 0
    return count
end

-------------------------------------
-- function getResetFruitCount
-- @brief 망각의 열매 갯수 리턴
-------------------------------------
function ServerData_User:getResetFruitCount()
    local fruit_id = self:getResetFruitID()
    return self:getFruitCount(fruit_id)
end

-------------------------------------
-- function getResetFruitID
-- @brief 망각의 열매 ID
-------------------------------------
function ServerData_User:getResetFruitID()
    -- 망각의 열매 id : 702009
    return 702009
end

-------------------------------------
-- function getEvolutionStoneList
-- @brief 보유중인 진화석 리스트 리턴(가방에서 사용)
-------------------------------------
function ServerData_User:getEvolutionStoneList(is_all)
    local is_all = is_all or false
    local l_evolution_stone = self:getRef('evolution_stones')

    -- key가 item_id(=esid)이고 value가 count인 리스트 생성
    local l_ret = {}
    for i,v in pairs(l_evolution_stone) do
        local evolution_stone_id = tonumber(i)
        local count = v

        local t_data = {}
        t_data['esid'] = evolution_stone_id
        t_data['count'] = count
        if (count > 0) then
            table.insert(l_ret, t_data)
        end
    end

    if (is_all) then
        l_ret = self:makeEmptyData(l_ret, 'evolution_stones')
    end

    return l_ret
end

-------------------------------------
-- function getEvolutionStoneCount
-- @brief 보유중인 진화재료 갯수 리턴
-------------------------------------
function ServerData_User:getEvolutionStoneCount(evolution_stone_id)
    local evolution_stone_id = tostring(evolution_stone_id)
    local count = self:get('evolution_stones', evolution_stone_id) or 0
    return count
end

-------------------------------------
-- function getTransformList
-- @brief 보유중인 외형 변환 리스트 리턴(가방에서 사용)
-------------------------------------
function ServerData_User:getTransformList(is_all)
    local is_all = is_all or false
    local l_transform = self:getRef('transform_materials')

    -- key가 item_id(=material_id)이고 value가 count인 리스트 생성
    local l_ret = {}
    for k,v in pairs(l_transform) do
        local material_id = tonumber(k)
        local count = v

        local t_data = {}
        t_data['mid'] = material_id
        t_data['count'] = count
        if (count > 0) then
            table.insert(l_ret, t_data)
        end
    end

    if (is_all) then
        l_ret = self:makeEmptyData(l_ret, 'transform')
    end

    return l_ret
end

-------------------------------------
-- function getTransformMaterialCount
-- @brief 보유중인 외형 변환 재료 갯수 리턴
-------------------------------------
function ServerData_User:getTransformMaterialCount(material_id)
    local material_id = tostring(material_id)
    local count = self:get('transform_materials', material_id) or 0
    return count
end

-------------------------------------
-- function getAttrMasteryMaterialCount
-- @brief 속성별 특성 재료 갯수
-------------------------------------
function ServerData_User:getAttrMasteryMaterialCount(material_id)
    local material_id = tostring(material_id)
    return self:get('mastery_materials', material_id) or 0
end

-------------------------------------
-- function makeEmptyData
-- @brief 보유하지 않은 아이템도 count 0으로 생성 (진화재료, 열매, 외형변환)
-------------------------------------
function ServerData_User:makeEmptyData(l_ret, type)
    local key
    local base_item_id
    local map_id = {}
      
    if (type == 'evolution_stones') then
        key = 'esid'
        base_item_id = 7011
        -- 진화재료는 속성별 아이템 말고 전체 아이템 따로 추가
        map_id['701011'] = 0
        map_id['701012'] = 0
        map_id['701013'] = 0
        map_id['701014'] = 0

    elseif (type == 'fruit') then
        key = 'fid'
        base_item_id = 7020

    elseif (type == 'transform') then
        key = 'mid'
        base_item_id = 7050
    end

    -- 속성별로 
    for attr_no = 1, 5 do
        -- 4단계
        for idx = 1, 4 do
            local tar_id = string.format('%d%d%d', base_item_id, idx, attr_no)
            map_id[tar_id] = 0
        end
    end

    for tar_id, _ in pairs(map_id) do
        local tar_id = tonumber(tar_id)
        local is_exist = false

        for i,v in ipairs(l_ret) do
            local check_id = v[key]
            if (check_id == tar_id) then
                is_exist = true
                break
            end
        end

        if (not is_exist) then
            local t_data = {}
            t_data[key] = tar_id
            t_data['count'] = 0
            table.insert(l_ret, t_data)
        end
    end

    return l_ret
end

-------------------------------------
-- function getUserLevelInfo
-- @brief
-------------------------------------
function ServerData_User:getUserLevelInfo()
    local table_user_level = TableUserLevel()

    local lv = g_userData:get('lv')
    local exp = g_userData:get('exp')
    local percentage = table_user_level:getUserLevelExpPercentage(lv, exp)

    return lv, exp, percentage
end

-------------------------------------
-- function getFruitPackCount
-- @brief 인벤에서 슬롯을 차지하는 열매 갯수
-------------------------------------
function ServerData_User:getFruitPackCount()
    local l_evolution_stone = self:getRef('fruits')

    local count = 0
    for i,v in pairs(l_evolution_stone) do
        if (0 < v) then
            count = (count + 1)
        end
    end

    return count
end

-------------------------------------
-- function getEvolutionStonePackCount
-- @brief 인벤에서 슬롯을 차지하는 진화석 갯수
-------------------------------------
function ServerData_User:getEvolutionStonePackCount()
    local l_evolution_stone = self:getRef('evolution_stones')

    local count = 0
    for i,v in pairs(l_evolution_stone) do
        if (0 < v) then
            count = (count + 1)
        end
    end

    return count
end

-------------------------------------
-- function getDragonGiftTime
-- @brief 드래곤이 선물을 주는 시간
-------------------------------------
function ServerData_User:getDragonGiftTime()
    return self:get('lobby_gift_box_at') / 1000
end

-------------------------------------
-- function requestDragonGift
-- @brief 드래곤에게 선물을 요구
-------------------------------------
function ServerData_User:requestDragonGift(cb_func)
    -- 파라미터
    local uid = self:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- 받은 아이템 처리
        g_serverData:networkCommonRespone_addedItems(ret)
		-- 선물 받을 수 있는 시간 갱신
		self:applyServerData(ret['lobby_gift_box_at'], 'lobby_gift_box_at')

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/lobby/gift')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	ui_network:hideLoading()
end

-------------------------------------
-- function getTicketList
-- @brief 보유중인 티켓 리스트 리턴(가방에서 사용)
-------------------------------------
function ServerData_User:getTicketList()
    local l_tickets = self:getRef('tickets')

    -- key가 item_id(=ticket_id)이고 value가 count인 리스트 생성
    local l_ret = {}
    for i,v in pairs(l_tickets) do
        local ticket_id = tonumber(i)
        local count = v

        local t_data = {}
        t_data['ticket_id'] = ticket_id
        t_data['count'] = count
        if (count > 0) then
            table.insert(l_ret, t_data)
        end
    end

    return l_ret
end

-------------------------------------
-- function isDragonSkinOpened
-- @brief 보유중인 스킨인지 체크
-------------------------------------
function ServerData_User:isDragonSkinOpened(skin_id)
    local m_dragon_skins = self:getRef('dragon_skins')

    if m_dragon_skins[tostring(skin_id)] == nil then
        return false
    end

    if m_dragon_skins[tostring(skin_id)] == 0 then
        return true
    end

    return true
end

-------------------------------------
-- function getTicketCOunt
-- @brief 보유 중인 티켓 갯수 리턴
-------------------------------------
function ServerData_User:getTicketCOunt(ticket_id)
    local ticket_id = tostring(ticket_id)
    local count = self:get('tickets', ticket_id) or 0
    return count
end

-------------------------------------
-- function getTicketPackCount
-- @brief 인벤에서 슬롯을 차지하는 티켓 갯수
-------------------------------------
function ServerData_User:getTicketPackCount()
    local l_tickets = self:getRef('tickets')

    local count = 0
    for i,v in pairs(l_tickets) do
        if (0 < v) then
            count = (count + 1)
        end
    end

    return count
end

-------------------------------------
-- function request_changeNick
-------------------------------------
function ServerData_User:request_changeNick(mid, code, nick, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 에러코드 처리
    local function result_cb(ret)
        if (ret['status'] == -1126) then
            local msg = Str('이미 존재하는 닉네임입니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return true -- 자체적으로 통신 처리를 완료했다는 뜻
        end
    end

    -- 콜백 함수
    local function success_cb(ret)
        -- nickname 적용
        self:applyServerData(nick, 'nick')
        
        -- 닉네임 최초 1회 변경했는지 여부값 갱신
        if (ret['first_nickchange']) then
            self:applyServerData(ret['first_nickchange'], 'first_nickchange')
        end

        -- 채팅 서버에 변경사항 적용
        g_lobbyChangeMgr:globalUpdatePlayerUserInfo()

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/nick/change')
    ui_network:setParam('uid', uid)
	ui_network:setParam('nick', nick)
    ui_network:setParam('mid', mid)
    ui_network:setParam('code', code)
    ui_network:setResponseStatusCB(result_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getTitleID
-- @biref 칭호 ID
-------------------------------------
function ServerData_User:getTitleID()
    return self:get('tamer_title')
end

-------------------------------------
-- function getTamerTitleStr
-- @biref 칭호 받아오기
-------------------------------------
function ServerData_User:getTamerTitleStr()
    local tamer_title_id = self:get('tamer_title')
    return TableTamerTitle:getTamerTitleStr(tamer_title_id)
end

-------------------------------------
-- function request_getTitleList
-------------------------------------
function ServerData_User:request_getTitleList(cb_func)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        if (cb_func) then
            cb_func(ret['tamer_title']) -- 이것은 리스트
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/tamer_title_info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_setTitle
-------------------------------------
function ServerData_User:request_setTitle(title_id, cb_func)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 바뀐 타이틀 저장
        self:applyServerData(ret['tamer_title'], 'tamer_title')

        -- 채팅 서버에 변경사항 적용
        g_lobbyChangeMgr:globalUpdatePlayerUserInfo()

        if (cb_func) then
            cb_func()
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/tamer_title_set')
    ui_network:setParam('uid', uid)
    ui_network:setParam('title_id', title_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end



-------------------------------------
-- function getReinforcePoint
-- @brief 강화포인트 갯수
-------------------------------------
function ServerData_User:getReinforcePoint(item_id)
	return self:get('reinforce_point')[tostring(item_id)] or 0
end

-------------------------------------
-- function isFirstNickChange
-- @brief 닉네임 변경 가능 여부 리턴(첫 로그인 시, 무료로 1회 변경 가능)
-- @brief login통신에서 받는 first_nickchange = 1일 경우 return true
-------------------------------------
function ServerData_User:isFirstNickChange()
    local first_nick_change = g_serverData:get('user', 'first_nickchange')
    return (first_nick_change == 1)
end

-------------------------------------
-- function setDeviceInfoTable
-------------------------------------
function ServerData_User:setDeviceInfoTable(t_data)
    self.m_tDeviceInfo = t_data or {}
end

-------------------------------------
-- function getDeviceInfoTable
-------------------------------------
function ServerData_User:getDeviceInfoTable()
    return self.m_tDeviceInfo or {}
end

-------------------------------------
-- function getDeviceInfoByKey
-------------------------------------
function ServerData_User:getDeviceInfoByKey(key)
    local t_data = self:getDeviceInfoTable()

    return t_data[key]
end

-------------------------------------
-- function getiOSMajorVersion
--[[ @breif
    Android : SDK_INT, api level .. like 27, 30
    iOS : Major version .. like 13, 14
]]
-------------------------------------
function ServerData_User:getOSVersion()
    local t_data = self:getDeviceInfoTable()

    -- iOS
    if (CppFunctions:isIos()) then
        -- systemVersion
        local system_version = g_userData:getDeviceInfoByKey('systemVersion')
        if (type(system_version) ~= 'string') then
            return 0
        end

        -- major버전을 얻어옴
        local l_version = pl.stringx.split(system_version, '.')
        local major_version = tonumber(l_version[1])
        if (major_version == nil) then
            return 0
        end

        return major_version

    -- Android
    elseif (CppFunctions:isAndroid()) then
        return t_data['VERSION_SDK_INT']

    end

    return 0    
end

-------------------------------------
-- function response_userInfo
-------------------------------------
function ServerData_User:response_userInfo(ret, t_result_ref)
    local user_levelup_data = t_result_ref['user_levelup_data']

    -- 이전 레벨과 경험치
    user_levelup_data['prev_lv'] = self:get('lv')
    user_levelup_data['prev_exp'] = self:get('exp')

    do -- 서버에서 넘어온 레벨과 경험치 적용
        if ret['lv'] then
            self:applyServerData(ret['lv'], 'lv')

            -- 채팅 서버에 변경사항 적용
            g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
        end

        if ret['exp'] then
            self:applyServerData(ret['exp'], 'exp')
        end
    end

    -- 현재 레벨과 경험치
    user_levelup_data['curr_lv'] = self:get('lv')
    user_levelup_data['curr_exp'] = self:get('exp')

    -- 현재 레벨의 최대 경험치
    local table_user_level = TableUserLevel()
    local lv = self:get('lv')
    local curr_max_exp = table_user_level:getReqExp(lv)
    user_levelup_data['curr_max_exp'] = curr_max_exp

    -- 최대 레벨 여부
    user_levelup_data['is_max_level'] = (curr_max_exp == 0)

    do -- 추가 경험치 총량
        local low_lv = user_levelup_data['prev_lv']
        local low_lv_exp = user_levelup_data['prev_exp']
        local high_lv = user_levelup_data['curr_lv']
        local high_lv_exp = user_levelup_data['curr_exp']
        user_levelup_data['add_exp'] = table_user_level:getBetweenExp(low_lv, low_lv_exp, high_lv, high_lv_exp)
    end    

    -- 레벨이 아닌 다른 컨텐츠 오픈 조건
    local t_content_open = t_result_ref['content_open']
    if (t_content_open) then
        do -- 시험의 탑 오픈 정보
            local open = ret['attr_tower_open']
            if (open and open == true) then
                t_content_open['open'] = open
                self:applyServerData(open, 'attr_tower_open')
            end
        end

        do -- 고대 유적 던전 오픈 정보
            local open = ret['ruin_open']
            if (open and open == true) then
                t_content_open['open'] = open
            end
        end
    end

    -- 레벨이 변경되었을 경우 Tapjoy유저 레벨 정보를 갱신하기 위해 호출
    if (user_levelup_data['prev_lv'] ~= user_levelup_data['curr_lv']) then
        -- @analytics (Tapjoy)
        Analytics:userInfo()

        -- @mskim 20.09.14 레벨업 패키지 출력에도 사용함
        g_personalpackData:push(PACK_LV_UP, user_levelup_data['curr_lv'])
    end
end

-------------------------------------
-- function response_vipInfo
-------------------------------------
function ServerData_User:response_vipInfo(ret)
    -- vip index : 1-Gold, 2-VIP, 3-SVIP
    local special_state = ret['special_state']

    if (special_state and (special_state ~= '')) then
        self:applyServerData(special_state, 'special_state')
    end
end

-------------------------------------
-- function getVipInfo
-- param key : 2021, 2022, ...
-------------------------------------
function ServerData_User:getVipInfo(key)
    return self:get('special_state', key)
end


-------------------------------------
-- function response_ingameDropInfo
--   "ingame_drop_stats_daily":{
--     "max_amethyst":10000,
--     "hours":0,
--     "play_cnt":1,
--     "gold":1211,
--     "cash":14,
--     "max_gold":1000000,
--     "amethyst":14,
--     "max_cash":10000
-------------------------------------
function ServerData_User:response_ingameDropInfo(ret)
    local drop_info = ret['ingame_drop_stats_daily']

    if (drop_info) then
        self.m_dropInfo = drop_info
    end
end

-------------------------------------
-- function getDropInfoGold
-- return number
-------------------------------------
function ServerData_User:getDropInfoGold()
    if self.m_dropInfo then
        return self.m_dropInfo['gold']
    end
end

-------------------------------------
-- function getDropInfoGold
-- return number
-------------------------------------
function ServerData_User:getDropInfoMaxGold()
    if self.m_dropInfo then
        return self.m_dropInfo['max_gold']
    end
end

-------------------------------------
-- function getDropInfoGold
-- return number
-------------------------------------
function ServerData_User:getDropInfoDia()
    if self.m_dropInfo then
        return self.m_dropInfo['cash']
    end
end

-------------------------------------
-- function getDropInfoGold
-- return number
-------------------------------------
function ServerData_User:getDropInfoMaxDia()
    if self.m_dropInfo then
        return self.m_dropInfo['max_cash']
    end
end

-------------------------------------
-- function getDropInfoGold
-- return number
-------------------------------------
function ServerData_User:getDropInfoAmethyst()
    if self.m_dropInfo then
        return self.m_dropInfo['amethyst']
    end
end
-------------------------------------
-- function getDropInfoGold
-- return number
-------------------------------------
function ServerData_User:getDropInfoMaxAmethyst()
    if self.m_dropInfo then
        return self.m_dropInfo['max_amethyst']
    end
end

-------------------------------------
-- function getDropInfoItemByType
-- return number
-------------------------------------
function ServerData_User:getDropInfoItemByType(item_type)
    if self.m_dropInfo then
        return self.m_dropInfo[item_type]
    end
end

-------------------------------------
-- function getDropInfoMaxItemByType
-- return number
-------------------------------------
function ServerData_User:getDropInfoMaxItemByType(item_type)
    if self.m_dropInfo then
        return self.m_dropInfo['max_' .. item_type]
    end
end


-------------------------------------
-- function request_termsInfo
-------------------------------------
function ServerData_User:request_termsInfo(success_cb, fail_cb)
    -- 유저 ID
    local uid = g_localData:get('local', 'uid')

    local function success(ret)
        -- ret['terms'] = 0 (동의 x) or 1 (동의 O)

        local need_agree = (ret['terms'] == 0)

        if success_cb then
            success_cb(need_agree)
        end
    end

    
    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/terms_info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_termsAgree
-------------------------------------
function ServerData_User:request_termsAgree(success_cb, fail_cb)
    -- 유저 ID
    local uid = g_localData:get('local', 'uid')

    local function success(ret)
        -- ret['terms'] = 0 (동의 x) or 1 (동의 O)

        local need_agree = (ret['terms'] == 0)

        if success_cb then
            success_cb(need_agree)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/terms_agree')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_termsAgree
-------------------------------------
function ServerData_User:request_checkDeletedUserID(success_cb, fail_cb)
        -- 유저 ID
        local uid = g_localData:get('local', 'uid')

        local function success(ret)
            local result_uid = ret['uid']

            g_localData:applyLocalData(result_uid, 'local', 'uid')
    
            if success_cb then
                success_cb(ret)
            end
        end
    
        -- 네트워크 통신 UI 생성
        local ui_network = UI_Network()
        ui_network:setUrl('/pre_login')
        ui_network:setParam('uid', uid)
        ui_network:setSuccessCB(success)
        ui_network:setFailCB(fail_cb)
        ui_network:setRevocable(true)
        ui_network:setReuse(false)
        ui_network:request()
end