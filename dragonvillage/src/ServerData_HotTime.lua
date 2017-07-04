-------------------------------------
-- class ServerData_HotTime
-------------------------------------
ServerData_HotTime = class({
        m_serverData = 'ServerData',
        m_hotTimeInfoList = 'table', -- �������� �Ѿ���� ������ �״�θ� ����
        m_activeEventList = 'table',
        m_listExpirationTime = 'timestamp',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_HotTime:init(server_data)
    self.m_serverData = server_data
    self.m_activeEventList = {}
    self.m_listExpirationTime = nil
end

-------------------------------------
-- function request_hottime
-------------------------------------
function ServerData_HotTime:request_hottime(finish_cb, fail_cb)
    -- ���� ID
    local uid = g_userData:get('uid')
    
    -- ���� �ݹ�
    local function success_cb(ret)

        self.m_hotTimeInfoList = ret['hottime']
        self.m_listExpirationTime = nil

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- ��Ʈ��ũ ���
    local ui_network = UI_Network()
    ui_network:setUrl('/users/hottime')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function refreshActiveList
-------------------------------------
function ServerData_HotTime:refreshActiveList()
    if (not self.m_hotTimeInfoList) then
        return {}
    end

    local curr_time = Timer:getServerTime()

    if (self.m_listExpirationTime) and (self.m_listExpirationTime < curr_time) then
        return
    end

    -- ������ ���� �ð��� ����
    self.m_listExpirationTime = TimeLib:getServerTime_midnight(curr_time)

    -- ����� �̺�Ʈ ����
    for key,v in pairs(self.m_activeEventList) do
        if ((v['enddate'] / 1000) < curr_time) then
            self.m_activeEventList[key] = nil
        end
    end

    -- Ȱ��ȭ�� �׸� ����
    self.m_activeEventList = {}
    for i,v in pairs(self.m_hotTimeInfoList) do

        local expiration_time = nil

        -- ��Ÿ�� ���� �ð� ��
        if (curr_time < (v['begindate'] / 1000)) then
            expiration_time = (v['begindate'] / 1000)

        -- ��Ÿ�� ���� ��
        elseif ((v['enddate'] / 1000) < curr_time) then

        -- �̺�Ʈ ���� ����
        elseif (table.count(v['contents']) <= 0) then

        else
            local key = v['event']
            self.m_activeEventList[key] = v
            expiration_time = (v['enddate'] / 1000)
        end

        -- ����Ʈ�� ��ȿ�� �ð� ����
        if (expiration_time) and ((not self.m_listExpirationTime) or (expiration_time < self.m_listExpirationTime)) then
            self.m_listExpirationTime = expiration_time
        end
    end
end

-------------------------------------
-- function getActiveHotTimeInfo
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo(hottime_nmae)
    self:refreshActiveList()

    local t_event = nil
    for i,v in pairs(self.m_activeEventList) do
        local l_contents = v['contents']
        for _,name in ipairs(l_contents) do
            if (hottime_nmae == name) then
                t_event = v
                break
            end
        end
    end

    return t_event
end

-------------------------------------
-- function isHighlightHotTime
-------------------------------------
function ServerData_HotTime:isHighlightHotTime()
    if self:getActiveHotTimeInfo('gold_2x') then
        return true
    end

    if self:getActiveHotTimeInfo('exp_2x') then
        return true
    end

    if self:getActiveHotTimeInfo('stamina_50p') then
        return true
    end
    
    return false
end