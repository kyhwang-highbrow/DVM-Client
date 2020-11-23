local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_EventPopupTab_HBShop_Coupon
-------------------------------------
UI_EventPopupTab_HBShop_Coupon = class(PARENT,{
        m_lCouponList = 'table',
        m_tableView = 'UIC_TableView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_HBShop_Coupon:init(coupon_list)
    local vars = self:load('event_capsule_coupon.ui')
    UIManager:open(self, UIManager.SCENE)
    
    -- @UI_ACTION
    self:doActionReset()
    self:doAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventPopupTab_HBShop_Coupon')

    self.m_lCouponList = coupon_list

    self:initUI()
	self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_EventPopupTab_HBShop_Coupon:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_EventPopupTab_HBShop_Coupon'
    self.m_bVisible = true
    self.m_titleStr = Str('쿠폰')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_HBShop_Coupon:initUI()
    local vars = self.vars
    self:init_tableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_HBShop_Coupon:initButton()
	local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_HBShop_Coupon:refresh()
	local vars = self.vars

    -- 비어있다면..!
    if (table.count(self.m_lCouponList) == 0) then
        vars['emptySprite']:setVisible(true)
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EventPopupTab_HBShop_Coupon:click_exitBtn()
    self:close()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_EventPopupTab_HBShop_Coupon:init_tableView()
    local node = self.vars['listNode']
    local l_item_list = self.m_lCouponList

    for idx, t_data in pairs(l_item_list) do
        t_data['idx'] = idx
    end

    -- 생성 콜백
    local function create_func(ui, data)
        -- 삭제 버튼
        ui.vars['deleteBtn']:registerScriptTapHandler(function()
            local coupon_id = data['id']
            local function cb_func()
                local idx = data['idx']
                self.m_tableView:delItem(data['idx'])
                self.m_lCouponList[idx] = nil
                self:refresh()
            end
            g_shopDataNew:request_delCoupon(coupon_id, cb_func)
        end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1160, 108 + 3)
    table_view:setCellUIClass(self.makeCellUI, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    self.m_tableView = table_view
end

-------------------------------------
-- function makeCellUI
-- @static
-- @brief 테이블 셀 생성
-------------------------------------
function UI_EventPopupTab_HBShop_Coupon.makeCellUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('event_capsule_coupon_item.ui')

    -- 여기서 name은 하이브로 api를 통해 넘어온 값
    local name = t_data['name']
    if (name == '아쿠아리움의 알') then
        name = '아쿠아리움 C의 알'
    end

    -- 보상 이름
    local full_name = TableHighbrow:getFullName(t_data['game'], Str(name) )
    vars['itemLabel']:setString(full_name)

    -- 쿠폰 번호
    local coupon = t_data['coupon']
    local coupon_str = Str('쿠폰 번호 : {1}', coupon)
    vars['couponLabel']:setString(coupon_str)
    
    -- 발행일
    local dateFormat = Str('%Y년 %m월 %d일')
    local date = os.date(dateFormat, t_data['received_at']/1000)
    vars['timeLabel']:setString(date)

    -- 아이콘
    local t_item = TableHighbrow:find(t_data['game'], name)
    if (t_item) then
        local res = t_item['res']
        local product_icon = IconHelper:getIcon(res)
        vars['itemNode']:addChild(product_icon)
    end

    -- 쿠폰 번호 복사 버튼
    vars['copyBtn']:registerScriptTapHandler(function()
        SDKManager:copyOntoClipBoard(coupon)
        UIManager:toastNotificationGreen(Str('쿠폰 번호가 복사되었습니다.'))
    end)

	return ui
end
