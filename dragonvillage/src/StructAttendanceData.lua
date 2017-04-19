-------------------------------------
-- class StructAttendanceData
-- @breif 출석 정보를 관리하는 클래스
--        일반 출석, 이벤트 출석 모두 이 클래스를 사용
-------------------------------------
StructAttendanceData = class({
        attendance_type = 'string', -- 출석 타입 'basic' or 'event'
        today_step = 'number', -- 출석상에서의 오늘 스텝
        step_list = 'list',
        guide_dragon = '',
        help_text = 'string',
        title_text = 'string',
        received = 'boolean', -- false인 경우 출석 보상을 지금 받았다는 뜻(연출을 보여줘야함)
        category = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function StructAttendanceData:init(data)
    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructAttendanceData:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    replacement['atd_type'] = 'attendance_type'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function hasReward
-- @brief false인 경우 출석 보상을 지금 받았다는 뜻(연출을 보여줘야함)
-------------------------------------
function StructAttendanceData:hasReward()
    return (self.received == false)
end

-------------------------------------
-- function setReceived
-- @brief
-------------------------------------
function StructAttendanceData:setReceived()
    self.received = true
end

-------------------------------------
-- function getBannerImg
-- @brief
-------------------------------------
function StructAttendanceData:getBannerImg()
    local res

    if (self.category == 'open_event') then
        res = 'res/ui/event/attendance_banner_001.png'
            
    elseif (self.category == 'newbie') then
        res = 'res/ui/event/attendance_banner_002.png'

    elseif (self.category == 'comeback') then
        res = 'res/ui/event/attendance_banner_003.png'

    elseif (self.category == 'normal') then
        res = 'res/ui/event/attendance_banner_004.png'

    end

    if (not res) then
        return nil
    end

    local img = cc.Sprite:create(res)
    img:setDockPoint(cc.p(0.5, 0.5))
    img:setAnchorPoint(cc.p(0.5, 0.5))

    return img
end