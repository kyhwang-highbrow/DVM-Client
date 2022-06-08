IconHelper = {}

-------------------------------------
-- function getIcon
-------------------------------------
function IconHelper:getIcon(res_name, default_res)
	local sprite = cc.Sprite:create(res_name)
    local is_exist = true
    if (not sprite) then
        is_exist = false
        sprite = cc.Sprite:create(default_res or 'res/ui/icons/cha/developing.png')
        -- @E.T.
		g_errorTracker:appendFailedRes(res_name)
    end

    if (sprite) then
	    sprite:setDockPoint(CENTER_POINT)
	    sprite:setAnchorPoint(CENTER_POINT)
    end

	return sprite, is_exist
end

-------------------------------------
-- function createWithSpriteFrameName
-------------------------------------
function IconHelper:createWithSpriteFrameName(res_name)
	local sprite = cc.Sprite:createWithSpriteFrameName(res_name)
    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icons/cha/developing.png')
        -- @E.T.
		g_errorTracker:appendFailedRes(res_name)
    end

	sprite:setDockPoint(CENTER_POINT)
	sprite:setAnchorPoint(CENTER_POINT)
	return sprite
end

-------------------------------------
-- function getHeroIcon
-------------------------------------
function IconHelper:getHeroIcon(res_name, evolution, attr, is_metamorphosis)
    local res_name = res_name

    if (is_metamorphosis) then
        res_name = string.gsub(res_name, '#', 'dragon_0' .. evolution)
    else
        res_name = string.gsub(res_name, '#', '0' .. evolution)
    end
	res_name = string.gsub(res_name, '@', attr)
    
    local sprite = self:getIcon(res_name)
    return sprite
end

-------------------------------------
-- function makeDragonIconRes
-- @breif 드래곤 아이콘 경로 생성
-------------------------------------
function IconHelper:makeDragonIconRes(t_dragon_data, t_dragon)
    local res = t_dragon['icon']
    local evolution = t_dragon_data['evolution']
    local attr = t_dragon['attr']

    res = string.gsub(res, '#', '0' .. evolution)
    res = string.gsub(res, '@', attr)

    return res
end

-------------------------------------
-- function getDragonIconFromTable
-- @breif 테이블을 받아서 드래곤 아이콘 생성
-------------------------------------
function IconHelper:getDragonIconFromTable(t_dragon_data, t_dragon, is_metamorphosis)
    local res = t_dragon['icon']
    local evolution = t_dragon_data['transform'] and t_dragon_data['transform'] or t_dragon_data['evolution']
    evolution = evolution or 3
    local attr = t_dragon['attr']
	local sprite = IconHelper:getHeroIcon(res, evolution, attr, is_metamorphosis)
    return sprite
end

-------------------------------------
-- function getDragonIconFromDid
-------------------------------------
function IconHelper:getDragonIconFromDid(dragon_id, evolution, grade, eclv)
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    assert(t_dragon, 'dragon_id : ' .. dragon_id)

    local res_name = t_dragon['icon']
    local evolution = evolution
    local attr = t_dragon['attr']
    local sprite = IconHelper:getHeroIcon(res_name, evolution, attr)

    -- 등급 정보가 있을 경우
    if (grade and eclv) then
		local t_dragon_data = clone(t_dragon)
		t_dragon_data['grade'] = grade
		t_dragon_data['evolution'] = evolution 
        local grade_sprite = self:getDragonGradeIcon(t_dragon_data, 1)
        if grade_sprite then
            grade_sprite:setScale(0.38)
            grade_sprite:setPositionY(-50)
            sprite:addChild(grade_sprite)
        end
    end

    return sprite
end

-------------------------------------
-- function getDragonGradeIcon
-- @param t_dragon_data - sturct or table
-- @param type - 1 : small
--				 2 : big
--				 3 : right_side				
-------------------------------------
function IconHelper:getDragonGradeIcon(t_dragon_data, type)
    local grade = (t_dragon_data['grade'] or 1)
    local evolution = (t_dragon_data['evolution'] or 0)
    local type = (type or 1)

    if (grade <= 0) then
        return nil
    end

	-- 색상을 찾음
	local color
	if (evolution == 1) then
		if (TableDragon():isUnderling(t_dragon_data['did'])) then
			color = 'gray'
		elseif (t_dragon_data['m_objectType'] == 'slime') then
			color = 'gray'
		else
			color = 'yellow'
		end
	elseif (evolution == 2) then
		color = 'purple'
	elseif (evolution == 3) then
		color = 'red'
	end

    local res = string.format('res/ui/icons/star/star_%s_%02d%02d.png', color, type, grade)

    local sprite = self:getIcon(res)

	if (type == 3) then
		-- mskim : 별이 왼쪽에서 나와야 하는데 이미지는 오른쪽에 붙어있다.
		-- 이미지가 왼쪽으로 바껴야 하지만 바쁘신거 같아 클라에서 제어..
		sprite:setScaleX(-1)
	end

    return sprite
end

-------------------------------------
-- function getDragonReinforceIcon
-------------------------------------
function IconHelper:getDragonReinforceIcon(rlv)
    local res = string.format('res/ui/icons/reinforce/reinforce_level_%d.png', rlv)
    local sprite = self:getIcon(res)
	return sprite
end

-------------------------------------
-- function getDragonMasteryIcon
-- @brief 드래곤 특성 레벨 아이콘
-------------------------------------
function IconHelper:getDragonMasteryIcon(mastery_level)
    local res = string.format('res/ui/icons/mastery/mastery_level_%.2d.png', mastery_level)
    local sprite = self:getIcon(res)
	return sprite
end

-------------------------------------
-- function getItemIcon
-- @brief item테이블의 item id로 아이콘 생성
-------------------------------------
function IconHelper:getItemIcon(item_id, t_sub_data)

    local table_item = TableItem()

	if (table_item:getItemIDFromItemType(item_id)) then
		item_id = table_item:getItemIDFromItemType(item_id)
	end

    local t_item = table_item:get(item_id)

    if (not t_item) then
        return
    end

    local sprite = nil

    -- 타입별 아이콘 별도 처리
    local item_type = t_item['type']

    -- 아이콘 리소스가 지정되어 있을 경우
    if t_item['icon'] and (t_item['icon'] ~= '') then
        -- 룬 세트 아이콘 생성
        if (pl.stringx.startswith(t_item['full_type'], 'rune_rand_')) then
            local grade = string.gsub(t_item['full_type'], 'rune_rand_', '')
            sprite = self:getRuneSetIcon(t_item['icon'], grade)
        else
            sprite = self:getIcon(t_item['icon'])
        end

    -- 드래곤 아이콘 생성
    elseif (item_type == 'dragon') then

        -- 2017-11-21 sgkim (상점에서 아르주나, 카르나를 판매할 때 UI_DragonCard로 변경함)
        --local dragon_id = t_item['did']
        --local evolution = t_item['evolution']
        --local grade = 1
        --local eclv = 0
        --sprite = IconHelper:getDragonIconFromDid(dragon_id, evolution, grade, eclv)

        local t_dragon_data = {}
        t_dragon_data['did'] = t_item['did']
        t_dragon_data['evolution'] = t_item['evolution'] or 1
        t_dragon_data['grade'] = t_item['grade'] or 1

        local card = UI_DragonCard(StructDragonObject(t_dragon_data))
        card.vars['clickBtn']:setEnabled(false)
        sprite = card.root

    -- 슬라임 아이콘 생성
    elseif (item_type == 'slime') then
        local t_slime_data = {}
        t_slime_data['slime_id'] = t_item['did']
        t_slime_data['evolution'] = t_item['evolution']
        t_slime_data['grade'] = t_item['grade']

        local card = UI_DragonCard(StructSlimeObject(t_slime_data))
        card.vars['clickBtn']:setEnabled(false)
        sprite = card.root

    -- 룬 아이콘 생성
    elseif (item_type == 'rune') then
        local rune_obj = t_sub_data or StructRuneObject({['rid'] = item_id})
        local slot = rune_obj['slot']
        local rarity = rune_obj['rarity'] or 0
        local grade = rune_obj['grade']
        local set_id = rune_obj['set_id']
        local lv = rune_obj['lv']
        local lock = rune_obj['lock'] or false

        sprite = self:getRuneIcon(slot, rarity, grade, set_id, lv, lock)

    -- 인연 포인트 아이콘 생성
    elseif (item_type == 'relation_point') then
        local item_cnt = t_sub_data or 0
        local card = UI_ItemCard(item_id, item_cnt)
         
        sprite = card.root

    -- 강화 포인트 아이콘 생성
    elseif (item_type == 'reinforce_point') then
        local item_cnt = t_sub_data or 0
        local card = UI_ItemCard(item_id, item_cnt)
		card.vars['clickBtn']:setEnabled(false)

        sprite = card.root

    -- 특성 재료 (icon res와 full_type이 일치하지 않아 따로 처리
    elseif (item_type == 'mastery_material') then
        local res_name = t_item['icon']
        sprite = self:getIcon(res_name)

    -- 기타 아이템 아이콘 생성
    else
        local type_str = t_item['full_type']
        local res_name = 'res/ui/icons/item/' .. type_str .. '.png'
        sprite = self:getIcon(res_name)
    end

    return sprite
end

-------------------------------------
-- function getRuneIcon
-- @brief 룬 아이콘 생성
-------------------------------------
function IconHelper:getRuneIcon(slot, rarity, grade, set_id, lv, lock)
    local rarity_str = ''

    if (rarity == 0) then
        rarity_str = 'none'

    elseif (rarity == 1) then
        rarity_str = 'common'

    elseif (rarity == 2) then
        rarity_str = 'rare'

    elseif (rarity == 3) then
        rarity_str = 'hero'

    elseif (rarity == 4) then
        rarity_str = 'legend'

    else
        error('rarity(rune_rarity) : ' .. rarity)
    end

    local bg = self:getIcon('res/ui/icons/rune/rune_bg_' .. rarity_str .. '.png')

    local set_color = TableRuneSet:getRuneSetColor(set_id)

    -- 룬 아이콘
    local rune_icon_res = string.format('res/ui/icons/rune/%.2d_%s_%.2d.png', slot, set_color, grade)
    local rune_icon = self:getIcon(rune_icon_res)

    -- 1번 슬롯 삼각형은 제외
    if (slot ~= 1) then
        rune_icon:setPositionY(10)
    end
    bg:addChild(rune_icon)

    -- 룬문자 (set_id로 결정됨), 룬 데이터가 아니므로 세트 아이디로 고대 룬 구분
    if slot and (0 < slot and slot <= 6) and (set_id < 9) then
        local alphabet_sprite = self:getIcon(string.format('res/ui/icons/rune/rune_number_%.2d.png', slot))
        if alphabet_sprite then
            alphabet_sprite:setDockPoint(CENTER_POINT)
            alphabet_sprite:setAnchorPoint(CENTER_POINT)
            rune_icon:addChild(alphabet_sprite)

            local c3b = TableRuneSet:getRuneSetColorC3b(set_id)
            alphabet_sprite:setColor(c3b)
        end
    end

    -- 룬 등급 (1성~5성)
    local grade_sprite = self:getIcon(string.format('res/ui/icons/rune/rune_star_%.2d.png', grade))
    if grade_sprite then
        grade_sprite:setDockPoint(CENTER_POINT)
        grade_sprite:setAnchorPoint(CENTER_POINT)
        grade_sprite:setPosition(0, -51)
        bg:addChild(grade_sprite)
    end

    -- 강화도 표시
    if lv then
        local str = Str('+{1}', lv)
        if (lv <= 0) then
            str = ''
        end
        local label = cc.Label:createWithTTF(str, Translate:getFontPath(), 26, 2, cc.size(250, 100), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        label:setPosition(-60, -30)
        label:setDockPoint(CENTER_POINT)
        label:setAnchorPoint(cc.p(0, 0.5))
        bg:addChild(label)
    end

    -- 잠금 여부
    if lock then
        local sprite = self:getIcon('res/ui/a2d/card/card_cha_icon_lock.png')
        sprite:setPosition(54, -24)
        bg:addChild(sprite)
    end

    return bg
end

-------------------------------------
-- function getRuneSetIcon
-- @brief 룬 아이콘 생성
-------------------------------------
function IconHelper:getRuneSetIcon(res_name, grade)
    -- 룬 아이콘
    local rune_icon = self:getIcon(res_name)

    -- 룬 등급 (1성~5성)
    local grade_sprite = self:getIcon(string.format('res/ui/icons/rune/rune_star_%.2d.png', grade))
    if grade_sprite then
        grade_sprite:setDockPoint(CENTER_POINT)
        grade_sprite:setAnchorPoint(CENTER_POINT)
        grade_sprite:setPosition(0, -51)
        rune_icon:addChild(grade_sprite)
    end

    return rune_icon
end

-------------------------------------
-- function getSkillIcon
-- @brief
-------------------------------------
function IconHelper:getSkillIcon(char_type, skill_id)
    local table_name = char_type .. '_skill'
    
    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    if (not t_skill) then
        error(skill_id .. '번 스킬은 테이블 데이타가 없다.')
    end

    local res_name = t_skill['res_icon']
    local sprite = self:getIcon(res_name)

    return sprite
end

-------------------------------------
-- function getSkillIconWithId
-- @brief 드래곤 스킬과 몬스터 스킬 모두 검사
-------------------------------------
function IconHelper:getSkillIconWithId(skill_id)
         
    local t_dragon_skill = TABLE:get('dragon_skill')
    local t_monster_skill = TABLE:get('monster_skill')

    local t_skill = t_dragon_skill[skill_id]

    if (not t_skill) then
        t_skill = t_monster_skill[skill_id]
    end

    if (not t_skill) then
        error(skill_id .. '번 스킬은 테이블 데이타가 없다.')
    end

    local res_name = t_skill['res_icon']
    local sprite = self:getIcon(res_name)
    return sprite
end

-------------------------------------
-- function getEmptySkillCard
-- @brief
-------------------------------------
function IconHelper:getEmptySkillCard()
    local ui = UI()
    local vars = ui:load('icon_skill_item.ui')
    vars['typeLabel']:setVisible(false)
    vars['levelLabel']:setVisible(false)
    vars['emptySprite']:setVisible(true)
    return ui.root
end

-------------------------------------
-- function getEmptySkillIcon
-- @brief
-------------------------------------
function IconHelper:getEmptySkillIcon()
    local sprite = self:getIcon('res/ui/icons/skill/skill_empty.png')
    return sprite
end

-------------------------------------
-- function getAttributeIcon
-- @brief 속성아이콘 생성
-------------------------------------
function IconHelper:getAttributeIcon(attribute)
    attribute = attributeNumToStr(attribute)

    if (attribute == 'none') then
        attribute = 'all'
    end
    
    local res_name = string.format('res/ui/icons/attr/attr_%s_02.png', attribute)
    local sprite = self:getIcon(res_name)
    return sprite
end

-------------------------------------
-- function getRoleIcon
-- @brief 역할 생성
-------------------------------------
function IconHelper:getRoleIcon(role)
    local res_name = string.format('res/ui/icons/book/role_%s.png', role)
    local sprite = self:getIcon(res_name)
    return sprite
end

-------------------------------------
-- function getRarityIcon
-- @brief 희귀도 아이콘
-------------------------------------
function IconHelper:getRarityIcon(rare)
    local res_name = string.format('res/ui/icons/rarity/gem_%s.png', rare)
    local sprite = self:getIcon(res_name)
    return sprite
end

-------------------------------------
-- function getAttributeIconButton
-- @brief 속성아이콘 버튼 생성
-------------------------------------
function IconHelper:getAttributeIconButton(attribute, t_info)
	local attr_button = DragonInfoIconHelper.makeAttrIconBtn(attribute, t_info)
    return attr_button
end

-------------------------------------
-- function getRoleIconButton
-- @brief 역할 아이콘 버튼 생성
-------------------------------------
function IconHelper:getRoleIconButton(role, t_info)
    local role_button = DragonInfoIconHelper.makeRoleIconBtn(role, t_info)
    return role_button
end

-------------------------------------
-- function getRarityIconButton
-- @brief 희귀도 아이콘 버튼 생성
-------------------------------------
function IconHelper:getRarityIconButton(rare, t_info)
   local rarity_button = DragonInfoIconHelper.makeRarityIconBtn(rare, t_info)
   return rarity_button
end

-------------------------------------
-- function getStatusEffectIcon
-- @brief 상태효과 아이콘 생성
-------------------------------------
function IconHelper:getStatusEffectIcon(status_effect_type)
	local res_name = TableStatusEffect():get(status_effect_type)['res_icon']
    local sprite

    if (res_name and res_name ~= '') then
        local path, file_name, extension = string.match(res_name, "(.-)([^//]-)(%.[^%.]+)$")
        res_name = string.format('ingame_status_effect_%s.png', file_name)
		-- @jhakim 190628
		-- 메모리 부족으로 캐싱된 데이터가 지워진 상태에서 sprite를 생성하려다가 오류 발생한 사례가 있었음
		-- 이미 해당 캐시가 존재한다면 추가로 등록하지 않기 때문에 필요할 때마다 캐시넣는 방향으로 수 
        cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_status_effect/ingame_status_effect.plist')
        sprite = cc.Sprite:createWithSpriteFrameName(res_name)
    else
        sprite = self:getIcon(res_name, 'res/ui/icons/noti_icon_0101.png' )    
    end
	
    return sprite
end

-------------------------------------
-- function getStaminaInboxIcon
-- @breif 입장권 아이콘 생성
-------------------------------------
function IconHelper:getStaminaInboxIcon(type)
    local res = 'res/ui/icons/inbox/inbox_staminas_' .. type .. '.png'
    local icon = self:getIcon(res, 'res/ui/icons/inbox/inbox_staminas_st.png')
    return icon
end

-------------------------------------
-- function getTamerProfileIcon
-- @breif
-------------------------------------
function IconHelper:getTamerProfileIcon(type)
    local res = 'res/ui/icons/tamer/tamer_manage_' .. type .. '_0101.png'
    local icon = self:getIcon(res)
    return icon
end

-------------------------------------
-- function getTamerProfileIconWithCostumeID
-- @breif 코스튬 SD 아이콘 반환
-------------------------------------
function IconHelper:getTamerProfileIconWithCostumeID(costume_id)
    local costume_data 
    if (costume_id) then
        costume_data = g_tamerCostumeData:getCostumeDataWithCostumeID(costume_id)
    else
        local curr_tamer_id = g_tamerData:getCurrTamerID() or 110001
        costume_data = g_tamerCostumeData:getUsedStructCostumeData(curr_tamer_id)
    end

    local sd_icon = costume_data:getTamerSDIcon()
    return sd_icon
end

-------------------------------------
-- function makeTamerReadyIcon
-- @brief 콜로세움 테이머 아이콘
-------------------------------------
function IconHelper:makeTamerReadyIcon(tamer_id)
    local table_tamer = TableTamer()
    local type = table_tamer:getValue(tamer_id, 'type')
    local res = string.format('res/ui/icons/tamer/colosseum_ready_%s.png', type)

    local icon = cc.Sprite:create(res)
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))

    return icon
end

-------------------------------------
-- function getTamerSDIcon
-------------------------------------
function IconHelper:getTamerSDIcon(tamer_id)
    if (not tamer_id) then
        return nil
    end
    local costume_data = g_tamerCostumeData:getUsedStructCostumeData(tamer_id)

    local sd_icon = costume_data:getTamerSDIcon()
    return sd_icon
end

-------------------------------------
-- function getFormationIcon
-- @brief 진형 아이콘 생성
-------------------------------------
function IconHelper:getFormationIcon(formation_type, is_activated)
    if (not formation_type) then
        return nil
    end
	local sub_str = is_activated and '02' or '01'
    local res_name = string.format('res/ui/icons/fomation/%s_%s.png', formation_type, sub_str)
    local sprite = self:getIcon(res_name)
    return sprite
end

-------------------------------------
-- function getEggIconByEggID
-------------------------------------
function IconHelper:getEggIconByEggID(egg_id)
    local table_item = TableItem()
    local res = table_item:getValue(tonumber(egg_id), 'icon')
    local sprite = self:getIcon(res)
    return sprite
end

-------------------------------------
-- function getPriceIcon
-------------------------------------
function IconHelper:getPriceIcon(price_type)
    -- 현금 상품 (이미지 쓰지 않음)
    if (price_type == 'money') then
        return nil
    end
    
    local res = string.format('res/ui/icons/inbox/inbox_%s.png', price_type)
    local icon = IconHelper:getIcon(res)
    return icon
end

-------------------------------------
-- function getPriceBigIcon
-------------------------------------
function IconHelper:getPriceBigIcon(price_type)
    -- 현금 상품
    if (price_type == 'money') then
        if isIos() then
            price_type = 'usd'
        else
            price_type = 'krw'
        end
    end
    
    local res = string.format('res/ui/icons/item/%s.png', price_type)
    local icon = IconHelper:getIcon(res)
    return icon
end


-------------------------------------
-- function getNotiIcon
-------------------------------------
function IconHelper:getNotiIcon()
    return IconHelper:getIcon('res/ui/icons/noti_icon_0101.png')
end

-------------------------------------
-- function getManaIcon
-------------------------------------
function IconHelper:getManaIcon(mana)
    local res_path = string.format('res/ui/buttons/skill_mana_01%02d.png', mana)
    return IconHelper:getIcon(res_path)
end

-------------------------------------
-- function getSystemIcon
-------------------------------------
function IconHelper:getSystemIcon()
	return IconHelper:getIcon('res/ui/icons/item/dvm.png')
end

-------------------------------------
-- function getClanExpIcon
-------------------------------------
function IconHelper:getClanExpIcon()
    return IconHelper:getIcon('res/ui/icons/item/clan_exp.png')
end

-------------------------------------
-- function getBattlePassExpIcon
-------------------------------------
function IconHelper:getBattlePassExpIcon()
    return IconHelper:getIcon('res/ui/icons/item/battle_pass_point.png')
end

-------------------------------------
-- function getClanBuffIcon
-------------------------------------
function IconHelper:getClanBuffIcon(clan_buff_type)
	local res
	if (string.find(clan_buff_type, 'exp')) then
		res = 'res/ui/icons/hot_time/clan_buff_exp.png'

	elseif (string.find(clan_buff_type, 'gold')) then
		res = 'res/ui/icons/hot_time/clan_buff_gold.png'

	end

	return res and IconHelper:getIcon(res) or nil
end

