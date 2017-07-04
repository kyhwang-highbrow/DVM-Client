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
-- function makePriceNodeVariable
-- @brief 반복 테스트용
-------------------------------------
function UIHelper:repeatTest(sequence_action)
	g_currScene.m_scene:runAction(cc.RepeatForever:create(sequence_action))
end

-------------------------------------
-- function makeItemStr
-------------------------------------
function UIHelper:makeItemStr(t_item)
	local item_id = t_item['item_id']
	local item_name = TableItem:getItemName(item_id)
	local item_cnt = t_item['count']
	if (item_cnt) and (item_cnt > 0) then
		return Str('{@DEEPSKYBLUE}{1} {@MUSTARD}{2}{@DESC}개를 획득하였습니다.', item_name, item_cnt)
	else
		return Str('{@DEEPSKYBLUE}{1}{@DESC}을/를 획득하였습니다.', item_name)
	end
end

-------------------------------------
-- function makeItemStr
-------------------------------------
function UIHelper:makeGoodbyeStr(t_item, dragon_name)
	local item_id = t_item['item_id']
	local rel_name = TableItem:getItemName(item_id)
	local rel_cnt = t_item['count']
	return Str(' {@DEEPSKYBLUE}{1}{@DESC}와/과 작별하여 {@ROSE}{2}{@DESC}를 {@MUSTARD}{3}{@DESC}개 획득했습니다.', dragon_name, rel_name, rel_cnt)
end

-------------------------------------
-- function getCardPosX
-- @brief ui_card를 병렬 시켰을 때의 갯수와 인덱스에 따른 x 좌표를 구한다.
-- @brief 중점 0 기준
-------------------------------------
function UIHelper:getCardPosX(total_cnt, idx)
	return -(150/2 * (total_cnt - 1)) + (150 * (idx - 1))
end