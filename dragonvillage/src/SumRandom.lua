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
function SumRandom:getRandomValue(rate_sum, b_remove)
    local rate_sum = (rate_sum or self.m_rateSum)
    local rand_num = math_random(1, rate_sum)
    local b_remove = (b_remove or false)

    for i,v in ipairs(self.m_lRandomList) do
        if (rand_num <= v[1]) then
            
            if b_remove then
                self:removeItem(i)
            end

            return v[2]
        end
    end

    return nil
end

-------------------------------------
-- function removeItem
-------------------------------------
function SumRandom:removeItem(idx)
    -- 해당 아이템의 rate를 계산
    local rete
    do
        local prev_rate = self.m_lRandomList[idx-1] and self.m_lRandomList[idx-1][1]
        local curr_reate = self.m_lRandomList[idx] and self.m_lRandomList[idx][1]

        if prev_rate then
            rate = (curr_reate - prev_rate)
        else
            rate = curr_reate
        end
    end

    -- 해당 idx 삭제
    table.remove(self.m_lRandomList, idx)

    -- 뒤의 확률 다시 계산
    for i=idx, #self.m_lRandomList do
        self.m_lRandomList[i][1] = (self.m_lRandomList[i][1] - rate)
    end

    -- rate의 총합을 수정
    self.m_rateSum = (self.m_rateSum - rate)
end