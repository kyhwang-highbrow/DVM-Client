local PARENT = class(UI, ITableViewCell:getCloneTable())

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_FormationListItem
-------------------------------------
UI_FormationListItem = class(PARENT,{
		m_tFormationInfo = '',
		m_formation = 'str',
		m_isActivated = 'boolean',
		m_temp = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FormationListItem:init(t_data)
    self:load('fomation_popup_item.ui')

	self:makeDataPretty(t_data)
	self.m_isActivated = false

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FormationListItem:initUI()
    local vars = self.vars
	local formation_type = self.m_tFormationInfo['formation']
	local table_formation = TableFormation()

	-- 진형 이름
	local formation_name = table_formation:getFormationName(formation_type)
	local formation_lv = self.m_tFormationInfo['formation_lv']
	local formation_str = string.format('%s Lv. %d', formation_name, formation_lv)
	vars['fomationLabel']:setString(formation_str)

	-- 진형 효과
	vars['dscLabel']:setString('진형 효과')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FormationListItem:initButton()
    local vars = self.vars

	vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FormationListItem:refresh()
	local vars = self.vars
	local formation_type = self.m_tFormationInfo['formation']

	-- icon
	local icon = IconHelper:getFormationIcon(formation_type, self.m_isActivated)
	vars['iconNode']:removeAllChildren()
	vars['iconNode']:addChild(icon)

	-- 선택 진형
	vars['selectSprite']:setVisible(self.m_isActivated)
end

-------------------------------------
-- function click_detailBtn
-------------------------------------
function UI_FormationListItem:makeDataPretty(t_data)
	self.m_tFormationInfo = t_data
	self.m_formation = t_data['formation']
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_FormationListItem:click_enhanceBtn()
	ccdisplay('click_enhanceBtn')
end

--@CHECK
UI:checkCompileError(UI_FormationListItem)
