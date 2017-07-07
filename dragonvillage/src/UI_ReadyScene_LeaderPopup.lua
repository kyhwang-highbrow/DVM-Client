local PARENT = UI

-------------------------------------
-- class UI_ReadyScene_LeaderPopup
-------------------------------------
UI_ReadyScene_LeaderPopup = class(PARENT,{
		m_currLeader = 'number',
		m_lDoidList = 'list',
		m_newLeader = 'number',

        m_tableView = 'UIC_TableView',
    })

local ARROW_POS_Y = 110

-------------------------------------
-- function init
-------------------------------------
function UI_ReadyScene_LeaderPopup:init(l_pos_list, l_doid, leader_idx)
    local vars = self:load('battle_ready_leader_popup_new.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:closeWithAction() end, 'UI_ReadyScene_LeaderPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- initialize
	self.m_currLeader = leader_idx
	self.m_lDoidList = l_doid
	self.m_newLeader = leader_idx

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadyScene_LeaderPopup:initUI()
	local vars = self.vars
    self:makeTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadyScene_LeaderPopup:initButton()
	local vars = self.vars

	vars['closeBtn']:registerScriptTapHandler(function() self:closeWithAction() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ReadyScene_LeaderPopup:refresh()
end

-------------------------------------
-- function makeTableViewFormation
-------------------------------------
function UI_ReadyScene_LeaderPopup:makeTableView()
	local vars = self.vars
	local node = vars['listNode']

	local l_doid_list = self.m_lDoidList

	do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 생성 콜백
		local function create_cb_func(ui)

		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(820, 100)
        table_view:setCellUIClass(self.makeLeaderCellUI, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_doid_list)

        self.m_tableView = table_view
    end
end

-------------------------------------
-- function makeLeaderCellUI
-- @static
-- @brief 테이블 셀 생성
-------------------------------------
function UI_ReadyScene_LeaderPopup.makeLeaderCellUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('battle_ready_leader_popup_item.ui')

	--[[
	if (not t_dragon_data) or (not t_dragon_data['did']) then
		vars['dragonLabel']:setString('없음')
		vars['buffLabel']:setString(Str('리더 버프 없음'))
		return
	end

	-- 드래곤 이름
	local dragon_name = TableDragon:getDragonName(t_dragon_data['did'])
	vars['dragonLabel']:setString(dragon_name)

	-- 드래곤 버프 설명 (버프 이름 있어야 할듯?)
	local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
	local leader_skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx('Leader')
	if (leader_skill_info) then
		local desc = leader_skill_info:getSkillDesc()
		vars['buffLabel']:setString(desc)
	else
		vars['buffLabel']:setString(Str('리더 버프 없음'))
	end
    ]]
	return ui
end

--@CHECK
UI:checkCompileError(UI_ReadyScene_LeaderPopup)
