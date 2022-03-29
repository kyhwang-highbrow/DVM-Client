-------------------------------------
-- class ServerData_GetDragonPackage
-------------------------------------
ServerData_GetDragonPackage = class({
    m_serverData = 'ServerData',                      --서버 데이터
    m_PackageList = 'list[StructDragonPkgeData]',     --패키지 정보가 들어있는 Table
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_GetDragonPackage:init(server_data)
    self.m_serverData = server_data
    self.m_PackageList = {}
end

-------------------------------------
-- function applyPackageList
-- @brief 서버에서 내려준 데이터 받아서 분해 후 테이블에 저장
-------------------------------------
function ServerData_GetDragonPackage:applyPackageList(data)
    local pkgList = self.m_PackageList

    local pkgDragonList = data['pkg_dragon_info']
    for did, dateTime in pairs(pkgDragonList) do
        did = tonumber(did)
        --생성된 패키지 없음
        if(pkgList[did] == nil) then
            --패키지 생성 후 insert
            local package = StructDragonPkgeData(did, dateTime)
            table.insert(pkgList, did, package)
        end
    end
end