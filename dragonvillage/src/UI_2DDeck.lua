local PARENT = UI

-------------------------------------
-- class UI_2DDeck
-------------------------------------
UI_2DDeck = class(PARENT,{
        m_direction = '',
        m_bNoAction = 'boolean',
        m_bArena = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_2DDeck:init(no_action, is_arena)
    local vars = self:load('2d_deck.ui')

    self.m_bNoAction = no_action or false
    self.m_bArena = is_arena or false
end

-------------------------------------
-- function setDirection
-------------------------------------
function UI_2DDeck:setDirection(direction)
    local vars = self.vars
    self.m_direction = direction

    -- 상대방일때 x축 반대로
    if (direction == 'right') then
        vars['formationNode']:setScaleX(-1)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_2DDeck:initUI()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_2DDeck:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_2DDeck:refresh()
    local vars = self.vars
end

-------------------------------------
-- function actionForChangeDeck_Immediately
-------------------------------------
function UI_2DDeck:actionForChangeDeck_Immediately(l_pos_list)
    local vars = self.vars
    for i, v in ipairs(l_pos_list) do
		vars['positionNode' .. i]:setPosition(v['x'], v['y'])
	end
end

-------------------------------------
-- function setDragonObjectList
-------------------------------------
function UI_2DDeck:setDragonObjectList(l_deck, leader)
    local vars = self.vars

    -- DC : DragonCard
    local DC_POS_Y = 0
	local DC_SCALE_ON_PLATE = 0.7
	local DC_SCALE = 0.61
	local DC_SCALE_PICK = (DC_SCALE * 0.8)

    -- doid list를 순회하며 deck의 카드 생성
    for idx = 1, 5 do
        vars['chNode' .. idx]:removeAllChildren()
	
		local t_dragon_data = l_deck[idx]
        if t_dragon_data then
		    local ui = UI_DragonCard(t_dragon_data)
		    ui.root:setPosition(0, DC_POS_Y)

		    if (self.m_direction == 'right') then
                
                -- 상대방은 대표드래곤, 잠금 표시 지워줌
                if (ui.vars['leaderSprite']) then
                    ui.vars['leaderSprite']:setVisible(false)
                end

                if (ui.vars['lockSprite']) then
                    ui.vars['lockSprite']:setVisible(false)
                end

                -- 틀어진 방향 원래대로 복구 (레벨, 강화표시)
                local l_recover = {}
                table.insert(l_recover, ui.vars['reinforceNode'])
                table.insert(l_recover, ui.vars['masteryNode'])

                -- 레벨 Sprite 노드로 분리되있지 않고 개별로 addChild 되서 따로 처리해줘야함
                local level_sprite_0 = ui.vars['numberSprite0']
                if (level_sprite_0) then
                    level_sprite_0:setAnchorPoint(cc.p(1, 0.5))
                    table.insert(l_recover, level_sprite_0)
                end

                local level_sprite_1 = ui.vars['numberSprite1']
                if (level_sprite_1) then
                    level_sprite_1:setAnchorPoint(cc.p(1, 0.5))
                    table.insert(l_recover, level_sprite_1)

                    -- change pos x
                    local pos_0_x = level_sprite_0:getPositionX()
                    local pos_1_x = level_sprite_1:getPositionX()
                    level_sprite_0:setPositionX(pos_1_x)
                    level_sprite_1:setPositionX(pos_0_x)
                end

                for _, node in ipairs(l_recover) do
                    node:setScaleX(-1)
                end
            end

		    -- 찰랑찰랑 하는 연출
            if (self.m_bNoAction) then
                ui.root:setScale(DC_SCALE_ON_PLATE)
            else
		        cca.uiReactionSlow(ui.root, DC_SCALE_ON_PLATE, DC_SCALE_ON_PLATE, DC_SCALE_PICK)
            end

		    -- 설정된 드래곤 표시 없애기
		    ui:setReadySpriteVisible(false)

		    vars['chNode' .. idx]:addChild(ui.root)--, ZORDER.DRAGON_CARD)
        end
	end

    -- 리더 체크
	if (leader) and (leader > 0) then
		self:refreshLeaderSprite(leader)

	else
		-- 덱에 드래곤이 없으므로 leader표시를 없앤다.
		vars['leaderSprite']:setVisible(false)
	end
end

-------------------------------------
-- function setFormation
-------------------------------------
function UI_2DDeck:setFormation(formation, force_arena)
    local force_arena = force_arena or false
    local formation = formation or 'attack'
    local interval = 110
    local l_pos_list

    if (self.m_bArena or force_arena) then
        l_pos_list = TableFormationArena:getFormationPositionListNew(formation, interval)
    else
        l_pos_list = TableFormation:getFormationPositionListNew(formation, interval)
    end

	-- 진형 위치 변경
	self:actionForChangeDeck_Immediately(l_pos_list)
end

-------------------------------------
-- function refreshLeader
-- @brief 리더 위치에 다시 붙여준다.
-------------------------------------
function UI_2DDeck:refreshLeaderSprite(tar_idx)
	local vars = self.vars

	vars['leaderSprite']:setVisible(true)
	vars['leaderSprite']:retain()
	vars['leaderSprite']:removeFromParent()
	vars['positionNode' .. tar_idx]:addChild(vars['leaderSprite'], 99)
	vars['leaderSprite']:release()

    if (self.m_direction == 'right') then
        vars['leaderSprite']:setScaleX(-1)
    end
end

-------------------------------------
-- function runAction
-- @brief 순차적으로 꿀렁이는 연출
-------------------------------------
function UI_2DDeck:runAction()
    local vars = self.vars
    for i=1, 5 do
        cca.fruitReact_MasterySkillIcon(vars['positionNode' .. i], i)
    end
end