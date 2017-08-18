local PARENT = UI

-------------------------------------
-- class UI_AdvertisingPopup
-------------------------------------
UI_AdvertisingPopup = class(PARENT,{
        m_selType = 'number',
    })

AD_TYPE = {
    LOBBY = 1, -- 로비 광고 보기
    SHOP = 2, -- 상점 광고 보기
    NONE = 3, -- 광고 없음
}

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
    vars['adBtn']:registerScriptTapHandler(function() self:click_adBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdvertisingPopup:refresh()
    local vars = self.vars
    local ad_type = self.m_selType

    vars['adMenu'..ad_type]:setVisible(true)

    local msg = {
        Str('동영상 광고를 보시면 보상을 획득할 수 있습니다.\n광고를 보시겠습니까?'),
        Str('동영상 광고를 보시면 위 보상중 한개를 획득할 수 있습니다.\n광고를 보시겠습니까?'),
        Str('현재 참여 가능한 동영상 광고가 없다고라.\n동영상 광고가 없더라도 선물은 준다고라.'),
    }
    vars['dscLabel']:setString(msg[ad_type])

    vars['adBtn']:setVisible(ad_type ~= AD_TYPE.NONE)
    vars['cancelBtn']:setVisible(ad_type ~= AD_TYPE.NONE)
    vars['okBtn']:setVisible(ad_type == AD_TYPE.NONE)

    if (ad_type == AD_TYPE.SHOP) then
        self:setRewardList()
    end
end

-------------------------------------
-- function showRewardList
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
    g_advertisingData:showAdv(ad_type, finish_cb)
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_AdvertisingPopup:click_okBtn()
    self:close()
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_AdvertisingPopup:click_cancelBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_AdvertisingPopup)
