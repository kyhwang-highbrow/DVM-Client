local PARENT = Structure

StructDragonPkgData = class({PARENT,
    m_dragonID = 'Number',       --등록된 드래곤 ID
    m_packageList = 'List',      --패키지 상품 ID List
    m_productTable = 'Table',    --상품 데이터 StructProduct Table

    m_startTime = 'Data',      --패키지 시작 시간
    m_endTime = 'Date',        --패키지 종료 시간

    t_name = 'String',
})

-------------------------------------
-- function init
-------------------------------------
function StructDragonPkgData:init(did, stTime)
    self.m_dragonID = tonumber(did)
    self.m_startTime = stTime
    self.m_endTime = stTime + 86400 --종료는 1일 뒤(60 * 60 * 24)
    local packageTable = g_getDragonPackage:GetList_DragonPackage()
    self.m_packageList = packageTable[did]

    --상품 정보
    self.m_productTable = {}
    for _, pid in ipairs(self.m_packageList) do
        --Shop Data에서 pid를 통해서 상품 정보들 다 찾아놓는다.
        self.m_productTable[pid] = g_shopDataNew:getTargetProduct(tonumber(pid))
    end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructDragonPkgData:getClassName()
    return 'StructDragonPkgData'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructDragonPkgData:getThis()
    return StructDragonPkgData
end

-------------------------------------
-- function getProductList
-------------------------------------
function StructDragonPkgData:getProductList()
    return self.m_packageList
end

-------------------------------------
-- function getDragonID
-------------------------------------
function StructDragonPkgData:getDragonID()
    return self.m_dragonID
end

-------------------------------------
-- function getLastProductID
-- @brief 패키지에서 마지막 상품 ID 전달
-------------------------------------
function StructDragonPkgData:getLastProductID()
    local productList = self:getProductList()
    return productList[#productList]
end

-------------------------------------
-- function getPossibleProduct
-- @brief 패키지에서 구매 가능 상품을 구해준다
-------------------------------------
function StructDragonPkgData:getPossibleProduct()
    local product = nil
    --상품 리스트 순회
    local productList = self:getProductList()
    for _, pid in ipairs(productList) do
        local data = self:getProduct(pid)   --상품 가져오기
        if (data ~= nil) and (not data:isBuyAll()) then
            --구매 가능한지 확인
            product = data
            break
        end
    end

    return product
end

-------------------------------------
-- function isSaleProduct
-- @brief 세일 상품인지 확인해준다
-------------------------------------
function StructDragonPkgData:isSaleProduct(product)
    local productList = self:getProductList()

    --세일 조건 체크 (첫번째 상품인 경우 세일)
    local fristPid = table.getFirst(productList)
    local pid = tonumber(product['product_id'])

    local retValue = (pid == tonumber(fristPid))
    return retValue
end

-------------------------------------
-- function getPossibleProduct
-- @brief 패키지에서 구매 가능 상품이 있는지 확인해준다
-------------------------------------
function StructDragonPkgData:isPossibleProduct()
    --상품 없음
    local product = self:getPossibleProduct()
    if (product == nil) then
        return false
    end

    --시간체크
    local serverTime = ServerTime:getInstance():getCurrentTimestampSeconds()
    if(self.m_endTime <= serverTime) then
        return false
    end

    return true
end

-------------------------------------
-- function getTotalBuyCntndMaxCnt
-- @brief 패키지에 대한 구매 개수, 최대 구매 가능 개수를 구해준다
-------------------------------------
function StructDragonPkgData:getTotalBuyCntndMaxCnt()
    local total_BuyCnt, total_MaxCnt = 0, 0

    local productList = self:getProductList()
    for _, pid in ipairs(productList) do
        local product = self:getProduct(pid)
        total_BuyCnt = total_BuyCnt + g_shopDataNew:getBuyCount(pid)
        total_MaxCnt = total_MaxCnt + product:getMaxBuyCount()
    end

    return total_BuyCnt, total_MaxCnt
end

-------------------------------------
-- function getProduct
-- @brief 상품 테이블에서 상품 정보 전달
-------------------------------------
function StructDragonPkgData:getProduct(pid)
    return self.m_productTable[pid]
end

-------------------------------------
-- function getRemainTime
-- @brief 남은 시간 계산해서 전달
-------------------------------------
function StructDragonPkgData:getRemainTime()
    local serverTime = ServerTime:getInstance():getCurrentTimestampSeconds()
    local remainTime = self.m_endTime - serverTime
    return remainTime
end

function StructDragonPkgData:getBadgeIcon()
    local product = self:getPossibleProduct()
    if (product == nil) then
        return product
    end

    return product:makeBadgeIcon()
end
