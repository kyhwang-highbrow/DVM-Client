local PARENT = UI

-------------------------------------
-- class UI_AdvertisingPopup
-------------------------------------
UI_AdvertisingPopup = class(PARENT,{
        m_selType = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AdvertisingPopup:init(ad_type)
    local vars = self:load('popup_ad.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_selType = ad_type

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AdvertisingPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- -- 광고 프리로드 요청
    -- AdSDKSelector:adPreload(ad_type)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AdvertisingPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdvertisingPopup:initButton()
    local vars = self.vars
    vars['adBtn1']:registerScriptTapHandler(function() self:click_adBtn() end)
    vars['adBtn2']:registerScriptTapHandler(function() self:click_adBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    --vars['dailyDiaBtn']:registerScriptTapHandler(function() self:click_dailyDiaBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdvertisingPopup:refresh()
    local vars = self.vars
    local ad_type = self.m_selType

    if ad_type and vars['adMenu'..ad_type] then
        vars['adMenu'..ad_type]:setVisible(true)
    end

    local msg = {
        Str('동영상 광고를 보시면 보상을 획득할 수 있습니다.\n광고를 보시겠습니까?'),
        Str('동영상 광고를 보시면 위 보상중 한개를 획득할 수 있습니다.\n광고를 보시겠습니까?'),
        Str('동영상 광고를 보시면 위 보상중 한개를 획득할 수 있습니다.\n광고를 보시겠습니까?'),
        Str('현재 참여 가능한 동영상 광고가 없다고라.\n동영상 광고가 없더라도 선물은 준다고라.'),
    }
    vars['dscLabel']:setString(msg[ad_type])

    if (ad_type == AD_TYPE.RANDOM_BOX_LOBBY) then
        self:setRewardList()
    end
end

-------------------------------------
-- function setRewardList
-------------------------------------
function UI_AdvertisingPopup:setRewardList()
    local node = self.vars['itemNode']
    node:removeAllChildren()

    local reward_list = g_advertisingData.m_rewardList

    local function make_func(data)
        local ui = UI_ItemCard(data['item_id'], data['count'])
        return ui
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.65)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(104, 110)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(reward_list)
    table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬
end

-------------------------------------
-- function click_adBtn
-------------------------------------
function UI_AdvertisingPopup:click_adBtn()
    local ad_type = self.m_selType
    local function finish_cb()
        self:close()
    end
    g_advertisingData:showAd(ad_type, finish_cb)
end

-------------------------------------
-- function click_dailyDiaBtn
-------------------------------------
function UI_AdvertisingPopup:click_dailyDiaBtn()
    self:close()

    -- 월정액 바로가기 
    --g_subscriptionData:openSubscriptionPopup()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_AdvertisingPopup:click_okBtn()
    self:close()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_AdvertisingPopup:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_AdvertisingPopup)
