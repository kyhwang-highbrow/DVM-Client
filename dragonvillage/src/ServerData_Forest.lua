-------------------------------------
-- class ServerData_Forest
-------------------------------------
ServerData_Forest = class({
        m_serverData = 'ServerData',
        m_happyRate = 'number',
        m_tStuffInfo = 'table',
        m_tDragonStruct = 'table',
        m_extensionMaxLV = 'number', -- 드래곤의 숲 확장 최대 레벨

        m_hasReward = 'bool',

        m_canHappy = 'bool', -- draogn/happy 호출 가능 여부
    })


local _instance = nil
-------------------------------------
-- function getInstance
-------------------------------------
function ServerData_Forest:getInstance()
    if _instance then
        return _instance
    end

    _instance = ServerData_Forest()
    return _instance
end

-------------------------------------
-- function init
-------------------------------------
function ServerData_Forest:init()
    self.m_tStuffInfo = {}
    self.m_tDragonStruct = {}
    self.m_canHappy = true
end

-------------------------------------
-- function getMyUserInfo
-------------------------------------
function ServerData_Forest:getMyUserInfo()
    local t_user_info = 
    {
        ['lv'] = g_userData:get('lv'),
        ['tamer'] = g_tamerData:getCurrTamerID(),
        ['tamer_title'] = g_userData:getTitleID(),
        ['nick'] = g_userData:get('nick'),
        ['leader'] = g_dragonsData:getLeaderDragon(),
        ['costume_id'] = g_tamerCostumeData:getCostumeID(),
        ['arena_new_last_tier'] = g_arenaNewData.m_playerUserInfo.m_lastTier,
    }

    return StructUserInfoForest:create(t_user_info)
end

-------------------------------------
-- function getMyDragons
-------------------------------------
function ServerData_Forest:getMyDragons()
    return self.m_tDragonStruct
end

-------------------------------------
-- function getStuffInfo
-------------------------------------
function ServerData_Forest:getStuffInfo()
    return self.m_tStuffInfo
end

-------------------------------------
-- function getExtensionLV
-------------------------------------
function ServerData_Forest:getExtensionLV()
    return self.m_tStuffInfo['extension']['stuff_lv']
end

-------------------------------------
-- function getExtensionMaxLV
-- @brief 드래곤의 숲 확장 최대 레벨
-------------------------------------
function ServerData_Forest:getExtensionMaxLV()
    if (not self.m_extensionMaxLV) then
        self.m_extensionMaxLV = TableForestStuffLevelInfo:getExtensionMaxLV()
    end

    return self.m_extensionMaxLV
end

-------------------------------------
-- function getHappy
-------------------------------------
function ServerData_Forest:getHappy()
    return self.m_happyRate
end

-------------------------------------
-- function canHappy
-------------------------------------
function ServerData_Forest:canHappy()
    return self.m_canHappy
end

-------------------------------------
-- function getMaxDragon
-------------------------------------
function ServerData_Forest:getMaxDragon()
    local lv = self.m_tStuffInfo['extension']['stuff_lv']
    local max_cnt = TableForestStuffLevelInfo:getDragonMaxCnt(lv) or 0
    return max_cnt
end










-------------------------------------
-- function request_myForestInfo
-------------------------------------
function ServerData_Forest:request_myForestInfo(finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        self:response_forestInfo(ret, finish_cb)
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/forest/get/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_forestInfo
-------------------------------------
function ServerData_Forest:response_forestInfo(t_ret, finish_cb)
    -- 공용 드래곤의 숲 정보
	if (t_ret['forest_info']) then
		self.m_happyRate = t_ret['forest_info']['happy']
	end
        
    -- 드래곤의 숲 오브젝트
    self.m_tStuffInfo = {}
	local l_forest_stuff_list = t_ret['forest_stuffs']
	if (l_forest_stuff_list) then
		for i, t_stuff in pairs(l_forest_stuff_list) do
			local stuff = t_stuff['stuff']
			self.m_tStuffInfo[stuff] = t_stuff
		end
	end
    
    -- 드래곤의 숲 드래곤 정보
    self.m_tDragonStruct = {}
    local l_forest_dragon_list = t_ret['forest_dragons']
	if (l_forest_dragon_list) then
		for i, t_dragon_info in pairs(l_forest_dragon_list) do
			local doid = t_dragon_info['doid']
			local struct_dragon = g_dragonsData:getDragonDataFromUid(doid)
			if (struct_dragon) then
				struct_dragon.happy_at = t_dragon_info['happy_at']/1000 or 0
				self.m_tDragonStruct[doid] = struct_dragon
			end
		end
	end

	if finish_cb then
        finish_cb(ret)
    end
end

-------------------------------------
-- function request_setDragons
-------------------------------------
function ServerData_Forest:request_setDragons(doids, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)

        -- 드래곤의 숲 드래곤 정보
        self.m_tDragonStruct = {}
        local doid, struct_dragon 
        for i, t_dragon_info in pairs(ret['forest_dragons']) do
            doid = t_dragon_info['doid']
            struct_dragon = g_dragonsData:getDragonDataFromUid(doid)
            if (struct_dragon) then
                struct_dragon.happy_at = (t_dragon_info['happy_at'] or 0)/1000
                self.m_tDragonStruct[doid] = struct_dragon
            end
        end 

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/forest/set/dragons')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doids', doids)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function request_dragonHappy
-------------------------------------
function ServerData_Forest:request_dragonHappy(doid, finish_cb)
    if (not self.m_canHappy) then
        cclog('dragon can not happy')
        return
    end
    self.m_canHappy = false

    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)

        -- 공용 드래곤의 숲 정보
        self.m_happyRate = ret['forest_info']['happy']

        -- 드래곤 만족도 시간 갱신
        local struct_dragon_object = self.m_tDragonStruct[doid]
        struct_dragon_object.happy_at = (ret['forest_dragon']['happy_at'] or 0)/1000

        if finish_cb then
            finish_cb(ret)
        end

        self.m_canHappy = true

        -- 지급된 아이템 동기화
        g_serverData:networkCommonRespone_addedItems(ret)
    end

    -- 실패 콜백
    local function fail_cb()
        self.m_canHappy = true
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/forest/dragon/happy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideLoading()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_stuffReward
-------------------------------------
function ServerData_Forest:request_stuffReward(stuff_type, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        self.m_hasReward = false

        -- 드래곤의 숲 오브젝트
        local stuff, ret_stuff
        for i, t_stuff in pairs(ret['forest_stuffs']) do
            stuff = t_stuff['stuff']
            self.m_tStuffInfo[stuff] = t_stuff
            if (stuff_type == stuff) then
                ret_stuff = t_stuff
            end
        end
        
        -- 보상 팝업
        -- self:showRewardResult(ret)

        -- 지급된 아이템 동기화
        g_serverData:networkCommonRespone_addedItems(ret)

        if finish_cb then
            local l_item = {}
            if (ret['added_items']) then
                l_item = ret['added_items']['items_list'] or {}
            end
            finish_cb(ret_stuff, l_item[1])
        end

    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/forest/stuff/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stuff', stuff_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideLoading()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_stuffLevelup
-------------------------------------
function ServerData_Forest:request_stuffLevelup(stuff_type, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        -- 재화 동기화
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 드래곤의 숲 오브젝트
        local stuff, ret_stuff
        for i, t_stuff in pairs(ret['forest_stuffs']) do
            stuff = t_stuff['stuff']
            self.m_tStuffInfo[stuff] = t_stuff
            if (stuff_type == stuff) then
                ret_stuff = t_stuff
            end
        end
        
        if finish_cb then
            finish_cb(ret_stuff)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/forest/stuff/lvup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stuff', stuff_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function showRewardResult
-------------------------------------
function ServerData_Forest:showRewardResult(ret)
    if (not ret) then
        return
    end
    
    local t_added_items = ret['added_items']

    if (not t_added_items) then
        return
    end
    local item_info = t_added_items['items_list'] or {}

    -- 아이템 정보가 있다면 팝업 처리
    if (item_info[1]) then
        local ui_popup = UI_MailRewardPopup(item_info[1])
        ui_popup:removeMailMsg()
        SoundMgr:playEffect('UI', 'ui_out_item_get')
    end
end

-------------------------------------
-- function extendMaxCount
-------------------------------------
function ServerData_Forest:extendMaxCount(cb_func)
    local extension = 'extension'

    local t_extension_info = TableForestStuffLevelInfo:getStuffTable(extension)
    local curr_lv = self:getStuffInfo()[extension]['stuff_lv']
    
    local t_next = t_extension_info[curr_lv + 1]
    if (not t_next) then
        return
    end

    -- 레벨 제한
    if (t_next['tamer_lv'] > g_userData:get('lv')) then
        local msg = Str('테이머 레벨 {1} 달성 시 레벨업 가능합니다.', t_next['tamer_lv'])
        UIManager:toastNotificationRed(msg)
        return
    end

    local price_type = t_next['price_type']
    local price = t_next['price_value']
    local new_max_cnt = t_next['dragon_cnt']

    local function ok_btn_cb()
        -- 캐쉬가 충분히 있는지 확인
        if (not ConfirmPrice(price_type, price)) then
            return
        end

        local toast_msg = Str('드래곤의 숲을 레벨업했습니다.')
        UI_ToastPopup(toast_msg)

	    ServerData_Forest:getInstance():request_stuffLevelup(extension, cb_func)
    end

    local msg = Str('드래곤의 숲을 레벨업하여\n최대 드래곤 수를 {2}까지 늘리시겠습니까?', price, new_max_cnt)
    UI_ConfirmPopup(price_type, price, msg, ok_btn_cb)
end

-------------------------------------
-- function isHighlightForest
-- @brief "드래곤의 숲"진입 버튼의 알림 표시 여부
-------------------------------------
function ServerData_Forest:isHighlightForest()
    local is_content_lock = g_contentLockData:isContentLock('forest')
    if is_content_lock == true then
        return false
    end

    -- reward가 있다면 트루
    if (self.m_hasReward) then
        return true
    end

    -- 레벨업 가능할 경우는 삭제함

    -- 오브젝트의 보상을 받을 수 있을 때
    local reward_time, curr_time
    for _, t_stuff in pairs(self.m_tStuffInfo) do
        if (t_stuff['stuff'] ~= 'extension') then
            reward_time = t_stuff['reward_at']/1000
            curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
            if (curr_time > reward_time) then
                return true
            end
        end
    end

    return false
end

-------------------------------------
-- function isHighlightForest_lv
-- @brief 숲 레벨업이 가능한지 여부
-------------------------------------
function ServerData_Forest:isHighlightForest_lv()
    local curr_lv = g_userData:get('lv')
    local curr_extension_lv = self:getExtensionLV()
    local next_extension_open_tamer_lv = TableForestStuffLevelInfo:getExtensionOpenLV(curr_extension_lv)
    local max_extension_lv = self:getExtensionMaxLV()
    if (curr_extension_lv ~= max_extension_lv) then
        if (next_extension_open_tamer_lv ~= 0) and (next_extension_open_tamer_lv <= curr_lv) then
            return true
        end
    end
    return false
end

-------------------------------------
-- function getStuffInfoList
-------------------------------------
function ServerData_Forest:getStuffInfoList()
    local table_forest_stuff = TableForestStuffType()
    local l_stuff_info_list = {}

    for i,v in pairs(table_forest_stuff.m_orgTable) do
        local stuff_type = v['stuff_type']
        local t_info = self:getStuffInfo_Indivisual(stuff_type)
        l_stuff_info_list[stuff_type] = t_info
    end

    return l_stuff_info_list
end

-------------------------------------
-- function getStuffInfo_Indivisual
-------------------------------------
function ServerData_Forest:getStuffInfo_Indivisual(stuff_type)
    local table_forest_stuff = TableForestStuffType()
    local t_server_info = self:getStuffInfo()

    local t_stuff = table_forest_stuff:get(stuff_type)
    
    if (not t_stuff) then
        error('stuff_type : ' .. stuff_type)
    end

    local clone_stuff = clone(t_stuff)
    local server_info = t_server_info[stuff_type] or {}

    for i, v in pairs(server_info) do
        clone_stuff[i] = v
    end

    return clone_stuff
end

-------------------------------------
-- function update
-------------------------------------
function ServerData_Forest:update(dt)
    if (self.m_hasReward) then
        return
    end

    -- 최초 보상을 받을 수 있을 때 로비 갱신해버린다.
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    for i, t_stuff in pairs(self.m_tStuffInfo) do
        if t_stuff['reward_at'] and (curr_time > t_stuff['reward_at']/1000) then
            self.m_hasReward = true
            g_highlightData:setDirty(true)
            break
        end
    end
end