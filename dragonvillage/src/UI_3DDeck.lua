local PARENT = UI

-------------------------------------
-- class UI_3DDeck
-------------------------------------
UI_3DDeck = class(PARENT,{
        m_currLeader = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_3DDeck:init()
    local vars = self:load('3d_deck.ui')

    -- 진형 회전 효과를 위한 것
	vars['formationNodeHelper']:setScaleY(0.7)
	vars['formationNodeHelperXAxis']:setRotation3D(cc.Vertex3F(0, 0, 50)) -- 시계방향으로 돌림

    -- 리더 선택에서 사용, 콜로세움에서 사용하지 않음
    vars['arrowSprite']:setVisible(false)
    vars['selectArrowSprite']:setVisible(false)
    vars['selectBgSprite']:setVisible(false)

    --self:initUI()
    --self:initButton()
    --self:refresh()

end

-------------------------------------
-- function setDirection
-------------------------------------
function UI_3DDeck:setDirection(direction, rotate)
    local rotate = rotate or 50
    local vars = self.vars

    -- 진형 회전 효과를 위한 것
    if (direction == 'left') then
	    vars['formationNodeHelper']:setScaleY(0.7)
        vars['formationNodeHelper']:setScaleX(1)
        vars['formationNodeHelperXAxis']:setScaleY(1)
	    vars['formationNodeHelperXAxis']:setRotation3D(cc.Vertex3F(0, 0, rotate)) -- 시계방향으로 돌림

    elseif (direction == 'right') then
        vars['formationNodeHelper']:setScaleY(0.7)
        vars['formationNodeHelper']:setScaleX(-1)
        vars['formationNodeHelperXAxis']:setScaleY(1)
	    vars['formationNodeHelperXAxis']:setRotation3D(cc.Vertex3F(0, 0, -rotate)) -- 시계방향으로 돌림

    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_3DDeck:initUI()
	local vars = self.vars

	-- UI_ReadyScene_Deck의 상수값들
	local ZORDER = 
	{
		BACK_PLATE = 1,
		FOCUS_EFFECT = 2,
		DRAGON_CARD = 3,
	}

	-- 리더 선택 표시
	local leader_idx = self.m_currLeader
    if leader_idx then
	    local leader_pos_x, leader_pos_y = vars['positionNode' .. leader_idx]:getPosition()
	    vars['arrowSprite']:setPosition(leader_pos_x, leader_pos_y + ARROW_POS_Y)
	    vars['selectArrowSprite']:setVisible(false)
	
	    -- 선택 발판은 떼어낸뒤 덱 plate위에 얹는다. 
	    vars['selectBgSprite']:setPosition(0,0)
	    vars['selectBgSprite']:retain()
	    vars['selectBgSprite']:removeFromParent()
	    vars['positionNode' .. leader_idx]:addChild(vars['selectBgSprite'], ZORDER.FOCUS_EFFECT)
	    vars['selectBgSprite']:release()
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_3DDeck:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_3DDeck:refresh()
    local vars = self.vars
end

-------------------------------------
-- function actionForChangeDeck_Immediately
-- @brief UI_ReadyScene_Deck:actionForChangeDeck_Immediately(l_pos_list)와 같은 기능인데... 어떻게 사용할지 고민중
-------------------------------------
function UI_3DDeck:actionForChangeDeck_Immediately(l_pos_list)
	local vars = self.vars
	local order_std = 10

	for i, node_space in ipairs(l_pos_list) do
		-- 드래곤 카드
		vars['positionNode' .. i]:setPosition(node_space['x'], node_space['y'])
		--vars['positionNode' .. i]:setLocalZOrder(order_std - i)
        vars['positionNode' .. i]:setLocalZOrder(2048 - node_space['y'])
	end

	-- z_order 정렬
	vars['arrowSprite']:setLocalZOrder(order_std)
	vars['selectBgSprite']:setLocalZOrder(order_std)
	vars['selectArrowSprite']:setLocalZOrder(order_std)
end

-------------------------------------
-- function getRotatedPosList
-- @brief 테이블을 통해 받은 좌표를 화면 축 회전에 의한 값으로 환산한다.
-- @param formation : 없으면 현재 포지션 이용
-------------------------------------
function UI_3DDeck:getRotatedPosList(formation)
	local vars = self.vars
	local formation = formation or self.m_currFormation

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

-------------------------------------
-- function setDragonObjectList
-------------------------------------
function UI_3DDeck:setDragonObjectList(l_deck)
    local vars = self.vars

    -- DC : DragonCard
    local DC_POS_Y = 50
	local DC_SCALE_ON_PLATE = 0.7
	local DC_SCALE = 0.61
	local DC_SCALE_PICK = (DC_SCALE * 0.8)

    -- doid list를 순회하며 deck의 카드 생성
    for idx=1, 5 do
        vars['positionNode' .. idx]:removeAllChildren()
	
		local t_dragon_data = l_deck[idx]
        if t_dragon_data then
		    local ui = UI_DragonCard(t_dragon_data)
		    ui.root:setPosition(0, DC_POS_Y)
		
		    -- 찰랑찰랑 하는 연출
		    cca.uiReactionSlow(ui.root, DC_SCALE_ON_PLATE, DC_SCALE_ON_PLATE, DC_SCALE_PICK)
		
            --[[
		    ui.vars['clickBtn']:registerScriptTapHandler(function() 
			    self:click_dragonCard(idx, t_dragon_data)
		    end)
            --]]

		    -- 설정된 드래곤 표시 없애기
		    ui:setReadySpriteVisible(false)

		    vars['positionNode' .. idx]:addChild(ui.root)--, ZORDER.DRAGON_CARD)
        end
	end
end

-------------------------------------
-- function setFormation
-------------------------------------
function UI_3DDeck:setFormation(formation)
    local formation = formation or 'attack'
    local l_pos_list = self:getRotatedPosList(formation)

	-- 진형 위치 변경
	self:actionForChangeDeck_Immediately(l_pos_list)
end