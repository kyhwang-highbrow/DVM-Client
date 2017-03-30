local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManageInfo
-------------------------------------
UI_DragonManageInfo = class(PARENT,{
        -- 서버상의 드래곤 정보가 마지막으로 변경된 시간 (refresh 체크 용도)
        m_dragonListLastChangeTime = 'timestamp',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManageInfo:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManageInfo'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 관리') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageInfo:init(doid, b_ascending_sort, sort_type)
    local vars = self:load('dragon_management_info.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageInfo')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr(b_ascending_sort, sort_type)

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageInfo:initUI()
    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageInfo:initButton()
    local vars = self.vars
    
    do -- 우상단 버튼들 초기화
        -- 레벨업
        vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)

        -- 승급
        vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)

        -- 초월
        vars['transcendBtn']:registerScriptTapHandler(function() self:click_transcendBtn() end)

        -- 진화
        vars['evolutionBtn']:registerScriptTapHandler(function() self:click_evolutionBtn() end)

        -- 친밀도
        vars['friendshipBtn']:registerScriptTapHandler(function() self:click_friendshipBtn() end)

        -- 룬
        vars['runeBtn']:registerScriptTapHandler(function() self:click_runeBtn() end)

        -- 기원
        vars['resechBtn']:registerScriptTapHandler(function() self:click_resechBtn() end)

        -- 스킬 레벨업
        vars['skillLevelupBtn']:registerScriptTapHandler(function() self:click_skillLevelupBtn() end)
    end

    do -- 좌상단 버튼들 초기화
        -- 보기
        vars['switchBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"보기" 미구현') end)

        -- 대표
        vars['leaderBtn']:registerScriptTapHandler(function() self:click_leaderBtn() end)

        -- 평가
        vars['assessBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"평가" 미구현') end)

        -- 잠금
        vars['lockBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"잠금" 미구현') end)

        -- 작별
        vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
    end

    do -- 하단 버튼들 초기화
        -- 도감
        vars['collectionBtn']:setVisible(true)
        vars['collectionBtn']:registerScriptTapHandler(function() self:click_collectionBtn() end)
        
        -- 정렬
        vars['sortBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"정렬" 미구현') end)
        
        -- 오름차순, 내림차순
        vars['sortOrderBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"오름차순, 내림차순" 미구현') end)

        -- 진화 단계 보기
        vars['evolutionViewBtn']:registerScriptTapHandler(function() self:click_evolutionViewBtn() end)
    end

    do -- 기타 버튼
        -- 능력치 상세보기
        vars['detailBtn']:registerScriptTapHandler(function() self:click_detailBtn() end)

        -- 장비 개별 버튼 1~3
        vars['equipSlotBtn1']:registerScriptTapHandler(function() self:click_runeBtn(1) end)
        vars['equipSlotBtn2']:registerScriptTapHandler(function() self:click_runeBtn(2) end)
        vars['equipSlotBtn3']:registerScriptTapHandler(function() self:click_runeBtn(3) end)
        vars['equipSlotBtn4']:registerScriptTapHandler(function() self:click_runeBtn(4) end)
        vars['equipSlotBtn5']:registerScriptTapHandler(function() self:click_runeBtn(5) end)
        vars['equipSlotBtn6']:registerScriptTapHandler(function() self:click_runeBtn(6) end)

        -- 장비
        vars['equipmentBtn']:registerScriptTapHandler(function() self:click_equipmentBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageInfo:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 드래곤 기본 정보 갱신
    self:refresh_dragonBasicInfo(t_dragon_data, t_dragon)

    -- 드래곤 스킬 정보 갱신
    self:refresh_dragonSkillsInfo(t_dragon_data, t_dragon, function() self:click_skillDetailBtn() end)

    -- 아이콘 갱신
    self:refresh_icons(t_dragon_data, t_dragon)

    -- 능력치 정보 갱신
    self:refresh_status(t_dragon_data, t_dragon)

    do -- 장착된 룬 표시
        local t_runes = t_dragon_data['runes']
        for i=1, 6 do
            local roid = t_dragon_data['runes'][tostring(i)]
            vars['runeSlotNode' .. i]:removeAllChildren()

            if (roid and roid ~= '') then
                local rune_obj = g_runesData:getRuneObject(roid)
                local icon = IconHelper:getItemIcon(rune_obj['item_id'], rune_obj)
                vars['runeSlotNode' .. i]:addChild(icon)
            end
        end
    end
end

-------------------------------------
-- function refresh_dragonBasicInfo
-- @brief 드래곤 기본 정보 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_dragonBasicInfo(t_dragon_data, t_dragon)
    local vars = self.vars
    local vars_key = self.vars_key

    local attr = t_dragon['attr']

    -- 배경
    if self:checkVarsKey('attrBgNode', attr) then
        vars['attrBgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr)
        vars['attrBgNode']:addChild(animator.m_node)
    end

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

    -- 드래곤 실리소스
    if vars['dragonNode'] then
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'], t_dragon['attr'])
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        vars['dragonNode']:removeAllChildren(false)
        vars['dragonNode']:addChild(animator.m_node)

        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)
        animator:setAlpha(0)
        animator:runAction(cc.FadeIn:create(0.1))
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

    do -- 희귀도
        local rarity = t_dragon['rarity']
        vars['rarityFrameNode']:removeAllChildren()
        local res = string.format('res/ui/frame/manage_grade_frame_%s.png', rarity)
        local frame = cc.Sprite:create(res)
        frame:setDockPoint(cc.p(0.5, 0.5))
        frame:setAnchorPoint(cc.p(0.5, 0.5))
        vars['rarityFrameNode']:addChild(frame)
    end
end

-------------------------------------
-- function refresh_dragonSkillsInfo
-- @brief 드래곤 스킬 정보 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_dragonSkillsInfo(t_dragon_data, t_dragon, func_skill_detail_btn)
    local vars = self.vars

    do -- 스킬 아이콘 생성
        local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
        local l_skill_icon = skill_mgr:getDragonSkillIconList()
        for i=0, MAX_DRAGON_EVOLUTION do
            if l_skill_icon[i] then
                vars['skillNode' .. i]:removeAllChildren()
                vars['skillNode' .. i]:addChild(l_skill_icon[i].root)

                -- 스킬 레벨 출력
                local skill_lv = skill_mgr:getSkillLevel(i)
                vars['skllLvLabel' .. i]:setString(tostring(skill_lv))

                l_skill_icon[i].vars['clickBtn']:registerScriptTapHandler(func_skill_detail_btn)
                l_skill_icon[i].vars['clickBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
            end
        end
    end
end

-------------------------------------
-- function click_skillDetailBtn
-- @brief 스킬 상세정보 보기 버튼
-------------------------------------
function UI_DragonManageInfo:click_skillDetailBtn()
    local doid = self.m_selectDragonOID
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

    UI_SkillDetailPopup(t_dragon_data)
end

-------------------------------------
-- function refresh_icons
-- @brief 아이콘 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_icons(t_dragon_data, t_dragon)
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

    do -- 드래곤 공격 타입(char_type)
        local attack_type = t_dragon['char_type']
        vars['charTypeNode']:removeAllChildren()
        local icon = IconHelper:getAttackTypeIcon(attack_type)
        vars['charTypeNode']:addChild(icon)

        vars['charTypeLabel']:setString(dragonAttackTypeName(attack_type))
    end
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_status(t_dragon_data, t_dragon)
    local vars = self.vars

    -- 능력치 계산기
    local doid = t_dragon_data['id']
    local status_calc = MakeOwnDragonStatusCalculator(doid)

    vars['atk_label']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['def_label']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))

    if vars['cp_label'] then
        vars['cp_label']:setString(comma_value(status_calc:getCombatPower()))
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageInfo:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_levelupBtn
-- @brief 드래곤 레벨업 버튼
-------------------------------------
function UI_DragonManageInfo:click_levelupBtn()
    local doid = self.m_selectDragonOID

    do -- 레벨업이 가능한지 확인
        local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)
        if (not possible) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    self:openSubManageUI(UI_DragonLevelUp)
end

-------------------------------------
-- function click_upgradeBtn
-- @brief 승급 버튼
-------------------------------------
function UI_DragonManageInfo:click_upgradeBtn()
    local doid = self.m_selectDragonOID

    do -- 최대 등급인지 확인
        local upgradeable, msg = g_dragonsData:checkUpgradeable(doid)
        if (not upgradeable) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    self:openSubManageUI(UI_DragonUpgrade)
end

-------------------------------------
-- function click_transcendBtn
-- @brief 초월 버튼
-------------------------------------
function UI_DragonManageInfo:click_transcendBtn()
    local doid = self.m_selectDragonOID

    do -- 초월 가능 여부 확인
        local upgradeable, msg = g_dragonsData:checkEclvUpgradeable(doid)
        if (not upgradeable) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    self:openSubManageUI(UI_DragonEclvupNew)
end


-------------------------------------
-- function click_evolutionBtn
-- @brief 진화 버튼
-------------------------------------
function UI_DragonManageInfo:click_evolutionBtn()
    local doid = self.m_selectDragonOID

    do -- 최대 진화도인지 확인
        if g_dragonsData:isMaxEvolution(doid) then
            UIManager:toastNotificationGreen(Str('최대 진화단계의 드래곤입니다.'))
            return
        end
    end

    self:openSubManageUI(UI_DragonManagementEvolution)
end

-------------------------------------
-- function click_friendshipBtn
-- @brief 친밀도 버튼
-------------------------------------
function UI_DragonManageInfo:click_friendshipBtn()
    self:openSubManageUI(UI_DragonManagementFriendship)
end

-------------------------------------
-- function click_runeBtn
-- @brief 룬 버튼
-------------------------------------
function UI_DragonManageInfo:click_runeBtn(slot_idx)
    --self:openSubManageUI(UI_DragonMgrRunesNew)

    local doid = self.m_selectDragonOID
    local prev_dragon_obj = g_dragonsData:getDragonDataFromUid(doid)

    local ui = UI_DragonRunes(doid, slot_idx)

    local function close_cb()
        local curr_dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
        if (prev_dragon_obj['updated_at'] ~= curr_dragon_obj['updated_at']) then
            local b_force = true
            self:setSelectDragonData(doid, b_force)
        end
        self:sceneFadeInAction()
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function openSubManageUI
-- @brief
-------------------------------------
function UI_DragonManageInfo:openSubManageUI(sub_manage_ui)
    -- 선탠된 드래곤과 정렬 설정
    local doid = self.m_selectDragonOID
    local b_ascending_sort = self.m_dragonSortMgr.m_bAscendingSort
    local sort_type = self.m_dragonSortMgr.m_currSortType

    local ui = sub_manage_ui(doid, b_ascending_sort, sort_type)

    -- UI종료 후 콜백
    local function close_cb()
        if ui.m_bChangeDragonList then
            self:init_dragonTableView()
            local dragon_object_id = ui.m_selectDragonOID
            local b_force = true
            self:setSelectDragonData(dragon_object_id, b_force)
        else
            if (self.m_selectDragonOID ~= ui.m_selectDragonOID) then
                local b_force = true
                self:setSelectDragonData(ui.m_selectDragonOID, b_force)
            end
        end

        do -- 정렬
            self.m_dragonSortMgr:click_sortOrderBtn(ui.m_dragonSortMgr.m_bAscendingSort, true)
            self.m_dragonSortMgr:click_sortTypeBtn(ui.m_dragonSortMgr.m_currSortType, true)
            self.m_dragonSortMgr:changeSort()
        end

        self:sceneFadeInAction()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_equipmentBtn
-- @brief (임시로 드래곤 개발 API 팝업 호출)
-------------------------------------
function UI_DragonManageInfo:click_equipmentBtn()
    if (not self.m_selectDragonOID) then
        return
    end

    local ui = UI_DragonDevApiPopup(self.m_selectDragonOID)
    local function close_cb()
        self:refresh_dragonIndivisual(self.m_selectDragonOID)
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_resechBtn
-- @brief 기원 버튼
-------------------------------------
function UI_DragonManageInfo:click_resechBtn()
    self:openSubManageUI(UI_DragonManageTrain)
end

-------------------------------------
-- function click_skillLevelupBtn
-- @brief 스킬 레벨업 버튼
-------------------------------------
function UI_DragonManageInfo:click_skillLevelupBtn()
    local doid = self.m_selectDragonOID

    do -- 스킬 레벨업 가능 여부 확인
        local upgradeable, msg = g_dragonsData:checkSkillUpgradeable(doid)
        if (not upgradeable) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    self:openSubManageUI(UI_DragonSkillLevelUp)
end

-------------------------------------
-- function click_leaderBtn
-- @brief 대표드래곤 지정
-------------------------------------
function UI_DragonManageInfo:click_leaderBtn()
    if (not self.m_selectDragonOID) then
        return
    end

    local leader_dragon = g_dragonsData:getLeaderDragon()
    if (leader_dragon and (leader_dragon['id'] == self.m_selectDragonOID)) then
        UIManager:toastNotificationRed(Str('이미 대표 드래곤으로 설정되어 있습니다.'))
        return
    end

    local function yes_cb()
        local uid = g_userData:get('uid')

        local function success_cb(ret)

            -- 서버에서 넘어온 드래곤 정보 저장
            if (ret['modified_dragons']) then
                self:refreshLeaderIcon(ret['modified_dragons'])
                for _,t_dragon in ipairs(ret['modified_dragons']) do
                    g_dragonsData:applyDragonData(t_dragon)
                end
            end

            -- 서버레 리더 정보 저장
            if (ret['leaders']) then
                g_userData:applyServerData(ret['leaders'], 'leaders')
            end

            UIManager:toastNotificationGreen(Str('대표 드래곤으로 설정되었습니다.'))
        end

        local ui_network = UI_Network()
        ui_network:setUrl('/users/set_leader_dragon')
        ui_network:setParam('uid', uid)
        ui_network:setParam('type', 'lobby')
        ui_network:setParam('doid', self.m_selectDragonOID)
        ui_network:setRevocable(true)
        ui_network:setSuccessCB(success_cb)
        ui_network:request()
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('대표 드래곤으로 설정하시겠습니까?'), yes_cb)
end

-------------------------------------
-- function refreshLeaderIcon
-- @brief 대표드래곤이 변경되었을 때
-------------------------------------
function UI_DragonManageInfo:refreshLeaderIcon(modified_dragons)
    for i,v in pairs(modified_dragons) do
        local doid = v['id']
        local item = self.m_tableViewExt:getItem(doid)

        if item then
            item['data'] = clone(v)
            if item['ui'] then
                item['ui'].m_dragonData = clone(v)
                item['ui']:refresh_LeaderIcon()
            end
        end
    end
end

-------------------------------------
-- function click_sellBtn
-- @brief 작별 (드래곤 판매)
-------------------------------------
function UI_DragonManageInfo:click_sellBtn()
    if (not self.m_selectDragonOID) then
        return
    end
    
    local ui = UI_DragonGoodbye()

    -- 선택된 드래곤은 바로 추가하기 위해서
    ui:addMaterial(self.m_selectDragonOID)

    -- UI종료 후 콜백
    local function close_cb()
        if ui.m_bChangeDragonList then
            self:init_dragonTableView()

            -- 기존에 선택되어 있던 드래곤이 없어졌을 경우
            if (not g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)) then
                self:setDefaultSelectDragon(nil)
            end
        end

        self:sceneFadeInAction()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_collectionBtn
-- @brief 임시 도감
-------------------------------------
function UI_DragonManageInfo:click_collectionBtn()
    local function close_cb()
        self:checkDragonListRefresh()
    end
    g_collectionData:openCollectionPopup(close_cb)
    --[[
    local ui = UI_DragonManageInfoView()
    ui:tempGstarInit()
    --]]
end

-------------------------------------
-- function click_evolutionViewBtn
-- @brief 드래곤 진화 단계 보기 팝업
-------------------------------------
function UI_DragonManageInfo:click_evolutionViewBtn()
    if (not self.m_selectDragonData) then
        return
    end

    local l_dragon_id = {}
    local curr_idx = nil

    for idx, item in ipairs(self.m_tableViewExt.m_lItem) do
        local data = item['data']
        local did = data['did']
        table.insert(l_dragon_id, did)

        if (data['id'] == self.m_selectDragonOID) then
            curr_idx = idx
        end
    end

    UI_DragonManageInfoView(l_dragon_id, curr_idx)
end

-------------------------------------
-- function click_detailBtn
-- @brief 드래곤 상세 보기 팝업
-------------------------------------
function UI_DragonManageInfo:click_detailBtn()
    if (not self.m_selectDragonData) then
        return
    end

    UI_DragonDetailPopup(self.m_selectDragonData)
end

-------------------------------------
-- function checkDragonListRefresh
-- @brief 드래곤 리스트에 변경이 있는지 확인 후 갱신
-------------------------------------
function UI_DragonManageInfo:checkDragonListRefresh()
    local is_changed = g_dragonsData:checkChange(self.m_dragonListLastChangeTime)

    if is_changed then
        self.m_dragonListLastChangeTime = g_dragonsData:getLastChangeTimeStamp()
        
        -- 드래곤 리스트 새로 생성
        self:init_dragonTableView()

        -- @TODO sgkim 정렬 클래스 바꾸자!!
        self.m_dragonSortMgr:changeSort()
    end
end

--@CHECK
UI:checkCompileError(UI_DragonManageInfo)
