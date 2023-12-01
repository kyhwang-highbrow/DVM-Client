local PARENT = PatchAssetBase

-------------------------------------
---@class PatchAssetLanguage : PatchAssetBase
---@field m_poppingPatchInfo PatchInfo
-------------------------------------
PatchAssetLanguage = class(PARENT, {
    m_poppingPatchInfo = '',
})

-------------------------------------
---@function init
-------------------------------------
function PatchAssetLanguage:init()
end

-------------------------------------
---@function applyPatchList
---전체 패치 정보 에서 클라이언트에서 다운로드 받을 패치 정보만 추출하여 저장  
---언어 패치의 경우 체크섬을 비교하여 판별한다. 다운로드 후 로컬에 저장함
---@param patch_list PatchInfo[] 서버에서 받은 전체 패치 정보
-------------------------------------
function PatchAssetLanguage:applyPatchList(patch_list)
    if (patch_list == nil) then
        return
    end 

    local lang_code = Translate:getGameLang()
    local curr_patch_lang_info = PatchData:getInstance():getLanguage(lang_code) or {}
    for _, patch_info in ipairs(patch_list) do
        local key = string.find(patch_info.name, '_patch_') and 'patch' or 'main'
        -- 언어 패치 checksum 검증
        if (curr_patch_lang_info[key] ~= patch_info.md5) then
            table.insert(self.m_patchList, patch_info)
        end
    end
end

-------------------------------------
---@function getPatchInfo
---다음 다운로드 받을 패치 정보 획득, pop 사용하기 때문에 m_patchList 원소는 제거되는 것에 주의
---@return table | nil
-------------------------------------
function PatchAssetLanguage:getPatchInfo()
    if (#self.m_patchList == 0) then
        return nil
    end
    self.m_poppingPatchInfo = table.pop(self.m_patchList)
    return self.m_poppingPatchInfo
end

-------------------------------------
---@function getDownloadPath
---패치 파일을 다운받을 경로
-------------------------------------
function PatchAssetLanguage:getDownloadPath()
	if (not self.m_downloadPath) then
        local path = cc.FileUtils:getInstance():getWritablePath()
        local ver_folder = string.gsub(self.m_appVer, '%D', '_')
        self.m_downloadPath = string.format('%spatch_%s/translate/', path, ver_folder)
	end
    return self.m_downloadPath
end

-------------------------------------
---@function savePatchData
---언어 패치 체크섬 저장
---@override
-------------------------------------
function PatchAssetLanguage:savePatchData()
    local lang_code = Translate:getGameLang()
    local patch_data = PatchData:getInstance()
    local patch_lang_info = patch_data:getLanguage(lang_code) or {}

    local key = self:_getLangPatchKey(self.m_poppingPatchInfo.name)
    patch_lang_info[key] = self.m_poppingPatchInfo.md5

    patch_data:setLanguage(lang_code, patch_lang_info)
	patch_data:save()
end

--#region Private

-------------------------------------
---@function _getLangPatchKey
---@private
---@param patch_name string
-------------------------------------
function PatchAssetLanguage:_getLangPatchKey(patch_name)
    return string.find(patch_name, '_patch_') and 'patch' or 'main'
end

--#endregion