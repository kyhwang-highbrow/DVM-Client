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
-------------------------------------
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
-- function hasNewMail
-- @brief 메일이 있는지 검사한다.
-------------------------------------
function ServerData_Mail:hasNewMail(category)
    return (table.count(self.m_mMailMap[category]) > 0)
end

-------------------------------------
-- function getNewMailMap
-- @brief category : 새메일 여부 의 맵
-------------------------------------
function ServerData_Mail:getNewMailMap()
    local t_ret = {}
    for _, category in pairs(self.m_lCategory) do
        if (self:hasNewMail(category)) then
            t_ret[category] = true
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

    local table_item = TableItem()

	-- mail map 생성
	for i, t_mail in pairs(l_mail_list) do
		local moid = t_mail['id']
		local mail_type = t_mail['mail_type']
		local category
        
        -- mail_type으로 구분 가능한 것을 미리 구분한다. 
        -- 'fp'와 'use_fp' and 'ret_fp'
		if pl.stringx.endswith(mail_type, 'fp') then
			category = 'friend'

		-- 아이템에 따라 분류한다.
		else
			local t_item = t_mail['items_list'][1]
			local item_id = t_item['item_id']

			-- 클라에서 미리 정의한 item type을 가져온다. goods와 item 구분이 모호하기 때문에!
			local item_type = TableItem:getItemTypeFromItemID(item_id)
			
			if item_type then
				-- staminas는 '활동력'에 속함		
				if string.find(item_type, 'stamina') then
					category = 'st'
				
                -- fp는 '우정'로 보내준다.		
			    elseif string.find(item_type, 'fp') then
					category = 'friend'

				-- stamina가 없고 item type이 있다면 모두 '재화'에 해당
				else
					category = 'goods'
				end

			-- 클라에서 미리 정의 하지 않은 것
			else
                category = 'item'
			end

		end

        -- mail struct로 생성
		self.m_mMailMap[category][moid] = StructMail(t_mail)
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

        for i,v in ipairs(mail_id_list) do
            self:deleteMailData(v)
        end

		-- 로비 노티 갱신
		g_highlightData:setDirty(true)

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
