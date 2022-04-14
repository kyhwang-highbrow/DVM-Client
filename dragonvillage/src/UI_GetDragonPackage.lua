local PARENT = UI

-------------------------------------
-- class UI_GetDragonPackage
-------------------------------------
UI_GetDragonPackage = class(PARENT, {
    m_packageData = 'StructDragonPkgData',  --드래곤 패키지 데이터
    m_closeCallBack = 'function',           --Close CallBack Function
    m_mainProduct = 'StructProduct',        --UI에 노출되어있는 메인 상품
    m_isPopUp     = 'bool',                 --팝업 UI인지(아닌경우 패키지 상점)
    m_Timer = 'number'                      --timeUpdate에서 dt를 누적시켜 지나간 시간을 확인 
})

-------------------------------------
-- function init
-------------------------------------
function UI_GetDragonPackage:init(packageData, close_cb, isPopUp)
    self.m_packageData = packageData
    self.m_closeCallBack = close_cb
    self.m_mainProduct = packageData:getPossibleProduct()
    --false를 제외한 모든 값을 True처리
    self.m_isPopUp = not (isPopUp == false)


    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GetDragonPackage:initUI()
    local vars = self:load('package_first_myth.ui')
    local isPopUp = self.m_isPopUp

    if (isPopUp) then
        UIManager:open(self, UIManager.POPUP)
	    --backkey 지정
	    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_GetDragonPackage')
    end

    --Close버튼
    vars['closeBtn']:setVisible(isPopUp)

    --남은시간 스케줄러
    self:setTimerSchedule()

    --드래곤에 따른 배경
    self:setDragonBg()

    --드래곤 애니매이션 추가
    self:setDragonAnimator()

    --제한 시간 설정
    self:setTimeLimit()
end


-------------------------------------
-- function setTimeLimit
-------------------------------------
function UI_GetDragonPackage:setTimeLimit()
    local vars = self.vars

    -- 남은 시간 이미지 텍스트로 보여줌
    local remain_time_label = cc.Label:createWithBMFont('res/font/tower_score.fnt', 0)
    remain_time_label:setAnchorPoint(cc.p(0.5, 0.5))
    remain_time_label:setDockPoint(cc.p(0.5, 0.5))
    remain_time_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    remain_time_label:setAdditionalKerning(0)

    vars['remainLabel'] = remain_time_label
    vars['timeNode']:addChild(remain_time_label)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GetDragonPackage:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end) --Close
    vars['contractBtn']:registerScriptTapHandler(function() GoToAgreeMentUrl() end) --청약철회

    --구매 버튼 설정
    self:setBuyButton()
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

    -- 가격 Label
    self:setPriceLabel()
    -- 구매하기 Label
    self:setBuyLabel()
    -- 상품 리스트
    self:initTableView()
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_GetDragonPackage:initTableView()
    local node = self.vars['itemNode']
    local product = self.m_mainProduct
    local itemList = ServerData_Item:parsePackageItemStr(product['mail_content'])
    node:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(155, 10)
    table_view:setCellUIClass(self.getUI_ProductItemCard)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) --가로
    table_view:setAlignCenter(true) --중앙 정렬
    table_view:setScrollLock(true)  --스크롤 Lock
    table_view:setItemList(itemList)
end

-------------------------------------
-- function timeUpdate
-------------------------------------
function UI_GetDragonPackage:timeUpdate(dt)
    self.m_Timer = self.m_Timer + dt
    if self.m_Timer < 1 then
        return 
    end
    local remainTime = self.m_packageData:getRemainTime() * 1000 --단위 변환 s -> ms
    if (remainTime < 0) then
        remainTime = 0
        self:unSetTimerSchedule()
    end

    local desc_time = datetime.makeTimeDesc_timer_filledByZero(remainTime)
    self.vars['remainLabel']:setString(desc_time)
    self.m_Timer = 0
end

-------------------------------------
-- function setTimerSchedule
-------------------------------------
function UI_GetDragonPackage:setTimerSchedule()
    self.m_Timer = 1 
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:timeUpdate(dt) end, 0)
end

-------------------------------------
-- function unSetTimerSchedule
-------------------------------------
function UI_GetDragonPackage:unSetTimerSchedule()
    self.root:unscheduleUpdate()
end

-------------------------------------
-- function setPriceLabel
-- @brief 가격 Label 설정
-------------------------------------
function UI_GetDragonPackage:setPriceLabel()
    local vars = self.vars
    local product = self.m_mainProduct
    local packageData = self.m_packageData

    local isSale = packageData:isSaleProduct(product)
    --가격 설정
    vars['saleSprite']:setVisible(isSale)    --세일 아이콘
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

    local str = '{@possible}' .. self:getPossiobleCntString()
    vars['buyLabel']:setVisible(true)
    vars['buyLabel']:setString(str)
end

-------------------------------------
-- function setAllProductBuy
-- @brief 모든 상품을 구매했을때
-------------------------------------
function UI_GetDragonPackage:setSoldOut()
    local vars = self.vars
    local packageData = self.m_packageData 
    local BuyCnt, MaxCnt = packageData:getTotalBuyCntndMaxCnt()
    self:unSetTimerSchedule()

    vars['buyBtn']:setEnabled(false)
    vars['limitMenu']:setVisible(false)
    vars['completeNode']:setVisible(true)

    local str = '{@impossible}' .. self:getPossiobleCntString()
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
        if (animator == nil) then
            break
        end
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

function UI_GetDragonPackage:getPossiobleCntString()
    local packageData = self.m_packageData
    local BuyCnt, MaxCnt = packageData:getTotalBuyCntndMaxCnt()
    return Str('구매 가능 {1}/{2}', (MaxCnt - BuyCnt), MaxCnt)
end

-------------------------------------
-- function setBuyButton
-- @brief 구매 버튼 설정
-------------------------------------
function UI_GetDragonPackage:setBuyButton()
    local vars = self.vars
    local isPopUp = self.m_isPopUp
    --구매 성공 Call Back
    local function cb_func()
        UI_ToastPopup(Str('보상이 우편함으로 전송되었습니다.'))
        local packageData = self.m_packageData
        --Main Product refresh
        self.m_mainProduct = packageData:getPossibleProduct()

        if (self.m_mainProduct == nil) then --더 이상 상품이 없으면 Close
            if (isPopUp) then
                self:click_closeBtn()
            else
                self:setSoldOut()
            end
            return
        end

        self:refresh()
    end

    vars['buyBtn']:registerScriptTapHandler(function() 
        local did = self.m_packageData:getDragonID()
        --도감에 있는 유저인지 확인한다
        local hasDragon = g_bookData:isExist_byDidAndEvolution(did, 1)
        if (hasDragon == false) then --드래곤을 가지고 있지않다면  restart
            MakeSimplePopup(POPUP_TYPE.OK, Str('잘못된 요청입니다.'), function() CppFunctions:restart() end)
            return
        end
        self.m_mainProduct:buy(cb_func)
    end)
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

--@CHECK
UI:checkCompileError(UI_GetDragonPackage)