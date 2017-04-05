local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManageInfo
-------------------------------------
UI_DragonManageInfo = class(PARENT,{
        -- 서버상의 드래곤 정보가 마지막으로 변경된 시간 (refresh 체크 용도)
        m_dragonListLastChangeTime = 'timestamp',

        m_dragonInfoBoardUI = 'UI_DragonInfoBoard',
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

    -- 드래곤 정보 보드 생성
    self.m_dragonInfoBoardUI = UI_DragonInfoBoard()
    self.m_dragonInfoBoardUI.vars['equipmentBtn']:setVisible(true)
    self.m_dragonInfoBoardUI.vars['equipmentBtn']:registerScriptTapHandler(function() self:click_equipmentBtn() end)
    self.vars['rightNode']:addChild(self.m_dragonInfoBoardUI.root)
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

        -- 연구
        vars['resechBtn']:registerScriptTapHandler(function() self:click_resechBtn() end)
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
        -- 장비 개별 버튼 1~3
        vars['equipSlotBtn1']:registerScriptTapHandler(function() self:click_runeBtn(1) end)
        vars['equipSlotBtn2']:registerScriptTapHandler(function() self:click_runeBtn(2) end)
        vars['equipSlotBtn3']:registerScriptTapHandler(function() self:click_runeBtn(3) end)
        vars['equipSlotBtn4']:registerScriptTapHandler(function() self:click_runeBtn(4) end)
        vars['equipSlotBtn5']:registerScriptTapHandler(function() self:click_runeBtn(5) end)
        vars['equipSlotBtn6']:registerScriptTapHandler(function() self:click_runeBtn(6) end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageInfo:refresh()
    local t_dragon_data = self.m_selectDragonData

    self.m_dragonInfoBoardUI:refresh(t_dragon_data)

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 드래곤 기본 정보 갱신
    self:refresh_dragonBasicInfo(t_dragon_data, t_dragon)

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

    -- 리더 드래곤 여부 표시
    self:refresh_leaderDragon(t_dragon_data)
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
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['attrBgNode']:addChild(animator.m_node)
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
end

-------------------------------------
-- function refresh_leaderDragon
-- @brief
-------------------------------------
function UI_DragonManageInfo:refresh_leaderDragon(t_dragon_data)
    local t_dragon_data = (t_dragon_data or self.m_selectDragonData)
    local doid = nil
    if (t_dragon_data) then
        doid = t_dragon_data['id']
    end
    local vars = self.vars

    -- 리더 드래곤
    if vars['leaderSprite'] then
        if doid then
            local is_leader = g_dragonsData:isLeaderDragon(doid)
            vars['leaderSprite']:setVisible(is_leader)
        else
            vars['leaderSprite']:setVisible(false)
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

    self:openSubManageUI(UI_DragonUpgradeNew)
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
    self:openSubManageUI(UI_DragonRunes, slot_idx)
end

-------------------------------------
-- function openSubManageUI
-- @brief
-------------------------------------
function UI_DragonManageInfo:openSubManageUI(sub_manage_ui, add_param)
    -- 선탠된 드래곤과 정렬 설정
    local doid = self.m_selectDragonOID
    local b_ascending_sort = self.m_dragonSortMgr.m_bAscendingSort
    local sort_type = self.m_dragonSortMgr.m_currSortType

    local ui = sub_manage_ui(doid, b_ascending_sort, sort_type, add_param)

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
-- @brief 연구 버튼
-------------------------------------
function UI_DragonManageInfo:click_resechBtn()
    local doid = self.m_selectDragonOID

    do -- 최대 등급인지 확인
        local upgradeable, msg = g_dragonsData:checkResearchUpgradeable(doid)
        if (not upgradeable) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    self:openSubManageUI(UI_DragonResearch)
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
            
            -- 리더 드래곤 여부 표시
            self:setSelectDragonDataRefresh()
            self:refresh_leaderDragon(t_dragon_data)
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
