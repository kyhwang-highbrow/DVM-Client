-------------------------------------
-- class ServerData_Mail
-------------------------------------
ServerData_Mail = class({
        m_serverData = 'ServerData',

		m_mMailMap = 'table[mail_type] = map<mail>',
		m_excludedNoticeCnt = 'number', -- 표시에 제외될 공지 개수

		m_lCategory = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Mail:init(server_data)
    self.m_serverData = server_data
	self.m_lCategory = {'goods', 'st', 'item', 'notice'} -- {'goods', 'st', 'friend', 'item', 'notice'} -- @jhakim 2019.09.23 업데이트에서 우정 탭 삭제 
    self.m_excludedNoticeCnt = 0
end

-------------------------------------
-- function getMailCategoryList
-- @brief 메일 범주 리스트 반환 (UI와 공유)
-------------------------------------
function ServerData_Mail:getMailCategoryList()
	return self.m_lCategory
end

-------------------------------------
-- function getMailList
-- @brief 타입에 해당하는 메일 리스트를 가져온다.
-------------------------------------
function ServerData_Mail:getMailList(category)
    if (not self.m_mMailMap) then
        return {}
    end

    return self.m_mMailMap[category]
end

-------------------------------------
-- function getMailListWithItemID
-- @brief 아이템 아이디를 가지고 있는 메일 리스트를 가져온다.
-------------------------------------
function ServerData_Mail:getMailListWithItemID(l_item_id_list)
    if (not self.m_mMailMap) then
        return {}
    end

    local m_mail_map = {}
    for _, category in ipairs(self.m_lCategory) do
        for mid, struct_mail in pairs(self.m_mMailMap[category]) do
            local mail_item = struct_mail:getItemList()[1]
            if (mail_item) then
                local mail_item_id = mail_item['item_id']
                for _, item_id in ipairs(l_item_id_list) do
                    if (item_id == mail_item_id) then
                        m_mail_map[mid] = struct_mail
                        break
                    end                
                end
            end
        end
    end

    return m_mail_map
end


-------------------------------------
-- function hasNewMail
-- @brief 메일이 있는지 검사한다.
-------------------------------------
function ServerData_Mail:hasNewMail(category)
    if (not self.m_mMailMap) then
        return false
    end

    return (table.count(self.m_mMailMap[category]) > 0)
end

-------------------------------------
-- function getNewMailMap
-- @brief category : 새메일 여부 의 맵
-------------------------------------
function ServerData_Mail:getNewMailMap()
    local t_ret = {}
    for _, category in pairs(self.m_lCategory) do
        if (category == 'notice') then
            -- 안 읽은 공지 있다면 알림 아이콘 표시
            for i, mail in pairs(self.m_mMailMap[category]) do
                if (not mail:isNoticeRead()) then
                    t_ret[category] = true
                    break
                end
            end
        else
            if (self:hasNewMail(category)) then
                t_ret[category] = true
            end
        end
    end
    return t_ret
end

-------------------------------------
-- function deleteMailData
-------------------------------------
function ServerData_Mail:deleteMailData(moid)
	for _, table_mail in pairs(self.m_mMailMap) do
		for mail_id, t_mail in pairs(table_mail) do
			if (mail_id == moid) then
				table_mail[mail_id] = nil
				break
			end
		end
	end
end

-------------------------------------
-- function canReadAll
-- @brief 모두 받기 가능한 메일이 있는지 검사!
-------------------------------------
function ServerData_Mail:canReadAll(mail_tab)
	for mid, struct_mail in pairs(self.m_mMailMap[mail_tab]) do
		-- 하나라도 모두 받기 가능한 메일이 있다면 탈출
		if (struct_mail:isMailCanReadAll()) then
			return true
		end
	end
	return false
end

-------------------------------------
-- function canReadAllWithItemID
-- @brief 모두 받기 가능한 메일(해당 아이템 리스트에 속한)이 있는지 검사!
-------------------------------------
function ServerData_Mail:canReadAllWithItemID(l_item_id_list)
    local m_mail_map = self:getMailListWithItemID(l_item_id_list)

	for mid, struct_mail in pairs(m_mail_map) do
		-- 하나라도 모두 받기 가능한 메일이 있다면 탈출
		if (struct_mail:isMailCanReadAll()) then
			return true
		end
	end
	return false
end

-------------------------------------
-- function sortMailList
-------------------------------------
function ServerData_Mail:sortMailList(sort_target_list, is_reverse)
    local sort_manager = SortManager()

    -- 시간 오름 차순 (얼마 안남은 것부터)
	sort_manager:setDefaultSortFunc(function(a, b) 
            local a_data = a['data']
            local b_data = b['data']

            local a_value = a_data['expired_at']
            local b_value = b_data['expired_at']

			if (is_reverse) then
				return a_value > b_value
			else
				return a_value < b_value
			end
	end)

    sort_manager:sortExecution(sort_target_list)
end

-------------------------------------
-- function sortNoticeList
-------------------------------------
function ServerData_Mail:sortNoticeList(sort_target_list)
    local sort_manager = SortManager()

    -- 보상이 있는 순, 이후 최신 공지를 맨위에 올리도록 함
	sort_manager:addSortType('reward', nil, function(a, b) 
            local a_data = a['data']
            local b_data = b['data']

            -- 메일이 회수되면서 데이터가 무효할 수도 있음
            if (not a_data or not b_data or not a_data['custom'] or not b_data['custom']) then
                return nil
            end

            local a_value = a_data['custom']['received']
            local b_value = b_data['custom']['received']

            if (a_value == true) and (b_value == false) then
                return false

            elseif (a_value == false) and (b_value == true) then
                return true

            else
                return nil

            end
	end)

    sort_manager:addSortType('date', nil, function(a, b)
        local a_data = a['data']
        local b_data = b['data']

        -- 메일이 회수되면서 데이터가 무효할 수도 있음
        if (not a_data or not b_data or not a_data['custom'] or not b_data['custom']) then
            return nil
        end

        local a_value = a_data['custom']['key']
        local b_value = b_data['custom']['key']

        return a_value > b_value
    end)

    sort_manager:pushSortOrder('date')
    sort_manager:pushSortOrder('reward')
    sort_manager:sortExecution(sort_target_list)
end

-------------------------------------
-- function makeMailMap
-- @brief 
-------------------------------------
function ServerData_Mail:makeMailMap(l_mail_list)
	-- 초기화
	self.m_mMailMap = {}
	for _, mail_type in pairs(self.m_lCategory) do
		self.m_mMailMap[mail_type] = {}
	end

	local table_item_type = TableItemType()

    self.m_excludedNoticeCnt = 0

    -- mail map 생성
    local is_mail = true
	for i, t_mail in pairs(l_mail_list) do
		local moid = t_mail['id']
		local mail_type = t_mail['mail_type']
		local category
        is_mail = true

        -- mail_type으로 구분 가능한 것을 미리 구분한다. 
        -- 'fp'와 'use_fp' and 'ret_fp'
		if pl.stringx.endswith(mail_type, 'fp') then
			category = 'friend'

        -- 공지 메일
        elseif (mail_type == 'notice') then
            category = 'notice'

            -- 2020-12-24 
            -- 이제부터 게시글은 공지팝업에서 해결한다.
            -- legacy
            -- 게시글이 연동되지 않은 공지는 올리지 않는다
            if t_mail['custom'] then
                --if (StructMail.getNoticeArticleID(t_mail) == nil) then
                --    is_mail = false
                --    self.m_excludedNoticeCnt = (self.m_excludedNoticeCnt + 1)
                --end
                if (not StructMail:hasValidNoticeMessage(t_mail)) then
                    is_mail = false
                    self.m_excludedNoticeCnt = (self.m_excludedNoticeCnt + 1)
                end
            end

		-- 아이템에 따라 분류한다.
		else
			local t_item = t_mail['items_list'][1]
			local item_id = t_item['item_id']
	
			if (table_item_type:isMailStaminas(item_id)) then
				category = 'st'		
			elseif (table_item_type:isMailFp(item_id)) then
				category = 'friend'	
			elseif (table_item_type:isMailItem(item_id)) then
				category = 'item'
			elseif (table_item_type:isMailMoney(item_id)) then
				category = 'goods'
			else
				category = 'item'
			end
		end
        -- mail struct로 생성
        if (is_mail) then
            if (self.m_mMailMap[category]) then
                self.m_mMailMap[category][moid] = StructMail(t_mail)
            end
        end
	end
end

-------------------------------------
-- function request_mailList
-- @brief 메일 리스트
-------------------------------------
function ServerData_Mail:request_mailList(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
		-- mail map을 생성한다.
        if ret['mails_list'] then
			self:makeMailMap(ret['mails_list'])

            -- 로비 노티 갱신
		    g_highlightData:setDirty(true)
        end
		
		-- @jhakim 190925 우정 탭이 사라지면서 기존에 받은 우정 포인트 수령이 불가능해짐
		-- 서버에서 기존 우정 포인트가 있을 경우 바로 획득했다고 보내줌 (added_items)
        g_serverData:networkCommonRespone_addedItems(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/mail_list')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_mailRead
-- @brief 우편 읽기 (받기)
-------------------------------------
function ServerData_Mail:request_mailRead(mail_id_list, t_mail_type_reward, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local mids = listToCsv(mail_id_list)

    -- 콜백 함수
    local function success_cb(ret)

        -- @analytics
        for mail_type, item_list in pairs(t_mail_type_reward) do
            if (mail_type == 'q_daily') then
                Analytics:trackGetGoodsWithItemList(item_list, '일일 퀘스트')

            elseif (mail_type == 'chlg') then
                Analytics:trackGetGoodsWithItemList(item_list, '업적')

            elseif (mail_type == 'advertising') then
                Analytics:trackGetGoodsWithItemList(item_list, '광고 보상')
            end
        end

        g_serverData:networkCommonRespone_addedItems(ret)
        g_supply:applySupplyList_fromRet(ret)

        for i,v in ipairs(mail_id_list) do
            self:deleteMailData(v)
        end

		-- 로비 노티 갱신
		g_highlightData:setDirty(true)

        if finish_cb then
            finish_cb(ret, mail_id_list)
        end

        -- 부스터 아이템 - 핫타임 정보 갱신
        if (ret['hottime'] and ret['all']) then
            g_hotTimeData:response_hottime(ret)
            g_hotTimeData:refreshActiveList()
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/mail_read')
    ui_network:setParam('uid', uid)
    ui_network:setParam('mids', mids)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_mailReadAll
-- @brief 우편 모두 읽기
-------------------------------------
function ServerData_Mail:request_mailReadAll(type, finish_cb)
    -- 적절한 우편 id list 추출
	local mail_list = self:getMailList(type)
	local mail_id_list = {}
    local t_mail_type_reward = {}
	for i, struct_mail in pairs(mail_list) do
		-- 모두 받기 가능한 메일만 테이블에 추가
		if (struct_mail:isMailCanReadAll()) then
			-- id list
			table.insert(mail_id_list, struct_mail:getMid())

			-- item_list : 지표 축적을 위해서 가공
			local mail_type = struct_mail:getMailType()
			local item_list = struct_mail:getItemList()
			if (not t_mail_type_reward[mail_type]) then
				t_mail_type_reward[mail_type] = {}
			end
			for i, t_item in ipairs(item_list) do
				table.insert(t_mail_type_reward[mail_type], t_item)
			end
		end
	end

	-- api로 보냄
	self:request_mailRead(mail_id_list, t_mail_type_reward, finish_cb)
end

-------------------------------------
-- function request_mailReadAllWithItemID
-- @brief 아이템 아이디 리스트에 해당하는 우편 모두 읽기
-------------------------------------
function ServerData_Mail:request_mailReadAllWithItemID(l_item_id_list, finish_cb)
    -- 적절한 우편 id list 추출
	local mail_list = self:getMailListWithItemID(l_item_id_list)
	local mail_id_list = {}
    local t_mail_type_reward = {}
	for i, struct_mail in pairs(mail_list) do
		-- 모두 받기 가능한 메일만 테이블에 추가
		if (struct_mail:isMailCanReadAll()) then
			-- id list
			table.insert(mail_id_list, struct_mail:getMid())

			-- item_list : 지표 축적을 위해서 가공
			local mail_type = struct_mail:getMailType()
			local item_list = struct_mail:getItemList()
			if (not t_mail_type_reward[mail_type]) then
				t_mail_type_reward[mail_type] = {}
			end
			for i, t_item in ipairs(item_list) do
				table.insert(t_mail_type_reward[mail_type], t_item)
			end
		end
	end

	-- api로 보냄
	self:request_mailRead(mail_id_list, t_mail_type_reward, finish_cb)
end

-------------------------------------
-- function request_summonTicket
-- @brief 우편 읽기 (고급소환권)
-------------------------------------
function ServerData_Mail:request_summonTicket(mail_id_list, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local mids = listToCsv(mail_id_list)

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        for i,v in ipairs(mail_id_list) do
            self:deleteMailData(v)
        end

		-- 로비 노티 갱신
		g_highlightData:setDirty(true)

        -- 드래곤들 추가
        g_dragonsData:applyDragonData_list(ret['added_dragons'])

        -- 슬라임들 추가
        g_slimesData:applySlimeData_list(ret['added_slimes'])
        g_hatcheryData:applyPickupCeilingInfo(ret)

        if finish_cb then
            finish_cb(ret, mail_id_list)
        end

        -- 고급소환 정보 가져옴
        local t_egg_data
        for _, t_data in pairs(g_hatcheryData:getGachaList()) do
            if (t_data['egg_id'] == 700002) then
                t_egg_data = t_data
                break
            end
        end

		local gacha_type = 'summon_ticket'
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local egg_id = t_egg_data['egg_id']
        local egg_res = t_egg_data['egg_res']
        local ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_egg_data, 0)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/mail')
    ui_network:setParam('uid', uid)
    ui_network:setParam('mid', mids)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_summon100Ticket
-- @brief 우편 읽기 (100회 뽑기권(일반 or 한정))
-------------------------------------
function ServerData_Mail:request_summon100Ticket(mail_id_list, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local mids = listToCsv(mail_id_list)

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        for i,v in ipairs(mail_id_list) do
            self:deleteMailData(v)
        end

		-- 로비 노티 갱신
		g_highlightData:setDirty(true)

        -- 드래곤들 추가
        g_dragonsData:applyDragonData_list(ret['added_dragons'])

        if finish_cb then
            finish_cb(ret, mail_id_list)
        end

		local gacha_type = 'tickect'
        local l_dragon_list = ret['added_dragons']
        local ui = UI_GachaResult_Dragon100(gacha_type, l_dragon_list)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/mail')
    ui_network:setParam('uid', uid)
    ui_network:setParam('mid', mids)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_summonDrawTicket
-- @brief 우편 읽기 (토파즈 드래곤 뽑기권)
-------------------------------------
function ServerData_Mail:request_summonDrawTicket(mail_id_list, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local mids = listToCsv(mail_id_list)
    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        for i,v in ipairs(mail_id_list) do
            self:deleteMailData(v)
        end

		-- 로비 노티 갱신
		g_highlightData:setDirty(true)

        -- 드래곤들 추가
        local dragon_list = {}  -- added_dragons 드래곤이 리스트 형식으로 안와서 리스트 만듬, 추후에 수정해야함     
        table.insert(dragon_list, ret['added_dragons'])
        g_dragonsData:applyDragonData_list(dragon_list)


        if finish_cb then
            finish_cb(ret, mail_id_list)
        end


		local gacha_type = 'immediately'
        local l_dragon_list = dragon_list
        local l_slime_list = nil
        local egg_id = nil
        local egg_res = nil
        local ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_egg_data, 0)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/draw_mail')
    ui_network:setParam('uid', uid)
    ui_network:setParam('mid', mids)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end


-------------------------------------
-- function hasNewNotice
-- @brief 최신 공지를 띄원는지 알려주는 함수
-------------------------------------
function ServerData_Mail:hasNewNotice()
    local t_notice = self:getNewNoticeData()
    local savedNoticeKey = -1

    -- 아예 공지가 없으면 노출 안하도록 하고 리턴
    if not t_notice or t_notice == '' then return false end

    -- 찾아온 공지가 있으면?
    -- 일단 본적 있는지 판단
    savedNoticeKey = g_settingData:get('lobby_ingame_notice', t_notice.custom['key']) or -1

    --날짜값이 의미없는 값이면 공지 확인!
    if tonumber(savedNoticeKey) < 0 then return true end

    -- 더 작은 날짜로 저장되어 있으니 새 공지가 있음
    return tonumber(savedNoticeKey) < tonumber(t_notice.custom['key'])
end

-------------------------------------
-- function getNewNoticeData
-- @brief 최신 공지의 정보를 반환하는 함수
-------------------------------------
function ServerData_Mail:getNewNoticeData()
    local noticeMailList = self:getMailList('notice')
    local savedKey = -1
    local item = ''

    -- 메일리스트에 공지가 하나라도 있다.
    if noticeMailList and table.count(noticeMailList) > 0 then
        -- 가장 최근 공지를 찾아낸다.
        -- 최신 공지를 찾아낸다
        for i, noticeMail in pairs(noticeMailList) do
            
            if noticeMail.custom then
                -- 키값은 YYYYmmDDhhMMss 형태를 가지고 있음
                -- 큰값이 가장 최근 등록된 팝업임
                local key = noticeMail.custom['key'] or -1
                local popupEndTime = noticeMail.custom['popup_at']
                local currentTime = socket.gettime() * 1000 -- 밀리세컨드로 계산

                -- 일단 읽었던건지부터 보고
                if not noticeMail:isNoticeRead() then
                    -- 키값이 큰 숫자이고 
                    -- 팝업 종료시간이 현재 시간보다 크다면
                    if (tonumber(key) > tonumber(savedKey) and tonumber(popupEndTime) >= tonumber(currentTime) )then
                        -- 만약에 저장이 안되어 있는 키라면?
                        -- 압봤다는 증거다
                        local localKey = g_settingData:get('lobby_ingame_notice', key) or -1
                        if (localKey == -1) then
                            item = noticeMail
                            savedKey = key
                        end
                    end
                end

            end
        end
    end
        
    return item        
end

