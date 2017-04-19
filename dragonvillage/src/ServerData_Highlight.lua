-------------------------------------
-- class ServerData_Highlight
-------------------------------------
ServerData_Highlight = class({
        m_serverData = 'ServerData',

        m_lastUpdateTime = '',

        -- 서버에서 넘겨받는 값
        ----------------------------------------------
        attendance_reward = '',
        attendance_event_reward = '',
        quest_reward = '',
        explore_reward = '',
        summon_free = '',
        ----------------------------------------------
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Highlight:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_highlightInfo
-------------------------------------
function ServerData_Highlight:request_highlightInfo(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:applyHighlightInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/status')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function applyHighlightInfo
-------------------------------------
function ServerData_Highlight:applyHighlightInfo(ret)
    local t_highlight = ret['highlight']

    if (not t_highlight) then
        return
    end
    
    for key,value in pairs(t_highlight) do
        self[key] = value
    end

    self.m_lastUpdateTime = Timer:getServerTime()
end

-------------------------------------
-- function isHighlightExploration
-------------------------------------
function ServerData_Highlight:isHighlightExploration()
    return self['explore_reward']
end

-------------------------------------
-- function isHighlightDragonSummonFree
-------------------------------------
function ServerData_Highlight:isHighlightDragonSummonFree()
    return self['summon_free']
end

-------------------------------------
-- function isHighlightQuest
-------------------------------------
function ServerData_Highlight:isHighlightQuest()
    return self['quest_reward']
end