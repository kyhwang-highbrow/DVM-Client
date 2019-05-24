local PARENT = UI

-------------------------------------
-- class UI_ReadyScene_LeaderPopup
-------------------------------------
UI_ReadyScene_LeaderPopup = class(PARENT,{
		m_lDoidList = 'list',
		m_leaderIdx = 'number',

        m_tableView = 'UIC_TableView',
    })

local ARROW_POS_Y = 110

-------------------------------------
-- function init
-------------------------------------
function UI_ReadyScene_LeaderPopup:init(l_doid, leader_idx)
    local vars = self:load('battle_ready_leader_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ReadyScene_LeaderPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- initialize
	self.m_lDoidList = l_doid
	self.m_leaderIdx = leader_idx

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

	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
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

	local l_doid_list = {}
    for i, v in pairs(self.m_lDoidList) do
        l_doid_list[i] =  {idx = i, doid = v}
    end

	do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 생성 콜백
		local function create_cb_func(ui, data)
            -- 선택 콜백
            ui.vars['selectBtn']:registerScriptTapHandler(function()
                self:selectLeaderCellUI(ui, data)
            end)

            -- 리더스킬이 없더라도 덱에서는 리더인덱스를 저장하기 때문에 생성시 data에 저장한 정보로 처리
            if (data['no_leader_skill'] == true) then
                ui.vars['selectSprite']:setVisible(false)

            -- 이미 선택되었는지 체크
            elseif (self.m_leaderIdx == data['idx']) then
                ui.vars['selectSprite']:setVisible(true)

            end
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
-- @brief 테이블 셀 생성
-------------------------------------
function UI_ReadyScene_LeaderPopup:selectLeaderCellUI(ui, data)
    self.m_leaderIdx = data['idx']
    for _, t_item in pairs(self.m_tableView.m_itemList) do
        t_item['ui'].vars['selectSprite']:setVisible(self.m_leaderIdx == t_item['data']['idx'])
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

    local idx = t_data['idx']
    local doid = t_data['doid']
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

	-- 환상던전 ReadyScene에서만 환상던전 전용 드래곤 추가
	-- 리더 드래곤이 보유 드래곤 목록에 없을 때, 환상던전 전용 드래곤인지 확인하는 단계
    if (not t_dragon_data) then
        if (string.match(doid,'illusion')) then
            if (g_illusionDungeonData) then
                t_dragon_data = g_illusionDungeonData:getDragonDataFromUid(doid)
            end
        end
    end

    -- 드래곤 카드
	vars['iconNode']:removeAllChildren()
	local card = UI_DragonCard(t_dragon_data)
	vars['iconNode']:addChild(card.root)

    -- 드래곤 정보가 없는 경우
	if (not t_dragon_data) or (not t_dragon_data['did']) then
		vars['nameLabel']:setString('없음')
		vars['dscLabel']:setString(Str('리더 스킬 없음'))
		return
	end

	-- 드래곤 이름
	local dragon_name = TableDragon:getDragonName(t_dragon_data['did'])
	vars['nameLabel']:setString(dragon_name)

	-- 드래곤 버프 설명 (버프 이름 있어야 할듯?)
	local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
	local leader_skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx('Leader')
	if (leader_skill_info) and (leader_skill_info:isActivated()) then
		local desc = leader_skill_info:getSkillDesc()
		vars['dscLabel']:setString(desc)
	else
		vars['dscLabel']:setString('{@SKILL_DESC}' .. Str('리더 스킬 없음'))
        vars['selectBtn']:setVisible(false)
        t_data['no_leader_skill'] = true
	end

	return ui
end

--@CHECK
UI:checkCompileError(UI_ReadyScene_LeaderPopup)
