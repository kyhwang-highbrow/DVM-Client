SensitivityHelper = {}

TAG_BUBBLE = 101

-------------------------------------
-- function doActionBubbleText_Extend
-- @public 범용성을 위해 테이블 요소 사용
-------------------------------------
function SensitivityHelper:doActionBubbleText_Extend(t_param)
	local t_param = t_param
	SensitivityHelper:doActionBubbleText(t_param['parent'], t_param['did'], t_param['flv'], t_param['case_type'], t_param['custom_str'], t_param['cb_func'])
end

-------------------------------------
-- function doActionBubbleText
-- @public 현재는 드래곤 전용이다 추후에 사용처가 늘어나면 범용성을 갖추어야 할것
-- @brief 케이스 처리 부
-------------------------------------
function SensitivityHelper:doActionBubbleText(parent, did, flv, case_type, custom_str, cb_func)
	-- 상황별 문구 생성
	local sens_str = '{@BLACK}' .. (custom_str or SensitivityHelper:getRandomSensStr(did, flv, case_type))

	-- 상황별 변수 및 포지션 정리
	local delay_time

	-- 채팅
	if (case_type == 'chat_tamer') then
		pos_y = 330
		delay_time = 4.5

	-- 로비
	elseif pl.stringx.startswith(case_type, 'lobby_') then
		pos_y = 300
		delay_time = 5

	-- 전투 준비 화면
	elseif pl.stringx.startswith(case_type, 'party_') then
		pos_y = 100
		delay_time = 0.5

    else
        pos_y = 300
		delay_time = 1.5

	end
	
	-- run
	self:completeBubbleText(parent, sens_str, delay_time, pos_y, cb_func)
end

-------------------------------------
-- function completeBubbleText
-- @brief 버블 텍스트 완성
-------------------------------------
function SensitivityHelper:completeBubbleText(parent, bubble_str, delay, pos_y, cb_func)
	-- 이전 버블 텍스트가 있다면 삭제해버린다.
	self:deleteBubbleText(parent)

	-- 버블 텍스트 생성하여 부모에 붙임
	local bubble_text = SensitivityHelper:getBubbleText(bubble_str)
	bubble_text:setTag(TAG_BUBBLE)
	bubble_text:setPosition(0, pos_y)
	parent:addChild(bubble_text, 2)
	
	-- 띠용~ 후 페이드 아웃 하는 액션
	local scale_action = cc.ScaleTo:create(0.17, 1.25)
	local scale_action_2 = cc.ScaleTo:create(0.08, 1)
	local delay_action = cc.DelayTime:create(delay)
	local fade_action = cc.FadeOut:create(0.25)
	local cb_action = cc.CallFunc:create(function() if (cb_func) then cb_func() end end)
	local remove_action = cc.RemoveSelf:create()
	local seq_action = cc.Sequence:create(scale_action, scale_action_2, delay_action, fade_action, cb_action, remove_action)
	bubble_text:runAction(seq_action)

	return bubble_text
end

-------------------------------------
-- function completeStoryDungeonBubbleText
-- @brief 스토리 던전용 버블 텍스트 완성
-------------------------------------
function SensitivityHelper:completeStoryDungeonBubbleText(parent, bubble_str, delay, pos_y, cb_func)
	-- 이전 버블 텍스트가 있다면 삭제해버린다.
	self:deleteBubbleText(parent)

	-- 버블 텍스트 생성하여 부모에 붙임
	local bubble_text = SensitivityHelper:getStoryDungeonBubbleText(bubble_str)
	bubble_text:setTag(TAG_BUBBLE)
	bubble_text:setPosition(0, pos_y)
	parent:addChild(bubble_text, 2)
	
	-- 띠용~ 후 페이드 아웃 하는 액션
	local scale_action = cc.ScaleTo:create(0.17, 1.25)
	local scale_action_2 = cc.ScaleTo:create(0.08, 1)
	local delay_action = cc.DelayTime:create(delay)
	local fade_action = cc.FadeOut:create(0.25)
	local cb_action = cc.CallFunc:create(function() if (cb_func) then cb_func() end end)
	local remove_action = cc.RemoveSelf:create()
	local seq_action = cc.Sequence:create(scale_action, scale_action_2, delay_action, fade_action, cb_action, remove_action)
	bubble_text:runAction(seq_action)

	return bubble_text
end

-------------------------------------
-- function getStoryDungeonBubbleText
-------------------------------------
function SensitivityHelper:getStoryDungeonBubbleText(txt_str)
	-- 베이스 노드
	local node = cc.Node:create()
	node:setDockPoint(CENTER_POINT)
	node:setAnchorPoint(CENTER_POINT)

	-- 말풍선 프레임
	local frame = cc.Scale9Sprite:create('res/ui/frames/master_road_navi_0101.png')
	frame:setDockPoint(CENTER_POINT)
	frame:setAnchorPoint(CENTER_POINT)

	-- 텍스트 (rich_label)
	local rich_label = UIC_RichLabel()
    rich_label:setString(txt_str)
    rich_label:setFontSize(24)
    rich_label:setDimension(500, 70)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	rich_label:setDockPoint(CENTER_POINT)
    rich_label:setAnchorPoint(CENTER_POINT)
	rich_label:setPosition(0, 10)

	-- label 사이즈로 프레임 조정
	local width = math_max(226, rich_label:getStringWidth() + 50)
	local size = frame:getContentSize()
	frame:setNormalSize(width, size['height'] + 50)

	-- addChild
	frame:addChild(rich_label.m_node)
	node:addChild(frame)

	-- fade out을 위해 설정
	doAllChildren(node, function(node) node:setCascadeOpacityEnabled(true) end)

	return node
end

-------------------------------------
-- function getBubbleText
-------------------------------------
function SensitivityHelper:getBubbleText(txt_str)
	-- 베이스 노드
	local node = cc.Node:create()
	node:setDockPoint(CENTER_POINT)
	node:setAnchorPoint(CENTER_POINT)

	-- 말풍선 프레임
	local frame = cc.Scale9Sprite:create('res/ui/frames/master_road_navi_0101.png')
	frame:setDockPoint(CENTER_POINT)
	frame:setAnchorPoint(CENTER_POINT)

	-- 텍스트 (rich_label)
	local rich_label = UIC_RichLabel()
    rich_label:setString(txt_str)
    rich_label:setFontSize(24)
    rich_label:setDimension(500, 70)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	rich_label:setDockPoint(CENTER_POINT)
    rich_label:setAnchorPoint(CENTER_POINT)
	rich_label:setPosition(0, 10)

	-- label 사이즈로 프레임 조정
	local width = math_max(226, rich_label:getStringWidth() + 50)
	local size = frame:getContentSize()
	frame:setNormalSize(width, size['height'])

	-- addChild
	frame:addChild(rich_label.m_node)
	node:addChild(frame)

	-- fade out을 위해 설정
	doAllChildren(node, function(node) node:setCascadeOpacityEnabled(true) end)

	return node
end

-------------------------------------
-- function getRandomSensStr
-------------------------------------
function SensitivityHelper:getRandomSensStr(did, flv, case_type)
	return TableDragonPhrase:getRandomPhrase_Sensitivity(did, flv, case_type)
end

-------------------------------------
-- function deleteBubbleText
-- @brief 버블 텍스트 바로 삭제
-------------------------------------
function SensitivityHelper:deleteBubbleText(parent)
	local pre_bubble = parent:getChildByTag(TAG_BUBBLE)
	if (pre_bubble) then
		local remove_action = cc.RemoveSelf:create()
		pre_bubble:runAction(remove_action)
	end
end

-------------------------------------
-- function makeObtainEffect
-- @brief
-------------------------------------
function SensitivityHelper:makeObtainEffect(gift_type, gift_count, parent_node)
    -- base node
    local node = cc.Node:create()
    node:setPosition(0, 250)
	node:setOpacity(0)
	node:setCascadeOpacityEnabled(true)
    parent_node:addChild(node, 5)

    -- icon
    local res = 'res/ui/icons/inbox/inbox_' .. gift_type .. '.png'
    local icon = cc.Sprite:create(res)
    if (icon) then
        icon:setPositionX(-20)
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        node:addChild(icon)
    end

    -- label
    local font_size = 30
    local label = cc.Label:createWithTTF('+' .. gift_count, Translate:getFontPath(), font_size, 2, cc.size(100, 100), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    if (label) then
        local string_width = label:getStringWidth()
        local offset_x = (string_width / 2)
        label:setPositionX(offset_x)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setColor(cc.c3b(255, 255, 255))
		label:setCascadeOpacityEnabled(true)
        node:addChild(label)
    end

    -- action
    local duration = 1
    node:runAction(cc.Sequence:create(cc.FadeIn:create(duration * 0.3), cc.DelayTime:create(duration * 0.5), cc.FadeOut:create(duration * 0.2), cc.RemoveSelf:create()))
    node:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveBy:create(duration, cc.p(0, 80)), 1)))
end

-------------------------------------
-- function makeObtainEffect_Big
-- @brief
-------------------------------------
function SensitivityHelper:makeObtainEffect_Big(item_id, item_cnt, parent_node, t_param)
    -- 변수 정리
    local pos_x = t_param['pos_x']
    local pos_y = t_param['pos_y']
    local scale = t_param['scale']

    -- base node
    local node = cc.Node:create()
    node:setPosition(pos_x, pos_y)
    node:setScale(scale)
	node:setOpacity(0)
	node:setCascadeOpacityEnabled(true)
    parent_node:addChild(node, 5)

    -- icon
    local res = TableItem:getItemIcon(item_id)
    local icon = cc.Sprite:create(res)
    if (icon) then
        icon:setPositionX(-50)
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        node:addChild(icon)
    end

    -- label
    local font_size = 40
    local label = cc.Label:createWithTTF('+' .. item_cnt, Translate:getFontPath(), font_size, 2, cc.size(100, 100), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    if (label) then
        local string_width = label:getStringWidth()
        local offset_x = (string_width / 2)
        label:setPositionX(offset_x)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setColor(cc.c3b(255, 255, 255))
		label:setCascadeOpacityEnabled(true)
        node:addChild(label)
    end

    -- action
    local duration = 1.5
    node:runAction(cc.Sequence:create(cc.FadeIn:create(duration * 0.3), cc.DelayTime:create(duration * 0.5), cc.FadeOut:create(duration * 0.2), cc.RemoveSelf:create()))
    node:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveBy:create(duration, cc.p(0, 80)), 1)))
end

-------------------------------------
-- function doRepeatBubbleText
-- @brief 미사용
-------------------------------------
function SensitivityHelper:doRepeatBubbleText(parent, did, flv, case_type)
	-- 상황별 문구 생성
	local sens_str = '{@BLACK}' .. SensitivityHelper:getRandomSensStr(did, flv, case_type)

	-- 이전 버블 텍스트가 있다면 삭제해버린다.
	self:deleteBubbleText(parent)

	-- 버블 텍스트 생성하여 부모에 붙임
	local bubble_text = SensitivityHelper:getBubbleText(sens_str)
	bubble_text:setTag(TAG_BUBBLE)
	parent:addChild(bubble_text, 2)

	-- 상황별 변수 및 포지션 정리
	bubble_text:setPosition(0, 150)
	
	-- 띠용~ 후 페이드 아웃 하는 액션
	local fade_in = cc.FadeIn:create(0.25)
	local delay_action = cc.DelayTime:create(1)
	local fade_out = cc.FadeOut:create(0.25)
	local post_delay = cc.DelayTime:create(4)
	local seq_action = cc.Sequence:create(fade_in, delay_action, fade_out, post_delay)

	bubble_text:runAction(cc.RepeatForever:create(seq_action))

	return bubble_text
end