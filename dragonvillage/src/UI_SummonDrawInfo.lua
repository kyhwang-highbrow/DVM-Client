local PARENT = UI

-------------------------------------
-- class UI_SummonDrawInfoPopup
-------------------------------------
UI_SummonDrawInfoPopup = class(PARENT,{
		m_item_id = 'number'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SummonDrawInfoPopup:init(item_id)
	local vars = self:load('package_global_anniversary_popup.ui')
	UIManager:open(self, UIManager.POPUP)
    self.m_item_id = item_id

    if (not item_id) then
        self.m_item_id = 700601 -- defult : 토파즈 뽑기권
    end

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SummonDrawInfoPopup')

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SummonDrawInfoPopup:initUI()
	local vars = self.vars
    vars['titleLabel']:setString(Str('토파즈 드래곤 뽑기권'))
    local dragon_list_str = TablePickDragon:getCustomList(self.m_item_id)
    local dragon_list = plSplit(dragon_list_str, ',') -- 아이템별로 리스트 생성

    for i, dragon_id in ipairs(dragon_list) do
        local list_item_ui = UI_SummonDrawInfoListItem(dragon_id)
        vars['itemNode'.. i]:addChild(list_item_ui.root)
    end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SummonDrawInfoPopup:initButton()
	local vars = self.vars
	
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SummonDrawInfoPopup:refresh()
	local vars = self.vars

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SummonDrawInfoPopup:click_closeBtn()
    self:close()
end


--@CHECK
UI:checkCompileError(UI_SummonDrawInfoPopup)
