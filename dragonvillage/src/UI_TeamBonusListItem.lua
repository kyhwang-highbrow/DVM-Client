local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TeamBonusListItem
-------------------------------------
UI_TeamBonusListItem = class(PARENT, {
        m_data = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_TeamBonusListItem:init(data)
    self.m_data = data
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
    local data = self.m_data

    -- 이름 & 조건
    local name = data['t_name'] or ''
    local condition = data['t_condition_desc'] or ''
    if (condition ~= '') then
        condition = ' - ' .. condition
    end
    local str = '{@apricot}'..name..'{@sky_blue}'..condition
    vars['titleLabel']:setString(str)

    -- 설명
    local desc = data['r_desc'] or ''
    vars['dscLabel']:setString(desc)

    -- 드래곤 카드
    local t_teambonus = TableTeamBonus():get(data['id'])
    local l_card = TeamBonusCardFactory:makeUIList(t_teambonus)

    if (l_card) then
        for i, ui in ipairs(l_card) do
            vars['dragonNode' .. i]:addChild(ui)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TeamBonusListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TeamBonusListItem:refresh()
end