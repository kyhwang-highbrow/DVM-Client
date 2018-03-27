local MAX_CONDITION_COUNT = 5

-------------------------------------
-- table TeamBonusCardFactory
-------------------------------------
TeamBonusCardFactory = {}

------------------------------------
-- function makeUIList
-- @brief 해당 팀보너스 DragonCard UI 리스트 생성
-- @param data : StructTeamBonus Data
-------------------------------------
function TeamBonusCardFactory:makeUIList(data)
    local l_card
    local t_teambonus = TableTeamBonus():get(data.m_id)
    local type = t_teambonus['condition_type']

    -- 적용중인 드래곤이 있다면 
    if (data:isSatisfied()) then
        l_card = self:makeUIList_Deck(data)

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
function TeamBonusCardFactory:makeUIList_Deck(data)
    local t_teambonus = TableTeamBonus():get(data.m_id)
    local l_dragon_data = data.m_lAllDragonData -- 팀보너스 적용 안되는 드래곤까지 받아옴

    local l_card = {}
    for _, struct_dragon_data in ipairs(l_dragon_data) do

        -- 팀보너스 적용중인 드래곤
        if (struct_dragon_data and struct_dragon_data['id']) then
            local card = UI_DragonCard(struct_dragon_data)
            local inuse_sprite = card.vars['inuseSprite']
            if (inuse_sprite) then
                inuse_sprite:setVisible(false)
            end
            card:setTeamBonusCheckBoxSpriteVisible(true)
            card:setTeamBonusCheckSpriteVisible(true)
            table.insert(l_card, card.root)

        -- 적용중이진 않지만 리스트에는 노출
        else
            local type = t_teambonus['condition_type']
            local did = struct_dragon_data['did']
            local is_all = ((type == 'did_attr') or (type == 'did_attr_same')) and true or false

            local card = self:getDefaultCard(did, is_all)
            table.insert(l_card, card.root)
        end
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
    for i = 1, MAX_CONDITION_COUNT do
        local condition = t_teambonus['condition_' .. i]
        if (condition ~= '') then
            local did = condition
            local is_all = true
            local card = self:getDefaultCard(did, is_all)
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
-- function getExistFirstDid
-- @brief 존재하는 속성 did 반환
-------------------------------------
function TeamBonusCardFactory:getExistFirstDid(start_did)
    local table_dragon = TableDragon()
    local exist_did 
    for i = 0, 5 do
        local did = start_did + i
        if (table_dragon:exists(did)) then
            exist_did = did
            break
        end
    end

    return exist_did
end

-------------------------------------
-- function getDefaultCard
-------------------------------------
function TeamBonusCardFactory:getDefaultCard(did, is_all)
    local is_all = is_all or false
    -- 존재하는 did 체크
    if (is_all) then
        did = self:getExistFirstDid(did)
    end

    local table_dragon = TableDragon()
    -- 무조건 성룡
    local evolution = 3
    local grade = table_dragon:getBirthGrade(did)

    local t_dragon_data = {}
    t_dragon_data['did'] = did
    t_dragon_data['evolution'] = evolution
    t_dragon_data['grade'] = grade

    local card = UI_DragonCard(StructDragonObject(t_dragon_data))
    local btn = card.vars['clickBtn']

    -- did 관련 팀보너스만 보유시 해당 드래곤 표시함
    -- 후에 바뀔 수 있음
    local struct_dragon_data = TeamBonusHelper:getExistDragonByDid(did, is_all)
    card:setTeamBonusCheckBoxSpriteVisible(true)

    -- 등급 표시 안함
    card:setSpriteVisible('starNode', res, false)

    -- 드래곤 보유하고 있다면 해당 드래곤 데이터로 갱신
    if (struct_dragon_data) then
        card.m_dragonData = struct_dragon_data
        local attr = struct_dragon_data:getAttr()
        card:makeAttrIcon(attr)
        card:refreshDragonInfo()

    -- 없을 경우 셰이더 효과
    else
        if (is_all) then
            -- 모든속성 아이콘 
            card:makeAttrIcon('all')
            -- 모든속성 배경 보여주지 않음
            card.vars['bgNode']:setVisible(false)
        end
        
        local shader = ShaderCache:getShader(SHADER_GRAY_PNG)
        card.vars['chaNode']:setGLProgram(shader)
    end

    -- 적용중 표시 x
    local inuse_sprite = card.vars['inuseSprite']
    if (inuse_sprite) then
        inuse_sprite:setVisible(false)
    end

    -- 눌렀을 경우             
    btn:registerScriptTapHandler(function() self:defaultCardTapHandler(did, btn, is_all) end)

    -- 꾹 눌렀을 경우 
    btn:registerScriptPressHandler(function() self:defaultCardPressHandler(did, btn, struct_dragon_data) end)

    return card
end

-------------------------------------
-- function defaultCardTapHandler
-------------------------------------
function TeamBonusCardFactory:defaultCardTapHandler(did, btn, is_all)
    -- 이름 툴팁 
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

-------------------------------------
-- function defaultCardPressHandler
-------------------------------------
function TeamBonusCardFactory:defaultCardPressHandler(did, btn, struct_dragon_data)
    -- 드래곤 정보팝업 노출
    if (struct_dragon_data) then
        UI_SimpleDragonInfoPopup(struct_dragon_data)

    -- 도감 상세보기 노출
    else
        local table_dragon = TableDragon()
        local evolution = 3
        local grade = table_dragon:getBirthGrade(did)

        local t_dragon = clone(table_dragon:get(did))
        t_dragon['bookType'] = 'dragon'
	    t_dragon['grade'] = grade 
	    t_dragon['evolution'] = evolution 

        local is_popup = true -- scene으로 열 경우 버튼 액션이 남이있음, 콜백으로 처리하려해도 UIC_BUTTON update에서 꼬여버림

        -- open으로 열 경우 팀보너스 버튼 제어 못함
        local ui = UI_BookDetailPopup(t_dragon, is_popup)
        ui:setUnableIndex()
        ui:setShowTemaBonus(false)
        ui.vars['teamBonusBtn']:setVisible(false)
    end
end