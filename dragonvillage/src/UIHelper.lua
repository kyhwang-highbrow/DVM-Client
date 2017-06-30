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

	-- ex)
	--[[
	local ui
	local sequence_action = cc.Sequence:create(
		cc.CallFunc:create(function()
			ccdisplay('디버깅 디버깅')
			ui = UI_ReadyScene(COLOSSEUM_STAGE_ID, nil, 'atk')
			local function close_cb()
				local player_3d_deck = self.m_player3DDeck
				local l_dragon_obj = g_colosseumData.m_playerUserInfo:getAtkDeck_dragonList()
				player_3d_deck:setDragonObjectList(l_dragon_obj)
			end
			ui:setCloseCB(close_cb) 
		end),
		cc.DelayTime:create(1.0),
		cc.CallFunc:create(function() ui:close() end),
		cc.DelayTime:create(1.0)
	)
	UIHelper:repeatTest(sequence_action)
	]]
end
