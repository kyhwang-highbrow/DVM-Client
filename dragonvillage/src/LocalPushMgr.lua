-------------------------------------
-- class LocalPushMgr
-------------------------------------
LocalPushMgr = class({
		m_pushMinSecond = 'num', -- 앱 종료후 최소 푸시 등록 시간
    })

PUSH_TEST = false

-------------------------------------
-- function init
-------------------------------------
function LocalPushMgr:init()
	self.m_pushMinSecond = 3
end

-------------------------------------
-- function applyLocalPush
-- @brief 로컬 푸시 정보를 등록
-------------------------------------
function LocalPushMgr:applyLocalPush()

    -- 옵션에서 알림을 껐을 경우
    local push_state = g_localData:get('push_state') or 1
    if push_state == 0 then
        return
    end

    -- 기존 local push 삭제
    self:cancel()

    if (g_explorationData) then
	    -- 탐험
        for _, t_epr in pairs(g_explorationData:getPushTimeList()) do
            local time = t_epr['time']
            local msg = self:getPushString('epr')
            self:addLocalPush('kami', time, msg)
        end
    end

    -- 푸시 디버그
    if (PUSH_TEST) then
        self:addLocalPush('kkami', 5, '로컬 푸시 테스트 1 2 3')
    end

	-- 신규 local push 등록
    self:register()
end

-------------------------------------
-- function addLocalPush
-- @brief 개별 로컬 푸시 정보를 추가
-- @param push_type : 폰에서 노출될 푸시 UI
-- @param push_time : n초 후 푸시
-- @param push_msg : 출력될 메세지, 타이틀은 고정
-------------------------------------
function LocalPushMgr:addLocalPush(push_type, push_time, push_msg)
    if push_time >= self.m_pushMinSecond then
	    local param_str = push_type .. ';' .. push_time .. ';' .. push_msg
        SDKManager:addPush(param_str)
    end
end

-------------------------------------
-- function cancel
-- @brief 로컬푸시 해제
-------------------------------------
function LocalPushMgr:cancel()
    SDKManager:clearPush()
end

-------------------------------------
-- function register
-- @brief 로컬푸시 등록
-------------------------------------
function LocalPushMgr:register()
    SDKManager:registerPush()
end

-------------------------------------
-- function setLocalPush_Color
-- @brief 로컬 푸시 색상을 지정한다.
-------------------------------------
function LocalPushMgr:setLocalPush_Color(bg_color, title_color, msg_color)
	if (not bg_color) then 
		bg_color = '#a71197'
	end
	if (not title_color) then 
		title_color = '#fcff29'
	end
	if (not msg_color) then 
		msg_color = '#ffffff'
	end

	local param_str = bg_color .. ';' .. title_color .. ';' .. msg_color
    SDKManager:setPushColor(param_str)
end

-------------------------------------
-- function setLocalPush_URL
-- @brief 로컬 푸시 URL을 지정한다.
-------------------------------------
function LocalPushMgr:setLocalPush_URL(link_title, link_url, cafe_url)
	local param_str = link_title .. ';' .. link_url .. ';' .. cafe_url
    SDKManager:setPushUrl(param_str)
end

-------------------------------------
-- function getPushString
-- @brief 
-------------------------------------
function LocalPushMgr:getPushString(category)
    if (category == 'epr') then
        local l_str = {
            '테이머님 드래곤들이 탐험을 완료했어요!',
            '기특한 드래곤들이 탐험 보상을 들고 왔네요!',
            '탐험이 완료되었습니다. 선물을 확인해볼까요?',
        }
        return Str(table.getRandom(l_str))
    else
        return ''
    end
end