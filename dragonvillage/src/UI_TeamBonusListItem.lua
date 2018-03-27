local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TeamBonusListItem
-------------------------------------
UI_TeamBonusListItem = class(PARENT, {
        m_data = 'StructTeamBonus',
        m_bRecommend = 'boolean', -- 추천배치 가능한 모드
        m_applyFunc = 'function',
     })

TEAMBONUS_EMPTY_TAG = 0
-------------------------------------
-- function init
-------------------------------------
function UI_TeamBonusListItem:init(data, b_recommend, apply_func)
    self.m_data = data
    self.m_bRecommend = b_recommend or false
    self.m_applyFunc = apply_func or nil

    local vars = self:load('team_bonus_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TeamBonusListItem:initUI()
    local vars = self.vars
    local struct_teambonus = self.m_data
    local id = struct_teambonus.m_id

    -- 적용중인 팀보너스 없을 경우 
    if (id == TEAMBONUS_EMPTY_TAG) then
        vars['emptySprite']:setVisible(true)
        return
    end

    local t_teambonus = TableTeamBonus():get(id)

    -- 이름 & 조건
    local name = t_teambonus['t_name'] or ''
    local condition = t_teambonus['t_condition_desc'] or ''
    if (condition ~= '') then
        condition = ' - ' .. Str(condition)
    end
    local str = '{@apricot}'..Str(name)..'{@sky_blue}'..condition
    vars['titleLabel']:setString(str)

    -- 설명
    local desc = TableTeamBonus():getDesc(id)
    vars['dscLabel']:setString(desc)

    -- 적용중인 상태
    local is_satisfied = struct_teambonus:isSatisfied()
    if (is_satisfied) then 
        vars['selectSprite']:setVisible(true)
    end

    -- 드래곤 카드
    local l_card = TeamBonusCardFactory:makeUIList(struct_teambonus)
    if (l_card) then
        for i, card in ipairs(l_card) do
            vars['dragonNode' .. i]:addChild(card.root)
            card.root:setSwallowTouch(false)
        end

        local cnt = #l_card
        -- 스케일 조절
        if (cnt > 5) then
            local scale = 5 / cnt
            vars['dragonNode']:setScale(scale)
        end

        -- 추천배치 가능한 상태
        if (not is_satisfied and self.m_bRecommend) then
            local can_apply, l_dragon_list = TeamBonusHelper:isSatisfiedByMyDragons(t_teambonus)
            if (can_apply) then
                local condition_type = t_teambonus['condition_type']

                -- 카드가 안올라간 경우
                if (condition_type == 'role' or condition_type == 'attr') then

                else
                    l_dragon_list = {}
                    -- 추천 로직이 다를떄가 있어서 일딴 카드위에 올라간 드래곤 배치하는걸로 수정
                    -- 리팩토링 필요함

                    for _, v in ipairs(l_card) do
                        local struct_dragon_data = v.m_dragonData
                        if (struct_dragon_data and struct_dragon_data['id']) then
                            table.insert(l_dragon_list, struct_dragon_data)
                        end
                    end
                end

                vars['applyBtn']:setVisible(true)
                vars['applyBtn']:registerScriptTapHandler(function() self:click_applyBtn(l_dragon_list, t_teambonus) end)
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TeamBonusListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TeamBonusListItem:refresh()
end

-------------------------------------
-- function click_applyBtn
-------------------------------------
function UI_TeamBonusListItem:click_applyBtn(l_dragon_list, t_teambonus) 
    local function ok_cb()
        if (self.m_applyFunc) then
            self.m_applyFunc(l_dragon_list)
        end
    end
    local name = Str(t_teambonus['t_name'])
    local msg = Str('현재 편성된 팀을 해제하고 {@sky_blue}{1}{@default}팀을 배치합니다.\n진행하시겠습니까?', name)
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
end