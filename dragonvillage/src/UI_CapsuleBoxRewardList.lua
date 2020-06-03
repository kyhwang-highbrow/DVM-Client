local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_CapsuleBoxRewardList
-------------------------------------
UI_CapsuleBoxRewardList = class(PARENT,{
		m_structCapsuleBox = '',
		m_tableView = '',
		m_lChanceLabelList = 'List<UIC_Label>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBoxRewardList:init(struct_capsule_box)
	local vars = self:load('capsule_box_reward.ui')
	UIManager:open(self, UIManager.POPUP)
	
	self.m_structCapsuleBox = struct_capsule_box

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_CapsuleBoxRewardList')

	self:initUI()
	self:initTab()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBoxRewardList:initUI()
	local vars = self.vars

	self.m_lChanceLabelList = {}

	local l_rate = self.m_structCapsuleBox:getRateByRankTable()
	for rank, rate in pairs(l_rate) do
		-- 등급 이름
		vars['tabLabel' .. rank]:setString(Str('{1}등급', rank))

		-- 등급별 비율
		vars['chanceLabel' .. rank]:setString(string.format('%.2f%%', rate * 100))

		table.insert(self.m_lChanceLabelList, vars['chanceLabel' .. rank])
	end
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_CapsuleBoxRewardList:initTab()
    local vars = self.vars
	for i = 1, 6 do
		self:addTabWithLabel(i, vars['tabBtn' .. i], vars['tabLabel' .. i])
	end
    self:setTab(1)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_CapsuleBoxRewardList:onChangeTab(tab, first)
	local vars = self.vars
	self:makeQuestTableView(tab)

	-- 탭 전환시 바뀌는 색이 2가지인데 특이한 경우인 것 같아서 UI에서 직접 구현
	-- 나중에 사용처가 늘어나면 n개의 label 색상 일괄 변환하도록 iTabUI 수정해야하는데
	-- 컬러는 가변적이기 힘듬
	for i, label in ipairs(self.m_lChanceLabelList) do
		local color
		if (tab == i) then
			color = cc.c4b(0, 0, 0, 255)
		else
			color = cc.c4b(240, 215, 159, 255)
		end

		label:setTextColor(color)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBoxRewardList:initButton()
	local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    -- 캡슐 뽑기 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'capsule_box_help')
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBoxRewardList:refresh()
	local vars = self.vars
end

-------------------------------------
-- function makeQuestTableView
-------------------------------------
function UI_CapsuleBoxRewardList:makeQuestTableView(tab)
    local vars = self.vars
	local node = vars['listNode']
	local rank = tab

	-- 등급별 상품 내용
	local l_reward = self.m_structCapsuleBox:getRankRewardList(rank)

    do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(200 + 10, 230)
        table_view:setCellUIClass(self.makeRewardCell)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
		table_view:setAlignCenter(true)
        table_view:setItemList(l_reward)

        self.m_tableView = table_view
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_CapsuleBoxRewardList:click_closeBtn()
    self:close()
end

-------------------------------------
-- function makeRewardCell
-------------------------------------
function UI_CapsuleBoxRewardList.makeRewardCell(struct_reward)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	ui:load('capsule_box_reward_item.ui')

	local vars = ui.vars

	local item_id = struct_reward['item_id']
	local item_cnt = struct_reward['item_cnt']

	-- 보상 아이콘
	local item_card = UI_ItemCard(item_id, item_cnt)
	vars['itemNode']:addChild(item_card.root)
	item_card.root:setSwallowTouch(false)

	-- 보상 이름
	local name = UIHelper:makeItemNamePlainByParam(item_id)
	vars['rewardLabel']:setString(name)
	vars['rewardLabel']:setLineBreakWithoutSpace(true)

	return ui
end

--@CHECK
UI:checkCompileError(UI_CapsuleBoxRewardList)
