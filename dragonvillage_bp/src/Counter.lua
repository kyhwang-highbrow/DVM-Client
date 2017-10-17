-------------------------------------
-- class Counter
-- @brief C++의 Enum같은 열거형 데이터를 초기화 할 때 사용
-------------------------------------
Counter = class({
        m_countIdx = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function Counter:init()
    self.m_countIdx = 0
end

-------------------------------------
-- function get
-- @brief idx가 1씩 증가되면서 값을 리턴
-------------------------------------
function Counter:get()
    self.m_countIdx = (self.m_countIdx + 1)
    return self.m_countIdx
end