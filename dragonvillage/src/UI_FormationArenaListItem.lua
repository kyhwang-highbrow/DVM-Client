local PARENT = class(UI, ITableViewCell:getCloneTable())

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_FormationArenaListItem
-------------------------------------
UI_FormationArenaListItem = class(PARENT,{
		m_tFormationInfo = '',
		m_formation = 'str',
		m_isActivated = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FormationArenaListItem:init(t_data)
    self:load('fomation_arena_popup_item.ui')

	self:makeDataPretty(t_data)
	self.m_isActivated = false

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FormationArenaListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FormationArenaListItem:initButton()
    local vars = self.vars

	vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
    --vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn(ui) end) 외부에서 정의
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FormationArenaListItem:refresh()
	local vars = self.vars
	local table_formation = TableFormationArena()
	
	local formation_type = self.m_formation
	local formation_lv = self.m_tFormationInfo['formation_lv']

	-- 진형 이름
	local formation_name = table_formation:getFormationName(formation_type)
	local formation_str = formation_name -- 콜로세움 (신규) 덱 이름만
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
	
    -- 콜로세움 (신규) : 버프 없음.
end

-------------------------------------
-- function getFormationEnhancePrice
-------------------------------------
function UI_FormationArenaListItem:getFormationEnhancePrice()
	local curr_formation_level = self.m_tFormationInfo['formation_lv']
	local formation_level = self.m_tFormationInfo['formation_lv'] + 1

	return TableReqGold:getTotalReqGold('formation', curr_formation_level, formation_level)
end


-------------------------------------
-- function makeDataPretty
-------------------------------------
function UI_FormationArenaListItem:makeDataPretty(t_data)
	self.m_tFormationInfo = t_data
	self.m_formation = t_data['formation']
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_FormationArenaListItem:click_enhanceBtn()
	local function cb_func()
		self:makeDataPretty(g_formationData:getFormationInfo(self.m_formation))
		self:refresh()
	end

    local ui = UI_FormationDetailPopup(self.m_tFormationInfo)
    ui:setCloseCB(cb_func)
end

--@CHECK
UI:checkCompileError(UI_FormationArenaListItem)
