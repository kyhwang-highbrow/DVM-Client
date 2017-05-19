local PARENT = UI

-------------------------------------
-- class UI_ObtainPopup
-------------------------------------
UI_ObtainPopup = class(PARENT,{
		m_itemKey = '',
		m_itemValue = '',
        m_msg = 'string',
        m_cbOKBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ObtainPopup:init(item_key, item_value, msg, ok_btn_cb)
	self.m_itemKey = item_key
	self.m_itemValue = item_value
    self.m_msg = msg
    self.m_cbOKBtn = ok_btn_cb

    local vars = self:load('popup_obtain.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_ObtainPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ObtainPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ObtainPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ObtainPopup:refresh()
--[[
    local base_node = self.vars['costNode']
	local total_count = table.count(self.m_tCostTable)
	local count = 0

	for item_id, value in pairs(self.m_tCostTable) do 
		local item = UI_ItemCard(item_id, value)
		base_node:addChild(item.root)
		local pos_x = (75 * (1 - total_count)) + (150 * count)
		item.root:setPosition(pos_x, 0) 
		count = count + 1
	end
]]
	local vars = self.vars

	vars['dscLabel']:setString(self.m_msg or Str('보상을 획득했습니다.'))

	local reward_icon = self:getObtainIcon(self.m_itemKey)
	if (reward_icon) then
		vars['iconNode']:addChild(reward_icon)
	end
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_ObtainPopup:getObtainIcon(reward_type)
    local res = nil

    if (reward_type == 'x') then

    elseif (reward_type == 'cash') then
        res = 'res/ui/icon/inbox/inbox_cash.png'

    elseif (reward_type == 'gold') then
        res = 'res/ui/icon/inbox/inbox_gold.png'

    elseif (reward_type == 'stamina_st') then
        res = 'res/ui/icon/inbox/inbox_staminas_st.png'

    elseif (reward_type == 'money') then

    elseif (reward_type == 'lactea') then
        res = 'res/ui/icon/inbox/inbox_lactea.png'

    elseif (reward_type == 'amethyst') then
        res = 'res/ui/icon/inbox/inbox_amethyst.png'

    else
        error('price_type : ' .. price_type)
    end

	if (res) then
		local sprite = cc.Sprite:create(res)
		sprite:setDockPoint(cc.p(0.5, 0.5))
		sprite:setAnchorPoint(cc.p(0.5, 0.5))
		return sprite
	end

	return nil
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_ObtainPopup:click_backKey()
    self:click_okBtn()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_ObtainPopup:click_okBtn()
    if self.m_cbOKBtn then
        self.m_cbOKBtn()
    end

    self:close()
end


--@CHECK
UI:checkCompileError(UI_ObtainPopup)
