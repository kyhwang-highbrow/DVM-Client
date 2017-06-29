local PARENT = UI

-------------------------------------
-- class UI_MonsterInfoBoard
-------------------------------------
UI_MonsterInfoBoard = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MonsterInfoBoard:init()
    local vars = self:load('monster_info_board.ui')
    
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
    vars['equipmentBtn']:setVisible(false)
    vars['detailBtn']:setVisible(false)
    vars['detailBtn']:registerScriptTapHandler(function() self:click_detailBtn() end)
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
    vars['nameLabel']:setString(name)

    self:refresh_monsterSkillsInfo(t_monster_data)
    self:refresh_icons(t_monster_data)
    self:refresh_status(t_monster_data)
end

-------------------------------------
-- function refresh_monsterSkillsInfo
-- @brief 몬스터 스킬 - 아직 미정
-------------------------------------
function UI_MonsterInfoBoard:refresh_monsterSkillsInfo(t_monster_data)
    local vars = self.vars

    local t_monster = TABLE:get('monster_skill')

    -- 몬스터 3개 스킬까지만 보여줌
    local max = 3

    for i = 1, max do
        local skill = t_monster_data['skill_'..i]
        if (skill) then
            local skill_node = vars['skillNode' .. i]
            skill_node:removeAllChildren()

            local desc = t_monster['t_name']
            local path = t_monster['res_icon']
            local sprite = cc.Sprite:create(path)
            if (sprite) then
                sprite:setDockPoint(CENTER_POINT)
                sprite:setAnchorPoint(CENTER_POINT)
                skill_node:addChild(sprite)
            end
        end
    end
end

-------------------------------------
-- function refresh_icons
-- @brief 아이콘 갱신
-------------------------------------
function UI_MonsterInfoBoard:refresh_icons(t_monster_data)
    local vars = self.vars

    do -- 몬스터 희귀도
        local rarity = t_monster_data['rarity']
        vars['rarityNode']:removeAllChildren()
        local icon = IconHelper:getRarityIcon(rarity)
        vars['rarityNode']:addChild(icon)

        vars['rarityLabel']:setString(monsterRarityName(rarity))
    end

    do -- 몬스터 속성
        local attr = t_monster_data['attr']
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)

        vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 몬스터 역할(role)
        local role_type = t_monster_data['role']
        vars['roleNode']:removeAllChildren()
        local icon = IconHelper:getRoleIcon(role_type)
        vars['roleNode']:addChild(icon)

        vars['roleLabel']:setString(dragonRoleName(role_type))
    end
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_MonsterInfoBoard:refresh_status(t_monster_data)
    local vars = self.vars

    -- 능력치 계산 미정
    vars['cp_label']:setString(tostring(0))
end

-------------------------------------
-- function click_detailBtn
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_MonsterInfoBoard:click_detailBtn(t_monster_data, t_monster)
    local vars = self.vars
    vars['detailNode']:runAction(cc.ToggleVisibility:create())
    vars['infoNode']:runAction(cc.ToggleVisibility:create())
end
