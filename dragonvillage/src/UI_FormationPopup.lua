local PARENT = UI

local COMMON_UI_ACTION_TIME = 0.3

-------------------------------------
-- class UI_FormationPopup
-------------------------------------
UI_FormationPopup = class(PARENT,{
		m_tableView = 'TableView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FormationPopup:init(info)
    local vars = self:load('fomation_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_FormationPopup')

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

	local l_formation = {}

	do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 생성 콜백
		local function create_cb_func(ui)
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1200, 105)
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
-- function click_closeBtn
-------------------------------------
function UI_FormationPopup:click_closeBtn()
	local function cb_func()
		self:close()
	end
	self:doActionReverse(cb_func, 1, false)
end


--@CHECK
UI:checkCompileError(UI_FormationPopup)
