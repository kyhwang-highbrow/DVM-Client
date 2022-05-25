local PARENT = Structure

-------------------------------------
-- class StructLobbyNotice
-- @comment StructMail 참고
-------------------------------------
StructLobbyNotice = class(PARENT, {
        -- 서버에서 받음
        id = 'string',
        uid = 'number',
        type = 'string',
        reward_list = 'list',
        expired_at = 'time',
        msg = 'string',
        receive_reward = 'boolean', -- 보상 수령 여부
        read = 'number', -- 읽음여부, 0:읽지않음, 1:읽음

        -- 클라에서 편의를 위해 생성하는 데이터
        expire_remain_time = 'time',
    })

local THIS = StructLobbyNotice

-------------------------------------
-- function init
-------------------------------------
function StructLobbyNotice:init(data)
    if data then
        self:applyTableData(data)
        
        self:setExpireRemainTime()
    end

end

-------------------------------------
-- function getClassName
-------------------------------------
function StructLobbyNotice:getClassName()
    return 'StructLobbyNotice'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructLobbyNotice:getThis()
    return THIS
end

-------------------------------------
-- function getLobbyNoticeID
-------------------------------------
function StructLobbyNotice:getLobbyNoticeID()
    return self.id
end


-------------------------------------
-- function getMessage
-------------------------------------
function StructLobbyNotice:getMessage()
    return self.msg
end

-------------------------------------
-- function setExpireRemainTime
-- @brief 만료 기한 갱신
-------------------------------------
function StructLobbyNotice:setExpireRemainTime()
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    local expired_at =0

    -- 사용 시간을 millisecond에서 second로 변경
    if self['expired_at'] then
        expired_at = (self['expired_at'] / 1000)
    end

    self['expire_remain_time'] = (expired_at - server_time)
end

local YEAR_TO_SEC = 60 * 60 * 24 * 365
-------------------------------------
-- function getExpireRemainTimeStr
-- @brief 만료 기한 문자열 반환
-------------------------------------
function StructLobbyNotice:getExpireRemainTimeStr()
    local expire_remain_time = self['expire_remain_time']
    
    -- 1년 이상은 무기한으로 처리
    if (expire_remain_time > YEAR_TO_SEC) then
        return Str('무기한')
    end

    return Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(expire_remain_time))
end

-------------------------------------
-- function hasReward
-------------------------------------
function StructLobbyNotice:hasReward()
    return (table.count(self['reward_list']) > 0)
end

-------------------------------------
-- function getRewardList
-------------------------------------
function StructLobbyNotice:getRewardList()
    return self['reward_list']
end

-------------------------------------
-- function getType
-- @brief
-------------------------------------
function StructLobbyNotice:getType()
    return self.type
end

-------------------------------------
-- function openLobbyNoticePopup
-- @brief
-- @param finish_cb function
-------------------------------------
function StructLobbyNotice:openLobbyNoticePopup(finish_cb)
    local type = self:getType()
    if (type == 'push_newbie') or (type == 'change_exp') then
        -- 보상이 존재하고 아직 수령하지 않은 경우에만 팝업 생성
        if self:hasReward() and (self['receive_reward'] == false) then
            require('UI_LobbyNoticePopup')
            local ui = UI_LobbyNoticePopup(self)
            ui:setCloseCB(finish_cb)
        else
            finish_cb()
        end
    else
        finish_cb()
    end
end


-------------------------------------
-- function makeSampleData
-------------------------------------
function StructLobbyNotice:makeSampleData()
    local t_data = {}

    t_data['type'] ='push_newbie'
    t_data['reward_list'] = {{item_id=700001, count=3000}}
    t_data['msg'] = 'message sample'
    --t_data['uid'] = '08b8f8fd-5bd2-4385-ba02-c42f50040374'
    --t_data['id'] = '5e9d604be8919356f20346b0'
    t_data['type'] = 'push_newbie'
    t_data['expired_at']  = 1587976907873
	t_data['receive_reward'] = false
    
    return t_data
end