-------------------------------------
-- class Stopwatch
-- @brief
-------------------------------------
Stopwatch = class({
        m_startTime = 'number',     -- 타이머 시작 시간
        m_endTime = 'number',       -- 타이머 종료 시간
        m_totalTime = 'number',     -- 총 소요 시간
        m_recordList = 'list',      -- 기록
    })

-------------------------------------
-- function init
-------------------------------------
function Stopwatch:init()
    self:reset()
end

-------------------------------------
-- function start
-------------------------------------
function Stopwatch:start()
    self.m_startTime = socket.gettime()
end

-------------------------------------
-- function stop
-------------------------------------
function Stopwatch:stop()
    self.m_endTime = socket.gettime()
    self.m_totalTime = (self.m_endTime - self.m_startTime)
end

-------------------------------------
-- function reset
-------------------------------------
function Stopwatch:reset()
    self.m_startTime = nil
    self.m_endTime = nil
    self.m_totalTime = 0
    self.m_recordList = {}
end

-------------------------------------
-- function record
-------------------------------------
function Stopwatch:record(message)
    local prev_record = self.m_recordList[#self.m_recordList]

    local t_record = {}
    t_record['msg'] = message or 'none'
    t_record['time'] = (socket.gettime() - self.m_startTime)

    if prev_record then
        t_record['gap'] = (t_record['time'] - prev_record['time'])
    else
        t_record['gap'] = t_record['time']
    end
    
    table.insert(self.m_recordList, t_record)
end

-------------------------------------
-- function print
-------------------------------------
function Stopwatch:print()
    cclog('## Stopwatch:print() ##')
    
    for i,v in ipairs(self.m_recordList) do
        local str = string.format('Time : %.3f, Interval : %.3f, [%s]', v['time'], v['gap'], v['msg'])
        cclog(str)
    end

    local str = string.format('Total time required : %.3f', self.m_totalTime)
    cclog(str)

    cclog('#######################')
end

-------------------------------------
-- function StopwatchSample
-------------------------------------
function StopwatchSample()
    local stopwatch = Stopwatch()
    stopwatch:start()
    
    for i=1, 1000 do
        local temp = math_random(1, 1000) * math_random(1, 1000)
        local temp2 = temp * temp
        cclog(temp2)
    end
    stopwatch:record('first')

    for i=1, 1000 do
        local temp = math_random(1, 1000) * math_random(1, 1000)
        local temp2 = temp * temp
        cclog(temp2)
    end
    stopwatch:record('seconds')

    stopwatch:stop()
    stopwatch:print()

end