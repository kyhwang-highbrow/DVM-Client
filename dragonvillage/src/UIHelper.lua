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
        elseif (item_id == ITEM_ID_CLEAR_TICKET) then
            return Str('{1} {2}일', item_name, comma_value(item_cnt))
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
        elseif (item_id == ITEM_ID_CLEAR_TICKET) then
            return Str('{@item_name}{1} {@count}{2}일', item_name, comma_value(item_cnt))
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
function UIHelper:checkPrice(price_type, price, price_type_id)
    if (price_type == 'money') then
		return true

    -- 다이아, 자수정, 토파즈, 마일리지, 명예, 캡슐, 골드, 우정포인트, 고대주화, 클랜코인, 캡슐코인, 용맹훈장, 이벤트 토큰
    elseif isExistValue(price_type, 'cash', 'amethyst', 'topaz', 'mileage', 'honor', 'capsule', 
    'gold', 'fp', 'ancient', 'clancoin', 'capsule_coin', 'valor', 'event_token', 'token_story_dungeon') then
        local own_item_number = g_userData:get(price_type) or 0
        local item_name = TableItem:getItemNameFromItemType(price_type)

        if (own_item_number < price) then
            local msg = Str('{1}이(가) 부족합니다.', Str(item_name))
            local popup_type = POPUP_TYPE.OK
            local ok_cb

            if (price_type == 'cash') then
                msg = msg .. Str('\n상점으로 이동하시겠습니까??')
                popup_type = POPUP_TYPE.YES_NO

                ok_cb = function() UINavigatorDefinition:goTo('package_shop', 'diamond_shop') end
            end

            if(own_item_number < price) then
                MakeSimplePopup(popup_type, Str(msg), ok_cb)
                return false
            end    
        end

    -- 차원문 메달, 별의 기억
    elseif isExistValue(price_type, 'medal', 'memory', 'memory_myth') then
        local item = TABLE:get('item')[price_type_id]

        if (price_type == 'memory_myth') then
            price_type = 'memory'
        end

        local own_item_number = g_userData:get(price_type, tostring(price_type_id))

        if(own_item_number < price) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('{1}이(가) 부족합니다.', Str(item['t_name'])))
            return false
        end
    else

        local own_item_number = g_userData:get(price_type)
        local item_name = TableItem:getItemNameFromItemType(price_type)
        if own_item_number ~= nil then
            if (own_item_number < price) then
                local msg = Str('{1}이(가) 부족합니다.', Str(item_name))
                local popup_type = POPUP_TYPE.OK
                local ok_cb

                if (price_type == 'cash') then
                    msg = msg .. Str('\n상점으로 이동하시겠습니까??')
                    popup_type = POPUP_TYPE.YES_NO

                    ok_cb = function() UINavigatorDefinition:goTo('package_shop', 'diamond_shop') end
                end

                if(own_item_number < price) then
                    MakeSimplePopup(popup_type, Str(msg), ok_cb)
                    return false
                end
            end
        else
            error('price_type : ' .. price_type)
        end
    end

	return true
end

-------------------------------------
-- function checkPrice_toastMessage
-------------------------------------
function UIHelper:checkPrice_toastMessage(price_type, price, price_type_id)
    -- 결제상품
    if (price_type == 'money') then
		return true
    -- 다이아, 자수정, 토파즈, 마일리지, 명예, 캡슐, 골드, 우정포인트, 고대주화, 클랜코인, 캡슐코인, 용맹훈장, 이벤트 토큰, 스토리 던전 토큰
    elseif isExistValue(price_type, 'cash', 'amethyst', 'topaz', 'mileage', 'honor', 'capsule', 
    'gold', 'fp', 'ancient', 'clancoin', 'capsule_coin', 'valor', 'event_token', 'token_story_dungeon') then
        local own_item_number = g_userData:get(price_type) or 0
        local item_name = TableItem:getItemNameFromItemType(price_type)

        if (own_item_number < price) then
            UIManager:toastNotificationRed(Str('{1}이(가) 부족합니다.', item_name))
            return false         
        end
    -- 차원문 메달, 별의 기억
    elseif isExistValue(price_type, 'medal', 'memory', 'memory_myth') then
        local item = TABLE:get('item')[price_type_id]

        if (price_type == 'memory_myth') then
            price_type = 'memory'
        end

        local own_item_number = g_userData:get(price_type, tostring(price_type_id))

        if(own_item_number < price) then
            UIManager:toastNotificationRed(Str('{1}이(가) 부족합니다.', item['t_name']))
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

-------------------------------------
-- function makeFormatedFloatStr
-- @brief 소수점 있으면 1자리, 없으면 정수만 표현
-------------------------------------
function UIHelper:makeFormatedFloatStr(float_num)
	return tostring(math_floor(float_num * 1000 ) / 10)
end



-------------------------------------
-- function autoPositioning
-------------------------------------
function UIHelper:autoPositioning(root_node, item, label)
    -- UI클래스의 root상 위치를 얻어옴
    local local_pos = convertToAnoterParentSpace(root_node, item.m_node)
    local pos_x = local_pos['x']
    local pos_y = local_pos['y']

    do -- X축 위치 지정
        local width = label:getStringWidth() + 100
        local scr_size = cc.Director:getInstance():getWinSize()
        if (pos_x < 0) then
            local min_x = -(scr_size['width'] / 2)
            local left_pos = pos_x - (width/2)
            if (left_pos < min_x) then
                pos_x = min_x + (width/2)
            end
        else
            local max_x = (scr_size['width'] / 2)
            local right_pos = pos_x + (width/2)
            if (max_x < right_pos) then
                pos_x = max_x - (width/2)
            end
        end
    end

    do -- Y축 위치 지정
        -- 화면상에 보이는 Y스케일을 얻어옴
        local transform = item.m_node:getNodeToWorldTransform()
        local scale_y = transform[5 + 1]

        -- tooltip의 위치를 위쪽으로 표시할지 아래쪽으로 표시할지 결정
        local bounding_box = item.m_node:getBoundingBox()
        local anchor_y = 0.5
        if (pos_y < 0) then
            pos_y = pos_y + (bounding_box['height'] * scale_y / 2) + 120
            anchor_y = 0
        else
            pos_y = pos_y - (bounding_box['height'] * scale_y / 2) - 120
            anchor_y = 1
        end

        -- 위, 아래의 위치에 따라 anchorPoint 설정
        item:setAnchorPoint(cc.p(0.5, anchor_y))
    end

    -- 위치 설정
   item:setPosition(pos_x, pos_y)
end


-------------------------------------
-- function CreateParticle
-- @brief 파티클을 지정된 노드에 생성
-------------------------------------
function UIHelper:CreateParticle(node, file_name)
    local is_low_mode = isLowEndMode()
    local can_play_particle = true
    if (CppFunctionsClass:isAndroid() == true) then
        local version_sdk_int = tonumber(g_userData:getDeviceInfoByKey('VERSION_SDK_INT'))
        if (version_sdk_int and (9 <= version_sdk_int)) then can_play_particle = false end
    end

    if (is_low_mode or can_play_particle == false) then return end

    local file_name = file_name and file_name or 'particle_star_crash'
    local particle_res = string.format('res/ui/particle/%s.plist', file_name)
    local particle

    if (isNullOrEmpty(particle_res) == false) then
        particle = cc.ParticleSystemQuad:create(particle_res)
    end

    if (particle) then
        particle:setAnchorPoint(CENTER_POINT)
        particle:setDockPoint(CENTER_POINT)
        node:addChild(particle)
        particle:setGlobalZOrder(node:getGlobalZOrder() + 1)
        --particle:setAutoRemoveOnFinish(true)
    end
end


-------------------------------------
-- function setDifficultyLabelWithColor
-- @brief 
-------------------------------------
function UIHelper:setDifficultyLabelWithColor(label_node, stage_id)
    if (not label_node) or (not stage_id) then return end

    local game_mode = g_stageData:getGameMode(stage_id)

     -- 모험 모드
     if (game_mode == GAME_MODE_ADVENTURE) then
        local difficulty, chapter, stage = parseAdventureID(stage_id)

        if (difficulty == 1) then
            label_node:setColor(COLOR['diff_normal'])
            label_node:setString(Str('보통'))

        elseif (difficulty == 2) then
            label_node:setColor(COLOR['diff_hard'])
            label_node:setString(Str('어려움'))

        elseif (difficulty == 3) then
            label_node:setColor(COLOR['diff_hell'])
            label_node:setString(Str('지옥'))
        elseif (difficulty == 4) then
            label_node:setColor(COLOR['diff_hellfire'])
            label_node:setString(Str('불지옥'))
        elseif (difficulty == 5) then
            label_node:setColor(COLOR['diff_abyss_0'])
            label_node:setString(Str('심연'))
        elseif (difficulty == 6) then
            label_node:setColor(COLOR['diff_abyss_1'])
            label_node:setString(Str('심연 1'))


        end
     end
end