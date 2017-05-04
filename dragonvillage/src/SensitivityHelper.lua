SensitivityHelper = {}

-------------------------------------
-- function doActionBubbleText
-- @public 현재는 드래곤 전용이다 추후에 사용처가 늘어나면 범용성을 갖추어야 할것
-------------------------------------
function SensitivityHelper:doActionBubbleText(parent, did, case_type)
	-- 1. 상황별 문구 생성
	local sens_str = SensitivityHelper:getRandomSensStr(did, case_type)

	-- 2. 버블 텍스트 생성하여 부모에 붙임
	local bubble_text = SensitivityHelper:getBubbleText(sens_str)
	parent:addChild(bubble_text, 2)
	bubble_text:setScale(0.1)
	
	-- 3. 띠용~ 후 페이드 아웃 하는 액션
	local scale_action = cc.ScaleTo:create(0.17, 1.25)
	local scale_action_2 = cc.ScaleTo:create(0.08, 1)
	local delay_action = cc.DelayTime:create(1.5)
	local fade_action = cc.FadeOut:create(0.25)
	local remove_action = cc.RemoveSelf:create()
	local seq_action = cc.Sequence:create(scale_action, scale_action_2, delay_action, fade_action, remove_action)
	bubble_text:runAction(seq_action)
end

-------------------------------------
-- function getBubbleText
-------------------------------------
function SensitivityHelper:getBubbleText(txt_str)
	-- 말풍선 프레임
	local sprite = cc.Sprite:create('res/ui/frame/dragon_info_bubble.png')
	sprite:setDockPoint(CENTER_POINT)
	sprite:setAnchorPoint(CENTER_POINT)
	sprite:setPosition(50, 300)

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

	return sprite
end

-------------------------------------
-- function getBubbleText
-------------------------------------
function SensitivityHelper:getRandomSensStr(did, case_type)
	return TableDragonPhrase:getRandomPhrase_Sensitivity(did, case_type)
end