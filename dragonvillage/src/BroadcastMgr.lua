local REQUEST_PERIOD = 60    -- 서버에 메세지 리스트를 요청하는 주기(단위 : 초)


-------------------------------------
-- class BroadcastMgr
-------------------------------------
BroadcastMgr = class({
    m_schedulerID = 'number',
    m_bEnableMessage = 'boolean',   -- 일반 메세지 활성화
    m_bEnableNotice = 'boolean',    -- 공지 메시지 활성화

    m_tMessage = 'table',       -- 일반 메세지 큐
    m_tNotice = 'table',        -- 공지 메세지 큐

    m_remainDelayTime = 'number',   -- 메세지 pop 이후 딜레이 시간
    m_recentRequestTime = 'number', -- 서버에 메세지를 요청한 마지막 시간
    m_recentTimeStamp = 'number'    -- 가장 마지막 이벤트의 시간(다음 서버 요청때 다음꺼만 받기 위함)
})

-------------------------------------
-- function initInstance
-------------------------------------
function BroadcastMgr:initInstance()
    if g_broadcastManager then
        return
    end

    g_broadcastManager = BroadcastMgr()
end

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function BroadcastMgr:init()
    self.m_bEnableMessage = false
    self.m_bEnableNotice = false

    self.m_tMessage = {}
    self.m_tNotice = {}

    self.m_remainDelayTime = 0
    self.m_recentRequestTime = -REQUEST_PERIOD
    self.m_recentTimeStamp = 0

    self.m_schedulerID = scheduler.scheduleGlobal(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function BroadcastMgr:update(dt)
    -- 유저 정보가 없을 경우 표시하지 않음
    if (not g_userData) then return end

    local uid = g_userData:get('uid')
    if (not uid) then return end

    local cur_time = os.time()

    -- 공지 메세지 우선 확인
    if (self.m_tNotice[1]) then
        local data = self.m_tNotice[1]
        if (data['timestamp'] <= cur_time) then
            -- TODO : 공지 표시
            --
            
            table.remove(self.m_tNotice, 1)
            return
        end
    end

    -- 일반 메세지가 활성화 되었을 경우
    if (self.m_bEnableMessage) then
        -- 메세지를 서버에 요청
		if (cur_time >= (self.m_recentRequestTime + REQUEST_PERIOD)) then
            self.m_recentRequestTime = cur_time
			self:requestMsg()
		end

        -- 일반 메세지 출력
        if (self.m_tMessage[1]) then
            if (self.m_remainDelayTime <= 0) then
                local data = self.m_tMessage[1]
		        local msg = self:makeMessage(data)
                local alive_time = self:getAliveTime(data)
                local b = false

                -- 정상적인 메세지가 아닐 경우 패스시킴
                if (not msg) then
                    table.remove(self.m_tMessage, 1)
                    return
                end
                
                -- 방송 표시
                if (g_currScene) then
                    if (g_currScene.m_sceneName == 'SceneGame' or g_currScene.m_sceneName == 'SceneGameColosseum') then
                        if (g_currScene.m_inGameUI) then
                            g_currScene.m_inGameUI:noticeBroadcast(msg, alive_time)
                            b = true
                        end
                    end

                    if (g_topUserInfo) then
                        g_topUserInfo:noticeBroadcast(msg, alive_time)
                        b = true
                    end
                end
                                
                if (b) then
                    table.remove(self.m_tMessage, 1)
                end

                self.m_remainDelayTime = alive_time
            else
                self.m_remainDelayTime = self.m_remainDelayTime - dt
            end
		end
    end
end

-------------------------------------
-- function requestMsg
-------------------------------------
function BroadcastMgr:requestMsg()

    local function success_cb(ret)
        if (ret['status'] ~= 0) then return end
        --cclog('request broadcast ret = ' .. luadump(ret))

        self.m_tMessage = {}
        self.m_tNotice = {}

        for i, v in ipairs(ret['broadcast']) do
            if (v['timestamp']) then
                v['timestamp'] = math_floor(v['timestamp'] / 1000)

                self.m_recentTimeStamp = math_max(self.m_recentTimeStamp, v['timestamp'])
            end

            table.insert(self.m_tMessage, v)
        end

        -- 테스트
        --[[
        do
            for i = 1, 100 do
                local v = {
                    timestamp = 1493709984 + i,
                    event = 'rec',
                    data = { nick = 'skim', uopt = 'def_add;17', rid = 710111 }
                }
                table.insert(self.m_tMessage, v)
            end
        end
        ]]--

        -- 정렬
        table.sort(self.m_tMessage, function(a,b) return a['timestamp'] < b['timestamp'] end)
        table.sort(self.m_tNotice, function(a,b) return a['timestamp'] < b['timestamp'] end)
    end

	local t_request = {}
    local uid = g_userData:get('uid')

    t_request['url'] = '/users/broadcast'
    t_request['method'] = 'POST'
    t_request['data'] = { uid = uid, timestamp = self.m_recentTimeStamp }
    t_request['success'] = success_cb
    
    Network:SimpleRequest(t_request)
end

-------------------------------------
-- function getAliveTime
-- @brief 메세지 노출 시간
-------------------------------------
function BroadcastMgr:getAliveTime(t_data)
    -- 다음 메세지가 있을 경우 짧게 유지
    if (self.m_tMessage[1]) then
        return 3
    else
	    return 5
    end
end

-------------------------------------
-- function setEnable
-- @brief 일반 메세지 활성 지정
-------------------------------------
function BroadcastMgr:setEnable(enable)
	self.m_bEnableMessage = enable
end

-------------------------------------
-- function setEnableNotice
-- @brief 공지 메세지 활성 지정
-------------------------------------
function BroadcastMgr:setEnableNotice(enable)
	self.m_bEnableNotice = enable
end

-------------------------------------
-- function makeMessage
-- @brief 메세지를 만듬
-------------------------------------
function BroadcastMgr:makeMessage(msg_info)
    local event_type = msg_info['event']
    local data = msg_info['data']

    local t_broadcast = TABLE:get('broadcast')[event_type]
    if (not t_broadcast) then
        cclog('Nonexistent Broadcast Event Type : ' .. event_type)
        return
    end

    local t_value = {}

    for i = 1, 5 do
        local value = t_broadcast['value' .. i]
        if (not value or value == '' or value == 'x') then break end
         
        -- 키값에 따라 필요한 문자열을 구성
        if (value == 'did') then
            -- 드래곤 이름
            t_value[i] = TableDragon():getValue(data['did'], 't_name')
                 
        elseif (value == 'rid') then
            -- 룬 이름
            t_value[i] = TableItem():getValue(data['rid'], 't_name')

        elseif (value == 'grade' or value == 'd_grade') then
            -- 등급(룬의 경우는 승급이 존재하지 않음)
            if (data['rid']) then
                t_value[i] = getDigit(data['rid'], 1, 1)
            else
                t_value[i] = data['grade'] or data['d_grade']
            end

        elseif (value == 'uopt') then
            -- 옵션( def_add;17 )
            local l_str = pl.stringx.split(data['uopt'], ';')
            local opiton_type = l_str[1]

            if (not opiton_type) then
                cclog('Invalid Broadcast Data : ' .. luadump(data))
                return
            end

            t_value[i] = TableOption():getValue(opiton_type, 't_prefix')

        else
            t_value[i] = data[value]

        end
    end

    local msg = Str(t_broadcast['t_desc'], t_value[1], t_value[2], t_value[3], t_value[4], t_value[5])
    return msg
end
