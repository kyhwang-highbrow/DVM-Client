-------------------------------------
-- class UI_CollectionStoryPopup_ApplyTeamTab
-------------------------------------
UI_CollectionStoryPopup_ApplyTeamTab = class({
        vars = '',

        -- 각 덱에 붙어있을 모션스트릭 리스트
		m_lMotionStreakList = 'cc.motionStreak',

        m_bFirstDeckAction = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:init(ui)
    self.vars = ui.vars
    self.m_bFirstDeckAction = true
    self.vars['leaderSprite']:setVisible(false)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:onEnterTab(first)
    if first then
        self:initUI()

        local vars = self.vars
        local uic_sort_list = MakeUICSortList_teamList(vars['teamBtn'], vars['teamLabel'])

        -- 버튼을 통해 정렬이 변경되었을 경우
        local function sort_change_cb(sort_type)
            local deck_name = sort_type
            local l_ret = g_dragonUnitData:getDragonUnitList_deck(deck_name)

            self:init_tableViewDragonUnitList(l_ret)

            do -- 덱
                local l_deck, formation = g_deckData:getDeck(deck_name)
                self:updateFormation(formation, true)--self.m_bFirstDeckAction)
                self.m_bFirstDeckAction = false

                for i=1, 5 do
                    vars['chNode' .. i]:removeAllChildren()
                    ccdump(l_deck[i])
                    local doid = l_deck[i]
                    if doid then
                        local dragon_object = g_dragonsData:getDragonObject(doid)
                        local ui = UI_DragonCard(dragon_object)
                        vars['chNode' .. i]:addChild(ui.root)
                        ui.root:setScale(0.8)
                    end
                end
            end
        end
        uic_sort_list:setSortChangeCB(sort_change_cb)

        -- 전체를 선택
        uic_sort_list:setSelectSortType('1')
    end
end

-------------------------------------
-- function init_tableViewDragonUnitList
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:init_tableViewDragonUnitList(l_ret)
    local node = self.vars['applyDragonListNode']
    node:removeAllChildren()

    local l_item_list = l_ret

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(790, 150 + 5)
    table_view:setCellUIClass(UI_CollectionStoryPopupApplyItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    table_view:makeDefaultEmptyDescLabel(Str('적용 팀 효과가 없습니다.'))
end


local TOTAL_POS_CNT = 5

-- positionNode에 붙어있는 노드들의 z-order
local ZORDER = 
{
	BACK_PLATE = 1,
	FOCUS_EFFECT = 2,
	DRAGON_CARD = 3,
}

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:initUI()
    local vars = self.vars

	-- 진형 회전 효과를 위한 것
    vars['formationNodeHelper']:setScaleX(0.72)
	vars['formationNodeHelper']:setScaleY(0.7 * 0.72)
	vars['formationNodeHelperXAxis']:setRotation3D(cc.Vertex3F(0, 0, 50))
	
    self.m_lMotionStreakList = {}

    for i=1, TOTAL_POS_CNT do
		vars['chNode'..i]:setLocalZOrder(ZORDER.BACK_PLATE)
				
		-- 모션스트릭을 생성한다.
		local motion_streak = cc.MotionStreak:create(0.3, -1, 50, cc.c3b(255, 255, 255), 'res/missile/motion_streak/motion_streak_water.png')
		vars['formationNodeXAxis']:addChild(motion_streak, 1)
		motion_streak:setAnchorPoint(cc.p(0.5, 0.5))
		motion_streak:setDockPoint(cc.p(0.5, 0.5))
			
		self.m_lMotionStreakList[i] = motion_streak
    end
end

-------------------------------------
-- function updateFormation
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:updateFormation(formation, immediately)
    local vars = self.vars

    local l_pos_list = self:getRotatedPosList(formation)

	-- 상태에 따라 즉시 이동 혹은 움직임 액션 추가
	if immediately then
		self:actionForChangeDeck_Sky(l_pos_list)
	else
		self:actionForChangeDeck_Smooth(l_pos_list)
	end

	-- 덩실 위치 조정
    vars['formationNode']:stopAllActions()
    local action = cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(0, -50)), cc.MoveTo:create(0.1, cc.p(-609, 99)))
	vars['formationNode']:runAction(action)
end

-------------------------------------
-- function actionForChangeDeck_Immediately
-- @brief 각 덱이 진형이 변경되었을 시 액션 : 액션없이 즉시 이동
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:actionForChangeDeck_Immediately(l_pos_list)
	for i, node_space in ipairs(l_pos_list) do
		-- 드래곤 카드
		vars['positionNode' .. i]:setPosition(node_space['x'], node_space['y'])
		vars['positionNode' .. i]:setLocalZOrder(1000 - node_space['y'])

		-- 모션스트릭
		self.m_lMotionStreakList[i]:setPosition(node_space['x'], node_space['y'])
	end
end

-------------------------------------
-- function actionForChangeDeck_Sky
-- @brief 각 덱이 진형이 변경되었을 시 액션 : 하늘로 솟았다가 내려온다.
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:actionForChangeDeck_Sky(l_pos_list)
	local vars = self.vars
	for i, node_space in ipairs(l_pos_list) do
		vars['positionNode' .. i]:setLocalZOrder(1000 - node_space['y'])
			
		local motion_streak = self.m_lMotionStreakList[i]
			
		-- 배치된 카드에 액션을 준다.
		local out_action = cca.makeBasicEaseMove(0.1, node_space['x'], 2000)
		local in_action = cca.makeBasicEaseMove(0.3 + (0.1 * i), node_space['x'], node_space['y'])
		local action = cc.Sequence:create(out_action, in_action)
		cca.runAction(vars['positionNode' .. i], action, 100)

		-- 모션스트릭에 동일한 액션을 준다.
		local out_action = cca.makeBasicEaseMove(0.1, node_space['x'], 2000)
		local in_action = cca.makeBasicEaseMove(0.3 + (0.1 * i), node_space['x'], node_space['y'])
		local action = cc.Sequence:create(out_action, in_action)
		cca.runAction(motion_streak, action, 101)
	end
end

-------------------------------------
-- function actionForChangeDeck_Smooth
-- @brief 각 덱이 진형이 변경되었을 시 액션 : 부드럽게 바뀐 진형으로 이동
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:actionForChangeDeck_Smooth(l_pos_list)
	local vars = self.vars
	for i, node_space in ipairs(l_pos_list) do
		vars['positionNode' .. i]:setLocalZOrder(1000 - node_space['y'])
			
		local motion_streak = self.m_lMotionStreakList[i]
			
		-- 배치된 카드에 액션을 준다.
		local action = cca.makeBasicEaseMove(0.3, node_space['x'], node_space['y'])
		cca.runAction(vars['positionNode' .. i], action, 100)

		-- 모션스트릭에 동일한 액션을 준다.
		local action = cca.makeBasicEaseMove(0.3, node_space['x'], node_space['y'])
		cca.runAction(motion_streak, action, 101)
	end
end

-------------------------------------
-- function getRotatedPosList
-- @brief 테이블을 통해 받은 좌표를 화면 축 회전에 의한 값으로 환산한다.
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:getRotatedPosList(formation)
	local vars = self.vars

	local length = 150
    local min_x = -length
    local max_x = length
    local min_y = -length
    local max_y = length
    local l_pos_list = TableFormation:getFormationPositionList(formation, min_x, max_x, min_y, max_y)

	local ret_list = {}

	for i, v in ipairs(l_pos_list) do
		vars['posHelper' .. i]:setPosition(v['x'], v['y'])
		local transform = vars['posHelper' .. i]:getNodeToWorldTransform();
		local world_x = transform[12 + 1]
		local world_y = transform[13 + 1]
		local node_space = convertToNodeSpace(vars['formationNodeXAxis'], cc.p(world_x, world_y))

		table.insert(ret_list, node_space)
	end

	return ret_list
end