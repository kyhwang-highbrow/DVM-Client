-------------------------------------
-- class LocalPushMgr
-------------------------------------
LocalPushMgr = class({
		m_pushMinSecond = 'num', -- 앱 종료후 최소 푸시 등록 시간
    })

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
    -- 기존 local push 삭제
    self:cancel()

	-- 탐험
	do
        for _, t_epr in pairs(g_explorationData:getPushTimeList()) do
            local time = t_epr['time']
            local msg = Str('{1} 탐험 완료! 지금 바로 접속해서 확인하세요!', t_epr['name'])
            self:addLocalPush('', time, msg)
            cclog(time, msg)
        end
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
    if push_time > self.m_pushMinSecond then

    end
	local param_str = push_type .. ';' .. push_time .. ';' .. push_msg
    cclog(param_str)
    PerpSocial:SDKEvent('localpush_add', param_str, '')
end

-------------------------------------
-- function cancel
-- @brief 로컬푸시 해제
-------------------------------------
function LocalPushMgr:cancel()
    PerpSocial:SDKEvent('localpush_cancel', '', '')
end

-------------------------------------
-- function register
-- @brief 로컬푸시 등록
-------------------------------------
function LocalPushMgr:register()
    PerpSocial:SDKEvent('localpush_register', '', '')
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
    PerpSocial:SDKEvent('localpush_setColor', param_str, '')
end

-------------------------------------
-- function setLocalPush_URL
-- @brief 로컬 푸시 URL을 지정한다.
-------------------------------------
function LocalPushMgr:setLocalPush_URL(link_title, link_url, cafe_url)
	local param_str = link_title .. ';' .. link_url .. ';' .. cafe_url
    PerpSocial:SDKEvent('localpush_setLinkUrl', param_str, '')
end