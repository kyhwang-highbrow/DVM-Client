local PARENT = UI

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_FormationArenaPopup
-------------------------------------
UI_FormationArenaPopup = class(PARENT,{
		m_tableView = 'TableView',
		m_currFormation = 'str',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FormationArenaPopup:init(curr_formation_type)
    local vars = self:load('fomation_arena_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_FormationArenaPopup')

	-- 멤버 변수
	self.m_currFormation = curr_formation_type

	-- 통신 후 UI 출력
	local cb_func = function()
		self:initUI()
		self:initButton()
		self:refresh()
	end 
	self:getStageServerInfo(cb_func)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FormationArenaPopup:initUI()
    local vars = self.vars
	self:makeTableViewFormation()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FormationArenaPopup:initButton()
    local vars = self.vars

	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FormationArenaPopup:refresh()
end

-------------------------------------
-- function makeTableViewFormation
-------------------------------------
function UI_FormationArenaPopup:makeTableViewFormation()
	local vars = self.vars
	local node = vars['listNode']

    local l_formation = g_formationArenaData:getFormationInfoList()

	do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 생성 콜백
		local function create_func(ui)
			ui.vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn(ui) end)
			ui.m_isActivated = (self.m_currFormation == ui.m_tFormationInfo['formation'])
			ui:refresh()
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view_td = UIC_TableViewTD(node)
        table_view_td.m_cellSize = cc.size(595, 155)
        table_view_td.m_nItemPerCell = 2
        table_view_td:setCellUIClass(UI_FormationArenaListItem, create_func)
        table_view_td:setItemList(l_formation)

        self.m_tableView = table_view_td
    end
end

-------------------------------------
-- function getStageServerInfo
-- @brief 서버로 부터 정보를 가져와서 저장한다.
-------------------------------------
function UI_FormationArenaPopup:getStageServerInfo(cb_func)
	cb_func()
end

-------------------------------------
-- function makeDataPretty
-- @brief 서버로부터 가져온 정보를 사용하기 좋게 가공한다.
-------------------------------------
function UI_FormationArenaPopup:makeDataPretty(ret)
end

-------------------------------------
-- function click_selectBtn
-- @brief 개별 리스트 아이템에 부여되는 선택 함수
-------------------------------------
function UI_FormationArenaPopup:click_selectBtn(selected_ui)
	local formation_type = selected_ui.m_formation
	self.m_currFormation = formation_type

	for _, t_item in pairs(self.m_tableView.m_itemList) do
		local ui = t_item['ui']
        if (ui) then
            ui.m_isActivated = (formation_type == ui.m_formation)
		    ui:refresh()
        end
	end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_FormationArenaPopup:click_closeBtn()
	-- 저장된 closeCB를 인자와 함께 실행시키기 위한 트릭
	self.m_closeCB(self.m_currFormation)
	self.m_closeCB = nil

	self:close()
end


--@CHECK
UI:checkCompileError(UI_FormationArenaPopup)
