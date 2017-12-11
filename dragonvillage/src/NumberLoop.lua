-------------------------------------
-- class NumberLoop
-- @brief 1 ~ n 까지의 숫자를 loop
-------------------------------------
NumberLoop = class{
		m_min = 'num',
		m_max = 'num',
		m_curr = 'num',
    }

-------------------------------------
-- function init
-------------------------------------
function NumberLoop:init(max_num, min_num)
	self.m_max = max_num
	self.m_min = min_num or 1
	self.m_curr = 0
end

-------------------------------------
-- function next
-------------------------------------
function NumberLoop:next()
	self.m_curr = self.m_curr + 1

	if (self.m_curr > self.m_max) then
		self.m_curr = 1
	end

	return self.m_curr
end

-------------------------------------
-- function prev
-------------------------------------
function NumberLoop:prev()
	self.m_curr = self.m_curr - 1

	if (self.m_curr < self.m_min) then
		self.m_curr = self.m_max
	end

	return self.m_curr
end

-------------------------------------
-- function setCurr
-------------------------------------
function NumberLoop:setCurr(n)
	self.m_curr = n
end

-------------------------------------
-- function getCurr
-------------------------------------
function NumberLoop:getCurr()
	return self.m_curr
end