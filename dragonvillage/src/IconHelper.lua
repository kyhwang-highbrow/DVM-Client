IconHelper = {}

-------------------------------------
-- function getHeroIcon
-------------------------------------
function IconHelper:getHeroIcon(res_name, evolution, attr)
    local res_name = res_name
	if evolution then 
		res_name = string.gsub(res_name, '#', '0' .. evolution)
	end
	if attr then
		res_name = string.gsub(res_name, '@', attr)
	end
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icon/cha/developing.png')
    end

    return sprite
end

-------------------------------------
-- function getItemIcon
-- @brief item테이블의 item id로 아이콘 생성
-------------------------------------
function IconHelper:getItemIcon(item_id)

    local type_str = nil

    if (type(item_id) == 'number') then
        local table_item = TABLE:get('item')
        local t_item = table_item[item_id]

        if (not t_item) then
            error('item_id : ' .. item_id)
        end

        type_str = t_item['full_type']
    else
        -- full_type일 경우
        type_str = item_id
    end


    local res_name = 'res/ui/icon/item/' .. type_str .. '.png'
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icon/item/developing.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
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
        error('t_skill : ' .. t_skill)
    end

    local res_name = t_skill['res_icon']
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icon/skill/developing.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getSpecialSkillIcon
-- @brief
-------------------------------------
function IconHelper:getSpecialSkillIcon(skill_id)
    local table_skill = TABLE:get('dragon_special')
    local t_skill = table_skill[skill_id]

    if (not t_skill) then
        error('t_skill : ' .. t_skill)
    end

    local res_name = t_skill['res_icon']
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icon/item/developing.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getAttributeIcon
-- @brief 속성아이콘 생성
-------------------------------------
function IconHelper:getAttributeIcon(attribute)
    attribute = attributeNumToStr(attribute)

    local res_name = string.format('res/ui/icon/attr/attr_%s.png', attribute)
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        error('res_name : ' .. res_name)
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getRoleIcon
-- @brief 역할 생성
-------------------------------------
function IconHelper:getRoleIcon(role)
    local res_name = string.format('res/ui/icon/role/dc_role_%s.png', role)
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        error('res_name : ' .. res_name)
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getAttackTypeIcon
-- @brief 공격 타입 아이콘 생성
-------------------------------------
function IconHelper:getAttackTypeIcon(attack_type)
    local res_name = string.format('res/ui/icon_attack_%s.png', attack_type)
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        error('res_name : ' .. res_name)
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getDragonRarityBG
-- @brief 드래곤 희귀도
-------------------------------------
function IconHelper:getDragonRarityBG(rarity)
    rarity = dragonRarityNumToStr(rarity)

    local res_name = string.format('res/ui/icon/rarity/rarity_bg_%s.png', rarity)
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        error('res_name : ' .. res_name)
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getDragonNamePng
-- @brief 드래곤 이름 png
-------------------------------------
function IconHelper:getDragonNamePng(dragon_id)
    local res_name = string.format('res/ui/dragon_card/dc_dragon_' .. dragon_id .. '.png')
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icon/item/developing.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getStatusEffectIcon
-- @brief 상태효과 아이콘 생성
-------------------------------------
function IconHelper:getStatusEffectIcon(status_effect_type)
	local res = TABLE:get('status_effect')[status_effect_type]['res_icon']
    local sprite = cc.Sprite:create(res)

    if (not sprite) then
		cclog(' no icon res : ' .. status_effect_type)
        sprite = cc.Sprite:create('res/ui/icon/status_effect/p_resist.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end