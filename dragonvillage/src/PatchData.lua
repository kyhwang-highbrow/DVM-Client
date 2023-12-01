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
    self.m_tData = {}

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
    if (LIVE_SERVER_CONNECT) then
        return
    end

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
    return SaveLocalSaveJson(self:getFilePath(), self.m_tData)
end

-------------------------------------
-- function load
-------------------------------------
function PatchData:load()
    local ret_json, success_load = LoadLocalSaveJson(self:getFilePath())
    if success_load then
        for k,v in pairs(ret_json) do
			self.m_tData[k] = v
		end

        -- 언어 지원 확대
        if (self.m_tData['language'] == nil) then
            self.m_tData['language'] = {}

            local cur_app_ver = getAppVer()
            self.m_tData['language'][cur_app_ver] = {}
        end

        return
    else
        -- 초기화
        local t_data = {}
	    t_data['latest_app_ver'] = '0.0.0'
	    t_data['patch_ver'] = 0
        t_data['res_ver'] = 0
        t_data['language'] = {}
        local cur_app_ver = getAppVer()
        t_data['language'][cur_app_ver] = {}
        
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
    local patch_idx_str = string.format('ver : %s, Patch : %d', cur_app_ver, patch_idx)
    local select_server = g_localData:getServerName() or ' '
    local target_server = CppFunctions:getTargetServer()

    --if (target_server == 'DEV') then
    --    patch_idx_str = patch_idx_str .. string.format(' (DEV[%s] server)', select_server)
    --elseif (target_server == 'QA') then
    --    patch_idx_str = patch_idx_str .. string.format(' (QA[%s] server)', select_server)
    --elseif (target_server == 'LIVE') then
    --    patch_idx_str = patch_idx_str .. string.format(' (LIVE[%s] server)', select_server)
    --else
    --    error('TARGET_SERVER : ' .. target_server)
    --end

    -- sgkim 2018-01-24
    patch_idx_str = patch_idx_str .. string.format(' (%s Server)', select_server)

    -- Cafe Bazaar 빌드를 식별하기 위해 추가
    if (CppFunctions:isCafeBazaarBuild() == true) then
        patch_idx_str = ('[Cafe Bazaar] ' .. patch_idx_str)
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

--#region Language Data

-------------------------------------
---@function _checkLanguageTable
---@private
---@param curr_app_ver string
-------------------------------------
function PatchData:_checkLanguageTable(curr_app_ver)
    if (self.m_tData['language'] == nil) then
        self.m_tData['language'] = {}
    end
    
    if (self.m_tData['language'][curr_app_ver] == nil) then
        self.m_tData['language'][curr_app_ver] = {}
    end
end

-------------------------------------
---@function setLanguage
---@param lang_code string
---@param lang_info table
-------------------------------------
function PatchData:setLanguage(lang_code, lang_info)
    local curr_app_ver = getAppVer()
    self:_checkLanguageTable(curr_app_ver)
    self.m_tData['language'][curr_app_ver][lang_code] = lang_info
end

-------------------------------------
---@function getLanguage
---@param lang_code any
---@return table language_info
-------------------------------------
function PatchData:getLanguage(lang_code)
    local curr_app_ver = getAppVer()
    self:_checkLanguageTable(curr_app_ver)
    return self.m_tData['language'][curr_app_ver][lang_code] or {}
end

--#endregion