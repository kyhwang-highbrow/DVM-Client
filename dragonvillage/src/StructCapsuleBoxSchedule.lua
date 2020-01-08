local PARENT = Structure

--[[
        "first_1":771045,
        "badge_first":"",
        "badge_second":"",
        "hidden_open_date":20200109,
        "first_2":770572,
        "chance_up_1":120623,
        "second_2":770671,
        "first_3":770723,
        "chance_up_2":"",
        "t_first_name":"지원형",
        "badge_second_1":"",
        "second_1":770675,
        "t_second_name":"",
        "badge_first_1":"hot",
        "noti":"",
        "day":20200109,
        "badge_second_3":"",
        "badge_second_2":"",
        "end_date":"2020-01-23 0:00:00",
        "badge_first_3":"",
        "badge_first_2":"",
        "start_date":"2019-12-26 0:00:00",
        "second_3":770673
--]]



-------------------------------------
-- class StructCapsuleBoxSchedule
-- @instance struct_capsule_box_schedule
-------------------------------------
StructCapsuleBoxSchedule = class(PARENT, {
    first_1 = '',
    badge_first = '',
    badge_second = '',
    hidden_open_date = '',
    first_2 = '',
    chance_up_1 = '',
    second_2 = '',
    first_3 = '',
    chance_up_2 = '',
    t_first_name = '',
    badge_second_1 = '',
    second_1 = '',
    t_second_name = '',
    badge_first_1 = '',
    noti = '',
    day = '',
    badge_second_3 = '',
    badge_second_2 = '',
    end_date = '',
    badge_first_3 = '',
    badge_first_2 = '',
    start_date = '',
    second_3 = '',
})

local THIS = StructCapsuleBoxSchedule

StructCapsuleBoxSchedule.NOTI = {}
StructCapsuleBoxSchedule.NOTI['GLOBAL_ANNIVERSARY'] = 'global_anniversary'

-------------------------------------
-- function init
-------------------------------------
function StructCapsuleBoxSchedule:init(data)

end

-------------------------------------
-- function getNoti
-------------------------------------
function StructCapsuleBoxSchedule:getNoti()
    return self['noti']
end

-------------------------------------
-- function getDay
-------------------------------------
function StructCapsuleBoxSchedule:getDay()
    return self['day']
end

-------------------------------------
-- function isHiddenOpen
-- @brief '공개안함'(물음표) 지정했을 경우
-------------------------------------
function StructCapsuleBoxSchedule:isHiddenOpen()
    local hidden_open_date = self['hidden_open_date']
    
    -- 날짜가 지정되지 않은 경우 '공개안함' 처리x
    if (hidden_open_date == '') then
        return true
    end

    local cur_day = g_capsuleBoxData:getCurScheduleDay()
    if (tonumber(cur_day) >= tonumber(hidden_open_date)) then
        return true
    end

    return false
end

-------------------------------------
-- function init
-------------------------------------
function StructCapsuleBoxSchedule:getThis(data)
    return THIS
end

-------------------------------------
-- function getClassName
-- @brief 클래스명 리턴
-------------------------------------
function StructCapsuleBoxSchedule:getClassName()
    return 'StructCapsuleBoxSchedule'
end

-------------------------------------
-- function isNoti_globalAnniversary
-- @brief 글로벌 N주년 기념 절전알 노티 뜨는 날이라면 return true
-------------------------------------
function StructCapsuleBoxSchedule.isNoti_globalAnniversary()
    local struct_capsule_box_schedule = g_capsuleBoxData:getTodaySchedule()
    if (not struct_capsule_box_schedule) then
        return false
    end

    local noti = struct_capsule_box_schedule:getNoti()
    if (noti == 'global_anniversary') then
        return true
    end

    return false
end