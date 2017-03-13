-------------------------------------
-- class ConstantData
-------------------------------------
ConstantData = class({
        m_constantData = '',
        m_cache = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ConstantData:init()
    self.m_cache = {}
	self:readDataFile()
end

-------------------------------------
-- function getInstance
-------------------------------------
function ConstantData:getInstance()
    if (not g_constant) then
		g_constant = ConstantData()
    end

	return g_constant
end

-------------------------------------
-- function readDataFile
-------------------------------------
function ConstantData:readDataFile()
	self.m_constantData = TABLE:loadJsonTable('constant', '.json', true)
end

-------------------------------------
-- function get
-------------------------------------
function ConstantData:get(...)
	-- 윈도우에서는 매번 읽어 테스트하기 용이하도록 한다.
	if (isWin32()) then
		self:readDataFile()
	end

    local args = {...}
    local cnt = #args

    local container = self.m_constantData
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return clone(container[key])
            end
        end
    end

    return nil
end
