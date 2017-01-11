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
        local grade_sprite = self:getDragonGradeIcon(grade, eclv, 1)
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
-------------------------------------
function IconHelper:getDragonGradeIcon(grade, eclv, type)
    grade = (grade or 1)
    eclv = (eclv or 0)
    type = (type or 1)
    
    local res = ''
    if (type == 1) then
        if (0 < eclv) then
            res = string.format('res/ui/icon/character_eclv_%.2d.png', eclv)
        else
            res = string.format('res/ui/icon/star01%.2d.png', grade)
        end
        
    elseif (type == 2) then
        if (0 < eclv) then
            res = string.format('res/ui/icon/character_eclv_%.2d.png', eclv)
        else
            res = string.format('res/ui/icon/star02%.2d.png', grade)
        end

    end

    local sprite = cc.Sprite:create(res)
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    sprite:setDockPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getItemIcon
-- @brief item테이블의 item id로 아이콘 생성
-------------------------------------
function IconHelper:getItemIcon(item_id)

    local table_item = TABLE:get('item')
    local t_item = table_item[item_id]

    if (not t_item) then
        error('item_id : ' .. item_id)
    end

    local sprite = nil

    -- 타입별 아이콘 별도 처리
    local item_type = t_item['type']
    if (item_type == 'dragon') then
        local dragon_id = t_item['val_1']
        local evolution = t_item['rarity']
        local grade = 1
        local eclv = 0
        sprite = IconHelper:getDragonIconFromDid(dragon_id, evolution, grade, eclv)
    else
        local type_str = t_item['full_type']
        local res_name = 'res/ui/icon/item/' .. type_str .. '.png'
        sprite = cc.Sprite:create(res_name)
    end

    -- 아이콘이 없을 경우
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
        error(skill_id .. '번 스킬은 테이블 데이타가 없다.')
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
-- function getAttributeIcon
-- @brief 속성아이콘 생성
-------------------------------------
function IconHelper:getAttributeIcon(attribute)
    attribute = attributeNumToStr(attribute)

    local res_name = string.format('res/ui/icon/attr/attr_%s.png', attribute)
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icon/item/developing.png')
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
        sprite = cc.Sprite:create('res/ui/icon/item/developing.png')
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
        sprite = cc.Sprite:create('res/ui/icon/item/developing.png')
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
        sprite = cc.Sprite:create('res/ui/icon/item/developing.png')
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
	
	if (res == 'x') then 
		res = 'res/ui/icon/alarm_01.png' 
	end 
    
	local sprite = cc.Sprite:create(res)

    if (not sprite) then
        if (res ~= 'x') then
		    cclog(status_effect_type .. ' 상태 효과는 아이콘이 없음. 추가 해야함')
        end
        sprite = cc.Sprite:create('res/ui/icon/alarm_01.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getRarityIcon
-- @brief 희귀도 아이콘
-------------------------------------
function IconHelper:getRarityIcon(rarity)
	local res = 'res/ui/icon/rarity/gem_' .. rarity .. '.png'
    local sprite = cc.Sprite:create(res)

    if (not sprite) then
		cclog('이 희귀도는 아이콘이 없네요 : ' .. rarity)
        sprite = cc.Sprite:create('res/ui/icon/rarity/gem_common.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end