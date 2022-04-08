-------------------------------------
-- class ServerData_GetDragonPackage
-------------------------------------
ServerData_GetDragonPackage = class({
    m_serverData = 'ServerData',                  --서버 데이터
    m_PackageList = 'list[StructDragonPkgeData]', --패키지 정보가 들어있는 Table
    m_PopUpList = 'list',                         --새로운 패키지가 생긴다면 팝업
    m_TableGetDragonPackage = 'Table',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_GetDragonPackage:init(server_data)
    self.m_serverData = server_data
    self.m_PopUpList = {}
    self.m_PackageList = {}
    self.m_TableGetDragonPackage = nil
end

-------------------------------------
-- function applyPackageList
-- @brief 서버에서 내려준 데이터 받아서 분해 후 테이블에 저장
-------------------------------------
function ServerData_GetDragonPackage:applyPackageList(ret, isRefresh)
    local pkgDragonList = ret['pkg_dragon_info']
    --데이터 없으면 리턴
    if (pkgDragonList == nil) then return end
    local pkgList = self.m_PackageList
    for did, startTime in pairs(pkgDragonList) do
        did, startTime = tonumber(did), startTime / 1000 --단위 변환  ms -> m

        local package = pkgList[did]
        --패키지 데이터 유무 확인 및 최신 데이터 여부 판단
        if (package == nil) or package.m_startTime < startTime then
            --없다면 패키지 생성
            package = StructDragonPkgData(did, startTime)
            if (package:getPossibleProduct()) then --판매 가능 상품이 있는지 확인
                table.insert(self.m_PackageList, did, package)
                --팝업 리스트 insert
                if not isRefresh then
                    table.insert(self.m_PopUpList, package)
                end
            end
        end
    end
end

-------------------------------------
-- function isPossibleBuyPackage
-- @brief 구매가능한 상품이 있는지 확인
-------------------------------------
function ServerData_GetDragonPackage:isPossibleBuyPackage()
    local pkgList = self.m_PackageList
    -- 등록된 상품 순회하면서 구매 가능 상품 확인
    for _, pkgData in pairs(pkgList) do
        if(pkgData:isPossibleProduct()) then
            return true
        end
    end
    return false
end

-------------------------------------
-- function getshortTimePackage
-- @brief 시간이 가장 짧게 남은 패키지를 구해준다
-------------------------------------
function ServerData_GetDragonPackage:getShortTimePackage()
    local shortPackage = nil
    local pkgList = self.m_PackageList

    for _, pkgData in pairs(pkgList) do
        if(pkgData:isPossibleProduct()) then
            if shortPackage == nil then
                shortPackage = pkgData
            else
                if (pkgData.m_endTime < shortPackage.m_endTime) then
                    shortPackage = pkgData
                end
            end
        end
    end
    return shortPackage
end

-------------------------------------
-- function getPackageList
-- @brief 구매 가능한 패키지를 뽑아서 전달해준다
-------------------------------------
function ServerData_GetDragonPackage:getPackageList()
    local pkgList = self.m_PackageList

    local retList = {}
    for key, pkgData in pairs(pkgList) do
        if(pkgData:isPossibleProduct()) then
            retList[key] = pkgData
        end
    end

    return retList
end

function ServerData_GetDragonPackage:getPopUpList()
    return self.m_PopUpList
end

-------------------------------------
-- function PopUp_GetDragonPackage
-- @brief 패키지를 팝업
-------------------------------------
function ServerData_GetDragonPackage:PopUp_GetDragonPackage()
    local packageList = self.m_PopUpList
    local function PopupPackage()
        local package = table.pop(packageList)
        if not package then
            return
        end

        if (package:isPossibleProduct() == false) then
            PopupPackage()
            return
        end

        UI_GetDragonPackage(package, PopupPackage)
    end
    PopupPackage()
end

-------------------------------------
-- function GetList_DragonPackage
-- @brief Table를 변환해서 전달
-------------------------------------
function ServerData_GetDragonPackage:GetList_DragonPackage()
    --값이 없다면 초기화
    if (self.m_TableGetDragonPackage == nil) then
        local packageList = {} 
        local pkgTable = TABLE:get('table_get_dragon_package')
        for productID, value in pairs(pkgTable) do
            local key = value['order']
            local did = value['did']
            if (packageList[did] == nil) then
                packageList[did] = {[key]=productID}
            else
                table.insert(packageList[did], key, productID)
            end
        end
        self.m_TableGetDragonPackage = packageList
    end

    return self.m_TableGetDragonPackage
end