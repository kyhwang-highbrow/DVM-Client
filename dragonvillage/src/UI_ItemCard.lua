local PARENT = ITableViewCell:getCloneClass()

-------------------------------------
-- class UI_ItemCard
-------------------------------------
UI_ItemCard = class(PARENT, {
        root = '',
        vars = '',
    
        m_itemID = 'number',
        m_itemCount = 'number',
        m_tSubData = 'number',

        m_itemName = 'string',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ItemCard:init(item_id, count, t_sub_data)
    self.m_itemID = item_id
    self.m_itemCount = count
	self.m_tSubData = t_sub_data

	self:setItemData()
end

-------------------------------------
-- function setItemData
-------------------------------------
function UI_ItemCard:setItemData()
	local table_item = TableItem()
    local t_item = table_item:get(self.m_itemID)

    if (not t_item) then
        -- 클랜 경험치는 table_item에 없음, 특이 케이스
        if (self.m_itemID == 'clan_exp') then
            self:init_clanExp(self.m_itemCount)
            return

        elseif (self.m_itemID == 'pass_point') then
        -- 패스 포인트도 table_item에 없음, 특이 케이스
            self:init_battlePassExp(self.m_itemCount)
            return

        else
            error('존재하지 않는 ID ' .. self.m_itemID)
        end
    end

    local item_type = t_item['type']
    if (item_type == 'dragon') then
        self:init_dragonItem(t_item)
    elseif (item_type == 'slime') then
        self:init_slimeItem(t_item)
    elseif (item_type == 'rune') then
        self:init_runeItem(t_item, self.m_tSubData)
    elseif (item_type == 'relation_point') then
        self:init_relationItem(t_item)
    elseif (item_type == 'reinforce_point') then
        self:init_reinforcePoint(t_item, self.m_itemCount)
    elseif (item_type == 'mastery_material') then
        self:init_masteryMaterial(t_item, self.m_itemCount)
    else
        self:init_commonItem(t_item)
    end

    self.vars['clickBtn']:registerScriptTapHandler(function() self:click_clickBtn() end)
    self.vars['clickBtn']:registerScriptPressHandler(function() self:press_clickBtn() end)
end

-------------------------------------
-- function init_commonItem
-------------------------------------
function UI_ItemCard:init_commonItem(t_item, t_sub_data)
    local item_id = self.m_itemID
	local count = self.m_itemCount
    
    local temp_ui = UI()
    local vars = temp_ui:load('icon_item_item.ui')
    self.root = temp_ui.root
    self.vars = vars

    local icon = IconHelper:getItemIcon(item_id, t_sub_data)
    vars['stoneNode']:addChild(icon)
    vars['icon'] = icon

    if (not count) or (count == 0) then
        vars['numberLabel']:setString('')
    else
        vars['numberLabel']:setString(Str('{1}', comma_value(count)))
    end

    vars['disableSprite']:setVisible(false)

    -- 레어도 표시
    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]
    local rarity_str = evolutionStoneRarityNumToStr(t_item['rarity'])
    vars['rarityVisual']:setVisual('group', rarity_str)
end

-------------------------------------
-- function setRareCountText
-------------------------------------
function UI_ItemCard:setRareCountText(count)
    local vars = self.vars
    if (not count) then
        count = 0
    end
    vars['numberLabel']:setString(Str('{1}', comma_value(count))) 
end

-------------------------------------
-- function init_dragonItem
-------------------------------------
function UI_ItemCard:init_dragonItem(t_item, t_sub_data)
    local item_id = self.m_itemID

    local t_dragon_data = {}
    t_dragon_data['did'] = t_item['did']
    t_dragon_data['evolution'] = t_item['evolution']
    t_dragon_data['grade'] = t_item['grade']
    t_dragon_data['skill_0'] = 1
    t_dragon_data['skill_1'] = 1
    t_dragon_data['skill_2'] = 0
    t_dragon_data['skill_3'] = 0

    local dragon_card = UI_DragonCard(StructDragonObject(t_dragon_data))
    -- UI_ItemCard로 생성한 경우 UI_DragonCard도 수량 표시함
    dragon_card:setCountText(self.m_itemCount)

    self.root = dragon_card.root
    self.vars = dragon_card.vars
    local vars = dragon_card.vars
end

-------------------------------------
-- function init_slimeItem
-------------------------------------
function UI_ItemCard:init_slimeItem(t_item, t_sub_data)
    local item_id = self.m_itemID

    local t_slime_data = {}
    t_slime_data['slime_id'] = t_item['did']
    t_slime_data['evolution'] = t_item['evolution']
    t_slime_data['grade'] = t_item['grade']

    local dragon_card = UI_DragonCard(StructSlimeObject(t_slime_data))
    -- UI_ItemCard로 생성한 경우 UI_DragonCard도 수량 표시함
    dragon_card:setCountText(self.m_itemCount)

    self.root = dragon_card.root
    self.vars = dragon_card.vars
    local vars = dragon_card.vars
end

-------------------------------------
-- function init_runeItem
-------------------------------------
function UI_ItemCard:init_runeItem(t_item, t_sub_data)
    local item_id = self.m_itemID

    local temp_ui = UI()
    local vars = temp_ui:load('icon_item_item.ui')
    self.root = temp_ui.root
    self.vars = vars

    local icon = IconHelper:getItemIcon(item_id, t_sub_data)
    vars['stoneNode']:addChild(icon)

    vars['numberLabel']:setVisible(false)
    vars['commonSprite']:setVisible(false)

    self.m_itemName = (t_sub_data and t_sub_data['name'] or nil)
end

-------------------------------------
-- function init_relationItem
-------------------------------------
function UI_ItemCard:init_relationItem(t_item, t_sub_data)
    local item_id = self.m_itemID
    local count = self.m_itemCount
        
    local t_dragon_data = {}
    t_dragon_data['did'] = t_item['did']
    t_dragon_data['evolution'] = 1
    t_dragon_data['grade'] = 1
    t_dragon_data['skill_0'] = 1
    t_dragon_data['skill_1'] = 1
    t_dragon_data['skill_2'] = 0
    t_dragon_data['skill_3'] = 0

    local struct_dragon_object = StructDragonObject(t_dragon_data)
    local dragon_card = UI_RelationCard(struct_dragon_object, count)
    self.root = dragon_card.root
    self.vars = dragon_card.vars
end

-------------------------------------
-- function init_reinforcePoint
-- @brief 강화 포인트
-------------------------------------
function UI_ItemCard:init_reinforcePoint(t_item, count)
    local card = UI_ReinforcePointCard(t_item, count)
    self.root = card.root
    self.vars = card.vars
end

-------------------------------------
-- function init_clanExp
-- @brief 클랜 경험치
-------------------------------------
function UI_ItemCard:init_clanExp(count)
    local card = UI_ClanExpCard(count)
    self.root = card.root
    self.vars = card.vars
end

-------------------------------------
-- function init_battlePassExp
-- @brief 클랜 경험치
-------------------------------------
function UI_ItemCard:init_battlePassExp(count)
    local card = UI_BattlePassCard(count)
    self.root = card.root
    self.vars = card.vars
end
-------------------------------------
-- function init_masteryMaterial
-------------------------------------
function UI_ItemCard:init_masteryMaterial(t_item, count)
    local item_id = self.m_itemID

    local temp_ui = UI()
    local vars = temp_ui:load('icon_item_item.ui')
    self.root = temp_ui.root
    self.vars = vars

    local icon = IconHelper:getItemIcon(item_id)
    vars['stoneNode']:addChild(icon)

    if (not count) or (count == 0) then
        vars['numberLabel']:setString('')
    else
        vars['numberLabel']:setString(Str('{1}', comma_value(count)))
    end

    -- 속성 아이콘 별도로 처리
    local attr = t_item['attr']
    if (attr ~= '' and attr ~= nil) then
        -- plist 사용 .. itemCard도 plist 사용하여 생성하도록 바꾸는 것이 좋다. card_item은 왜 안쓰게 된거지?
        cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/card/card.plist')

        local res = 'card_cha_attr_' .. attr .. '.png'
        local sprite = IconHelper:createWithSpriteFrameName(res)
        
        vars['attrNode']:removeAllChildren()
        vars['attrNode']:addChild(sprite)
        vars['attrNode']:setVisible(true)
    end
end




-------------------------------------
-- function setNumberLabel
-- @ksjang 밖에서 해당 메서드 호출해서 라벨 변경하지 말것
-- type에 따라서 오류, 의도와 맞지 않는 동작 발생 가능
-------------------------------------
function UI_ItemCard:setNumberLabel(str)
    local vars = self.vars
    vars['numberLabel']:setString(str)
end

-------------------------------------
-- function setRarityVisibled
-------------------------------------
function UI_ItemCard:setRarityVisibled(visible)
    if (not self.vars['rarityVisual']) then
        return
    end

    self.vars['rarityVisual']:setVisible(visible)
end

-------------------------------------
-- function setString
-------------------------------------
function UI_ItemCard:setString(str)
    if (not self.vars['numberLabel']) then
        return
    end

    self.vars['numberLabel']:setString(str)
end

-------------------------------------
-- function click_clickBtn
-------------------------------------
function UI_ItemCard:click_clickBtn()
    local str = self:getToolTipDesc()
    local tool_tip = UI_Tooltip_Skill(70, -145, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['clickBtn'])
end

-------------------------------------
-- function press_clickBtn
-------------------------------------
function UI_ItemCard:press_clickBtn()
    local item_id = self.m_itemID
    local count = self.m_itemCount
	local t_sub_data = self.m_tSubData

    UINavigatorDefinition:CloseOpendUI('UI_ItemInfoPopup')-- UI 무한 Open방지
    UI_ItemInfoPopup(item_id, count, t_sub_data)
end

-------------------------------------
-- function setEnabledClickBtn
-------------------------------------
function UI_ItemCard:setEnabledClickBtn(enabled)
    self.vars['clickBtn']:setEnabled(enabled)
end

-------------------------------------
-- function unregisterScriptPressHandler
-------------------------------------
function UI_ItemCard:unregisterScriptPressHandler()
    self.vars['clickBtn']:unregisterScriptPressHandler()
end

-------------------------------------
-- function setHighlightSpriteVisible
-- @brief UI_RuneCard와 코드 공유하기 위해 추가
-------------------------------------
function UI_ItemCard:setHighlightSpriteVisible(visible)
    self.vars['highlightSprite']:setVisible(visible)
end


-------------------------------------
-- function getToolTipDesc
-------------------------------------
function UI_ItemCard:getToolTipDesc()
    local item_id = self.m_itemID

    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]
    -- @delete_rune
    if (not t_item) then
        return '{@SKILL_NAME}none'
    end
    local desc = t_item['t_desc']

    -- 설정된 별도의 이름이 있으면 우선 사용
    local name = (self.m_itemName or t_item['t_name'])

    local str = Str('{@SKILL_NAME}{1}\n{@DEFAULT}{2}', Str(name), Str(desc))
    return str
end

-------------------------------------
-- function setCheckSpriteVisible
-- @brief 체크 표시
-------------------------------------
function UI_ItemCard:setCheckSpriteVisible(visible)
    self.vars['checkSprite']:setVisible(visible)
end

-------------------------------------
-- function setSwallowTouch
-- @brief SwallowTouch 버튼눌러도 스크롤 되도록 
-------------------------------------
function UI_ItemCard:setSwallowTouch()
    self.root:setSwallowTouch(false)
end


function UI_ItemCard:SetBackgroundVisible(bool_value)
    local vars = self.vars

    if(vars['commonSprite']) then
        vars['commonSprite']:setVisible(bool_value)
    end

    if(vars['bgSprite']) then
        vars['bgSprite']:setVisible(bool_value)
    end
end


------------------------------------
-- function UI_BattlePassCard
-- @brief UI에서 사용하기 위한 패스 포인트 카드, itemCard를 사용하지는 않음
-------------------------------------
function UI_BattlePassCard(pass_exp)
	local ui = UI()
    local vars = ui:load('icon_item_item.ui')
    
    local icon = IconHelper:getBattlePassExpIcon()
    vars['stoneNode']:addChild(icon)
    vars['icon'] = icon

    if (not pass_exp) or (pass_exp == 0) then
        vars['numberLabel']:setString('')
    else
        vars['numberLabel']:setString(comma_value(pass_exp))
    end

    vars['disableSprite']:setVisible(false)

	-- 클릭 시 툴팁
	vars['clickBtn']:registerScriptTapHandler(function()
		local str = '{@SKILL_NAME}' .. Str('개인 패스 경험치')
		local tool_tip = UI_Tooltip_Skill(70, -145, str)
		tool_tip:autoPositioning(vars['clickBtn'])
	end)

	return ui
end


------------------------------------
-- function UI_ClanExpCard
-- @brief UI에서 사용하기 위한 클랜 카드, itemCard를 사용하지는 않음
-------------------------------------
function UI_ClanExpCard(clan_exp)
	local ui = UI()
    local vars = ui:load('icon_item_item.ui')
    
    local icon = IconHelper:getClanExpIcon()
    vars['stoneNode']:addChild(icon)
    vars['icon'] = icon

    if (not clan_exp) or (clan_exp == 0) then
        vars['numberLabel']:setString('')
    else
        vars['numberLabel']:setString(comma_value(clan_exp))
    end

    vars['disableSprite']:setVisible(false)

	-- 클릭 시 툴팁
	vars['clickBtn']:registerScriptTapHandler(function()
		local str = '{@SKILL_NAME}' .. Str('클랜 경험치')
		local tool_tip = UI_Tooltip_Skill(70, -145, str)
		tool_tip:autoPositioning(vars['clickBtn'])
	end)

	return ui
end

-------------------------------------
-- function setEventIllusionVisible
-------------------------------------
function UI_ItemCard:setEventIllusionVisible(visible, is_bonus)
    local res = 'res/ui/a2d/event_dungeon/event_dungeon.vrp'
    local ani = 'idle'
    if (is_bonus) then
        ani = 'idle_bonus'
    end
    
    local animator = MakeAnimator(res)
    animator:changeAni(ani, true)
    animator:setIgnoreLowEndMode(true)
    self.vars['clickBtn']:addChild(animator.m_node)

    animator:setPosition(44, 40)
    animator:setScale(0.5)
end

-------------------------------------
-- function showZeroCount
-- @brief 아이템 갯수가 0개일 경우 0이라고 표기, 원래 0개라면 아예 표기를 안함
-------------------------------------
function UI_ItemCard:showZeroCount()
    if (self.m_itemCount == 0) then
        self.vars['numberLabel']:setString(0)
    end
end



-------------------------------------
-- function MakeItemCard
-- @brief t_item의 키를 입력하는 수고를 덜고자 함
-------------------------------------
function MakeItemCard(t_item)
    local card_ui = UI_ItemCard(t_item['item_id'], t_item['count'], nil)
    card_ui.root:setSwallowTouch(false)
    return card_ui
end