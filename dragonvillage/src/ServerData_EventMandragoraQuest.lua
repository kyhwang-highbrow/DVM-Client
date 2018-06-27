-------------------------------------
-- class ServerData_EventMandragoraQuest
-------------------------------------
ServerData_EventMandragoraQuest = class({
        m_questInfo = 'list', -- 퀘스트 정보
        m_currentQuestInfo = 'list', 

        m_productInfo = 'list', -- 교환 상품 정보
        m_rewardInfo = 'map', -- 보상 정보

        m_endTime = 'time',
        m_bDirty = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventMandragoraQuest:init()
    self.m_bDirty = false
end

-------------------------------------
-- function parseProductInfo
-------------------------------------
function ServerData_EventMandragoraQuest:parseProductInfo(product_info)
    self.m_productInfo = {}
    if (product_info) then
        local step = product_info['step']
        for i = 1, step do
            self.m_productInfo[tostring(i)] =  product_info['mail_content_'..i] 
        end
    end
end

-------------------------------------
-- function parseQuestInfo
-------------------------------------
function ServerData_EventMandragoraQuest:parseQuestInfo(quset_info)
    if (not self.m_productInfo) then
        return
    end

    self.m_questInfo = {}
    if (quset_info) then
        for k, v in pairs(quset_info) do
            local data = StructEventMandragoraQuest(v)
            data['qid'] = tonumber(k) -- 키값이 qid로 넘어옴
            data['reward_info'] = self.m_productInfo[k]
            table.insert(self.m_questInfo, data)
        end
    end

    -- qid 순으로 정렬
    table.sort(self.m_questInfo, function(a, b)
        return a['qid'] < b['qid']
    end)
end

-------------------------------------
-- function getCurrentQid
-------------------------------------
function ServerData_EventMandragoraQuest:getCurrentQid()
    if (not self.m_currentQuestInfo) then
        return nil
    end

    return self.m_currentQuestInfo['qid']
end

-------------------------------------
-- function isAvailable_SpecialReward
-- @brief 캐릭터 페어 보상 (한국 서버에만 적용)
-------------------------------------
function ServerData_EventMandragoraQuest:isAvailable_SpecialReward()
    if (not g_localData:isKoreaServer()) then
        return false
    end

    local is_able = (self.m_currentQuestInfo['special_reward_able'] == 1) -- 받을 수 있는 상태고
    local is_get = (self.m_currentQuestInfo['special_reward'] == 0) -- 받지 않은 유저에게만 노출

    return (is_able and is_get)
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_EventMandragoraQuest:getStatusText()
    local curr_time = Timer:getServerTime()
    local end_time = (self.m_endTime / 1000)

    local time = (end_time - curr_time)
    return Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))
end

-------------------------------------
-- function isAllClear
-------------------------------------
function ServerData_EventMandragoraQuest:isAllClear()
    local is_all_clear = (self.m_currentQuestInfo and self.m_currentQuestInfo['qid'] == nil) and true or false
    return is_all_clear
end

-------------------------------------
-- function confirm_reward
-- @brief 보상 정보
-------------------------------------
function ServerData_EventMandragoraQuest:confirm_reward(ret)
    local item_info = ret['item_info'] or nil
    if (item_info) then
        UI_MailRewardPopup(item_info)
    else
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)

        g_highlightData:setHighlightMail()
    end
end

-------------------------------------
-- function networkCommonRespone
-------------------------------------
function ServerData_EventMandragoraQuest:networkCommonRespone(ret)
    g_serverData:networkCommonRespone(ret)

    -- 현재 진행중인 퀘스트 정보
    if (ret['state']) then
        self.m_bDirty = true
        self.m_currentQuestInfo = ret['state']
    end

    -- 전체 퀘스트 정보
    if (ret['quests']) then
        self.m_bDirty = true
        self:parseQuestInfo(ret['quests'])
    end

    -- 이벤트 종료 시간
    if (ret['end']) then
        self.m_endTime = ret['end']
    end
end

-------------------------------------
-- function request_questInfo
-- @brief 만드라고라의 퀘스트 정보
-------------------------------------
function ServerData_EventMandragoraQuest:request_questInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:networkCommonRespone(ret)
        self:parseProductInfo(ret['mission_event_product'][1])
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/mission_event/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_clearReward
-- @brief 만드라고라의 퀘스트 보상
-------------------------------------
function ServerData_EventMandragoraQuest:request_clearReward(qid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)                    
        self:networkCommonRespone(ret)
        self:confirm_reward(ret)
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/mission_event/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('qid', qid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_specialReward
-- @brief 만드라고라의 퀘스트 보상 (캐릭터페어)
-------------------------------------
function ServerData_EventMandragoraQuest:request_specialReward(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)                    
        self:networkCommonRespone(ret)

        -- 현물 아이템이므로 토스트 메세지만 띄워줌
        local toast_msg = Str('아이템을 지급받았습니다.')
        UI_ToastPopup(toast_msg)    

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/mission_event/chrfair')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end