SensitivityHelper = {}

TAG_BUBBLE = 101

-------------------------------------
-- function doActionBubbleText
-- @public 현재는 드래곤 전용이다 추후에 사용처가 늘어나면 범용성을 갖추어야 할것
-------------------------------------
function SensitivityHelper:doActionBubbleText(parent, did, flv, case_type)
	-- 상황별 문구 생성
	local sens_str = SensitivityHelper:getRandomSensStr(did, flv, case_type)

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
	end
	
	-- 띠용~ 후 페이드 아웃 하는 액션
	local scale_action = cc.ScaleTo:create(0.17, 1.25)
	local scale_action_2 = cc.ScaleTo:create(0.08, 1)
	local delay_action = cc.DelayTime:create(delay_time)
	local fade_action = cc.FadeOut:create(0.25)
	local remove_action = cc.RemoveSelf:create()
	local seq_action = cc.Sequence:create(scale_action, scale_action_2, delay_action, fade_action, remove_action)
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
	node:setCascadeOpacityEnabled(true)

	-- 말풍선 프레임
	local sprite = cc.Sprite:create('res/ui/frame/dragon_info_bubble.png')
	sprite:setDockPoint(CENTER_POINT)
	sprite:setAnchorPoint(CENTER_POINT)

	-- 텍스트 (rich_label)
	local rich_label = UIC_RichLabel()

    -- label의 속성들
    rich_label:setString(txt_str)
    rich_label:setFontSize(24)
    rich_label:setDimension(370, 70)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    rich_label:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    rich_label:enableShadow(cc.c4b(0 , 0, 0, 255), cc.size(2, -2), 1)

	rich_label:setDockPoint(CENTER_POINT)
    rich_label:setAnchorPoint(CENTER_POINT)
	rich_label:setPosition(0, 12)

	sprite:addChild(rich_label.m_node)
	node:addChild(sprite)

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
        parent_node:addChild(node)

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
-- @public 현재는 드래곤 전용이다 추후에 사용처가 늘어나면 범용성을 갖추어야 할것
-------------------------------------
function SensitivityHelper:doRepeatBubbleText(parent, did, flv, case_type)
	-- 상황별 문구 생성
	local sens_str = SensitivityHelper:getRandomSensStr(did, flv, case_type)

	-- 이전 버블 텍스트가 있다면 삭제해버린다.
	self:deleteBubbleText(parent)

	-- 버블 텍스트 생성하여 부모에 붙임
	local bubble_text = SensitivityHelper:getBubbleText(sens_str)
	bubble_text:setTag(TAG_BUBBLE)
	parent:addChild(bubble_text, 2)

	-- 상황별 변수 및 포지션 정리
	bubble_text:setPosition(0, 100)
	
	-- 띠용~ 후 페이드 아웃 하는 액션
	local fade_in = cc.FadeIn:create(0.25)
	local delay_action = cc.DelayTime:create(1)
	local fade_out = cc.FadeOut:create(0.25)
	local post_delay = cc.DelayTime:create(4)
	local seq_action = cc.Sequence:create(fade_in, delay_action, fade_out, post_delay)

	bubble_text:runAction(cc.RepeatForever:create(seq_action))

	return bubble_text
end