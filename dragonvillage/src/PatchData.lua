-------------------------------------
-- class PatchData
-------------------------------------
PatchData = class({
	    m_tData = '',
        m_tApkExtension = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function PatchData:init()
    self:load()

    -- APK 확장 파일 정보
    local t_apk_expantion = {}
    t_apk_expantion['file'] = '' -- 'main.8.com.perplelab.dragonvillagem.kr.obb'
    t_apk_expantion['size'] = 0 -- 268371750 (byte)
    t_apk_expantion['md5'] = '' -- string
    t_apk_expantion['version_code'] = '8' -- number
    self.m_tApkExtension = t_apk_expantion
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
-- function setApkExtensionInfo
-- @brief APK 확장 파일 정보 설정
-------------------------------------
function PatchData:setApkExtensionInfo(t_apk_extension_info)
    if (not self.m_tApkExtension) then
        self.m_tApkExtension = {}
    end

	self.m_tApkExtension['file'] = t_apk_extension_info['file'] or ''
    self.m_tApkExtension['size'] = t_apk_extension_info['size'] or 0
    self.m_tApkExtension['md5'] = t_apk_extension_info['md5'] or ''
    self.m_tApkExtension['version_code'] = t_apk_extension_info['version_code'] or 0
end

-------------------------------------
-- function getApkExtensionInfo
-- @brief APK 확장 파일 정보 설정 얻어옴
-------------------------------------
function PatchData:getApkExtensionInfo()
    return self.m_tApkExtension
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
        f:close()

		if (#content > 0) then
			t_data = json_decode(content)

            for k,v in pairs(t_data) do
			    self.m_tData[k] = v
		    end

            return
		end
	end

    do -- 초기화
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

    local target_server = CppFunctions:getTargetServer()
    if (target_server == 'DEV') then
        patch_idx_str = patch_idx_str .. ' (DEV server)'
    elseif (target_server == 'QA') then
        patch_idx_str = patch_idx_str .. ' (QA server)'
    elseif (target_server == 'LIVE') then
        patch_idx_str = patch_idx_str .. ' (LIVE server)'
    else
        error('TARGET_SERVER : ' .. target_server)
    end

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