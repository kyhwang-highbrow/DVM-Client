local PARENT = PatchAssetBase

-------------------------------------
---@class PatchAssetResource : PatchAssetBase
-------------------------------------
PatchAssetResource = class(PARENT, {
})

-------------------------------------
---@function init
-------------------------------------
function PatchAssetResource:init()
end

-------------------------------------
---@function applyPatchList
---패치 정보에서 다운로드 받을 패치 선별  
---리소스 패치는 버전으로 구분
---@param patch_list PatchInfo[]
---@param curr_patch_ver number
---@param latest_patch_ver number
-------------------------------------
function PatchAssetResource:applyPatchList(patch_list, curr_patch_ver, latest_patch_ver)
    for _, v in ipairs(patch_list) do
        local version = v['version']
        if (curr_patch_ver < version) and (version <= latest_patch_ver) then
            self.m_patchList[version] = v
        end
    end
end

-------------------------------------
---@function getPatchInfo
---다음 다운로드 받을 패치 정보 획득
---@return table | nil
-------------------------------------
function PatchAssetResource:getPatchInfo(curr_patch_ver, latest_patch_ver)
    while true do
        curr_patch_ver = (curr_patch_ver + 1)

        -- 패치 있음
        if self.m_patchList[curr_patch_ver] then
            break
        end

        -- 패치 없음
        if (curr_patch_ver >= latest_patch_ver) then
            return nil
        end
    end

    return self.m_patchList[curr_patch_ver]
end

-------------------------------------
---@function savePatchData
---패치 데이터 저장  
---패치 파일 하나를 다운받았을 때마다 저장
---@override
---@param curr_patch_ver number
-------------------------------------
function PatchAssetResource:savePatchData(curr_patch_ver)
    local patch_data = PatchData:getInstance()
    patch_data:set('patch_ver', curr_patch_ver)
	patch_data:save()
end