local PARENT = UI

-------------------------------------
-- class UI_MonsterInfoBoard
-------------------------------------
UI_MonsterInfoBoard = class(PARENT,{
        m_owner_ui = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MonsterInfoBoard:init(owner_ui)
    local vars = self:load('monster_info_board.ui')
    
    self.m_owner_ui = owner_ui
    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MonsterInfoBoard:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MonsterInfoBoard:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MonsterInfoBoard:refresh(t_monster_data)

    if (not t_monster_data) then
        return
    end

    local vars = self.vars

    -- 몬스터 이름
    local name = t_monster_data['t_name'] or ''
    vars['nameLabel']:setString(Str(name))

    self:refresh_monsterSkillsInfo(t_monster_data)
    self:refresh_status(t_monster_data)
end

-------------------------------------
-- function refresh_monsterSkillsInfo
-- @brief 몬스터 스킬 - 아직 미정
-------------------------------------
function UI_MonsterInfoBoard:refresh_monsterSkillsInfo(t_monster_data)
    local vars = self.vars
    local is_dragon = self.m_owner_ui.m_bDragonMonster

    -- 드래곤 몬스터는 3개, 그냥 몬스터는 9개 까지 보여줌
    local max = (is_dragon) and 3 or 9
    local table_skill = (is_dragon) and TABLE:get('dragon_skill') 
                                    or TABLE:get('monster_skill')

    for i = 1, max do
        local skill_id = t_monster_data['skill_'..i]
        if (skill_id) and (skill_id ~= '') then
            local t_skill = table_skill[skill_id]

            local skill_node = vars['skillNode' .. i]
            skill_node:removeAllChildren()

            local icon = UI_MonsterSkillCard('monster', skill_id)
            skill_node:addChild(icon.root)
        end
    end
	
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_MonsterInfoBoard:refresh_status(t_monster_data)
    local vars = self.vars

    -- 몬스터 레벨은 해당 스테이지 레벨
    local monster_lv = self.m_owner_ui.m_nMonsterLv
    t_monster_data['lv'] = monster_lv

    local is_dragon = self.m_owner_ui.m_bDragonMonster

    -- 능력치 계산기
    local status_calc = MakeMonsterStatusCalculator_fromMonsterDataTable(t_monster_data, is_dragon)
    vars['cpLabel']:setString(comma_value(status_calc:getCombatPower()))
end

