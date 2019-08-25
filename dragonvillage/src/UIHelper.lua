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

    if bg_node then
        local _, height = bg_node:getNormalSize()
        bg_node:setNormalSize(total_width, height)
    end
end

-------------------------------------
-- function repeatTest
-- @brief 반복 테스트용
-------------------------------------
function UIHelper:repeatTest(sequence_action)
	g_currScene.m_scene:runAction(cc.RepeatForever:create(sequence_action))
end

-------------------------------------
-- function makeItemNamePlainByParam
-------------------------------------
function UIHelper:makeItemNamePlainByParam(item_id, item_cnt)
	return self:makeItemNamePlain({['item_id'] = item_id, ['count'] = item_cnt})
end

-------------------------------------
-- function makeItemNamePlain
-------------------------------------
function UIHelper:makeItemNamePlain(t_item)
	local item_id = t_item['item_id']
	local item_name = TableItem:getItemName(item_id)
	local item_cnt = tonumber(t_item['count'])
	if (item_cnt) and (item_cnt > 0) then
        -- 자동 줍기 아이템 예외 처리
        if (item_id == ITEM_ID_AUTO_PICK) then
            return Str('{1} {2}시간', item_name, comma_value(item_cnt))
        -- 부스터 아이템 예외 처리
        elseif (item_id == ITEM_ID_EXP_BOOSTER or item_id == ITEM_ID_GOLD_BOOSTER) then
            return Str('{1} {2}일', item_name, comma_value(item_cnt))
        else
            return Str('{1} {2}개', item_name, comma_value(item_cnt))
        end
	else
		return Str('{1}', item_name)
	end
end

-------------------------------------
-- function makeItemName
-- @example 다이아 100개
-- @example 룬 확정권
-------------------------------------
function UIHelper:makeItemName(t_item)
	local item_id = t_item['item_id']
	local item_name = TableItem:getItemName(item_id)
	local item_cnt = tonumber(t_item['count'])
	if (item_cnt) and (item_cnt > 0) then
        -- 자동 줍기 아이템 예외 처리
        if (item_id == ITEM_ID_AUTO_PICK) then
            return Str('{@item_name}{1} {@count}{2}시간', item_name, comma_value(item_cnt))
        -- 부스터 아이템 예외 처리
        elseif (item_id == ITEM_ID_EXP_BOOSTER or item_id == ITEM_ID_GOLD_BOOSTER) then
            return Str('{@item_name}{1} {@count}{2}일', item_name, comma_value(item_cnt))
        else
            return Str('{@item_name}{1} {@count}{2}개', item_name, comma_value(item_cnt))
        end
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
	local item_cnt = tonumber(t_item['count'])
	if (item_cnt) and (item_cnt > 0) then
		return Str('{@count}{1} {2}개{@DESC}를 획득하였습니다.', item_name, comma_value(item_cnt))
	else
		return Str('{@item_name}{1}{@DESC}(을)를 획득하였습니다.', item_name)
	end
end

-------------------------------------
-- function makeGoodbyeStr
-------------------------------------
function UIHelper:makeGoodbyeStr(t_item, dragon_name)
	local item_id = t_item['item_id']
	local rel_name = TableItem:getItemName(item_id)
	local rel_cnt = tonumber(t_item['count'])
	return Str('{@ROSE}{2}{@DESC}(을)를 {@count}{3}{@DESC}개 획득했습니다.', dragon_name, rel_name, rel_cnt)
end

-------------------------------------
-- function getCardPosX
-- @brief ui_card를 병렬 시켰을 때의 갯수와 인덱스에 따른 x 좌표를 구한다.
-- @brief 중점 0 기준
-------------------------------------
function UIHelper:getCardPosX(total_cnt, idx)
    local card_size =  155
	return -(card_size/2 * (total_cnt - 1)) + (card_size * (idx - 1))
end

-------------------------------------
-- function getCardPosXWithScale
-------------------------------------
function UIHelper:getCardPosXWithScale(total_cnt, idx, scale)
    local card_size =  155 * scale
	return -(card_size/2 * (total_cnt - 1)) + (card_size * (idx - 1))
end

-------------------------------------
-- function getNodePosXWithScale
-------------------------------------
function UIHelper:getNodePosXWithScale(total_cnt, idx, width, scale)
    local scale = scale or 1
    local node_size =  width * scale
	return -(node_size/2 * (total_cnt - 1)) + (node_size * (idx - 1))
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
-- function attachNotiIcon
-- @brief 받은 노드 우상단에 노티 아이콘을 붙인다
-------------------------------------
function UIHelper:attachNotiIcon(node, level)
    local icon = IconHelper:getNotiIcon()
    level = level or 1
    icon:setDockPoint(cc.p(1, 1))
    icon:setPosition(-5 * level, -5 * level)
    node:addChild(icon)
    return icon
end

-------------------------------------
-- function autoNoti
-- @brief 탭이나 버튼 등에 자동으로 노티를 붙여준다.
-- @param category_bool_map : {항목 : true/false} 의 맵 
-- @param noti_ui_table : noti 아이콘 테이블
-- @param ui_key : category와 조합하여 noti 아이콘을 붙일 node를 찾음
-------------------------------------
function UIHelper:autoNoti(category_bool_map, noti_ui_table, ui_key, vars)
	local noti_ui_table = noti_ui_table or {}
	
	for _, spr in pairs(noti_ui_table) do
		spr:setVisible(false)
	end

	for category, _ in pairs(category_bool_map) do
    	-- 없으면 생성
		if (not noti_ui_table[category]) then
            
            -- ZOrder가 같은 Node들이 뒤죽박죽 섞이는 것을 방지
            local parent = vars[category .. ui_key]
            KeepOrderOfArrival(parent)

			local icon = self:attachNotiIcon(parent, 1)
			noti_ui_table[category] = icon

		-- 있으면 킴
		else
			noti_ui_table[category]:setVisible(true)

		end
    end
end

-------------------------------------
-- function checkPrice
-------------------------------------
function UIHelper:checkPrice(price_type, price)
    if (price_type == 'money') then
		return true

    -- 다이아몬드 확인
    elseif (price_type == 'cash') then
        local cash = g_userData:get('cash')
        if (cash < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다이아몬드가 부족합니다.'))
            return false
        end

    -- 자수정 확인
    elseif (price_type == 'amethyst') then
        local amethyst = g_userData:get('amethyst')
        if (amethyst < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('자수정이 부족합니다.'))
            return false
        end

    -- 토파즈 확인
    elseif (price_type == 'topaz') then
        local topaz = g_userData:get('topaz')
        if (topaz < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('토파즈가 부족합니다.'))
            return false
        end

    -- 마일리지 확인
    elseif (price_type == 'mileage') then
        local mileage = g_userData:get('mileage')
        if (mileage < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('마일리지가 부족합니다.'))
            return false
        end

    -- 명예 확인
    elseif (price_type == 'honor') then
        local honor = g_userData:get('honor')
        if (honor < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('명예가 부족합니다.'))
            return false
        end

    -- 캡슐 확인
    elseif (price_type == 'capsule') then
        local capsule = g_userData:get('capsule')
        if (capsule < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('캡슐이 부족합니다.'))
            return false
        end

    -- 골드 확인
    elseif (price_type == 'gold') then
        local gold = g_userData:get('gold')
        if (gold < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('골드가 부족합니다.'))
            return false
        end

    -- 우정 포인트 확인
    elseif (price_type == 'fp') then
        local fp = g_userData:get('fp')
        if (fp < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('우정포인트가 부족합니다.'))
            return false
        end

    -- 고대주화 확인
    elseif (price_type == 'ancient') then
        local ancient = g_userData:get('ancient')
        if (ancient < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('고대주화가 부족합니다.'))
            return false
        end

    -- 클랜코인 확인
    elseif (price_type == 'clancoin') then
        local clancoin = g_userData:get('clancoin')
        if (clancoin < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('클랜코인이 부족합니다.'))
            return false
        end

	-- 캡슐코인 확인
    elseif (price_type == 'capsule_coin') then
        local capsule_coin = g_userData:get(price_type)
        if (capsule_coin < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('캡슐코인이 부족합니다.'))
            return false
        end

    -- 용맹훈장 확인
    elseif (price_type == 'valor') then
        local valor = g_userData:get(price_type)
        if (valor < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('용맹훈장이 부족합니다.'))
            return false
        end

    else
        error('price_type : ' .. price_type)
    end

	return true
end

-------------------------------------
-- function makeHighlightFrame
-------------------------------------
function UIHelper:makeHighlightFrame(node)
	if (not node) then
		return
	end

	local content_size = node:getContentSize()
	local highlight_sprite = cc.Scale9Sprite:create('res/ui/a2d/card/card_cha_frame_select.png')
	highlight_sprite:setDockPoint(cc.p(0.5, 0.5))
    highlight_sprite:setAnchorPoint(cc.p(0.5, 0.5))
	highlight_sprite:setContentSize(content_size)
	highlight_sprite:runAction(cca.flash())
	node:addChild(highlight_sprite)
end
