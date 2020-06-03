local PARENT = class(UI, ITableViewCell:getCloneTable())

local COMMON_UI_ACTION_TIME = 0.3

--@jhakiim 20191219 업데이트에서 테이머 레벨 99 확장, but 진형 테이머 스킬 레벨은 70으로 제한
local MAX_LEVEL = 70
-------------------------------------
-- class UI_FormationListItem
-------------------------------------
UI_FormationListItem = class(PARENT,{
		m_tFormationInfo = '',
		m_formation = 'str',
		m_isActivated = 'boolean',

        m_maxLevel = 'number',
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
    self.m_maxLevel = math.min(g_userData:get('lv'), MAX_LEVEL)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FormationListItem:initButton()
    local vars = self.vars

	vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
    --vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn(ui) end) 외부에서 정의
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FormationListItem:refresh()
	local vars = self.vars
	
	local table_formation = TableFormation()
	
	local formation_type = self.m_formation
	local formation_lv = self.m_tFormationInfo['formation_lv']

	-- 진형 이름
	local formation_name = table_formation:getFormationName(formation_type)
	local formation_str = string.format('Lv. %d %s', formation_lv, formation_name)
	vars['fomationLabel']:setString(formation_str)

	-- 진형 효과
	local desc = table_formation:getFormatioDesc(formation_type)
	vars['dscLabel']:setString(desc)

	-- icon
	local icon = IconHelper:getFormationIcon(formation_type, self.m_isActivated)
	vars['iconNode']:removeAllChildren()
	vars['iconNode']:addChild(icon)

	-- 선택 진형
	vars['selectSprite']:setVisible(self.m_isActivated)

	-- 버튼 처리
	vars['maxSprite']:setVisible(false)
	vars['enhanceBtn']:setVisible(false)
	
	-- 최대 레벨
	if (formation_lv >= self.m_maxLevel and g_userData:get('lv') >= 70) then
		vars['maxSprite']:setVisible(true)

	-- 강화가 가능한 상태
	else
		vars['enhanceBtn']:setVisible(true)
        local price = self:getFormationEnhancePrice()
        vars['priceLabel']:setString(comma_value(price))
	end
end

-------------------------------------
-- function getFormationEnhancePrice
-------------------------------------
function UI_FormationListItem:getFormationEnhancePrice()
	local curr_formation_level = self.m_tFormationInfo['formation_lv']
	local formation_level = self.m_tFormationInfo['formation_lv'] + 1

	return TableReqGold:getTotalReqGold('formation', curr_formation_level, formation_level)
end


-------------------------------------
-- function makeDataPretty
-------------------------------------
function UI_FormationListItem:makeDataPretty(t_data)
	self.m_tFormationInfo = t_data
	self.m_formation = t_data['formation']
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_FormationListItem:click_enhanceBtn()
	local function cb_func()
		self:makeDataPretty(g_formationData:getFormationInfo(self.m_formation))
		self:refresh()
	end

    local ui = UI_FormationDetailPopup(self.m_tFormationInfo)
    ui:setCloseCB(cb_func)
end

--@CHECK
UI:checkCompileError(UI_FormationListItem)
