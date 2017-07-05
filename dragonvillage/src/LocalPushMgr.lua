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
	self:applyLocalPush()
end

-------------------------------------
-- function applyLocalPush
-- @brief 로컬 푸시 정보를 등록
-------------------------------------
function LocalPushMgr:applyLocalPush()
    -- 기존 local push 삭제
	luaEventHandler('send_event_to_app', 'local_noti_cancel')

	-- 탐험
	do

	end

	-- 신규 local push 등록
    luaEventHandler('send_event_to_app', 'local_noti_start')
end

-------------------------------------
-- function addLocalPush
-- @brief 개별 로컬 푸시 정보를 추가
-------------------------------------
function LocalPushMgr:addLocalPush(push_type, push_time, push_msg)
    if push_time > self.m_pushMinSecond then
		local param_str = push_type .. ';' .. push_time .. ';' .. push_msg
        luaEventHandler('send_event_to_app', 'local_noti_add', param_str)
    end
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
    luaEventHandler('send_event_to_app', 'local_noti_setColor', param_str)
end

-------------------------------------
-- function setLocalPush_URL
-- @brief 로컬 푸시 URL을 지정한다.
-------------------------------------
function LocalPushMgr:setLocalPush_URL(link_title, link_url, cafe_url)
	local param_str = link_title .. ';' .. link_url .. ';' .. cafe_url
    luaEventHandler('send_event_to_app', 'local_noti_setlinkUrl', param_str)
end