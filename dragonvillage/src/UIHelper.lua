-------------------------------------
-- table UIHelper
-------------------------------------
UIHelper = {}

-------------------------------------
-- function makePriceNodeVariable
-- @brief 가격라벨과 아이콘을 가변적으로 예쁘게 배치
-------------------------------------
function UIHelper:makePriceNodeVariable(bg_node, icon_node, price_label)
    local str_width = price_label:getStringWidth()
	local icon_width, _ = icon_node:getNormalSize()
    icon_width = icon_width * icon_node:getScale()

    local total_width = str_width + icon_width + 10

    local icon_x = -(total_width/2) + (icon_width/2)
    icon_node:setPositionX(icon_x)
    local label_x = (icon_width/2)
    price_label:setPositionX(label_x)

    local _, height = bg_node:getNormalSize()
    bg_node:setNormalSize(total_width, height)
end

-------------------------------------
-- function repeatTest
-- @brief 반복 테스트용
-------------------------------------
function UIHelper:repeatTest(sequence_action)
	g_currScene.m_scene:runAction(cc.RepeatForever:create(sequence_action))
end

-------------------------------------
-- function makeItemName
-- @example 다이아 100개
-- @example 룬 확정권
-------------------------------------
function UIHelper:makeItemName(t_item)
	local item_id = t_item['item_id']
	local item_name = TableItem:getItemName(item_id)
	local item_cnt = t_item['count']
	if (item_cnt) and (item_cnt > 0) then
		return Str('{@item_name}{1} {@count}{2}개', item_name, item_cnt)
	else
		return Str('{@item_name}{1}', item_name)
	end
end

-------------------------------------
-- function makeItemStr
-- @example 다이아 100개를 획득하였습니다.
-- @example 룬 확정권을 획득하였습니다.
-------------------------------------
function UIHelper:makeItemStr(t_item)
	local item_id = t_item['item_id']
	local item_name = TableItem:getItemName(item_id)
	local item_cnt = t_item['count']
	if (item_cnt) and (item_cnt > 0) then
		return Str('{@item_name}{1} {@count}{2}{@DESC}개를 획득하였습니다.', item_name, item_cnt)
	else
		return Str('{@item_name}{1}{@DESC}(을)를 획득하였습니다.', item_name)
	end
end

-------------------------------------
-- function makeItemStr
-------------------------------------
function UIHelper:makeGoodbyeStr(t_item, dragon_name)
	local item_id = t_item['item_id']
	local rel_name = TableItem:getItemName(item_id)
	local rel_cnt = t_item['count']
	return Str(' {@item_name}{1}{@DESC}과(와) 작별하여 {@ROSE}{2}{@DESC}(을)를 {@count}{3}{@DESC}개 획득했습니다.', dragon_name, rel_name, rel_cnt)
end

-------------------------------------
-- function getCardPosX
-- @brief ui_card를 병렬 시켰을 때의 갯수와 인덱스에 따른 x 좌표를 구한다.
-- @brief 중점 0 기준
-------------------------------------
function UIHelper:getCardPosX(total_cnt, idx)
	return -(150/2 * (total_cnt - 1)) + (150 * (idx - 1))
end

-------------------------------------
-- function reattachNode
-- @brief 노드를 떼어서 새로운 부모에게 붙인다.
-------------------------------------
function UIHelper:reattachNode(new_parent, node, z_order)
	node:retain()
	node:removeFromParent(false)
	new_parent:addChild(node, z_order)
	node:release()
end

-------------------------------------
-- function autoNoti
-- @brief 탭이나 버튼 등에 자동으로 노티를 붙여준다.
-- @param category_bool_map : {항목 : true/false} 의 맵 
-- @param noti_ui_table : noti 아이콘 테이블
-- @param ui_key : category와 조합하여 noti 아이콘을 붙일 node를 찾음
-------------------------------------
function UIHelper:autoNoti(category_bool_map, noti_ui_table, ui_key, vars)
    for _, spr in pairs(noti_ui_table) do
		spr:setVisible(false)
	end

	for category, _ in pairs(category_bool_map) do
    	-- 없으면 생성
		if (not noti_ui_table[category]) then
			local icon = IconHelper:getNotiIcon()
			icon:setDockPoint(cc.p(1, 1))
			icon:setPosition(-5, -5)
			vars[category .. ui_key]:addChild(icon)
			noti_ui_table[category] = icon

		-- 있으면 킴
		else
			noti_ui_table[category]:setVisible(true)

		end
    end
end