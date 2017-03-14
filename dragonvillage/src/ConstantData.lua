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
	if (not self.m_constantData) then 
		error('constant.json 파일에 구문 오류가 있습니다. 개발자에게 문의해주세요.')
	end
end

-------------------------------------
-- function get
-------------------------------------
function ConstantData:get(...)
	-- 윈도우에서는 매번 읽어 테스트하기 용이하도록 한다.
	-- @TODO 보류 -> 매프레임 읽는 것들이 많아 부하가 너무 크다
	if (isWin32()) then
		--self:readDataFile()
	end
	
    local args = {...}
    local cnt = #args

    local container = self.m_constantData
    for i, key in ipairs(args) do
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

-------------------------------------
-- function sets
-------------------------------------
function ConstantData:set(set_data, ...)
	local set_data = set_data
    local args = {...}
    local cnt = #args

    local container = self.m_constantData
    for i, key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                error('트리가 잘못되었습니다. data/constant.json를 확인해 주세요')
            end
            container = container[key]
        else
            container[key] = set_data
        end
    end
end
