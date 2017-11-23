local PARENT = UI

-------------------------------------
-- class UI_DragonInfoBoardNew
-------------------------------------
UI_DragonInfoBoardNew = class(PARENT,{
        m_dragonObject = '',
        m_bSimpleMode = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonInfoBoardNew:init(is_simple_mode)
    self.m_bSimpleMode = is_simple_mode
    local vars = self:load('dragon_info_board_new.ui')
    
    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonInfoBoardNew:initUI(is_simple_mode)
    local vars = self.vars

    vars['friendshipGauge']:setPercentage(0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonInfoBoardNew:initButton()
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
function UI_DragonInfoBoardNew:refresh(t_dragon_data)
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
            vars['expLabel']:setString(string.format('%.2f%%', percentage))

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

    -- 룬슬롯 애니 
    for i = 1, 6 do
        vars['runeVisual'..i]:setVisible(false)
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
function UI_DragonInfoBoardNew:refresh_dragonSkillsInfo(t_dragon_data, t_dragon)
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
					UI_SkillDetailPopupNew(t_dragon_data, i)
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
function UI_DragonInfoBoardNew:refresh_icons(t_dragon_data, t_dragon)
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
function UI_DragonInfoBoardNew:refresh_status(t_dragon_data, t_dragon)
    local vars = self.vars

    -- 슬라임인지 드래곤인지 여부
    local is_slime_object = (t_dragon_data.m_objectType == 'slime')
    if is_slime_object then
        vars['atk_label']:setString('0')
        vars['aspd_label']:setString('0')
        vars['cri_chance_label']:setString('0')
        vars['def_label']:setString('0')
        vars['hp_label']:setString('0')
        vars['cri_avoid_label']:setString('0')
        vars['avoid_label']:setString('0')
        vars['hit_rate_label']:setString('0')
        vars['cri_dmg_label']:setString('0')

        local dr = 0.2
        vars['hp_gauge']:runAction(cc.ProgressTo:create(dr, 0))
        vars['atk_gauge']:runAction(cc.ProgressTo:create(dr, 0))
        vars['def_gauge']:runAction(cc.ProgressTo:create(dr, 0))
        vars['aspd_gauge']:runAction(cc.ProgressTo:create(dr, 0))
        vars['cri_chance_gauge']:runAction(cc.ProgressTo:create(dr, 0))
        vars['cri_dmg_gauge']:runAction(cc.ProgressTo:create(dr, 0))

        if vars['cp_label'] then
            vars['cp_label']:setString('0')
        end
        return
    end

    -- 능력치 계산기
    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)

    -- 모든 스탯 계산
    local use_percent = true

    local hp = status_calc:getFinalStatDisplay('hp')
    local atk = status_calc:getFinalStatDisplay('atk')
    local def = status_calc:getFinalStatDisplay('def')
    local aspd = status_calc:getFinalStatDisplay('aspd', use_percent)
    local cri_chance = status_calc:getFinalStatDisplay('cri_chance', use_percent)
    local cri_dmg = status_calc:getFinalStatDisplay('cri_dmg', use_percent)
    local hit_rate = status_calc:getFinalStatDisplay('hit_rate')
    local avoid = status_calc:getFinalStatDisplay('avoid')
    local cri_avoid = status_calc:getFinalStatDisplay('cri_avoid')
    local accuracy = status_calc:getFinalStatDisplay('accuracy')
    local resistance = status_calc:getFinalStatDisplay('resistance')

    -- detail node : final stat
    do
        vars['hp_label']:setString(hp)
        vars['atk_label']:setString(atk)
        vars['def_label']:setString(def)
        vars['aspd_label']:setString(aspd)
        vars['cri_chance_label']:setString(cri_chance)
        vars['cri_dmg_label']:setString(cri_dmg)
        vars['hit_rate_label']:setString(hit_rate)
        vars['avoid_label']:setString(avoid)
        vars['cri_avoid_label']:setString(cri_avoid)
        vars['accuracy_label']:setString(accuracy)
        vars['resistance_label']:setString(resistance)
    end
    
    -- detail node : rune stat delta
    do
        local dt_hp = status_calc:getDeltaStatDisplay('hp')
        local dt_atk = status_calc:getDeltaStatDisplay('atk')
        local dt_def = status_calc:getDeltaStatDisplay('def')
        local dt_aspd = status_calc:getDeltaStatDisplay('aspd', use_percent)
        local dt_cri_chance = status_calc:getDeltaStatDisplay('cri_chance', use_percent)
        local dt_cri_dmg = status_calc:getDeltaStatDisplay('cri_dmg', use_percent)
        local dt_hit_rate = status_calc:getDeltaStatDisplay('hit_rate')
        local dt_avoid = status_calc:getDeltaStatDisplay('avoid')
        local dt_cri_avoid = status_calc:getDeltaStatDisplay('cri_avoid')
        local dt_accuracy = status_calc:getDeltaStatDisplay('accuracy')
        local dt_resistance = status_calc:getDeltaStatDisplay('resistance')

        vars['hp_label2']:setString(dt_hp)
        vars['atk_label2']:setString(dt_atk)
        vars['def_label2']:setString(dt_def)
        vars['aspd_label2']:setString(dt_aspd)
        vars['cri_chance_label2']:setString(dt_cri_chance)
        vars['cri_dmg_label2']:setString(dt_cri_dmg)
        vars['hit_rate_label2']:setString(dt_hit_rate)
        vars['avoid_label2']:setString(dt_avoid)
        vars['cri_avoid_label2']:setString(dt_cri_avoid)
        vars['accuracy_label2']:setString(dt_accuracy)
        vars['resistance_label2']:setString(dt_resistance)
    end

    -- detail node 2
    do
        vars['hp_label3']:setString(hp)
        vars['atk_label3']:setString(atk)
        vars['def_label3']:setString(def)
        vars['aspd_label3']:setString(aspd)
        vars['cri_chance_label3']:setString(cri_chance)
        vars['cri_dmg_label3']:setString(cri_dmg)
    end
    
    self:refresh_gauge(status_calc)

    if vars['cp_label'] then
        vars['cp_label']:setString(comma_value(status_calc:getCombatPower()))
    end
end

-------------------------------------
-- function init_gauge
-- @brief 능력치 게이지 초기화 (연출 예쁘게 하기 위해서)
-------------------------------------
function UI_DragonInfoBoardNew:init_gauge()
    local vars = self.vars
    vars['hp_gauge']:setPercentage(0)
    vars['atk_gauge']:setPercentage(0)
    vars['def_gauge']:setPercentage(0)
    vars['aspd_gauge']:setPercentage(0)
    vars['cri_chance_gauge']:setPercentage(0)
    vars['cri_dmg_gauge']:setPercentage(0)
end

-------------------------------------
-- local function make_pretty_percentage_action
-- @brief 능력치 퍼센트를 예쁘게 계산한 프로그레스 액션 생성
-------------------------------------
local function make_pretty_percentage_action(src, key)
	local half = g_constant:get('UI', 'HALF_STAT', key)
	local max = g_constant:get('UI', 'MAX_STAT', key)
	
	local percent
	if (src <= half) then
		percent = 0.5 * (src / half)

	else
		percent = 0.5 + (0.5 * (((src - half) / (max - half))))
		
	end

	if (IS_TEST_MODE()) then
		cclog('================================')
		cclog(' key : ' .. key)
		cclog(' src : ' .. src)
		cclog(' half : ' .. half)
		cclog(' max : ' .. max)
		cclog(string.format(' percnet : %d%%', percent * 100))
	end

	return cc.ProgressTo:create(0.2, percent * 100)
end

-------------------------------------
-- function refresh_gauge
-- @brief 능력치 게이지 액션
-------------------------------------
function UI_DragonInfoBoardNew:refresh_gauge(status_calc)
    local vars = self.vars
    
    -- 슬라임인지 드래곤인지 여부
    local is_slime_object = (self.m_dragonObject:getObjectType() == 'slime')
    if is_slime_object then
        return
    end

    local status_calc = status_calc or MakeDragonStatusCalculator_fromDragonDataTable(self.m_dragonObject)

	local l_stat = {'hp', 'atk', 'def', 'aspd', 'cri_chance', 'cri_dmg'}
	local stat, progress_action
	for _, stat_key in ipairs(l_stat) do
		stat = status_calc:getFinalStat(stat_key)
		progress_action = make_pretty_percentage_action(stat, stat_key)

		vars[stat_key .. '_gauge']:runAction(progress_action)
	end
end

-------------------------------------
-- function click_detailBtn
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonInfoBoardNew:click_detailBtn()
    local vars = self.vars
    vars['detailNode']:runAction(cc.ToggleVisibility:create())
    vars['detailNode2']:runAction(cc.ToggleVisibility:create())

    -- gauge action
    self:init_gauge()
    self:refresh_gauge()
end

-------------------------------------
-- function click_runeBtn
-- @brief 룬 버튼
-------------------------------------
function UI_DragonInfoBoardNew:click_runeBtn(slot_idx)
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
function UI_DragonInfoBoardNew:refresh_dragonRunes(t_dragon_data)
    local vars = self.vars

    if (t_dragon_data.m_objectType ~= 'dragon') then
        for slot=1, RUNE_SLOT_MAX do
            vars['runeSlotNode' .. slot]:removeAllChildren()
        end

        vars['runeSetNode']:removeAllChildren()
        return
    end

    local rune_set_obj = t_dragon_data:getStructRuneSetObject()
    local active_set_list = rune_set_obj:getActiveRuneSetList()

    -- 애니 재생 가능한 룬 갯수 설정 (2세트 5개 착용시 처음 슬롯부터 4개까지만)
    local function get_need_equip(set_id)
        local need_equip = 0
        for _, v in ipairs(active_set_list) do
            if (v == set_id) then
                need_equip = need_equip + TableRuneSet:getRuneSetNeedEquip(set_id)
            end
        end

        return need_equip
    end

    -- 해당룬 세트 효과 활성화 되있다면 애니 재생
    local t_equip = {}
    local function show_set_effect(slot_id, set_id)
        for _, v in ipairs(active_set_list) do
            local visual = vars['runeVisual'..slot_id]
            if (v == set_id) then
                if (t_equip[set_id]) then
                    t_equip[set_id] = t_equip[set_id] + 1
                else
                    t_equip[set_id] = 1
                end

                local need_equip = get_need_equip(set_id)
                if (t_equip[set_id] <= need_equip) then
                    local ani_name = TableRuneSet:getRuneSetVisualName(slot_id, set_id)
                    visual:setVisible(true)
                    visual:changeAni(ani_name, true)
                end
                break
            end
        end
    end

    do -- 장착된 룬 표시
        for slot=1, RUNE_SLOT_MAX do
            vars['runeVisual' .. slot]:setVisible(false)
            vars['runeSlotNode' .. slot]:removeAllChildren()
            local rune_obj = t_dragon_data:getRuneObjectBySlot(slot)
            if rune_obj then
                local icon = IconHelper:getItemIcon(rune_obj['item_id'], rune_obj)
                vars['runeSlotNode' .. slot]:addChild(icon)

                local set_id =  rune_obj['set_id'] 
                show_set_effect(slot, set_id)
            end
        end
    end

    do -- 룬 세트
        vars['runeSetNode']:removeAllChildren()

        local l_pos = getSortPosList(35, #active_set_list)
        for i,set_id in ipairs(active_set_list) do
            local ui = UI()
            ui:load('dragon_manage_rune_set.ui')

            -- 색상 지정
            local c3b = TableRuneSet:getRuneSetColorC3b(set_id)
            ui.vars['runeSetLabel']:setColor(c3b)

            -- 세트 이름
            local set_name = TableRuneSet:getRuneSetName(set_id)
            ui.vars['runeSetLabel']:setString(set_name)

            -- AddCHild, 위치 지정
            vars['runeSetNode']:addChild(ui.root)
            ui.root:setPositionY(l_pos[i])
        end
    end
end