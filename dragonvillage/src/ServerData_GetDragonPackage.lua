-------------------------------------
-- class ServerData_GetDragonPackage
-------------------------------------
ServerData_GetDragonPackage = class({
    m_serverData = 'ServerData',                     --서버 데이터
    m_PackageList = 'list[StructDragonPkgeData]',     --패키지 정보가 들어있는 Table
    m_PopUpList = 'list',                         --새로운 패키지가 생긴다면 팝업
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_GetDragonPackage:init(server_data)
    self.m_serverData = server_data
    self.m_PackageList = {}
    self.m_PopUpList = {}
end

-------------------------------------
-- function applyPackageList
-- @brief 서버에서 내려준 데이터 받아서 분해 후 테이블에 저장
-------------------------------------
function ServerData_GetDragonPackage:applyPackageList(ret)
    local pkgDragonList = ret['pkg_dragon_info']
    if (pkgDragonList == nil) then
        return
    end
    local pkgList = self.m_PackageList
    for did, startTime in pairs(pkgDragonList) do
        did, startTime = tonumber(did)
        --이미 패키지가 있는지 확인
        if (pkgList[did] == nil) then
            --없다면 패키지 생성 후 insert
            local package = StructDragonPkgData(did, startTime)
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

function ServerData_GetDragonPackage:getPackageList()
    return self.m_PackageList
end

function ServerData_GetDragonPackage:getPackage(dragonID)
    return self.m_PackageList[dragonID]
end
