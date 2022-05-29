local PARENT = UI

-------------------------------------
-- class UI_EventThankAnniversary_rewardPopup
-------------------------------------
UI_EventThankAnniversary_rewardPopup = class(PARENT, {
    m_rewardNum = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventThankAnniversary_rewardPopup:init(reward_num)
    local vars = self:load('event_thanks_anniversary_popup_02.ui')
	UIManager:open(self, UIManager.POPUP)
    self.m_rewardNum = reward_num
	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventThankAnniversary_rewardPopup')

	self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventThankAnniversary_rewardPopup:initUI()
    local vars = self.vars
    local m_rewardNum
    local create_func = function(t_data)
        return UI_ObtainPopup.createMailListUI(t_data)
    end
    
    local item_str
    if (self.m_rewardNum == 1) then
        item_str = '700001;5000,700612;1' -- 다이아 5000, 전설 추천 드래곤 선택권
    else
        item_str = '700651;1,700701;1' -- -- 룬 11개 뽑기 상자, 성장 재료 선택권
        --item_str = '700001;5000,700701;1' -- -- 다이아 5000, 성장 재료 선택권
    end

    local l_item_str = pl.stringx.split(item_str, ',')
    local l_item = {}
    for i, content_str in ipairs(l_item_str) do
        local l_content = plSplit(content_str, ';')
        t_item = {['item_id'] = tonumber(l_content[1]), ['count'] = tonumber(l_content[2]) or 0}
        table.insert(l_item, t_item)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view.m_defaultCellSize = cc.size(550, 105)
    table_view:setCellUIClass(create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventThankAnniversary_rewardPopup:initButton()
    local vars = self.vars
	vars['okBtn']:registerScriptTapHandler(function() self:close(1) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversary_rewardPopup:refresh()

end
