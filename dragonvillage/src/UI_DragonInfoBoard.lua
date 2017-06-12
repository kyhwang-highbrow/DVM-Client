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

    vars['friendshipGauge']:setPercentage(0)
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

    -- 슬라임인지 드래곤인지 여부
    local is_slime_object = (t_dragon_data.m_objectType == 'slime')

    local vars = self.vars
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 드래곤 이름
    if vars['nameLabel'] then
        vars['nameLabel']:setString(t_dragon_data:getDragonNameWithEclv())
    end

    -- 진화도 이름
    if vars['evolutionLabel'] then
        local evolution_lv = t_dragon_data['evolution']
        vars['evolutionLabel']:setString(evolutionName(evolution_lv))
    end

    do -- 드래곤 등급
        vars['starNode']:removeAllChildren()
        local star_icon = IconHelper:getDragonGradeIcon(t_dragon_data:getGrade(), t_dragon_data:getEclv(), 2)
        vars['starNode']:addChild(star_icon)
    end

    do -- 레벨
        local lv = (t_dragon_data['lv'] or 1)
        local grade = (t_dragon_data:getGrade() or 1)
        local eclv = (t_dragon_data:getEclv() or 0)
        local lv_str = Str('레벨 {1}/{2}', lv, dragonMaxLevel(grade, eclv))
        vars['lvLabel']:setString(lv_str)
    end

    do -- 경혐치 exp
        local grade = (t_dragon_data:getGrade() or 1)
        local eclv = (t_dragon_data:getEclv() or 0)
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
    if vars['friendshipLabel'] and vars['friendshipGauge'] then
        local friendship_obj = t_dragon_data:getFriendshipObject()
        local t_friendship_info = friendship_obj:getFriendshipInfo()

        vars['friendshipLabel']:setString(t_friendship_info['name'])

        vars['friendshipGauge']:stopAllActions()
        vars['friendshipGauge']:runAction(cc.ProgressTo:create(0.3, t_friendship_info['exp_percent']))
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

    -- 슬라임일 경우
    local is_slime_object = (t_dragon_data.m_objectType == 'slime')
    if is_slime_object then
        for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
            vars['skillNode' .. i]:removeAllChildren()
        end

        vars['slimeSprite']:setVisible(true)
        vars['slimeLabel']:setString(t_dragon_data:getSlimeDesc())

        local icon = t_dragon_data:makeSlimeSkillIcon()
        if icon then
            vars['skillNodeLeader']:addChild(icon)
        end
        return
    end

	-- 드래곤의 경우 
    vars['slimeSprite']:setVisible(false)
    do 
        local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
        local l_skill_icon = skill_mgr:getDragonSkillIconList()
        local function func_skill_detail_btn()
			UI_SkillDetailPopup(t_dragon_data)
		end

		for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
            local skill_node = vars['skillNode' .. i]
			skill_node:removeAllChildren()
            
			-- 스킬 아이콘 생성
			if l_skill_icon[i] then
                skill_node:addChild(l_skill_icon[i].root)
				l_skill_icon[i]:setLeaderLabelToggle(i == 'Leader')

                l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(func_skill_detail_btn)
                l_skill_icon[i].vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)

			-- 비어있는 스킬 아이콘 생성
			else
				local empty_skill_icon = IconHelper:getEmptySkillIcon()
				skill_node:addChild(empty_skill_icon)

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
        local rarity = t_dragon_data:getRarity()
        vars['rarityNode']:removeAllChildren()
        local icon = IconHelper:getRarityIcon(rarity)
        vars['rarityNode']:addChild(icon)

        vars['rarityLabel']:setString(dragonRarityName(rarity))
    end

    do -- 드래곤 속성
        local attr = t_dragon_data:getAttr()
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)

        vars['attrLabel']:setString(dragonAttributeName(attr))
    end

    do -- 드래곤 역할(role)
        local role_type = t_dragon_data:getRole()
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

    -- 슬라임인지 드래곤인지 여부
    local is_slime_object = (t_dragon_data.m_objectType == 'slime')
    if is_slime_object then
        vars['atk_label']:setString('0')
        vars['atk_spd_label']:setString('0')
        vars['cri_chance_label']:setString('0')
        vars['def_label']:setString('0')
        vars['hp_label']:setString('0')
        vars['cri_avoid_label']:setString('0')
        vars['avoid_label']:setString('0')
        vars['hit_rate_label']:setString('0')
        vars['cri_dmg_label']:setString('0')

        if vars['cp_label'] then
            vars['cp_label']:setString('0')
        end
        return
    end

    -- 능력치 계산기
    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)

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
