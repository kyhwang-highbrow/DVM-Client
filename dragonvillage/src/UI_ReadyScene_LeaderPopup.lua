local PARENT = UI

-------------------------------------
-- class UI_ReadyScene_LeaderPopup
-------------------------------------
UI_ReadyScene_LeaderPopup = class(PARENT,{
		m_currLeader = 'number',
		m_lDoidList = 'list',
		m_newLeader = 'number',
    })

local ARROW_POS_Y = 110

-------------------------------------
-- function init
-------------------------------------
function UI_ReadyScene_LeaderPopup:init(l_pos_list, l_doid, leader_idx)
    local vars = self:load('battle_ready_leader_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:closeWithAction() end, 'UI_ReadyScene_LeaderPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- initialize
	self.m_currLeader = leader_idx
	self.m_lDoidList = l_doid
	self.m_newLeader = leader_idx

	-- leader dragon struct : 최초 refresh용
	local leader_dragon_data = g_dragonsData:getDragonDataFromUid(l_doid[leader_idx])

    self:initUI(l_pos_list)
    self:initButton()
    self:refresh(leader_dragon_data)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadyScene_LeaderPopup:initUI(l_pos_list)
	local vars = self.vars

	-- 진형 위치 변경
	self:actionForChangeDeck_Immediately(l_pos_list)

	-- UI_ReadyScene_Deck의 상수값들
	local ZORDER = 
	{
		BACK_PLATE = 1,
		FOCUS_EFFECT = 2,
		DRAGON_CARD = 3,
	}
	local DC_POS_Y = 50
	local DC_SCALE_ON_PLATE = 0.7
	local DC_SCALE = 0.61
	local DC_SCALE_PICK = (DC_SCALE * 0.8)

	-- doid list를 순회하며 deck의 카드 생성
	for idx, doid in pairs(self.m_lDoidList) do
		local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
		local ui = UI_DragonCard(t_dragon_data)
		ui.root:setPosition(0, DC_POS_Y)
		
		-- 찰랑찰랑 하는 연출
		cca.uiReactionSlow(ui.root, DC_SCALE_ON_PLATE, DC_SCALE_ON_PLATE, DC_SCALE_PICK)
		
		ui.vars['clickBtn']:registerScriptTapHandler(function() 
			self:click_dragonCard(idx, t_dragon_data)
		end)

		-- 설정된 드래곤 표시 없애기
		ui:setReadySpriteVisible(false)

		vars['positionNode' .. idx]:addChild(ui.root, ZORDER.DRAGON_CARD)
	end

	-- 리더 선택 표시
	local leader_idx = self.m_currLeader
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

-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadyScene_LeaderPopup:initButton()
	local vars = self.vars

	vars['okBtn']:registerScriptTapHandler(function() self:closeWithAction() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:closeWithAction() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ReadyScene_LeaderPopup:refresh(t_dragon_data)
	local vars = self.vars
	
	if (not t_dragon_data) or (not t_dragon_data['did']) then
		vars['dragonLabel']:setString('없음')
		vars['buffLabel']:setString(Str('리더 버프 없음'))
		return
	end

	-- 드래곤 이름
	local dragon_name = TableDragon:getDragonName(t_dragon_data['did'])
	vars['dragonLabel']:setString(dragon_name)

	-- 드래곤 버프 설명 (버프 이름 있어야 할듯?)
	local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
	local leader_skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx('Leader')
	if (leader_skill_info) then
		local desc = leader_skill_info:getSkillDesc()
		vars['buffLabel']:setString(desc)
	else
		vars['buffLabel']:setString(Str('리더 버프 없음'))
	end
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_ReadyScene_LeaderPopup:click_dragonCard(new_leader_idx, t_dragon_data)
	local vars = self.vars

	-- 현재 리더와 같은것을 선택하면 표시 없앰
	if (self.m_currLeader == new_leader_idx) then
		vars['selectArrowSprite']:setVisible(false)

	-- 선택한 리더에 화살표 붙임
	else
		local leader_pos_x, leader_pos_y = vars['positionNode' .. new_leader_idx]:getPosition()
		vars['selectArrowSprite']:setPosition(leader_pos_x, leader_pos_y + ARROW_POS_Y)
		vars['selectArrowSprite']:setVisible(true)

	end
	
	-- 정보 새로 표시
	self:refresh(t_dragon_data)
	self.m_newLeader = new_leader_idx
end

-------------------------------------
-- function actionForChangeDeck_Immediately
-- @brief UI_ReadyScene_Deck:actionForChangeDeck_Immediately(l_pos_list)와 같은 기능인데... 어떻게 사용할지 고민중
-------------------------------------
function UI_ReadyScene_LeaderPopup:actionForChangeDeck_Immediately(l_pos_list)
	local vars = self.vars
	local order_std = 10

	for i, node_space in ipairs(l_pos_list) do
		-- 드래곤 카드
		vars['positionNode' .. i]:setPosition(node_space['x'], node_space['y'])
		vars['positionNode' .. i]:setLocalZOrder(order_std - i)
	end

	-- z_order 정렬
	vars['arrowSprite']:setLocalZOrder(order_std)
	vars['selectBgSprite']:setLocalZOrder(order_std)
	vars['selectArrowSprite']:setLocalZOrder(order_std)
end

--@CHECK
UI:checkCompileError(UI_ReadyScene_LeaderPopup)
