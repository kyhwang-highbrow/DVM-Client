local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Exchange
-------------------------------------
UI_EventPopupTab_Exchange = class(PARENT,{
        m_titleText = 'string',

        m_tableExchange = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Exchange:init(owner, struct_event_popup_tab)
    local vars = self:load('event_exchange.ui')

    self.m_tableExchange = struct_event_popup_tab.m_userData

    self:initTableView()

    do
        --local res = self.m_tableExchange['banner']
        local res = 'res/ui/event/banner_exchange_01.png'
        local banner_img = cc.Sprite:create(res)
        if (banner_img) then
            banner_img:setDockPoint(cc.p(0.5, 0.5))
            banner_img:setAnchorPoint(cc.p(0.5, 0.5))
            vars['bannerNode']:addChild(banner_img)
        end
    end
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_EventPopupTab_Exchange:initTableView()
    local node = self.vars['itemNode']
    --node:removeAllChildren()

    local l_item_list = g_exchangeData:getProductList(self.m_tableExchange['group_type'])
    
    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(400 + 10, 420)
    table_view:setCellUIClass(UI_ExchangeProductListItem)
    table_view:setItemList(l_item_list)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Exchange:onEnterTab()
    local vars = self.vars
end
