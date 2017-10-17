local PARENT = UI

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_FormationPopup
-------------------------------------
UI_FormationPopup = class(PARENT,{
		m_tableView = 'TableView',
		m_currFormation = 'str',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FormationPopup:init(curr_formation_type)
    local vars = self:load('fomation_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_FormationPopup')

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
function UI_FormationPopup:initUI()
    local vars = self.vars
	self:makeTableViewFormation()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FormationPopup:initButton()
    local vars = self.vars

	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FormationPopup:refresh()
end

-------------------------------------
-- function makeTableViewFormation
-------------------------------------
function UI_FormationPopup:makeTableViewFormation()
	local vars = self.vars
	local node = vars['listNode']

	local l_formation = g_formationData:getFormationInfoList()

	do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 생성 콜백
		local function create_cb_func(ui)
			ui.vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn(ui) end)
			ui.m_isActivated = (self.m_currFormation == ui.m_tFormationInfo['formation'])
			ui:refresh()
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(820, 125)
        table_view:setCellUIClass(UI_FormationListItem, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_formation)

        self.m_tableView = table_view
    end
end

-------------------------------------
-- function getStageServerInfo
-- @brief 서버로 부터 정보를 가져와서 저장한다.
-------------------------------------
function UI_FormationPopup:getStageServerInfo(cb_func)
	cb_func()
end

-------------------------------------
-- function makeDataPretty
-- @brief 서버로부터 가져온 정보를 사용하기 좋게 가공한다.
-------------------------------------
function UI_FormationPopup:makeDataPretty(ret)
end

-------------------------------------
-- function click_selectBtn
-- @brief 개별 리스트 아이템에 부여되는 선택 함수
-------------------------------------
function UI_FormationPopup:click_selectBtn(selected_ui)
	local formation_type = selected_ui.m_formation
	self.m_currFormation = formation_type

	for _, t_item in pairs(self.m_tableView.m_itemList) do
		local ui = t_item['ui']

		ui.m_isActivated = (formation_type == ui.m_formation)
		ui:refresh()
	end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_FormationPopup:click_closeBtn()
	local function cb_func()
		-- 저장된 closeCB를 인자와 함께 실행시키기 위한 트릭
		self.m_closeCB(self.m_currFormation)
		self.m_closeCB = nil

		self:close()
	end
	self:doActionReverse(cb_func, 1/2, false)
end


--@CHECK
UI:checkCompileError(UI_FormationPopup)
