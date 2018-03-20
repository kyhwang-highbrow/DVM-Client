local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TeamBonusListItem
-------------------------------------
UI_TeamBonusListItem = class(PARENT, {
        m_data = 'StructTeamBonus',
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
    local orgin_data = TableTeamBonus():get(data.m_id)

    -- 이름 & 조건
    local name = orgin_data['t_name'] or ''
    local condition = orgin_data['t_condition_desc'] or ''
    if (condition ~= '') then
        condition = ' - ' .. Str(condition)
    end
    local str = '{@apricot}'..Str(name)..'{@sky_blue}'..condition
    vars['titleLabel']:setString(str)

    -- 설명
    local desc = TableTeamBonus():getDesc(data.m_id)
    vars['dscLabel']:setString(desc)

    -- 드래곤 카드
    local l_dragon = data['m_lSatisfied'] -- 팀 보너스 조건 만족하는 드래곤 리스트
    local t_teambonus = TableTeamBonus():get(orgin_data['id'])
    local l_card = TeamBonusCardFactory:makeUIList(t_teambonus, l_dragon)

    if (l_card) then
        for i, ui in ipairs(l_card) do
            vars['dragonNode' .. i]:addChild(ui)
            ui:setSwallowTouch(false)
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