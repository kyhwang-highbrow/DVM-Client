local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonSkillEnhance
-------------------------------------
UI_DragonSkillEnhance = class(PARENT,{
		-- 재료
        m_selectedMtrl = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonSkillEnhance:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonSkillEnhance'
    self.m_bVisible = true
    self.m_titleStr = Str('스킬 강화')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkillEnhance:init(doid)
    local vars = self:load('dragon_skill_enhance.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonSkillEnhance')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
 
    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
	
	-- 정렬 도우미
    self:init_dragonSortMgr()
	self:init_mtrDragonSortMgr()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkillEnhance:initUI()
    local vars = self.vars

    self:init_dragonTableView()
	vars['priceLabel']:setString(0)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonSkillEnhance:initButton()
    local vars = self.vars
    --vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkillEnhance:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local did = t_dragon_data['did']

    -- 배경
    local attr = TableDragon:getDragonAttr(did)
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
        if (self.m_selectedMtrl) then
            self.m_selectedMtrl.root:removeFromParent()
        end
    end

	-- 승급 가능 여부 처리
	--[[
	local upgradeable = g_dragonsData:checkUpgradeable(self.m_selectDragonOID)
	vars['infoLabel']:setVisible(not upgradeable)
	]]

	self:refresh_skillIcon()
    self:refresh_dragonMaterialTableView()
end

-------------------------------------
-- function refresh_skillIcon
-------------------------------------
function UI_DragonSkillEnhance:refresh_skillIcon()
	local vars = self.vars

	local t_dragon_data = self.m_selectDragonData

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

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 스킬강화
-- @override
-------------------------------------
function UI_DragonSkillEnhance:getDragonMaterialList(doid)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 자기 자신 드래곤 제외
    dragon_dic[doid] = nil

	-- 원종이 같은 드래곤을 체크한다 대상이 아닌 경우가 대부분이라 추출하는게 좋을것같지만...
	local ret_dic = {}
	local did_digit = math_floor(t_dragon_data['did']/10)
	local tar_digit
    for oid, v in pairs(dragon_dic) do

		-- 드래곤의 경우 동일종 추가
		if (g_dragonsData:possibleMaterialDragon(oid)) then
			tar_digit = math_floor(v['did']/10)
			if (tar_digit == did_digit) then
				ret_dic[oid] = v
			end

		-- 스킬 강화 슬라임 추가
		elseif (g_slimesData:possibleMaterialSlime(oid, 'skill')) then
			if (t_dragon_data:getRarity() == v:getRarity()) then
				ret_dic[oid] = v
			end

		end
    end

    return ret_dic
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-- @override
-------------------------------------
function UI_DragonSkillEnhance:createDragonCardCB(ui, data)
	local doid = data['id']

    local enhancable, msg = g_dragonsData:checkDragonSkillEnhancable(doid)
    if (not enhancable) then
        if ui then
            ui:setShadowSpriteVisible(true)
        end
    end
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-- @override
-------------------------------------
function UI_DragonSkillEnhance:checkDragonSelect(doid)
	local possible, msg = g_dragonsData:checkDragonSkillEnhancable(doid)

    if possible then
        return true
    else
        UIManager:toastNotificationRed(msg)
        return false
    end

	return true
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonSkillEnhance:click_dragonMaterial(data)
    local vars = self.vars

    local doid = data['id']

    local list_item = self.m_mtrlTableViewTD:getItem(doid)
    local list_item_ui = list_item['ui']
    
	-- 선택된 재료가 있는 경우
    if self.m_selectedMtrl then
		-- 선택된 재료와 클릭한 재료가 같음 
		if (doid == self.m_selectedMtrl.m_dragonData['id']) then
			--> 해제 처리
			local ui = self.m_selectedMtrl
			ui.root:removeFromParent()
			self.m_selectedMtrl = nil

			list_item_ui:setShadowSpriteVisible(false)

		-- 선택 클릭 다름
		else
			--> @TODO 해제 및 다시 선택

		end

	-- 선택된 재료가 없는 경우
    else
		local ui = UI_DragonCard(data)
		ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonUpgradeMaterial(data) end)
		self.m_selectedMtrl = ui

		local scale = 0.57
		cca.uiReactionSlow(ui.root, scale, scale, scale * 0.7)
		vars['materialNode']:addChild(ui.root)

		list_item_ui:setShadowSpriteVisible(true)
	end
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_DragonSkillEnhance:click_enhanceBtn()
	-- 승급 가능 여부
	--[[
	local upgradeable, msg = g_dragonsData:checkUpgradeable(self.m_selectDragonOID)
	if (not upgradeable) then
		UIManager:toastNotificationRed(msg)
        return
	end
	]]

	-- 재료 요건 여부
    if (not self.m_selectedMtrl) then
        UIManager:toastNotificationRed(Str('재료 드래곤을 넣어주세요'))
        cca.uiImpossibleAction(self.vars['materialNode'])
        return
    end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID
    local src_doids = ''
    local src_soids = ''

	local _doid = v.m_dragonData['id']
	local _dragon_object = g_dragonsData:getDragonObject(_doid)
       
	-- 드래곤     
	if (_dragon_object.m_objectType == 'dragon') then
		src_doids = tostring(_doid)

	-- 슬라임
	elseif (_dragon_object.m_objectType == 'slime') then
		src_soids = tostring(_doid)

	end

    local function success_cb(ret)
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

        -- 골드 갱신
        if ret['gold'] then
            g_serverData:applyServerData(ret['gold'], 'user', 'gold')
            g_topUserInfo:refreshData()
        end

        self.m_bChangeDragonList = true

        local t_next_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)

        -- 연출 시작
        self:upgradeDirecting(doid, t_prev_dragon_data, t_next_dragon_data)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/upgrade')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setParam('src_soids', src_soids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function upgradeDirecting
-- @brief 강화 연출
-------------------------------------
function UI_DragonSkillEnhance:upgradeDirecting(doid, t_prev_dragon_data, t_next_dragon_data)
    local block_ui = UI_BlockPopup()

    local directing_animation
    local directing_result

    -- 에니메이션 연출
    directing_animation = function()
        local vars = self.vars

        self.vars['upgradeVisual']:setVisible(true)
        self.vars['upgradeVisual']:setVisual('group', 'idle')
        self.vars['upgradeVisual']:setRepeat(false)
        self.vars['upgradeVisual']:addAniHandler(directing_result)
        SoundMgr:playEffect('EFFECT', 'exp_gauge')
    end

    -- 결과 연출
    directing_result = function()
        block_ui:close()
        
        -- 결과 팝업 (승급)
        if (t_prev_dragon_data['grade'] < t_next_dragon_data['grade']) then
            UI_DragonUpgradeResult(t_next_dragon_data, t_prev_dragon_data)
        end

        -- UI 닫음
        self:close()
    end

    directing_result()
end

--@CHECK
UI:checkCompileError(UI_DragonSkillEnhance)
