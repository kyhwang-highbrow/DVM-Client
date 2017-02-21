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
    luaEventHandler('send_event_to_app', 'local_noti_cancel')

    local premium_box_remain = 10
	self:addLocalPush('full', 10, Str('로컬 푸시 테스트 1 - 돈까스'))
	self:addLocalPush('full', 20, Str('로컬 푸시 테스트 2 - 쫄면'))
	self:addLocalPush('full', 30, Str('로컬 푸시 테스트 3 - 카레'))
	self:addLocalPush('type2', 40, Str('로컬 푸시 테스트 type2 - 갈릭치킨'))
	self:addLocalPush('type3', 50, Str('로컬 푸시 테스트 type3 - 볶음밥'))

    luaEventHandler('send_event_to_app', 'local_noti_start')
end

-------------------------------------
-- function addLocalPush
-- @brief 개별 로컬 푸시 정보를 추가
-------------------------------------
function LocalPushMgr:addLocalPush(push_type, push_time, push_msg)
    if push_time > self.m_pushMinSecond then
		local push_str = push_type .. ';' .. push_time .. ';' .. push_msg
        luaEventHandler('send_event_to_app', 'local_noti_add', push_str)
    end
end