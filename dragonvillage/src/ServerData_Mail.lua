-------------------------------------
-- class ServerData_Mail
-------------------------------------
ServerData_Mail = class({
        m_serverData = 'ServerData',
        m_mMailList_withoutFp = 'table[moid]', -- mail object id
        m_mFpMailList = 'table[moid]', -- mail object id
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Mail:init(server_data)
    self.m_serverData = server_data
    self.m_mMailList_withoutFp = {}
    self.m_mFpMailList = {}
end

-------------------------------------
-- function getMailList
-- @brief 타입에 해당하는 메일 리스트를 가져온다.
-------------------------------------
function ServerData_Mail:getMailList(type)
	local mail_list

	-- 우편함(우정포인트 우편 제외)
    if (type == 'mail') then
        mail_list = self:getMailList_withoutFp()

    -- 우정포인트 우편함
    elseif (type == 'friend') then
        mail_list = self:getFpMailList()

    else
        error('tab : ' .. tab)
    end
	
    return mail_list
end

-------------------------------------
-- function getMailList_withoutFp
-- @brief 메일 리스트 (우정포인트 제외)
-------------------------------------
function ServerData_Mail:getMailList_withoutFp()
    for _, t_mail_data in pairs(self.m_mMailList_withoutFp) do
        self:updateMailServerTime(t_mail_data)
    end

    return self.m_mMailList_withoutFp
end

-------------------------------------
-- function getFpMailList
-- @brief 메일 리스트 (우정포인트만)
-------------------------------------
function ServerData_Mail:getFpMailList()
    for _, t_mail_data in pairs(self.m_mFpMailList) do
        self:updateMailServerTime(t_mail_data)
    end
    return self.m_mFpMailList
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
    self.m_mMailList_withoutFp[moid] = nil
    self.m_mFpMailList[moid] = nil
end

-------------------------------------
-- function checkExistTicket
-------------------------------------
function ServerData_Mail:checkExistTicket()
	local isExistTicket = false

	-- 메일을 순회하며 확정권 타입이 있는지 검사
	for i, mail in pairs(self.m_mMailList_withoutFp) do
		if (mail['type'] == 'ticket') then
			isExistTicket = true
			break
		end
	end

	return isExistTicket
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
-- function request_mailList
-- @brief 메일 리스트
-------------------------------------
function ServerData_Mail:request_mailList(finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if ret['mails_list'] then
            for i,v in pairs(ret['mails_list']) do
                local moid = v['id']
                local type = v['type']

				-- type에 따라 정렬
                if (type == 'fp') then
                    self.m_mFpMailList[moid] = v
                else
                    self.m_mMailList_withoutFp[moid] = v

                end
            end
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
	local mail_list = self:getMailList_withoutFp()
	local mail_id_list = {}
	for i, mail in pairs(mail_list) do 
		table.insert(mail_id_list, mail['id'])
	end

	-- api로 보냄
	g_mailData:request_mailRead(mail_id_list, finish_cb)
end
