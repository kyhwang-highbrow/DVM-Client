local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonNewcomerShop
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonNewcomerShop = class(PARENT, {
        m_ncmId = 'number',
    })

-- 최초 1번은 노티를 보여주기 위함
UI_ButtonNewcomerShop.s_tOpenCnt = {}

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonNewcomerShop:init(ncm_id)
    self.m_ncmId = ncm_id
    self:load('button_newcomer_shop.ui')

    do -- 모든 상품 구매한 유저 체크
        -- 상품 리스트 받아옴
        require('TableNewcomerShop')
        local l_product_id = TableNewcomerShop:getNewcomerShopProductList(self.m_ncmId)

        local available_cnt = 0

        -- 개별 상품 생성
        for i,product_id in ipairs(l_product_id) do
            local struct_product = g_shopDataNew:getTargetProduct(product_id)
            if struct_product then
                if (struct_product:checkMaxBuyCount() == true) then
                    available_cnt = (available_cnt + 1)
                end
            end
        end

        -- 모든 상품을 구매한 유저는 오픈 cnt를 늘려서 noti가 뜨지 않도록 처리함
        if (available_cnt <= 0) then
            self:incOpenCnt()
        end

    end

    -- 업데이트 스케줄러
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- 버튼 설정
    local btn = self.vars['btn']
    if btn then
        btn:registerScriptTapHandler(function() self:click_btn() end)
    end
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonNewcomerShop:isActive()
    return true -- 무조건 노출일 경우

    -- 첫 충전 선물이 활성화일 경우 숨김
    --local ret = g_firstPurchaseEventData:isActiveAnnyFirstPurchaseEvent()
    --return (not ret)
end

-------------------------------------
-- function getOpenCnt
-- @brief
-------------------------------------
function UI_ButtonNewcomerShop:getOpenCnt()
    return UI_ButtonNewcomerShop.s_tOpenCnt[self.m_ncmId] or 0
end

-------------------------------------
-- function incOpenCnt
-- @brief
-------------------------------------
function UI_ButtonNewcomerShop:incOpenCnt()
    if (UI_ButtonNewcomerShop.s_tOpenCnt[self.m_ncmId] == nil) then
        UI_ButtonNewcomerShop.s_tOpenCnt[self.m_ncmId] = 0
    end
    UI_ButtonNewcomerShop.s_tOpenCnt[self.m_ncmId] = (UI_ButtonNewcomerShop.s_tOpenCnt[self.m_ncmId] + 1)
end

-------------------------------------
-- function click_btn
-- @brief 버튼 클릭
-------------------------------------
function UI_ButtonNewcomerShop:click_btn()
    self:incOpenCnt()

    require('UI_NewcomerShop')
    local ui = UI_NewcomerShop(self.m_ncmId)

    local function close_cb()
        -- 초보자 선물 팝업 내에서 변동이 일어날 경우 갱신을 위해 호출
        self:callDirtyStatusCB()
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function updateButtonStatus
-------------------------------------
function UI_ButtonNewcomerShop:updateButtonStatus()

end

-------------------------------------
-- function update
-- @brief 매 프레인 호출되는 함수
-------------------------------------
function UI_ButtonNewcomerShop:update(dt)
    local vars = self.vars
    local end_date = (g_newcomerShop:getNewcomerShopEndTimestamp(self.m_ncmId) or 0) / 1000 -- timestamp 1585839600000
    local curr_time = Timer:getServerTime()

    -- 1. 남은 시간 표시 (기간제일 경우에만)
    local time_label = vars['timeLabel']
    if time_label then
        if (0 < end_date) and (curr_time < end_date) then
            local time_millisec = (end_date - curr_time) * 1000
            local str = datetime.makeTimeDesc_timer(time_millisec)
            time_label:setString(str)
        else
            time_label:setString('')
        end
    end

    -- 2. 빨간 느낌표 표시 상태 (실행 후 한번도 보지 않았을 경우 or 보상이 수령 가능한 상태일 경우)
    local noti_sprite = vars['notiSprite']
    if noti_sprite then
        -- 앱 실행 후 최초 1회는 노출
        if (self:getOpenCnt() <= 0) then
            noti_sprite:setVisible(true)
        
        -- 획득 가능한 보상이 있을 경우 노출
        elseif (status == 0) then
            noti_sprite:setVisible(true)

        -- 그 외 경우 미노출
        else
            noti_sprite:setVisible(false)
        end
    end

    do -- 3. 삭제될 건지 확인
        -- 시간이 지난 경우 (제한 시간이 없을 경우 end_date가 0)
        if (g_newcomerShop:isActiveNewcomerShop(self.m_ncmId) == false) then
            self.m_bMarkDelete = true
            self:callDirtyStatusCB()
        end
    end
end