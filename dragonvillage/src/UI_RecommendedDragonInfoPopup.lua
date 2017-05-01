local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_RecommendedDragonInfoPopup
-------------------------------------
UI_RecommendedDragonInfoPopup = class(PARENT,{
		m_modeID = 'num',
		m_dungeonLV = 'num',
		m_selectStageID = 'num',

		m_tableViewDungeon = 'TableView',
		m_tableViewRecommendParty = 'TableView',
		m_tableViewSuccessDragon = 'TableView',


    })

UI_RecommendedDragonInfoPopup.PARTY = 1
UI_RecommendedDragonInfoPopup.DRAGON = 2

--[[
	['key'] = ['mode_id']
	['data'] = {
		['ani']='nest_dungeon_gold';
		['is_open']=1;
		['sub_mode']=0;
		['t_name']='황금 던전';
		['res']='res/ui/a2d/nest_dungeon/nest_dungeon.vrp';
		['bonus_rate']=0;
		['mode_id']=1240000;
		['major_day']='mon';
		['bonus_value']='';
		['next_invalid_at']=1494183600000;
		['days']='mon,tue,wed,thu,fri,sat,sun';
		['mode']=4;
		['t_info']='골드 획득 가능';
		['next_valid_at']=1493609251000;
	}
--]]

-------------------------------------
-- function init
-------------------------------------
function UI_RecommendedDragonInfoPopup:init(info)
    local vars = self:load('dragon_ranking.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RecommendedDragonInfoPopup')

    self:initUI()
    self:initButton()
    self:refresh()

	self.m_modeID = info['key']
	self.m_dungeonLV = 1
	local stage_id = self.m_modeID + self.m_dungeonLV
	g_stageData:requestStageInfo(stage_id, finish_cb)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_RecommendedDragonInfoPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RecommendedDragonInfoPopup'
    self.m_titleStr = Str('공략 드래곤 정보')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RecommendedDragonInfoPopup:initUI()
    local vars = self.vars
	self:makeTableView_dungeon()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_RecommendedDragonInfoPopup:initTab()
    local vars = self.vars
    self:addTab(UI_RecommendedDragonInfoPopup.PARTY, vars['partyBtn'], vars['partyNode'])
    self:addTab(UI_RecommendedDragonInfoPopup.DRAGON, vars['dragonBtn'], vars['dragonNode'])
    self:setTab(UI_RecommendedDragonInfoPopup.PARTY)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RecommendedDragonInfoPopup:initButton()
    local vars = self.vars

	vars['levelBtn']:registerScriptTapHandler(function() self:click_levelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RecommendedDragonInfoPopup:refresh()
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_RecommendedDragonInfoPopup:onChangeTab(tab, first)
	local vars = self.vars
	
	-- 최초 생성만 실행
	if (first) then
		self:makeTableView_dragon(tab)
	end
end

-------------------------------------
-- function makeTableView_dungeon
-------------------------------------
function UI_RecommendedDragonInfoPopup:makeTableView_dungeon()
	local vars = self.vars
	local node = vars['dungeonNode']
	--[[
	do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 퀘스트 팝업 자체를 각 아이템이 가지기 위한 생성 콜백
		local create_cb_func = function(ui)
			local function click_dungeonBtn()
				self:refresh()
			end
			ui.vars['dungeonBtn']:registerScriptTapHandler(click_dungeonBtn)
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1160, 108)
        table_view:setCellUIClass(UI_RecommendedDragonInfoListItem_Dungeon, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        --table_view:setItemList()

        self.m_tableViewDungeon = table_view
    end
	--]]
end

-------------------------------------
-- function makeTableView_dragon
-------------------------------------
function UI_RecommendedDragonInfoPopup:makeTableView_dragon()
end

-------------------------------------
-- function click_levelBtn
-------------------------------------
function UI_RecommendedDragonInfoPopup:click_levelBtn()
	ccdisplay('LEVEL BTN')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RecommendedDragonInfoPopup:click_exitBtn()
    self:close()
end


--@CHECK
UI:checkCompileError(UI_RecommendedDragonInfoPopup)
