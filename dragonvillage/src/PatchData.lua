-------------------------------------
-- class PatchData
-------------------------------------
PatchData = class({
	    m_tData = '',
    })

-------------------------------------
-- function init
-------------------------------------
function PatchData:init()
    local t_data = {}
	t_data['latest_app_ver'] = '0.0.0'
	t_data['patch_ver'] = 0
    t_data['res_ver'] = 0

    self.m_tData = t_data
end

-------------------------------------
-- function set
-------------------------------------
function PatchData:set(key, value)
	self.m_tData[key] = value
end

-------------------------------------
-- function get
-------------------------------------
function PatchData:get(key)
	return self.m_tData[key]
end

-------------------------------------
-- function getFilePath
-------------------------------------
function PatchData:getFilePath()
	local file = 'patch_data.json'
	local path = cc.FileUtils:getInstance():getWritablePath()

	local full_path = string.format('%s%s', path, file)
	return full_path
end

-------------------------------------
-- function remove
-------------------------------------
function PatchData:remove()
    os.remove(self:getFilePath())
end

-------------------------------------
-- function save
-------------------------------------
function PatchData:save()
	local f = io.open(self:getFilePath(),'w')
	if (not f) then
        return false
    end

	local content = json.encode(self.m_tData)
	f:write(content)
	f:close()

	return true
end

-------------------------------------
-- function load
-------------------------------------
function PatchData:load()
	local f = io.open(self:getFilePath(),'r')
	if f then
		local data = {}
		local content = f:read('*all')

		if #content > 0 then
			data = json.decode(content)
		end
		f:close()

		for k,v in pairs(data) do
			self.m_tData[k] = v
		end
		
	else
		self:init()
	end
end

-------------------------------------
-- function getInstance
-------------------------------------
function PatchData:getInstance()
    if (not g_patchData) then
        g_patchData = PatchData()
    end

    return g_patchData
end