-------------------------------------
-- class TimeLib
-- @brief 드래곤히어로즈의 lib/Timer와 동일한 개념
--        TimeLib클래스에서는 모든 시간은 초(sec)단위로 사용
--        서버에서 넘어오는 시간은 1/1000초로 넘어오기때문에 주의해서 사용할 것
-------------------------------------
TimeLib = class({
        m_diffServer = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function TimeLib:init()
    self.m_diffServer = 0
end

-------------------------------------
-- function initInstance
-------------------------------------
function TimeLib:initInstance()
    if Timer then
        return
    end
    -- 인스턴스를 생성
    Timer = TimeLib()
end

-------------------------------------
-- function setServerTime
-- @breif 서버의 현재 타임스탬프를 받아와서 클라이언트와의 시간차를 저장
--        서버에서 넘어오는 시간은 1/1000초로 넘어오기때문에 주의해서 사용할 것
-------------------------------------
function TimeLib:setServerTime(server_time)
    self.m_diffServer = server_time - os.time()
end

-------------------------------------
-- function getServerTime
-------------------------------------
function TimeLib:getServerTime()
    local server_time = (os.time() + self.m_diffServer)
    return server_time
end


