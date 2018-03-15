local MAX_CONDITION_COUNT = 5

-------------------------------------
-- table TeamBonusCardFactory
-------------------------------------
TeamBonusCardFactory = {}

------------------------------------
-- function makeUIList
-- @brief 해당 팀보너스 DragonCard UI 리스트 생성
-- @param teambonus_data : TableTeamBonus Data
-- @param l_dragon : 적용중인지 체크하고자 하는 Dragon 객체 리스트 (없는 경우 체크 안함)
-------------------------------------
function TeamBonusCardFactory:makeUIList(t_teambonus, l_dragon)
    local l_card
    local type = t_teambonus['condition_type']
    
    -- 속성 조건
    if (type == 'attr') then
        l_card = self:makeUIList_Attr(t_teambonus, l_dragon)

    -- 역할 조건
    elseif (type == 'role') then
        l_card = self:makeUIList_Role(t_teambonus, l_dragon)

    -- 같은 드래곤 조건 (모든 속성 포함)
    elseif (type == 'did_attr') or (type == 'did_attr_same') then
        l_card = self:makeUIList_Did_Attr(t_teambonus, l_dragon)

    -- 같은 드래곤 조건
    elseif (type == 'did') then
        l_card = self:makeUIList_Did(t_teambonus, l_dragon)

    else
        error('TeamBonusCardFactory - 정의 되지 않은 condition_type : ' .. type)
    end

    return l_card
end

-------------------------------------
-- function makeUIList_Attr
-- @brief 속성 조건 카드 생성
-------------------------------------
function TeamBonusCardFactory:makeUIList_Attr(t_teambonus, l_dragon)
    local l_card = {}

    -- 활성화 체크
    if (l_dragon) then


    -- 단순 전체보기
    else
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
    end
       
    return l_card
end

-------------------------------------
-- function makeUIList_Role
-- @brief 역할 조건 카드 생성
-------------------------------------
function TeamBonusCardFactory:makeUIList_Role(t_teambonus, l_dragon)
    local l_card = {}

    -- 활성화 체크
    if (l_dragon) then


    -- 단순 전체보기
    else
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
    end

    return l_card
end

-------------------------------------
-- function makeUIList_Did_Attr
-- @brief 같은 드래곤 조건 (모든 속성 포함) 카드 생성
-------------------------------------
function TeamBonusCardFactory:makeUIList_Did_Attr(t_teambonus, l_dragon)
    local l_card = {}

    -- 활성화 체크
    if (l_dragon) then


    -- 단순 전체보기
    else
        -- 모든 속성인 경우 존재하는 첫번째 속성 드래곤 카드 찍어줌
        local get_did = function(start_did)
            for i = 1, 5 do
                local did = start_did + i
                local name = TableDragon:getDragonName(did)
                if (name) then
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
    end

    return l_card
end

-------------------------------------
-- function makeUIList_Did
-- @brief 같은 드래곤 조건 카드 생성
-------------------------------------
function TeamBonusCardFactory:makeUIList_Did(t_teambonus, l_dragon)
    local l_card = {}

    -- 활성화 체크
    if (l_dragon) then


    -- 단순 전체보기
    else
        for i = 1, MAX_CONDITION_COUNT do
            local condition = t_teambonus['condition_' .. i]
            if (condition ~= '') then
                local did = condition
                local card = self:getDefaultCard(did)
                table.insert(l_card, card.root)
            end
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
        local desc = is_all and Str('(모든 속성)') or ''
        
        local str = '{@SKILL_NAME}' .. name .. ' ' .. desc
        local tooltip = UI_Tooltip_Skill(0, 0, str)
        if (tooltip) then
            tooltip:autoPositioning(btn)
        end
    end

    btn:registerScriptTapHandler(tap_func)

    return card
end