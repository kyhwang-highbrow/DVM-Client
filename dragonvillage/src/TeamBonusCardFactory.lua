local MAX_CONDITION_COUNT = 5

-------------------------------------
-- table TeamBonusCardFactory
-------------------------------------
TeamBonusCardFactory = {}

------------------------------------
-- function makeUIList
-- @brief 해당 팀보너스 DragonCard UI 리스트 생성
-- @param teambonus_data : StructTeamBonus Data
-- @param l_dragon : 적용중인 Dragon객체 리스트
-------------------------------------
function TeamBonusCardFactory:makeUIList(t_teambonus, l_dragon)
    local l_card
    local type = t_teambonus['condition_type']

    -- 적용중인 드래곤이 있다면 
    if (l_dragon) and (#l_dragon > 0) then
        l_card = self:makeUIList_Deck(l_dragon)

    -- 속성 조건
    elseif (type == 'attr') then
        l_card = self:makeUIList_Attr(t_teambonus)

    -- 역할 조건
    elseif (type == 'role') then
        l_card = self:makeUIList_Role(t_teambonus)

    -- 같은 드래곤 조건 (모든 속성 포함)
    elseif (type == 'did_attr') or (type == 'did_attr_same') then
        l_card = self:makeUIList_Did_Attr(t_teambonus)

    -- 같은 드래곤 조건
    elseif (type == 'did') then
        l_card = self:makeUIList_Did(t_teambonus)

    else
        error('TeamBonusCardFactory - 정의 되지 않은 condition_type : ' .. type)
    end

    return l_card
end

-------------------------------------
-- function makeUIList_Deck
-- @brief 적용중인 드래곤 카드 생성
-------------------------------------
function TeamBonusCardFactory:makeUIList_Deck(l_dragon)
    local l_card = {}

    for _, dragon_data in ipairs(l_dragon) do
        local card = UI_DragonCard(dragon_data)
        local inuse_sprite = card.vars['inuseSprite']
        if (inuse_sprite) then
            inuse_sprite:setVisible(false)
        end
        table.insert(l_card, card.root)
    end
    
    return l_card
end

-------------------------------------
-- function makeUIList_Attr
-- @brief 속성 조건 카드 생성
-------------------------------------
function TeamBonusCardFactory:makeUIList_Attr(t_teambonus)
    local l_card = {}
    local condition_cnt = t_teambonus['condition_count']

    for i = 1, MAX_CONDITION_COUNT do
        local condition = t_teambonus['condition_' .. i]
        if (condition ~= '') and (i <= condition_cnt) then
            local attr = condition
            local card = UI_CharacterCard()
            card:makeFrame()
            card:makeAttrIcon(attr)

            local res = 'res/ui/icons/cha/developing.png'
            card:makeSprite('chaNode', res, true)
            card.vars['clickBtn']:setEnabled(false)

            table.insert(l_card, card.root)
        end
    end
    
    return l_card
end

-------------------------------------
-- function makeUIList_Role
-- @brief 역할 조건 카드 생성
-------------------------------------
function TeamBonusCardFactory:makeUIList_Role(t_teambonus)
    local l_card = {}
    local condition_cnt = t_teambonus['condition_count']

    for i = 1, MAX_CONDITION_COUNT do
        local condition = t_teambonus['condition_' .. i]
        if (condition ~= '') and (i <= condition_cnt) then
            local role = condition
            local card = UI_CharacterCard()
            card:makeFrame()

            local res = string.format('res/ui/icons/book/role_%s.png', role)
            card:makeSprite('chaNode', res, true)

            card.vars['clickBtn']:setEnabled(false)

            table.insert(l_card, card.root)
        end
    end
    
    return l_card
end

-------------------------------------
-- function makeUIList_Did_Attr
-- @brief 같은 드래곤 조건 (모든 속성 포함) 카드 생성
-------------------------------------
function TeamBonusCardFactory:makeUIList_Did_Attr(t_teambonus)
    local l_card = {}
    local table_dragon = TableDragon()

    -- 모든 속성인 경우 존재하는 첫번째 속성 드래곤 카드 찍어줌
    local get_did = function(start_did)
        for i = 1, 5 do
            local did = start_did + i
            if (table_dragon:exists(did)) then
                return did
            end
        end
            
        error('TeamBonusCardFactory - did 존재 하지 않음 : ' .. start_did)
    end

    for i = 1, MAX_CONDITION_COUNT do
        local condition = t_teambonus['condition_' .. i]
        if (condition ~= '') then
            local did = get_did(condition)
            local is_all = true
            local card = self:getDefaultCard(did, is_all)

            -- 모든속성 아이콘 
            card:makeAttrIcon('all')
            -- 모든속성 배경 보여주지 않음
            card.vars['bgNode']:setVisible(false)
            -- 셰이더 효과
            local shader = ShaderCache:getShader(SHADER_GRAY_PNG)
            card.vars['chaNode']:setGLProgram(shader)

            table.insert(l_card, card.root)
        end
    end
    
    return l_card
end

-------------------------------------
-- function makeUIList_Did
-- @brief 같은 드래곤 조건 카드 생성
-------------------------------------
function TeamBonusCardFactory:makeUIList_Did(t_teambonus)
    local l_card = {}

    for i = 1, MAX_CONDITION_COUNT do
        local condition = t_teambonus['condition_' .. i]
        if (condition ~= '') then
            local did = condition
            local card = self:getDefaultCard(did)
            table.insert(l_card, card.root)
        end
    end

    return l_card
end


-------------------------------------
-- function getDefaultCard
-------------------------------------
function TeamBonusCardFactory:getDefaultCard(did, is_all)
    local is_all = is_all or false

    local t_dragon_data = {}
    t_dragon_data['did'] = did

    -- 무조건 해치
    t_dragon_data['evolution'] = 1

    local card = UI_DragonCard(StructDragonObject(t_dragon_data))

    -- 눌렀을 경우 드래곤 이름 툴팁 출력                
    local btn = card.vars['clickBtn']
    local tap_func = function()
        local name = TableDragon:getDragonName(did)
        local attr = TableDragon:getDragonAttr(did)
        local str_attr = is_all and Str('(모든 속성)') or 
                         string.format('(%s)', dragonAttributeName(attr))
        name = name .. str_attr

        local desc = TableDragon:getDragonStoryStr(did)

        local str = Str('{@SKILL_NAME}{1}\n{@DEFAULT}{2}', name, desc)

        local tooltip = UI_Tooltip_Skill(0, 0, str)
        if (tooltip) then
            tooltip:autoPositioning(btn)
        end
    end

    btn:registerScriptTapHandler(tap_func)

    return card
end