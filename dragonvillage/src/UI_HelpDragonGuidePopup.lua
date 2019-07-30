local PARENT = UI

-------------------------------------
-- class UI_HelpDragonGuidePopup
-------------------------------------
UI_HelpDragonGuidePopup = class(PARENT,{
		m_focusType = 'string',
		m_focusValue = 'string',
		
		m_tInfo = 'table',
		--[[
			{
				['attr'] = 'fire',
				['role'] = 'defend',
				['rarity'] = 'legend',
			}
		
		--]]
	})

-------------------------------------
-- function init
-------------------------------------
function UI_HelpDragonGuidePopup:init(focus_type, focus_value, t_info)
    local vars = self:load('help_dragon_guide_popup.ui')
    UIManager:open(self, UIManager.POPUP)

	self.m_focusType = focus_type
	self.m_focusValue = focus_value
	self.m_tInfo = t_info

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HelpDragonGuidePopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HelpDragonGuidePopup:initUI()
    local vars = self.vars

    local list_expansion = UIC_ListExpansion()
    local item_name_list = {'role', 'rarity', 'attr'}
    list_expansion:configListExpansion(vars, item_name_list)

    -- 처음부터 특정 아이템을 펼쳐진 상태로 하고싶을 경우
    list_expansion:setDefaultSelectedListItem(self.m_focusType)

	-- 희귀도, 속성, 역할 중 해당하는 값에는 하이라이트
	self:setHighLight()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HelpDragonGuidePopup:initButton()
    self.vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_HelpDragonGuidePopup:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_HelpDragonGuidePopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function setHighLight
-------------------------------------
function UI_HelpDragonGuidePopup:setHighLight()
	local focus_type = self.m_focusType

	-- focus_value에 하이라이트
	if (focus_type == 'attr') then

	elseif (focus_type == 'role') then
	
	elseif (focus_type == 'rarity') then
	
	end
	
	local t_info = self.m_tInfo
	-- 나머지 정보가 존재한다면, 존재하는 정보에는 하이라이트
	if (t_info) then
		if (t_info['attr']) then
		end

		if (t_info['role']) then
		end

		if (t_info['rarity']) then
		end
	end
end