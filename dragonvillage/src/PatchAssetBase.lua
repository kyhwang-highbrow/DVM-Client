-------------------------------------
---@class PatchAssetBase
---@field m_downloadPath string
---@field m_appVer string  앱 버전
---@field m_patchList PatchInfo[]
-------------------------------------
PatchAssetBase = class({
    m_appVer = '',
    m_downloadPath = '',
    m_patchList = '',
})

---@class PatchInfo
---@field name string
---@field md5 string
---@field size number
---@field web_path string
---@field local_path string

-------------------------------------
---@function init
---@param app_ver string
-------------------------------------
function PatchAssetBase:init(app_ver)
    self.m_appVer = app_ver
    self.m_patchList = {}
end

-------------------------------------
---@function getPatchList
---@return {}
-------------------------------------
function PatchAssetBase:getPatchList()
    return self.m_patchList
end

-------------------------------------
---@function getTotalSize
---저장한 패치 리스트의 용량의 합
---@return number
-------------------------------------
function PatchAssetBase:getTotalSize()
    local l_info_list = self:getPatchList()
    local total_size = 0
    local exist_size, res_size
    local is_exist

    -- 다운로드 받을 리소스 목록을 순회하며 다운로드 받을 사이즈를 취합하며
    -- 이미 받은 것이 있다면 용량을 체크하며 이어받기 사이즈를 적용한다.
    for _, v in pairs(l_info_list) do
        res_size = v['size']
        is_exist, exist_size = self:checkFileExist(v['name'], res_size)
        if (not is_exist) then
            res_size = res_size - exist_size
            total_size = total_size + res_size
            v['size'] = res_size
        end
    end

    return total_size
end

-------------------------------------
---@function checkFileExist
---파일이 (용량까지) 완전히 존재하는지 확인한다.
-------------------------------------
function PatchAssetBase:checkFileExist(down_name, down_size)
    local local_path = self:_makeLocalPath(down_name)

    -- 파일 존재 유무 확인
    local f = io.open(local_path, 'r')
    if (not f) then
        return false, 0
    end

    -- 파일 사이즈 얻어옴
    local size = f:seek("end")
    f:close()

    -- @sgkim 2021.12.08 iOS에서 파일에 상태에 따라 seek함수가 nil을 리턴하는 경우가 있는 것 같다.
    if (size == nil) then
        size = 0
    end

    -- 파일 사이즈가 같을 경우 true 리턴
    if (down_size == size) then
        return true, size
    end

    return false, size
end

-------------------------------------
---@function _makeLocalPath
---@private
---@param name string
---@return string
-------------------------------------
function PatchAssetBase:_makeLocalPath(name)
	local l_word = seperate(name, '/')
    local directory = self:getDownloadPath()
	local local_path = directory .. l_word[#l_word]
    return local_path
end

-------------------------------------
---@function getLocalPath
---패치를 다운로드 받을 경로
---@param name string
---@return string
-------------------------------------
function PatchAssetBase:getLocalPath(name)
    return self:_makeLocalPath(name)
end

-------------------------------------
---@function getDownloadPath
---패치 파일을 다운받을 앱버전 폴더
-------------------------------------
function PatchAssetBase:getDownloadPath()
	if (not self.m_downloadPath) then
        local path = cc.FileUtils:getInstance():getWritablePath()
        local ver_folder = string.gsub(self.m_appVer, '[.]', '_')
        self.m_downloadPath = string.format('%spatch_%s/', path, ver_folder)
	end

    return self.m_downloadPath
end

-------------------------------------
---@function savePatchData
---@param value any
-------------------------------------
function PatchAssetBase:savePatchData(value)
end