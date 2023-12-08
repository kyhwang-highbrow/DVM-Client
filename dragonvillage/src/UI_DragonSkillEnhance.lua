local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonSkillEnhance
-------------------------------------
UI_DragonSkillEnhance = class(PARENT,{
		-- 재료
        m_selectedMtrls = '',
        m_skillSpareLvSum = 'number',
        m_limitMtrlsCount = 'number',
    })

UI_DragonSkillEnhance.TAB_ENHANCE = 'enhance' -- 강화
UI_DragonSkillEnhance.TAB_MOVE = 'move' -- 이전

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonSkillEnhance:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonSkillEnhance'
    self.m_bVisible = true
    self.m_titleStr = Str('스킬 레벨업')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkillEnhance:init(doid, is_myth)
    self.m_selectedMtrls = {}
    self.m_skillSpareLvSum = g_dragonsData:getSkillSpareLVSum(doid)
    self:load('dragon_skill_enhance.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonSkillEnhance')

    self:sceneFadeInAction()

    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()
 
    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
	
	-- 정렬 도우미
    self:init_dragonSortMgr()
	self:init_mtrDragonSortMgr(true) -- slime_first

    -- 선택한 드래곤에 포커싱
    self:focusSelectedDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkillEnhance:initUI()
    local vars = self.vars

    self:init_dragonTableView()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_DragonSkillEnhance:initTab()
    local vars = self.vars
    self:addTabAuto(UI_DragonSkillEnhance.TAB_ENHANCE, vars, vars['materialTableViewNode'])
    self:addTabAuto(UI_DragonSkillEnhance.TAB_MOVE, vars, vars['moveTableViewNode'])
    self:setTab(UI_DragonSkillEnhance.TAB_ENHANCE)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonSkillEnhance:initButton()
    local vars = self.vars
    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceNewBtn() end)

    -- 스킬 슬라임 상점
    vars['skillSlimShopBtn']:registerScriptTapHandler(function() self:click_skillSlimeShopBtn() end)

    -- ahen tjsxor
    vars['allSelectBtn']:registerScriptTapHandler(function() self:click_allSelectBtn() end)

    -- 스킬 레벨업 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'd_skill_levelup_help')

    -- infoBtn
    if (vars['infoBtn']) then vars['infoBtn']:registerScriptTapHandler(function() UI_DragonSkillEnhanceHelp() end) end
end

-------------------------------------
-- function setSelectDragonData
-- @brief 선택된 드래곤 설정
-------------------------------------
function UI_DragonSkillEnhance:setSelectDragonData(object_id, b_force)
    if (not b_force) and (self.m_selectDragonOID == object_id) then
        return
    end

    local object_data = g_dragonsData:getDragonDataFromUid(object_id)
    if (not object_data) then
        object_data = g_slimesData:getSlimeObject(object_id)
    end

    if (not object_data) then
        return self:setDefaultSelectDragon()
    end

    if (not self:checkDragonSelect(object_id)) then
        return
    end

    -- 선택된 드래곤의 데이터를 최신으로 갱신
    self.m_selectDragonOID = object_id
    self.m_selectDragonData = object_data
    self.m_bSlimeObject = (object_data.m_objectType == 'slime')
    self.m_limitMtrlsCount = object_data:getRarity() == 'myth' and 1 or 9999

    -- 선택된 드래곤 카드에 프레임 표시
    self:changeDragonSelectFrame()

    -- 선택된 드래곤이 변경되면 refresh함수를 호출
    self:refresh()

    -- 신규 드래곤이면 삭제
    g_highlightData:removeNewDoid(object_id)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkillEnhance:refresh()
    local vars = self.vars
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end
    
    -- 신화 드래곤인지 체크
    local is_myth = (t_dragon_data:getRarity() == 'myth')

    if is_myth then
        self:setTab(UI_DragonSkillEnhance.TAB_ENHANCE)
    end
    
    if vars['moveTabBtn'] then
        vars['moveTabBtn']:setVisible(not is_myth)
    end

    local did = t_dragon_data['did']
    local attr = t_dragon_data:getAttr()
    local role_type = t_dragon_data:getRole()
    local rarity_type = nil
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 배경
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(t_dragon_data:getDragonNameWithEclv())
    end
    
    do -- 드래곤 속성
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    end

    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        vars['dragonIconNode']:addChild(dragon_card.root)
    end

    do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution']
        vars['dragonNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)

        vars['dragonNode']:addChild(animator.m_node)
    end

    do -- 재료 중에서 선택된 드래곤 항목들 정리
        if (#self.m_selectedMtrls > 0) then
            self.m_selectedMtrls = {}
        end
    end

    -- 레벨업 가능 여부 처리
	local possible = g_dragonsData:possibleDragonSkillEnhance(self.m_selectDragonOID)
    if (not possible) then
        if (t_dragon_data['evolution'] < MAX_DRAGON_EVOLUTION) then
            local next_evolution = t_dragon_data['evolution'] + 1
            local tar_evolution = evolutionName(next_evolution)
	        vars['lockSprite']:setVisible(true)
            vars['infoLabel2']:setString(Str('{1} 진화시 스킬 레벨업이 가능해요 ', tar_evolution))
        end
    end

    -- 할인 이벤트
    local only_value = true
	g_hotTimeData:setDiscountEventNode(HOTTIME_SALE_EVENT.SKILL_MOVE, vars, 'moveEventSprite', only_value)

	-- 소모 골드 표시
    self:refresh_skillprice()
	self:refresh_skillIcon()
    self:refresh_dragonMaterialTableView()
    self:refresh_dragonSkillMoveTableView()

    -- 스킬 슬라임 상점 버튼 갱신 (전설 등급 드래곤만 상점 노출)
    local shop_visible = (self.m_selectDragonData:getRarity() == 'legend')
	vars['skillSlimShopBtn']:setVisible(shop_visible)
    vars['skillSlimShopBtn']:setAutoShake(shop_visible) -- 버튼 흔들기효과 (눈에 더 띄게)
end

-------------------------------------
-- function refresh_skillprice
-------------------------------------
function UI_DragonSkillEnhance:refresh_skillprice()
    -- 소모 골드 표시
    local vars = self.vars
	local price = self:getSkillEnhancePrice()
	--vars['priceLabel']:setString(comma_value(price))

    local label = vars['priceLabel']

    local function tween_cb(value, node)    
        label:setString(comma_value(math_floor(value)))        
    end

    local old_str = string.gsub(label:getString(), ',', '')    
    local old_val = tonumber(old_str)
    if old_val == nil then
        old_val = 0
    end

    local new_val = price
    local tween_action = cc.ActionTweenForLua:create(0.2, old_val, new_val, tween_cb)
    label:stopAllActions()
    label:runAction(tween_action)
end

-------------------------------------
-- function show_effect
-- @brief 스킬 강화 연출
-------------------------------------
function UI_DragonSkillEnhance:show_effect(skill_idx_list, finish_cb)
    local block_ui = UI_BlockPopup() 
    local res_path = 'res/ui/a2d/dragon_skill_enhance_move/dragon_skill_enhance_move.vrp'

    -- SKILL LV UP 
    do
        for _, slot in ipairs(skill_idx_list) do
            local target_node = self.vars['skillNode'..slot]

            local effect = MakeAnimator(res_path)
            effect:changeAni('lvup', false)
            effect:setPosition(ZERO_POINT)
            effect:setScale(1.2)
            target_node:addChild(effect.m_node)

            local duration = effect:getDuration()
            effect:runAction(cc.Sequence:create(
                cc.DelayTime:create(duration),
                cc.RemoveSelf:create()
            ))
        end
    end

    local delay_time = cc.DelayTime:create(0.2)
    local call_func = cc.CallFunc:create(function() 
        if (finish_cb) then
            finish_cb()
        end
        block_ui:close()
    end)

    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(delay_time, call_func))
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_DragonSkillEnhance:onChangeTab(tab, first)
    local vars = self.vars
    vars['enhanceBtn']:setVisible(tab == UI_DragonSkillEnhance.TAB_ENHANCE)

    local msg = (tab == UI_DragonSkillEnhance.TAB_ENHANCE) and 
                Str('동일 드래곤을 사용하여\n스킬을 강화합니다.') or
                Str('스킬 레벨을 이전하여\n스킬을 강화합니다.')

    vars['dscLabel']:setString(msg)

    local is_move_tab = UI_DragonSkillEnhance.TAB_MOVE == tab
    if (vars['infoBtn']) then vars['infoBtn']:setVisible(is_move_tab) end
end

-------------------------------------
-- function refresh_skillIcon
-------------------------------------
function UI_DragonSkillEnhance:refresh_skillIcon()
	local vars = self.vars

	local t_dragon_data = self.m_selectDragonData

	local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
	local l_skill_icon = skill_mgr:getDragonSkillIconList()

	for _, i in ipairs(IDragonSkillManager:getSkillKeyList()) do
		local skill_node = vars['skillNode' .. i]
		skill_node:removeAllChildren()
            
		-- 스킬 아이콘 생성
		if l_skill_icon[i] then
			skill_node:addChild(l_skill_icon[i].root)
            l_skill_icon[i].vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
            l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(function()
				UI_SkillDetailPopup(t_dragon_data, i)
			end)

		-- 비어있는 스킬 아이콘 생성
		else
			local empty_skill_icon = IconHelper:getEmptySkillCard()
			skill_node:addChild(empty_skill_icon)

		end
	end
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonSkillEnhance:getDragonList()
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 절대 레벨업 불가능한 드래곤 제외
    for oid, v in pairs(dragon_dic) do
        if (g_dragonsData:impossibleSkillEnhanceForever(oid)) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
--- @function isSelectedMateral
--- @breif 재료 선택 여부
-------------------------------------
function UI_DragonSkillEnhance:isSelectedMateral(doid)
    return table.find(self.m_selectedMtrls,doid) ~= nil
end

-------------------------------------
--- @function selecteMateral
--- @breif 재료 선택
-------------------------------------
function UI_DragonSkillEnhance:selectMateral(doid)
    table.insert(self.m_selectedMtrls, doid)
    self:refresh_dragonIndivisual_material(doid) -- 특성 재료 tableview
end

-------------------------------------
--- @function unselecteMateral
--- @breif 재료 선택 해제
-------------------------------------
function UI_DragonSkillEnhance:unselectMateral(doid)
    local idx = table.find(self.m_selectedMtrls,doid)
    table.remove(self.m_selectedMtrls, idx)
    self:refresh_dragonIndivisual_material(doid) -- 특성 재료 tableview
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 스킬강화
-- @override
-------------------------------------
function UI_DragonSkillEnhance:getDragonMaterialList(doid)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid) -- StructDragonObject

    local dragon_dic = g_dragonsData:getDragonListWithSlime()
    
    -- 자기 자신 드래곤 제외
    dragon_dic[doid] = nil

	-- 원종이 같은 드래곤을 체크한다 대상이 아닌 경우가 대부분이라 추출하는게 좋을것같지만...
	local ret_dic = {}
	local did_digit = math_floor(t_dragon_data['did']/10)
	local tar_digit
    local birthgrade = t_dragon_data:getBirthGrade()
    
    -- v = StructDragonObject or StructSlimeObject
    for oid, v in pairs(dragon_dic) do

		-- 드래곤의 경우 동일종 추가
		if (v:getObjectType() == 'dragon') then
			tar_digit = math_floor(v['did']/10)
			if (tar_digit == did_digit) then
				ret_dic[oid] = v
			end

		-- 스킬 강화 슬라임 추가
		else -- if (v:getObjectType() == 'slime') then
            if (v:getSlimeType() == 'skill') then

                -- 스킬 슬라임은 태생이 같아야 사용 가능
                if (v:getBirthGrade() == birthgrade) then
			        ret_dic[oid] = v
                end
            end
		end
    end

    return ret_dic
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-------------------------------------
function UI_DragonSkillEnhance:createMtrlDragonCardCB(ui, data)
    if (not ui) then
        return
    end

    -- 선택한 드래곤이 레벨업 가능한지 판단
    local doid = self.m_selectDragonOID
	local is_shadow = false
    if (not g_dragonsData:possibleDragonSkillEnhance(doid)) then
        is_shadow = true
    else
		is_shadow = false
    end

    -- 재료 드래곤이 재료 가능한지 판별
    doid = data['id']
    if (data:getObjectType() == 'dragon') then
        if (not g_dragonsData:possibleMaterialDragon(doid)) then
            is_shadow = true
		else
			is_shadow = false
        end

    elseif (data:getObjectType() == 'slime') then
        if (not g_slimesData:possibleMaterialSlime(doid, 'skill')) then
            is_shadow = true			
		else
            is_shadow = false
        end
    end

	ui:setShadowSpriteVisible(is_shadow)
	
	-- 프레스 함수 세팅
    local press_card_cb = function()
        local doid = data['id']
        if doid and (doid ~= '') then
            local ui = UI_SimpleDragonInfoPopup(data)
			local is_selected = self:isSelectedMateral(doid)
            ui:setLockPossible(true, is_selected)
            ui:setRefreshFunc(function()
                self:refresh_dragonIndivisual(doid)          -- 하단의 드래곤 tableview
                self:refresh_dragonIndivisual_material(doid) -- 특성 재료 tableview
                
                -- 특성 UI 뒤의 드래곤관리UI를 갱신하도록 한다.
                self.m_bChangeDragonList = true
            end)
        end
    end
        
    ui.vars['clickBtn']:registerScriptPressHandler(press_card_cb)
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonSkillEnhance:click_dragonMaterial(data)
    local vars = self.vars

    local doid = data['id']

    -- 현재 스킬 강화 가능한 드래곤인지 검증
    local possible, msg = g_dragonsData:possibleDragonSkillEnhance(self.m_selectDragonOID)
    if (not possible) then
        UIManager:toastNotificationRed(msg)
        return
    end

    -- 재료 드래곤이 재료 가능한지 판별
    if (data:getObjectType() == 'dragon') then
        local possible, msg = g_dragonsData:possibleMaterialDragon(doid)
        if (not possible) then
            UIManager:toastNotificationRed(msg)
            return
        end
    else
        local possible, msg = g_slimesData:possibleMaterialSlime(doid)
        if (not possible) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    local list_item = self.m_mtrlTableViewTD:getItem(doid)
    local list_item_ui = list_item['ui']
    
	-- 선택된 재료가 있는 경우
    if self:isSelectedMateral(doid) == true then
		-- 선택된 재료와 클릭한 재료가 같음 	
        self:unselectMateral(doid)
        --> 해제 처리
        list_item_ui:setCheckSpriteVisible(false)	
        self:refresh_skillprice()
    else
        -- 최대 레벨업 가능 횟수보다 많이 선택한 경우
        if #self.m_selectedMtrls >= self.m_skillSpareLvSum then
            UIManager:toastNotificationRed(Str('더 이상 선택할 수 없습니다.'))
            return
        end

        -- 최대 레벨업 가능 횟수보다 많이 선택한 경우
        if #self.m_selectedMtrls >= self.m_limitMtrlsCount then
            UIManager:toastNotificationRed(Str('신화 드래곤은 1마리 이상 선택이 불가능합니다.'))
            return
        end

        -- 재료 경고
        g_dragonsData:dragonMaterialWarning(doid, function()
            self:selectMateral(data['id'])
            self:refresh_skillprice()
            list_item_ui:setCheckSpriteVisible(true)
        end)
	end
end

-------------------------------------
-- function click_dragonSkillMove
-- @override
-------------------------------------
function UI_DragonSkillEnhance:click_dragonSkillMove(data)
    local vars = self.vars

    local doid = data['id']

    -- 현재 스킬 강화 가능한 드래곤인지 검증
    local possible, msg = g_dragonsData:possibleDragonSkillEnhance(self.m_selectDragonOID)
    if (not possible) then
        UIManager:toastNotificationRed(msg)
        return
    end

    local tar_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)
    local src_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

    local ui = UI_DragonSkillMove(tar_dragon_data, src_dragon_data)
    ui:setCloseCB(function(mod_struct_dragon)
        if (not mod_struct_dragon) then
            return
        end
        -- 스킬강화 UI 뒤의 드래곤관리UI를 갱신하도록 한다.
        self.m_bChangeDragonList = true

        self.m_selectDragonData = mod_struct_dragon
        self:refresh()
    end)
end

-------------------------------------
-- function getSkillEnhancePrice
-------------------------------------
function UI_DragonSkillEnhance:getSkillEnhancePrice()
	local did = self.m_selectDragonData['did']
	return (TableDragon:getBirthGrade(did) * 10000) * (#self.m_selectedMtrls)
end

-------------------------------------
-- function findEnhancedSkillIdx
-------------------------------------
function UI_DragonSkillEnhance:findEnhancedSkillIdx(old_struct_dragon, mod_struct_dragon)
    local  skill_idx_list = {}
	for i = 0, 3 do
		local a_lv = old_struct_dragon['skill_' .. i]
		local b_lv = mod_struct_dragon['skill_' .. i]
		if (a_lv ~= b_lv) then
            if table.find(skill_idx_list, i) == nil then
                table.insert(skill_idx_list, i)
            end
		end
	end
    return skill_idx_list
end

-------------------------------------
--- @function click_enhanceNewBtn
-------------------------------------
function UI_DragonSkillEnhance:click_enhanceNewBtn()
	-- 스킬 강화 가능 여부
	local possible, msg = g_dragonsData:possibleDragonSkillEnhance(self.m_selectDragonOID)
	if (not possible) then
		UIManager:toastNotificationRed(msg)
        return
	end
	-- 재료 요건 여부
    if (#self.m_selectedMtrls == 0) then
        UIManager:toastNotificationRed(Str('재료 드래곤을 선택해주세요'))
        return
    end

    local ok_btn_cb = function ()
        self:coroutine_enhance()
    end

    local msg = Str('스킬 레벨업을 진행하시겠습니까?')
    local submsg = Str('{1}마리가 재료로 사용됩니다.', #self.m_selectedMtrls)
    local ui = MakeSimplePricePopup(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
    ui:setPrice('gold', self:getSkillEnhancePrice())
end

-------------------------------------
--- @function coroutine_enhance
-------------------------------------
function UI_DragonSkillEnhance:coroutine_enhance()
    local t_prev_dragon_data = clone(self.m_selectDragonData)
    
    local function coroutine_function(dt)
        local co = CoroutineHelper()

        while #self.m_selectedMtrls > 0 do
            local mtrl_doid = table.remove(self.m_selectedMtrls, 1)
            local src_soids = {}
            local src_doids = {}
            local mtrl_dragon_object = g_dragonsData:getDragonObject(mtrl_doid)
            -- 드래곤     
            if (mtrl_dragon_object.m_objectType == 'dragon') then
                table.insert(src_doids, mtrl_doid)
            -- 슬라임
            elseif (mtrl_dragon_object.m_objectType == 'slime') then
                table.insert(src_soids, mtrl_doid)
            end

            src_doids = table.concat(src_doids, ',')
            src_soids = table.concat(src_soids, ',')

            co:work()
            local success_cb = function(ret)
                -- 드래곤
                if ret['deleted_dragons_oid'] then
                    for _,doid in pairs(ret['deleted_dragons_oid']) do
                        -- 드래곤 리스트 갱신
                        self.m_tableViewExt:delItem(doid)
                    end
                end
                -- 슬라임
                if ret['deleted_slimes_oid'] then
                    for _,soid in pairs(ret['deleted_slimes_oid']) do
                        -- 리스트 갱신
                        self.m_tableViewExt:delItem(soid)
                    end
                end

                co.NEXT()
            end

            g_dragonsData:request_skillLevelUp(self.m_selectDragonOID, src_doids, src_soids, success_cb, co.ESCAPE)
            if co:waitWork() then return end
        end

        -- 스킬강화 UI 뒤의 드래곤관리UI를 갱신하도록 한다.
        self.m_bChangeDragonList = true
        local mod_struct_dragon = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)        
        local skill_idx_list = self:findEnhancedSkillIdx(t_prev_dragon_data, mod_struct_dragon)
        self:show_effect(skill_idx_list, function()
            local ui = UI_DragonSkillEnhance_Result(t_prev_dragon_data, mod_struct_dragon, skill_idx_list)
            ui:setCloseCB(function()
                -- 스킬 강화 가능 여부 판별하여 가능하지 않으면 닫아버림
                local impossible, msg = g_dragonsData:impossibleSkillEnhanceForever(self.m_selectDragonOID)
                if (impossible) then
                    UIManager:toastNotificationRed(msg)
                    self:close()
                end
            end)
            -- 동시에 본UI 갱신
            self.m_selectDragonData = mod_struct_dragon
            self:refresh()
            self:refresh_skillprice()
        end)

        co:close()
    end

    Coroutine(coroutine_function, 'UI_DragonSkillEnhance:coroutine_enhance()')
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_DragonSkillEnhance:click_enhanceBtn()
	-- 스킬 강화 가능 여부
	local possible, msg = g_dragonsData:possibleDragonSkillEnhance(self.m_selectDragonOID)
	if (not possible) then
		UIManager:toastNotificationRed(msg)
        return
	end

	-- 재료 요건 여부
    if (not self.m_selectedMtrls) then
        UIManager:toastNotificationRed(Str('재료 드래곤을 선택해주세요'))
        return
    end

	-- 골드 충족 여부
    if (not ConfirmPrice('gold', self:getSkillEnhancePrice())) then
        cca.uiImpossibleAction(self.vars['enhanceBtn'])
        return
	end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID
    local src_doids = ''
    local src_soids = ''

	local mtrl_doid = self.m_selectedMtrls
	local mtrl_dragon_object = g_dragonsData:getDragonObject(mtrl_doid)
       
	-- 드래곤     
	if (mtrl_dragon_object.m_objectType == 'dragon') then
		src_doids = tostring(mtrl_doid)

	-- 슬라임
	elseif (mtrl_dragon_object.m_objectType == 'slime') then
		src_soids = tostring(mtrl_doid)

	end

    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '드래곤 스킬 레벨업')

        local t_prev_dragon_data = self.m_selectDragonData

        -- 재료로 사용된 드래곤 삭제
        if ret['deleted_dragons_oid'] then
            for _,doid in pairs(ret['deleted_dragons_oid']) do
                g_dragonsData:delDragonData(doid)

                -- 드래곤 리스트 갱신
                self.m_tableViewExt:delItem(doid)
            end
        end

        -- 슬라임
        if ret['deleted_slimes_oid'] then
            for _,soid in pairs(ret['deleted_slimes_oid']) do
                g_slimesData:delSlimeObject(soid)

                -- 리스트 갱신
                self.m_tableViewExt:delItem(soid)
            end
        end

        -- 드래곤 정보 갱신
        g_dragonsData:applyDragonData(ret['modified_dragon'])

        -- 갱신
        g_serverData:networkCommonRespone(ret)

		-- 스킬강화 UI 뒤의 드래곤관리UI를 갱신하도록 한다.
        self.m_bChangeDragonList = true

		-- 결과창 출력
        local finish_cb = function()
            local mod_struct_dragon = StructDragonObject(ret['modified_dragon'])
            local ui = UI_DragonSkillEnhance_Result(t_prev_dragon_data, mod_struct_dragon)
		    ui:setCloseCB(function()
			    -- 스킬 강화 가능 여부 판별하여 가능하지 않으면 닫아버림
			    local impossible, msg = g_dragonsData:impossibleSkillEnhanceForever(self.m_selectDragonOID)
			    if (impossible) then
				    UIManager:toastNotificationRed(msg)
				    self:close()
			    end
		    end)

            -- 동시에 본UI 갱신
		    self.m_selectDragonData = mod_struct_dragon
            self:refresh()
        end

        self:show_effect(finish_cb)

        -- @ master road
        g_masterRoadData:addRawData('d_sklvup')

        -- @ MASTER ROAD
        local t_data = {clear_key = 'd_sklvup'}
        g_masterRoadData:updateMasterRoad(t_data)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/skillup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setParam('src_soids', src_soids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function click_skillSlimeShopBtn
-- @brief 스킬 슬라임 상점
-------------------------------------
function UI_DragonSkillEnhance:click_skillSlimeShopBtn()
    local ui = UI_Shop_Popup_SkillSlime(self.m_selectDragonData) 
	ui:setCloseCB(function() 
        self:refresh() 
    end)
end

-------------------------------------
--- @function click_allSelectBtn
--- @brief 모두 선택
-------------------------------------
function UI_DragonSkillEnhance:click_allSelectBtn()
    local available_count = self.m_skillSpareLvSum - #self.m_selectedMtrls

    if available_count == 0 then
        UIManager:toastNotificationRed(Str('더 이상 선택할 수 없습니다.'))
        return
    end

    -- 최대 레벨업 가능 횟수보다 많이 선택한 경우
    if #self.m_selectedMtrls >= self.m_limitMtrlsCount then
        UIManager:toastNotificationRed(Str('신화 드래곤은 1마리 이상 선택이 불가능합니다.'))
        return
    end

    for _, v in ipairs(self.m_mtrlTableViewTD.m_itemList) do
        if available_count == 0  then
            break
        end

        if #self.m_selectedMtrls >= self.m_limitMtrlsCount then
            break
        end

        local ui = v['ui']
        local struct_dragon = v['data']

        if ui ~= nil then
            local doid = struct_dragon['id']
            if self:isSelectedMateral(doid) == false then
                self:selectMateral(doid)
                ui:setCheckSpriteVisible(true)
                available_count = available_count - 1
            end
        end
    end

    self:refresh_skillprice()
end

-------------------------------------
-- function refresh_dragonIndivisual_material
-------------------------------------
function UI_DragonSkillEnhance:refresh_dragonIndivisual_material(doid)
    local item = self.m_mtrlTableViewTD.m_itemMap[doid]

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        t_dragon_data = g_slimesData:getSlimeObject(doid)
    end

    -- 테이블뷰 리스트의 데이터 갱신
    item['data'] = t_dragon_data

    -- UI card 버튼이 있을 경우 데이터 갱신
    if item and item['ui'] then
        local ui = item['ui']
        ui.m_dragonData = t_dragon_data
        ui:refreshDragonInfo()
        self:createMtrlDragonCardCB(ui, t_dragon_data)
    end
end

-------------------------------------
-- function checkSelectedDragonCondition
-------------------------------------
function UI_DragonSkillEnhance:checkSelectedDragonCondition(dragon_object)
    if (not dragon_object) then
        return false
    end
    -- StructSlimeObject는 soid (== id)
    -- StructDragonObject는 doid (== id)
    -- 두 클래스 모두 id에 값을 저장하고 있다
    local doid = dragon_object['id']
    local object_type = dragon_object:getObjectType()

    local upgradeable, msg = g_dragonsData:impossibleSkillEnhanceForever(doid)
    if (upgradeable) then
        UIManager:toastNotificationRed(msg)
        return false
    end

    return true
end

--@CHECK
UI:checkCompileError(UI_DragonSkillEnhance)







-------------------------------------
-- class UI_RuneForgeCombineHelp
-------------------------------------
UI_DragonSkillEnhanceHelp = class(UI, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkillEnhanceHelp:init(owner_ui)
    local vars = self:load('dragon_skill_enhance_info_popup.ui')
    
    UIManager:open(self, UIManager.POPUP)

    self:initButton()
end

function UI_DragonSkillEnhanceHelp:initButton()
    local vars = self.vars

    -- infoBtn
    if (vars['closeBtn']) then vars['closeBtn']:registerScriptTapHandler(function() self:close() end) end
end
