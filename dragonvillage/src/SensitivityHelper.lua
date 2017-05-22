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
-------------------------------------
function SensitivityHelper:doActionBubbleText(parent, did, flv, case_type, custom_str, cb_func)
	-- 상황별 문구 생성
	local sens_str = '{@BLACK}' .. (custom_str or SensitivityHelper:getRandomSensStr(did, flv, case_type))

	-- 이전 버블 텍스트가 있다면 삭제해버린다.
	self:deleteBubbleText(parent)

	-- 버블 텍스트 생성하여 부모에 붙임
	local bubble_text = SensitivityHelper:getBubbleText(sens_str)
	bubble_text:setTag(TAG_BUBBLE)
	parent:addChild(bubble_text, 2)

	-- 상황별 변수 및 포지션 정리
	local delay_time
	if string.find(case_type, 'lobby_') then
		bubble_text:setPosition(50, 300)
		delay_time = 1.5

	elseif string.find(case_type, 'party_') then
		bubble_text:setPosition(0, 100)
		delay_time = 0.5

	elseif string.find(case_type, 'lactea_') then
		bubble_text:setPosition(0, 150)
		delay_time = 0.5
	
	elseif (case_type == 'lactea_tamer') then
		bubble_text:setPosition(0, 200)
		delay_time = 1.5
		bubble_text:setScaleX(-1)
	end
	
	-- 띠용~ 후 페이드 아웃 하는 액션
	local scale_action = cc.ScaleTo:create(0.17, 1.25)
	local scale_action_2 = cc.ScaleTo:create(0.08, 1)
	local delay_action = cc.DelayTime:create(delay_time)
	local fade_action = cc.FadeOut:create(0.25)
	local cb_action = cc.CallFunc:create(function() if (cb_func) then cb_func() end end)
	local remove_action = cc.RemoveSelf:create()
	local seq_action = cc.Sequence:create(scale_action, scale_action_2, delay_action, fade_action, cb_action, remove_action)
	bubble_text:runAction(seq_action)
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
	local sprite = cc.Scale9Sprite:create('res/ui/frame/dragon_info_bubble.png')
	sprite:setDockPoint(CENTER_POINT)
	sprite:setAnchorPoint(CENTER_POINT)

	-- 텍스트 (rich_label)
	local rich_label = UIC_RichLabel()
    rich_label:setString(txt_str)
    rich_label:setFontSize(24)
    rich_label:setDimension(370, 70)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	rich_label:setDockPoint(CENTER_POINT)
    rich_label:setAnchorPoint(CENTER_POINT)
	rich_label:setPosition(0, 12)

	-- label 사이즈로 프레임 조정
	local width = rich_label:getStringWidth() + 50
	local size = sprite:getContentSize()
	sprite:setNormalSize(width, size['height'])

	-- addChild
	sprite:addChild(rich_label.m_node)
	node:addChild(sprite)

	-- fade out을 위해 설정
	doAllChildren(node, function(node) node:setCascadeOpacityEnabled(true) end)

	return node
end

-------------------------------------
-- function getBubbleText
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
    local type, count = gift_type, gift_count

    local res = 'res/ui/icon/inbox/inbox_' .. type .. '.png'
    if (res) then
        local node = cc.Node:create()
        node:setPosition(0, 250)
		node:setOpacity(0)
		node:setCascadeOpacityEnabled(true)
        parent_node:addChild(node, 5)

        local icon = cc.Sprite:create(res)
        if (icon) then
            icon:setPositionX(-20)
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            node:addChild(icon)
        end

        local label = cc.Label:createWithTTF('+' .. count, 'res/font/common_font_01.ttf', 30, 2, cc.size(100, 100), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
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

        node:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.5), cc.FadeOut:create(0.2), cc.RemoveSelf:create()))
        node:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveBy:create(1, cc.p(0, 80)), 1)))
    end
end

-------------------------------------
-- function doRepeatBubbleText
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

-------------------------------------
-- function doRepeatBubbleText
-------------------------------------
function SensitivityHelper:isPassedBattleGiftSeenOnce()
	local seen_at = g_localData:get('battle_gift_dragon_seen_at') or 0
	local curr_time = Timer:getServerTime()
	local hour_gap = (curr_time - seen_at) / 60 / 60
	return hour_gap > 24
end