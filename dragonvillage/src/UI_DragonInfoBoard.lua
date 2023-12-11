local PARENT = UI

-------------------------------------
-- class UI_DragonInfoBoard
-------------------------------------
UI_DragonInfoBoard = class(PARENT,{
        m_dragonObject = '',

        m_bIsBlockedPopup = 'boolean', -- UI_DragonInfoBoard를 통해 추가적인 팝업이 뜨지 않도록
        m_bSimpleMode = 'boolean',
        m_checkBoxList = 'List<string>', -- 전투력 보기 체크박스

        m_bRuneInfoPopup = 'boolean',
        m_bIsMyDragon = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonInfoBoard:init(is_simple_mode)
    self.m_bIsBlockedPopup = is_simple_mode or false
    self.m_bIsMyDragon = false
    self.m_checkBoxList = {'lair', 'research'}

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
   
    vars['equipSlotBtn1']:registerScriptTapHandler(function() self:click_runeBtn(1) end)
    vars['equipSlotBtn2']:registerScriptTapHandler(function() self:click_runeBtn(2) end)
    vars['equipSlotBtn3']:registerScriptTapHandler(function() self:click_runeBtn(3) end)
    vars['equipSlotBtn4']:registerScriptTapHandler(function() self:click_runeBtn(4) end)
    vars['equipSlotBtn5']:registerScriptTapHandler(function() self:click_runeBtn(5) end)
    vars['equipSlotBtn6']:registerScriptTapHandler(function() self:click_runeBtn(6) end)

    local check_btn_list = {}
    for _, v in ipairs(self.m_checkBoxList) do
        local btn_str = string.format('check%sAbilityBtn', v)
        local sprite_str = string.format('check%sAbilitySprite', v)

        if vars[btn_str] ~= nil and vars[sprite_str] ~= nil then
		    vars[btn_str] = UIC_CheckBox(vars[btn_str].m_node, vars[sprite_str], true)
		    vars[btn_str]:registerScriptTapHandler(function() self:click_checkAbilityBtn(v) end)

            table.insert(check_btn_list, vars[btn_str])
        end
	end

    --AlignUIPos(check_btn_list, 'HORIZONTAL', 'CENTER', 10)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonInfoBoard:refresh(t_dragon_data)
    self.m_dragonObject = t_dragon_data

    if (not t_dragon_data) then
        return
    end

    if (g_dragonsData:getDragonDataFromUidRef(self.m_dragonObject['id'])) then
        self.m_bIsMyDragon = true
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

	do -- 드래곤 강화 레벨
		vars['reinforceNode']:removeAllChildren()
        -- 강화 단계가 0이더라도 특성 레벨이 1 이상이면 아이콘 출력
		if (t_dragon_data:getRlv() > 0) or (t_dragon_data:getMasteryLevel() > 0) then
			local rlv = t_dragon_data:getRlv()
			local icon = IconHelper:getDragonReinforceIcon(rlv)
			vars['reinforceNode']:addChild(icon)
		end
	end

    do -- 드래곤 특성
		vars['masteryNode']:removeAllChildren()
		if (t_dragon_data:getMasteryLevel() > 0) then
			local mastery_level = t_dragon_data:getMasteryLevel()
			local icon = IconHelper:getDragonMasteryIcon(mastery_level)
			vars['masteryNode']:addChild(icon)
		end
	end

    do -- 레벨
        local lv = (t_dragon_data['lv'] or 1)
        local grade = (t_dragon_data:getGrade() or 1)
        local eclv = (t_dragon_data:getEclv() or 0)
        local lv_str = Str('레벨 {1}/{2}', lv, dragonMaxLevel(grade))
        vars['lvLabel']:setString(lv_str)
    end

    do -- 레벨 게이지
        local grade = (t_dragon_data:getGrade() or 1)
        local lv = (t_dragon_data['lv'] or 1)
        local max_lv = TableGradeInfo():getValue(grade, 'max_lv')

        if (lv == max_lv) then
            vars['expLabel']:setString(Str('최대레벨'))
                        
            vars['maxGauge']:setVisible(true)
        else
            local percentage = (lv / max_lv) * 100
            vars['expLabel']:setString(string.format('%d / %d', lv, max_lv))
            
            vars['expGauge']:stopAllActions()
            vars['expGauge']:setPercentage(0)
            vars['expGauge']:runAction(cc.ProgressTo:create(0.2, percentage)) 
            vars['maxGauge']:setVisible(false)
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

    self:refresh_dragonSkillsInfo(t_dragon_data)
    self:refresh_icons(t_dragon_data)
    self:refresh_status(t_dragon_data)
    self:refresh_dragonRunes(t_dragon_data)
end

-------------------------------------
-- function refresh_dragonSkillsInfo
-- @brief 드래곤 스킬 정보 갱신
-------------------------------------
function UI_DragonInfoBoard:refresh_dragonSkillsInfo(t_dragon_data)
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
function UI_DragonInfoBoard:refresh_icons(t_dragon_data)
    local vars = self.vars

    local attr = t_dragon_data:getAttr()
    local role_type = t_dragon_data:getRole()
    local rarity_type = t_dragon_data:getRarity()
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    do -- 희귀도 
        vars['rarityNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)
    end

    do -- 드래곤 속성
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    end
end

-------------------------------------
--- @function getExcludeStatKeyList
--- @brief 제외할 능력치 리스트 얻어옴
-------------------------------------
function UI_DragonInfoBoard:getExcludeStatKeyList()
    local vars = self.vars
    local stat_key_list = {}
    for _, stat_key in ipairs(self.m_checkBoxList) do
        local btn_str = string.format('check%sAbilityBtn',stat_key)
        if vars[btn_str]:isChecked() == false then
            table.insert(stat_key_list, stat_key)
        end
	end
    return stat_key_list
end


-------------------------------------
--- @function directActionStatChange
--- @brief 능력치 정보 숫자 올라가는 연출
-------------------------------------
function UI_DragonInfoBoard:directActionStatChange(label, new_val, is_percent)
    local old_str = label:getString()    
    old_str = string.gsub(old_str, ',', '')
    old_str = string.gsub(old_str, '%%', '')
    local old_val = tonumber(old_str)
    if old_val == nil then
        old_val = 0
    end

    new_val = string.gsub(new_val, ',', '')
    new_val = string.gsub(new_val, '%%', '')
    new_val = tonumber(new_val)

    local function tween_cb(value, node)
        if is_percent == true then
            label:setString(string.format('%s%%', comma_value(math_floor(value))))
        else
            label:setString(string.format('%s', comma_value(math_floor(value))))
        end
    end

    local tween_action = cc.ActionTweenForLua:create(0.2, old_val, new_val, tween_cb)
    label:stopAllActions()
    label:runAction(tween_action)
end


-------------------------------------
--- @function directActionDeltaStatChange
--- @brief 능력치 정보 숫자 올라가는 연출
-------------------------------------
function UI_DragonInfoBoard:directActionDeltaStatChange(label, new_val, is_percent)
    local old_str = label:getString()    
    old_str = string.gsub(old_str, '%D', '')
    local old_val = tonumber(old_str)
    if old_val == nil then
        old_val = 0
    end

    local function tween_cb(value, node)
        if is_percent == true then
            label:setString(string.format('(+ %s%%)', comma_value(math_floor(value))))
        else
            label:setString(string.format('(+ %s)', comma_value(math_floor(value))))
        end
    end

    local tween_action = cc.ActionTweenForLua:create(0.2, old_val, new_val, tween_cb)
    label:stopAllActions()
    label:runAction(tween_action)
end

-------------------------------------
-- function setStatInfo
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonInfoBoard:setStatInfo(status_calc, stat_key, exclude_stat_key_list)
    local vars = self.vars
    local is_percent = TableStatus():isPercentValue(stat_key)
    local total_val = '0' --

    do -- 전체 스탯 라벨/바깥쪽 스탯 라벨
        local str_label = string.format('%s_label', stat_key)        
        total_val = status_calc and status_calc:getFinalStatDisplay(stat_key, is_percent, exclude_stat_key_list) or total_val
        self:directActionStatChange(vars[str_label], total_val, is_percent)
        vars[str_label]:setString(total_val)
    end

    do -- 증가분 스탯 라벨
        local str_label = string.format('%s_label2', stat_key)
        local stat_val = status_calc and status_calc:getDeltaStatDisplay(exclude_stat_key_list, stat_key) or total_val
        self:directActionDeltaStatChange(vars[str_label], stat_val, is_percent)
        --vars[str_label]:setString(stat_val)
    end

    do -- 바깥쪽 스탯 라벨
        local str_label = string.format('%s_label3', stat_key)
        local real_total_val = status_calc and status_calc:getFinalStatDisplay(stat_key, is_percent) or total_val
        if vars[str_label] ~= nil then
            vars[str_label]:setString(real_total_val)
        end
    end

    do -- 게이지 처리        
        local str_gauge = string.format('%s_gauge', stat_key)
        if vars[str_gauge] ~= nil then
            local percent = status_calc and status_calc:makePrettyPercentage(stat_key, exclude_stat_key_list) or 0
            vars[str_gauge]:runAction(cc.ProgressTo:create(0.2, percent * 100))
        end
    end
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonInfoBoard:refresh_status(t_dragon_data)
    local vars = self.vars
    local l_stat = {'hp', 'atk', 'def', 'aspd', 'cri_chance', 'cri_dmg', 'hit_rate', 'avoid', 'cri_avoid', 'accuracy', 'resistance'}

    -- 슬라임인지 드래곤인지 여부
    local is_slime_object = (t_dragon_data.m_objectType == 'slime')
    if is_slime_object then
        for _, stat_key in ipairs(l_stat) do
            self:setStatInfo(nil, stat_key)
        end

        if vars['cp_label'] then
            vars['cp_label']:setString('0')
        end
        return
    end

    -- 스탯 계산
    local exclude_stat_key_list = self:getExcludeStatKeyList()

    -- 능력치 계산기
    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)

    for _, stat_key in ipairs(l_stat) do
        self:setStatInfo(status_calc, stat_key, exclude_stat_key_list)
    end

    if vars['cp_label'] then
        vars['cp_label']:setString(comma_value(t_dragon_data:getCombatPower()))
    end

    -- 드래곤 성장일지 : 능력치 체크
    local start_dragon_data = g_dragonDiaryData:getStartDragonData(t_dragon_data)
    if (start_dragon_data) then
        -- @ DRAGON DIARY
        local t_data = {clear_key = 'check_d_stat', sub_data = start_dragon_data}
        g_dragonDiaryData:updateDragonDiary(t_data)
    end
end

-------------------------------------
-- function init_gauge
-- @brief 능력치 게이지 초기화 (연출 예쁘게 하기 위해서)
-------------------------------------
function UI_DragonInfoBoard:init_gauge()
    local vars = self.vars
    vars['hp_gauge']:setPercentage(0)
    vars['atk_gauge']:setPercentage(0)
    vars['def_gauge']:setPercentage(0)
    vars['aspd_gauge']:setPercentage(0)
    vars['cri_chance_gauge']:setPercentage(0)
    vars['cri_dmg_gauge']:setPercentage(0)
end

-------------------------------------
-- function refresh_gauge
-- @brief 능력치 게이지 액션
-------------------------------------
function UI_DragonInfoBoard:refresh_gauge(status_calc)
    local vars = self.vars
    
    -- 슬라임인지 드래곤인지 여부
    local is_slime_object = (self.m_dragonObject:getObjectType() == 'slime')
    if is_slime_object then
        return
    end

    local status_calc = status_calc or MakeDragonStatusCalculator_fromDragonDataTable(self.m_dragonObject)
    -- 스탯 계산
    local stat_key_list = self:getExcludeStatKeyList()

	-- stat gauge refresh
	local l_stat = {'hp', 'atk', 'def', 'aspd', 'cri_chance', 'cri_dmg'}
	for _, stat_key in ipairs(l_stat) do
		local percent = status_calc:makePrettyPercentage(stat_key, stat_key_list)
		vars[stat_key .. '_gauge']:runAction(cc.ProgressTo:create(0.2, percent * 100))
	end
end

-------------------------------------
-- function click_detailBtn
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonInfoBoard:click_detailBtn()
    local vars = self.vars
    vars['detailNode1']:runAction(cc.ToggleVisibility:create())
    vars['detailNode2']:runAction(cc.ToggleVisibility:create())

    -- gauge action
    self:init_gauge()
    self:refresh_gauge()
end

-------------------------------------
--- @function click_checkAbilityBtn
--- @brief 전투력 정보
-------------------------------------
function UI_DragonInfoBoard:click_checkAbilityBtn(key)
    local vars = self.vars

    --self:init_gauge()
    self:refresh_status(self.m_dragonObject)
    --self:refresh_gauge()
end

-------------------------------------
-- function click_runeBtn
-- @brief 룬 버튼
-------------------------------------
function UI_DragonInfoBoard:click_runeBtn(slot_idx)
    -- 드래곤 정보가 없을 경우
    if (not self.m_dragonObject) then
        return
    end
    
    -- 내 드래곤이 아니거나, 혹은 해당 팝업의 depth가 깊거나 의도치 않은 접근인 경우
    if self.m_bIsBlockedPopup or (self.m_bIsMyDragon == false) then
        return
    end

    local is_slime_object = (self.m_dragonObject:getObjectType() ~= 'dragon')
    if is_slime_object then
        return
    end


    if (self.m_bRuneInfoPopup) then
        local t_dragon_data = self.m_dragonObject
		if (t_dragon_data) then
        	local rune_obj = t_dragon_data:getRuneObjectBySlot(slot_idx)
        	UI_ItemInfoPopup(rune_obj['item_id'], 1, rune_obj)
		end

        return
    end

    -- 룬 UI 오픈
    local doid = self.m_dragonObject['id']
    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
    if dragon_obj == nil then
        return
    end

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
-- function showClickRuneInfoPopup
-------------------------------------
function UI_DragonInfoBoard:showClickRuneInfoPopup(show_popup)
    self.m_bRuneInfoPopup = show_popup
end

-------------------------------------
-- function setBlockPopup
-- breif 해당 팝업의 depth가 깊거나 의도치 않은 접근을 막기위함
-------------------------------------
function UI_DragonInfoBoard:setBlockPopup(is_blocked)
    if (is_blocked == nil) then is_blocked = true end
    
    self.m_bIsBlockedPopup = is_blocked
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
				local card = UI_RuneCard(rune_obj)
				card:setBtnEnabled(false)
                vars['runeSlotNode' .. slot]:addChild(card.root)

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

            -- 툴팁 클릭
            ui.vars['tooltipBtn']:registerScriptTapHandler(function()
                local str = TableRuneSet:makeRuneSetFullNameRichText(set_id)
                local tool_tip = UI_Tooltip_Skill(0, 0, str)
                tool_tip:autoPositioning(ui.vars['tooltipBtn']) -- 자동 위치 지정
            end)

            -- AddCHild, 위치 지정
            vars['runeSetNode']:addChild(ui.root)
            ui.root:setPositionY(l_pos[i])
        end
    end
end