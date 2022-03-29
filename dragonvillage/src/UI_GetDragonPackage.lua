local PARENT = UI

-------------------------------------
-- class UI_GetDragonPackage
-------------------------------------
UI_GetDragonPackage = class(PARENT, {
    m_packageData = 'StructDragonPkgeData',  --드래곤 패키지 데이터
    m_closeCallBack = 'function'             --Close CallBack Function    
})

-------------------------------------
-- function init
-------------------------------------
function UI_GetDragonPackage:init(packageData, close_cb)
    self.m_packageData = packageData
    self.m_closeCallBack = close_cb

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GetDragonPackage:initUI()
    self:load('package_first_myth.ui')
    UIManager:open(self, UIManager.POPUP)

	--backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_GetDragonPackage')

    local vars = self.vars
    local packageData = self.m_packageData

    --남은 시간 (핸들러 등록해야한다)
    local time_str = datetime.makeTimeDesc(packageData:getRemainTime())
    vars['timeLabel']:setString(Str('판매 종료까지 {1} 남음', time_str))

    --드래곤에 따른 배경
    self:setDragonBg()

    --드래곤 애니매이션 추가
    self:setDragonAnimator()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GetDragonPackage:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['contractBtn']:registerScriptTapHandler(function() GoToAgreeMentUrl() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GetDragonPackage:refresh()
    local vars = self.vars
    local packageData = self.m_packageData

    --축하 메시지
    local did = packageData:getDragonID()  --등록된 드래곤
    local dragonRarity = dragonRarityName(TableDragon:getValue(did,'rarity')) .. ' ' .. Str('드래곤')
    local dragonName = string.format('{@%s}%s{@white}', TableDragon:getDragonAttr(did), TableDragon:getDragonName(did))
    local congratulateText = Str('{1} {2} 획득을 축하합니다.', dragonRarity, dragonName)
    vars['congratulateLabel']:setString(congratulateText)

    --구매 가능한 상품, 세일여부
    local product, isSale = packageData:getPossibleProduct()

    -- 가격 Label
    self:setPriceLabel(product, isSale)
    -- 구매하기 Label
    self:setBuyLabel()
    -- 상품 리스트
    self:initTableView(product)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_GetDragonPackage:initTableView(product)
    local node = self.vars['itemNode']
    local itemList = ServerData_Item:parsePackageItemStr(product['mail_content'])
    node:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(155, 10)
    table_view:setCellUIClass(self.getUI_ProductItemCard)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setAlignCenter(true)
    table_view:setScrollLock(true)
    table_view:setItemList(itemList)
end

-------------------------------------
-- function setPriceLabel
-- @brief 가격 Label 설정
-------------------------------------
function UI_GetDragonPackage:setPriceLabel(product, isSale)
    local vars = self.vars
    local packageData = self.m_packageData 

    --가격 설정
    vars['saleSprite'] :setVisible(isSale)    --세일 아이콘
    vars['priceLabel']:setVisible(not isSale) 
    vars['promotionSprite']:setVisible(isSale)
    vars['originalPriceLabel']:setVisible(isSale)
    vars['promotionPriceLabel']:setVisible(isSale)

    if (isSale) then 
        --마지막 상품이 origina가격
        local last_ProductID = packageData:getLastProductID()
        local last_product = packageData:getProduct(last_ProductID)  
        vars['originalPriceLabel']:setString(last_product:getPriceStr())
        vars['promotionPriceLabel']:setString(product:getPriceStr())
    else
        vars['priceLabel']:setString(product:getPriceStr())
    end
end

-------------------------------------
-- function setBuyLabel
-- @brief 구매 Label 설정
-------------------------------------
function UI_GetDragonPackage:setBuyLabel()
    local vars = self.vars
    local packageData = self.m_packageData 

    local BuyCnt, MaxCnt = packageData:getTotalBuyCntndMaxCnt()
    local str = Str('구매 가능 {1}/{2}', (MaxCnt - BuyCnt), MaxCnt)
    str = '{@possible}' .. str
    vars['buyLabel']:setVisible(true)
    vars['buyLabel']:setString(str)
end

-------------------------------------
-- function setDragonAnimator
-- @brief UI Node에 드래곤 추가
-------------------------------------
function UI_GetDragonPackage:setDragonAnimator()
    local did = self.m_packageData:getDragonID()  --등록된 드래곤
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[did]
    local res, attr = t_dragon['res'], t_dragon['attr']

    --드래곤 추가 조건 테이블
    local aniTable = {}
    table.insert(aniTable, {['evolution'] = 1})
    table.insert(aniTable, {['evolution'] = 3, ['isFlip'] = true})

    --테이블 순회하면서 조건에 맞게 애니매이션 설정
    local vars = self.vars
    for index, value in ipairs(aniTable) do
        local node = vars['dragonNode' .. index]
        node:removeAllChildren()

        local animator = AnimatorHelper:makeDragonAnimator(res, value['evolution'], attr)
        if (value['isFlip']) then
            animator:setFlip(90)
        end

        --공통 작업
        animator:setDockPoint(CENTER_POINT)
        animator:setAnchorPoint(CENTER_POINT)
        animator:setAnimationPause(true)   --애니매이션 정지
        node:addChild(animator.m_node)
    end
end

-------------------------------------
-- function setDragonBg
-- @brief UI Node에 드래곤 종류에 따른 배경 설정
-------------------------------------
function UI_GetDragonPackage:setDragonBg()
    local node = self.vars['bgNode']
    local did = self.m_packageData:getDragonID()  --등록된 드래곤
    local attr = TableDragon:getDragonAttr(did)

    local bgSprite = self:getStepNodeBgBarImg(attr)
    bgSprite:setPosition(237, -30)
    node:removeAllChildren()
    node:addChild(bgSprite)
end


-------------------------------------
-- function getStepNodeBgBarImg
-- @brief 드래곤 속성에 따른 Bar Img 획득
-------------------------------------
function UI_GetDragonPackage:getStepNodeBgBarImg(attr)
    local res_name = 'res/ui/package/bg_first_myth_' .. attr .. '.png'
    local res = IconHelper:getIcon(res_name)
    return res
end


-------------------------------------
-- function getUI_ProductItemCard
-- @brief 아이템 리스트에 추가되는 아이템 UI
-------------------------------------
function UI_GetDragonPackage.getUI_ProductItemCard(data)
    local item_id, count = data['item_id'], data['count']

    local ui_card = UI_ItemCard(item_id, count) -- 아이템 카드
    --드래곤 카드라면 드래곤 정보 팝업
    local did = tonumber(TableItem:getDidByItemId(item_id))
    if did and (0 < did) then
        local function func_clickBtn()
            --슬라임은 진화 1단계
            local evolution = TableSlime:isSlimeID(did) and 1 or 3
            UI_BookDetailPopup.openWithFrame(did, nil, evolution, 0.8, true)
        end        
        ui_card.vars['clickBtn']:registerScriptTapHandler(function() func_clickBtn() end)
    end
    return ui_card
end

-------------------------------------
-- function click_closeBtn
-- @brief 종료 버튼
-------------------------------------
function UI_GetDragonPackage:click_closeBtn()
    if (self.m_closeCallBack) then
        self.m_closeCallBack()
    end

    self:close()
end

--@CHECK
UI:checkCompileError(UI_GetDragonPackage)