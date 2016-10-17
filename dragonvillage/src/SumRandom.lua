-------------------------------------
-- class SumRandom
-------------------------------------
SumRandom = class({
        m_lRandomList = 'list',
        m_rateSum = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SumRandom:init()
    self.m_lRandomList = {}
    self.m_rateSum = 0
end

-------------------------------------
-- function addItem
-------------------------------------
function SumRandom:addItem(rate, value)
    if (not rate) or (rate == 0) then
        return
    end

    self.m_rateSum = (self.m_rateSum + rate)
    table.insert(self.m_lRandomList, {self.m_rateSum, value})
end

-------------------------------------
-- function getRandomValue
-------------------------------------
function SumRandom:getRandomValue(rate_sum)
    local rate_sum = (rate_sum or self.m_rateSum)
    local rand_num = math_random(1, rate_sum)

    for i,v in ipairs(self.m_lRandomList) do
        if (rand_num <= v[1]) then
            return v[2]
        end
    end

    return nil
end