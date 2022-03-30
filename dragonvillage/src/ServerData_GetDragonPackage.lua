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
    for did, startTime in pairs(pkgDragonList) do
        did = tonumber(did)
        --생성된 패키지 없음
        if(pkgList[did] == nil) then
            --패키지 생성 후 insert
            local package = StructDragonPkgeData(did, startTime)
            table.insert(pkgList, did, package)
        end
    end
end

-------------------------------------
-- function isPossibleBuyPackage
-- @brief 구매가능한 상품이 있는지 확인
-------------------------------------
function ServerData_GetDragonPackage:isPossibleBuyPackage()
    local pkgList = self.m_PackageList
    -- 등록된 상품 없음
    if #pkgList == 0 then
        return false
    end

    -- 등록된 상품 순회하면서 구매 가능 상품 확인
    for _, pkgData in pairs(pkgList) do
        if( pkgData:isPossibleBuyPackage() == true) then
            return true
        end
    end

    return false
end