-------------------------------------
-- class ServerData_Mail
-------------------------------------
ServerData_Mail = class({
        m_serverData = 'ServerData',

		m_mMailMap = 'table[mail_type] = map<mail>',
		
		m_lCategory = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Mail:init(server_data)
    self.m_serverData = server_data
	self.m_lCategory = {'goods', 'st', 'friend', 'item'}
end

-------------------------------------
-- function getMailCategoryList
-- @brief 메일 범주 리스트 반환 (UI와 공유)
-------------------------------------150
function ServerData_Mail:getMailCategoryList()
	return self.m_lCategory
end

-------------------------------------
-- function getMailList
-- @brief 타입에 해당하는 메일 리스트를 가져온다.
-------------------------------------
function ServerData_Mail:getMailList(category)
    return self.m_mMailMap[category]
end

-------------------------------------
-- function updateMailServerTime
-- @brief 만료 기한 갱신
-------------------------------------
function ServerData_Mail:updateMailServerTime(t_mail_data)
    local server_time = Timer:getServerTime()

    -- 사용 시간을 millisecond에서 second로 변경
    local expired_at = (t_mail_data['expired_at'] / 1000)

    t_mail_data['expire_remain_time'] = (expired_at - server_time)
end

-------------------------------------
-- function getExpireRemainTimeStr
-- @brief 만료 기한
-------------------------------------
function ServerData_Mail:getExpireRemainTimeStr(t_mail_data)
    local expire_remain_time = t_mail_data['expire_remain_time']
    return Str('{1} 남음', datetime.makeTimeDesc(expire_remain_time))
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
-- function checkTicket
-- @brief 확정권인지 검사한다.
-------------------------------------
function ServerData_Mail:checkTicket(mail_data)
	local item_list = mail_data['items_list']

	-- 확정권인지 체크
	local item_type = TableItem():getValue(item_list[1]['item_id'], 'type')
	if (item_type == 'ticket') then
		return true
	end

	return false
end

-------------------------------------
-- function isMailCanReadAll
-- @brief 모두 받기 가능한 메일인지 검사
-------------------------------------
function ServerData_Mail:isMailCanReadAll(t_mail_data)
	local item_id = t_mail_data['items_list'][1]['item_id']
	return (TableItem:getItemTypeFromItemID(item_id) ~= nil)
end

-------------------------------------
-- function canReadAll
-- @brief 모두 받기 가능한 메일이 있는지 검사!
-------------------------------------
function ServerData_Mail:canReadAll(mail_tab)
	for mid, t_mail_data in pairs(self.m_mMailMap[mail_tab]) do
		-- 하나라도 모두 받기 가능한 메일이 있다면 탈출
		if (self:isMailCanReadAll(t_mail_data)) then
			return true
		end
	end
	return false
end

-------------------------------------
-- function sortMailList
-------------------------------------
function ServerData_Mail:sortMailList(sort_target_list)
    local sort_manager = SortManager()

    -- 시간 오름 차순 (얼마 안남은 것부터)
	sort_manager:setDefaultSortFunc(function(a, b) 
            local a_data = a['data']
            local b_data = b['data']

            local a_value = a_data['expired_at']
            local b_value = b_data['expired_at']

            return a_value < b_value
	end)

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

	-- mail map 생성
	for i, t_mail in pairs(l_mail_list) do
		local moid = t_mail['id']
		local mail_type = t_mail['mail_type']
		local category
        
		-- 우정포인트를 패키지에서 받는다면 위의 '재화'로 가게 되고 친구가 보낸다면 '우정'으로 간다.
        -- 'fp'와 'use_fp'
		if pl.stringx.endswith(mail_type, 'fp') then
			category = 'friend'

		-- 우정포인트로 보낸게 아니라면 아이템에 따라 나눈다.
		else
			local t_item = t_mail['items_list'][1]
			local item_id = t_item['item_id']

			-- 클라에서 미리 정의한 item type을 가져온다.
			local item_type = TableItem:getItemTypeFromItemID(item_id)
			
			if item_type then
				-- staminas는 '활동력에 속함'			
				if string.find(item_type, 'stamina') then
					category = 'st'
				
				-- stamina가 없고 item type이 있다면 모두 '재화'에 해당
				else
					category = 'goods'
				end

			-- 클라에서 미리 정의 하지 않은 것은 '아이템'에 속한다.
			else
				category = 'item'

			end

		end

		self:updateMailServerTime(t_mail)
		self.m_mMailMap[category][moid] = t_mail
	end
end

-------------------------------------
-- function request_mailList
-- @brief 메일 리스트
-------------------------------------
function ServerData_Mail:request_mailList(finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
		-- mail map을 생성한다.
        if ret['mails_list'] then
			self:makeMailMap(ret['mails_list'])
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/mail_list')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_mailRead
-- @brief 우편 읽기 (받기)
-------------------------------------
function ServerData_Mail:request_mailRead(mail_id_list, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local mids = listToCsv(mail_id_list)

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        for i,v in ipairs(mail_id_list) do
            self:deleteMailData(v)
        end

        if finish_cb then
            finish_cb(ret, mail_id_list)
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
	for i, mail in pairs(mail_list) do
		-- 모두 받기 가능한 메일만 테이블에 추가
		if (self:isMailCanReadAll(mail)) then 
			table.insert(mail_id_list, mail['id'])
		end
	end

	-- api로 보냄
	g_mailData:request_mailRead(mail_id_list, finish_cb)
end
