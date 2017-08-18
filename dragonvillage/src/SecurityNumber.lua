local function get_crc(v)
	local c = 0
	local _v = math.floor(v)
	if _v < 0 then _v = -math.floor(v) end

	while math.floor(_v*0.1) > 0 do
		c = c + (_v % 10)
		c = c % 10
		_v = math.floor(_v*0.1)
	end
	
	return c
end


SecurityNumberClass = class({
    m_data = ''
})

-------------------------------------
-- function init
-------------------------------------
function SecurityNumberClass:init(v)
    self:set(v)
end

-------------------------------------
-- function init
-------------------------------------
function SecurityNumberClass:get()
    -- crc가 다르면 값을 지워버리고 0을 리턴
	local c = get_crc(self.m_data.x)
	if not self.m_data.z or c ~= self.m_data.z then
		self.m_data = nil
		return 0
	end

	return self.m_data.x - self.m_data.y
end

-------------------------------------
-- function set
-------------------------------------
function SecurityNumberClass:set(v)
    local t = {x=0,y=0,z=0}
	local r = math.random(-6758472,7637467)
	t.x = r + v
	t.y = r
	-- crc를 항상 다시 세팅
	t.z = get_crc(t.x)
	self.m_data = t
end

-------------------------------------
-- function init
-------------------------------------
function SecurityNumberClass:add(v)
    local t = {x=0,y=0,z=0}
	local r = math.random(-6758472,7637467)
	if self.m_data then
		t.x = self.m_data.x - self.m_data.y + v + r
		t.z = self.m_data.z
	else
		t.x = r + v
	end
	t.y = r
	-- crc를 항상 다시 세팅
	t.z = get_crc(t.x)
	self.m_data = t
end