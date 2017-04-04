local PARENT = UI

-------------------------------------
-- class UI_DragonInfoBoard
-------------------------------------
UI_DragonInfoBoard = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonInfoBoard:init()
    local vars = self:load('dragon_info_board.ui')
    
    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonInfoBoard:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonInfoBoard:initButton()
    local vars = self.vars
    vars['equipmentBtn']:setVisible(false)
    vars['detailBtn']:registerScriptTapHandler(function() self:click_detailBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonInfoBoard:refresh(t_dragon_data)

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 드래곤 이름
    if vars['nameLabel'] then
        vars['nameLabel']:setString(Str(t_dragon['t_name']))
    end

    -- 진화도 이름
    if vars['evolutionLabel'] then
        local evolution_lv = t_dragon_data['evolution']
        vars['evolutionLabel']:setString(evolutionName(evolution_lv))
    end

    do -- 드래곤 등급
        vars['starNode']:removeAllChildren()
        local star_icon = IconHelper:getDragonGradeIcon(t_dragon_data['grade'], t_dragon_data['eclv'], 2)
        vars['starNode']:addChild(star_icon)
    end

    do -- 레벨
        local lv = (t_dragon_data['lv'] or 1)
        local grade = (t_dragon_data['grade'] or 1)
        local eclv = (t_dragon_data['eclv'] or 0)
        local lv_str = Str('{1}/{2}', lv, dragonMaxLevel(grade, eclv))
        vars['lvLabel']:setString(lv_str)
    end

    do -- 경혐치 exp
        local grade = (t_dragon_data['grade'] or 1)
        local eclv = (t_dragon_data['eclv'] or 0)
        local lv = (t_dragon_data['lv'] or 1)
        local exp = (t_dragon_data['exp'] or 0)
        local table_exp = TableDragonExp()
        local max_exp = table_exp:getDragonMaxExp(grade, lv)
        local is_max_lv = TableGradeInfo:isMaxLevel(grade, eclv, lv)

        if (not is_max_lv) then
            local percentage = (exp / max_exp) * 100
            percentage = math_floor(percentage)
            vars['expLabel']:setString(Str('{1}%', percentage))

            vars['expGauge']:stopAllActions()
            vars['expGauge']:setPercentage(0)
            vars['expGauge']:runAction(cc.ProgressTo:create(0.2, percentage)) 
        else
            vars['expLabel']:setString(Str('최대레벨'))
            vars['expGauge']:stopAllActions()
            vars['expGauge']:setPercentage(100)
        end
        
    end

    -- 친밀도
    if vars['friendshipLabel'] then
        local t_friendship_info = TableFriendship:getFriendshipLvAndExpInfo(t_dragon_data)
        vars['friendshipLabel']:setString(t_friendship_info['name'])
        vars['friendshipGauge']:setPercentage(t_friendship_info['percentage'])
    end


    self:refresh_dragonSkillsInfo(t_dragon_data, t_dragon)
    self:refresh_icons(t_dragon_data, t_dragon)
    self:refresh_status(t_dragon_data, t_dragon)
end

-------------------------------------
-- function refresh_dragonSkillsInfo
-- @brief 드래곤 스킬 정보 갱신
-------------------------------------
function UI_DragonInfoBoard:refresh_dragonSkillsInfo(t_dragon_data, t_dragon)
    local vars = self.vars

    local function func_skill_detail_btn()
        UI_SkillDetailPopup(t_dragon_data)
    end

    do -- 스킬 아이콘 생성
        local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
        local l_skill_icon = skill_mgr:getDragonSkillIconList()
        for i=0, MAX_DRAGON_EVOLUTION do
            if l_skill_icon[i] then
                vars['skillNode' .. i]:removeAllChildren()
                vars['skillNode' .. i]:addChild(l_skill_icon[i].root)

                l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(func_skill_detail_btn)
                l_skill_icon[i].vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
            end
        end
    end
end

-------------------------------------
-- function refresh_icons
-- @brief 아이콘 갱신
-------------------------------------
function UI_DragonInfoBoard:refresh_icons(t_dragon_data, t_dragon)
    local vars = self.vars

    do -- 희귀도
        local rarity = t_dragon['rarity']
        vars['rarityNode']:removeAllChildren()
        local icon = IconHelper:getRarityIcon(rarity)
        vars['rarityNode']:addChild(icon)

        vars['rarityLabel']:setString(dragonRarityName(rarity))
    end

    do -- 드래곤 속성
        local attr = t_dragon['attr']
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)

        vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon['role']
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
function UI_DragonInfoBoard:refresh_status(t_dragon_data, t_dragon)
    local vars = self.vars

    -- 능력치 계산기
    local doid = t_dragon_data['id']
    local status_calc = MakeOwnDragonStatusCalculator(doid)

    vars['atk_label']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['atk_spd_label']:setString(status_calc:getFinalStatDisplay('aspd'))
    vars['cri_chance_label']:setString(status_calc:getFinalStatDisplay('cri_chance'))
    vars['def_label']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))
    vars['cri_avoid_label']:setString(status_calc:getFinalStatDisplay('cri_avoid'))
    vars['avoid_label']:setString(status_calc:getFinalStatDisplay('avoid'))
    vars['hit_rate_label']:setString(status_calc:getFinalStatDisplay('hit_rate'))
    vars['cri_dmg_label']:setString(status_calc:getFinalStatDisplay('cri_dmg'))

    if vars['cp_label'] then
        vars['cp_label']:setString(comma_value(status_calc:getCombatPower()))
    end
end

-------------------------------------
-- function click_detailBtn
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonInfoBoard:click_detailBtn(t_dragon_data, t_dragon)
    local vars = self.vars
    vars['detailNode']:runAction(cc.ToggleVisibility:create())
    vars['infoNode']:runAction(cc.ToggleVisibility:create())
end
