local PARENT = UI

local L_ATTR = {}
L_ATTR['earth'] = 1
L_ATTR['water'] = 2
L_ATTR['fire'] = 3
L_ATTR['light'] = 4
L_ATTR['dark'] = 5

local L_ROLE = {}
L_ROLE['dealer'] = 1
L_ROLE['tanker'] = 2
L_ROLE['supporter'] = 3
L_ROLE['healer'] = 4

local L_RARE = {}
L_RARE['myth'] = 5
L_RARE['legend'] = 4
L_RARE['hero'] = 3
L_RARE['rare'] = 2
L_RARE['common'] = 1

-------------------------------------
-- class UI_HelpDragonGuidePopup
-------------------------------------
UI_HelpDragonGuidePopup = class(PARENT,{
		m_focusType = 'string',
		m_focusValue = 'string',
		
		m_attr = 'string',
        m_role = 'string',
        m_rarity = 'string',
	})

-------------------------------------
-- function init
-------------------------------------
function UI_HelpDragonGuidePopup:init(focus_type, focus_value, t_info)
	self.m_uiName = 'UI_HelpDragonGuidePopup'
    local vars = self:load('help_dragon_guide_popup.ui')
    UIManager:open(self, UIManager.POPUP)

	self.m_focusType = focus_type
	self.m_focusValue = focus_value
	
    if (t_info) then
        self.m_attr = t_info['attr']
        self.m_role =  t_info['role']
        self.m_rarity = t_info['rarity']
    end

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
    local item_list_interval = 10
    list_expansion:configListExpansion(vars, item_name_list, item_list_interval)

    -- 처음부터 특정 아이템을 펼쳐진 상태로 하고싶을 경우
    list_expansion:setDefaultSelectedListItem(nil)
    if self.m_focusType then
        list_expansion:click_listItemBtn(self.m_focusType)
    end
    

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
	local vars = self.vars

    if (self.m_focusType == 'attr') then
        self.m_attr = self.m_focusValue
    elseif (self.m_focusType == 'role') then
        self.m_role = self.m_focusValue
    elseif (self.m_focusType == 'rarity') then
        self.m_rarity = self.m_focusValue
    end

    if (self.m_attr) then
        local attr_num = L_ATTR[self.m_attr] or ''
        if (vars['attrIconNode' .. attr_num]) then
            vars['attrIconNode' .. attr_num]:setVisible(true)
        end
	end

    if (self.m_role) then
	    local role_num = L_ROLE[self.m_role] or ''
        if (vars['roleIconNode' .. role_num]) then
            vars['roleIconNode' .. role_num]:setVisible(true)
        end
        
        if (vars['roleInfoNode' .. role_num]) then
            vars['roleInfoNode' .. role_num]:setVisible(true)
        end
	end

    if (self.m_rarity) then
        local rarity_num = L_RARE[self.m_rarity] or ''
	    if (vars['rarityIconNode' .. rarity_num]) then
            vars['rarityIconNode' .. rarity_num]:setVisible(true)
        end

	    if (vars['rarityInfoNode' .. rarity_num]) then
            vars['rarityInfoNode' .. rarity_num]:setVisible(true)
        end
	end
	
end