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

    -- 적용중인 팀보너스 없을 경우 id : 0
    if (not TableTeamBonus():exists(data.m_id)) then
        vars['emptySprite']:setVisible(true)
        return
    end
    local t_teambonus = TableTeamBonus():get(data.m_id)

    -- 이름 & 조건
    local name = t_teambonus['t_name'] or ''
    local condition = t_teambonus['t_condition_desc'] or ''
    if (condition ~= '') then
        condition = ' - ' .. Str(condition)
    end
    local str = '{@apricot}'..Str(name)..'{@sky_blue}'..condition
    vars['titleLabel']:setString(str)

    -- 설명
    local desc = TableTeamBonus():getDesc(data.m_id)
    vars['dscLabel']:setString(desc)

    -- 드래곤 카드
    if (data:isSatisfied()) then -- 적용중인 상태에서만 만족하는 드래곤 리스트 찍어줌
        vars['selectSprite']:setVisible(true)
    end

    local l_card = TeamBonusCardFactory:makeUIList(data)

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
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TeamBonusListItem:refresh()
end