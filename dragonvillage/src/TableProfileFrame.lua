local PARENT = TableClass
-------------------------------------
--- @class TableProfileFrame
-------------------------------------
TableProfileFrame = class(PARENT, {
})

local instance = nil
-------------------------------------
---@function init
-------------------------------------
function TableProfileFrame:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_profile_frame'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
---@function getInstance
---@return TableProfileFrame instance
-------------------------------------
function TableProfileFrame:getInstance()
    if (instance == nil) then
        instance = TableProfileFrame()
    end
    return instance
end

-------------------------------------
---@function getProfileFrameRes
---@brief 프로필 프레임 리소스
-------------------------------------
function TableProfileFrame:getProfileFrameRes(profile_frame_id)
    local res = self:getValue(profile_frame_id, 'frame_res')
    local scale = self:getProfileFrameScale(profile_frame_id)
    return 'res/frames/' .. res, scale
end

-------------------------------------
---@function getProfileFrameScale
---@brief 프로필 프레임 리소스 스케일
-------------------------------------
function TableProfileFrame:getProfileFrameScale(profile_frame_id)
    local num = self:getValue(profile_frame_id, 'scale') or 1
    return num
end

-------------------------------------
---@function getAllProfileIdList
---@brief 모든 프로필 리스트 반환
-------------------------------------
function TableProfileFrame:getAllProfileIdList()
    local id_list = self:getTableKeyList(true)
    local res_list = {}
    for _, profile_frame_id in ipairs(id_list) do
        if TableItem:getInstance():exists(profile_frame_id) ~= nil then
            table.insert(res_list, profile_frame_id)
        end
    end

    return res_list
end