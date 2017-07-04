local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_MasterRoadPopup
-------------------------------------
UI_MasterRoadPopup = class(PARENT, {
        m_tableView = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MasterRoadPopup:init()
	local vars = self:load('master_road_popup.ui')
	UIManager:open(self, UIManager.SCENE)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_MasterRoadPopup')

	-- @UI_ACTION
	--self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_MasterRoadPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_MasterRoadPopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('퀘스트')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MasterRoadPopup:initUI()
    do -- NPC
        local res = 'res/character/npc/yuria/yuria.spine'
        local animator = MakeAnimator(res)
        --animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        --animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)
        self.vars['npcNode']:addChild(animator.m_node)
        --self.m_npcAnimator = animator
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MasterRoadPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MasterRoadPopup:refresh()

end

-------------------------------------
-- function makeQuestTableView
-------------------------------------
function UI_MasterRoadPopup:makeQuestTableView()
	local node = self.vars['listNode']
	
    do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(160, 108)
        table_view:setCellUIClass(UI_QuestListItem, nil)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        --table_view:setItemList()

        self.m_tableView = table_view
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_MasterRoadPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_MasterRoadPopup)