local PARENT = UI

-------------------------------------
-- class UI_DragonInfoBoard
-------------------------------------
UI_DragonInfoBoard = class(PARENT,{
        m_dragonObject = '',
        m_bSimpleMode = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonInfoBoard:init(is_simple_mode)
    self.m_bSimpleMode = is_simple_mode
    local vars = self:load('dragon_info_board_new.ui')
    
    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonInfoBoard:initUI(is_simple_mode)
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
   
    vars['equipSlotBtn1']:registerScriptTapHandler(function() self:click_runeBtn(1) end)
    vars['equipSlotBtn2']:registerScriptTapHandler(function() self:click_runeBtn(2) end)
    vars['equipSlotBtn3']:registerScriptTapHandler(function() self:click_runeBtn(3) end)
    vars['equipSlotBtn4']:registerScriptTapHandler(function() self:click_runeBtn(4) end)
    vars['equipSlotBtn5']:registerScriptTapHandler(function() self:click_runeBtn(5) end)
    vars['equipSlotBtn6']:registerScriptTapHandler(function() self:click_runeBtn(6) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonInfoBoard:refresh(t_dragon_data)
    self.m_dragonObject = t_dragon_data

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
        local star_icon = IconHelper:getDragonGradeIcon(t_dragon_data, 2)
        vars['starNode']:addChild(star_icon)
    end

    do -- 레벨
        local lv = (t_dragon_data['lv'] or 1)
        local grade = (t_dragon_data:getGrade() or 1)
        local eclv = (t_dragon_data:getEclv() or 0)
        local lv_str = Str('레벨 {1}/{2}', lv, dragonMaxLevel(grade))
        vars['lvLabel']:setString(lv_str)
    end

    do -- 경혐치 exp
        local grade = (t_dragon_data:getGrade() or 1)
        local eclv = (t_dragon_data:getEclv() or 0)
        local lv = (t_dragon_data['lv'] or 1)
        local exp = (t_dragon_data['exp'] or 0)
        local table_exp = TableDragonExp()
        local max_exp = table_exp:getDragonMaxExp(grade, lv)
        local is_max_lv = TableGradeInfo:isMaxLevel(grade, lv)

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
        -- friendship_obj 2017-07-19 sgkim
        --{
        --    ['fdef']=0;
        --    ['fexp']=0;
        --    ['ffeel']=0;
        --    ['fatk']=0;
        --    ['flv']=0;
        --    ['fhp']=0;
        --}

        local t_friendship_info = friendship_obj:getFriendshipInfo()
        -- t_friendship_info 2017-07-19 sgkim
        --{
        --    ['desc']='[곤히이]님에게 아무런 관심이 없습니다.';
        --    ['exp_percent']=0;
        --    ['def_max']=300;
        --    ['hp_max']=2100;
        --    ['atk_max']=300;
        --    ['feel_percent']=0;
        --    ['name']='무관심';
        --    ['max_exp']=300;
        --}

        local str = friendship_obj:getFriendshipDisplayText()
        vars['friendshipLabel1']:setString(str)
        vars['friendshipLabel2']:setString(t_friendship_info['name'])

        vars['friendshipGauge']:stopAllActions()
        vars['friendshipGauge']:runAction(cc.ProgressTo:create(0.3, t_friendship_info['exp_percent']))
    end


    self:refresh_dragonSkillsInfo(t_dragon_data, t_dragon)
    self:refresh_icons(t_dragon_data, t_dragon)
    self:refresh_status(t_dragon_data, t_dragon)
    self:refresh_dragonRunes(t_dragon_data)
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

	else
		vars['slimeSprite']:setVisible(false)

    end

	-- 드래곤의 경우 
    do 
        local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
        local l_skill_icon = skill_mgr:getDragonSkillIconList()

		for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
            local skill_node = vars['skillNode' .. i]
			skill_node:removeAllChildren()
            
			-- 스킬 아이콘 생성
			if l_skill_icon[i] then
                skill_node:addChild(l_skill_icon[i].root)
                l_skill_icon[i]:setSimple()

				l_skill_icon[i].vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
                l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(function()
					UI_SkillDetailPopup(t_dragon_data, i)
				end)

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
        vars['typeNode']:removeAllChildren()
        local icon = IconHelper:getRoleIcon(role_type)
        vars['typeNode']:addChild(icon)

        vars['typeLabel']:setString(dragonRoleName(role_type))
    end

    -- 드래곤 역할
    local role_type = t_dragon_data:getRole()
    vars['typeLabel']:setString(dragonRoleName(role_type))
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

-------------------------------------
-- function click_runeBtn
-- @brief 룬 버튼
-------------------------------------
function UI_DragonInfoBoard:click_runeBtn(slot_idx)
    -- UI가 간단모드로 설정되어 있을 경우
    if (self.m_bSimpleMode == true) then
        return
    end

    -- 드래곤 정보가 없을 경우
    if (not self.m_dragonObject) then
        return
    end

    -- 룬 UI 오픈
    local doid = self.m_dragonObject['id']
    local ui = UI_DragonRunes(doid, slot_idx)

    -- 룬 장착에 대한 변경사항이 있을 경우 처리
    local function close_cb()
        local doid = self.m_dragonObject['id']
        local dragon_object = g_dragonsData:getDragonObject(doid)

        if (dragon_object['updated_at'] ~= self.m_dragonObject['updated_at']) or ui.m_bChangeDragonList then
            self.m_dragonObject = dragon_object
            self:refresh(self.m_dragonObject)
        end
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function refresh_dragonRunes
-- @brief 드래곤이 장착 중인 룬 정보 갱신
-------------------------------------
function UI_DragonInfoBoard:refresh_dragonRunes(t_dragon_data)
    local vars = self.vars

    if (t_dragon_data.m_objectType ~= 'dragon') then
        for slot=1, RUNE_SLOT_MAX do
            vars['runeSlotNode' .. slot]:removeAllChildren()
        end

        vars['runeSetNode']:removeAllChildren()
        return
    end

    do -- 장착된 룬 표시
        for slot=1, RUNE_SLOT_MAX do
            vars['runeSlotNode' .. slot]:removeAllChildren()
            local rune_obj = t_dragon_data:getRuneObjectBySlot(slot)
            if rune_obj then
                local icon = IconHelper:getItemIcon(rune_obj['item_id'], rune_obj)
                vars['runeSlotNode' .. slot]:addChild(icon)
            end
        end
    end

    do -- 룬 세트
        local rune_set_obj = t_dragon_data:getStructRuneSetObject()
        local active_set_list = rune_set_obj:getActiveRuneSetList()
        vars['runeSetNode']:removeAllChildren()

        local l_pos = getSortPosList(70, #active_set_list)
        for i,set_id in ipairs(active_set_list) do
            local ui = UI()
            ui:load('dragon_manage_rune_set.ui')

            -- 색상 지정
            --local c3b = TableRuneSet:getRuneSetColorC3b(set_id)
            --ui.vars['runeBgSprite']:setColor(c3b)

            -- 세트 이름
            local set_name = TableRuneSet:getRuneSetName(set_id)
            ui.vars['runeSetLabel']:setString(set_name)

            -- AddCHild, 위치 지정
            vars['runeSetNode']:addChild(ui.root)
            ui.root:setPositionX(l_pos[i])
        end
    end
end