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
end

-------------------------------------
-- function getInstance
-------------------------------------
function ConstantData:getInstance()
    if (not g_constant) then
		g_constant = ConstantData()
		g_constant:loadDataFile()
    end

	return g_constant
end

-------------------------------------
-- function loadDataFile
-------------------------------------
function ConstantData:loadDataFile()
    local f = io.open(self:getFilePath(), 'r')

    if f then
        local content = f:read('*all')

        if #content > 0 then
			-- json에 주석이 있으면 처리가 안되기 때문에 제거
			content = string.gsub(content, '/%/.-%\n', '')
		    self.m_constantData = json.decode(content)
        end
        f:close()
    end
end

-------------------------------------
-- function getFilePath
-- 'C:/project/dragonvillage/frameworks/dragonvillage/runtime/'
-------------------------------------
function ConstantData:getFilePath()
	local file = '../data/constant.json'
    local path = cc.FileUtils:getInstance():getWritablePath() 

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function get
-------------------------------------
function ConstantData:get(...)
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
