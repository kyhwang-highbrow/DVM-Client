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
    self:load()
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
        self.m_tData = {}
		local t_data = {}
		local content = f:read('*all')

		if #content > 0 then
			t_data = json_decode(content)
		end
		f:close()

		for k,v in pairs(t_data) do
			self.m_tData[k] = v
		end
		
	else
        local t_data = {}
	    t_data['latest_app_ver'] = '0.0.0'
	    t_data['patch_ver'] = 0
        t_data['res_ver'] = 0
        self.m_tData = t_data
	end
end

-------------------------------------
-- function getAppVersionAndPatchIdxString
-- @breif 앱버전과 패치 정보 출력용 문자열
-------------------------------------
function PatchData:getAppVersionAndPatchIdxString()
	local cur_app_ver = getAppVer()
    local patch_idx = self:get('patch_ver')
    local patch_idx_str = string.format('ver : %s, patch : %d', cur_app_ver, patch_idx)
    return patch_idx_str
end

-------------------------------------
-- function getInstance
-------------------------------------
function PatchData:getInstance()
    if (not g_patchData) then
        g_patchData = PatchData()
        g_patchData:load()
    end

    return g_patchData
end