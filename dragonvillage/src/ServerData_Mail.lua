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
-- function getMailList_withoutFp
-- @brief 메일 리스트 (우정포인트 제외)
-------------------------------------
function ServerData_Mail:getMailList_withoutFp()
    for _,t_mail_data in pairs(self.m_mMailList_withoutFp) do
        self:updateMailServerTime(t_mail_data)
    end

    return self.m_mMailList_withoutFp
end

-------------------------------------
-- function getFpMailList
-- @brief 메일 리스트 (우정포인트만)
-------------------------------------
function ServerData_Mail:getFpMailList()
    for _,t_mail_data in pairs(self.m_mFpMailList) do
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
            finish_cb(ret)
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
-- function deleteMailData
-------------------------------------
function ServerData_Mail:deleteMailData(moid)
    self.m_mMailList_withoutFp[moid] = nil
    self.m_mFpMailList[moid] = nil
end
