local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonManageInfo
-------------------------------------
UI_DragonManageInfo = class(PARENT,{
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
function UI_DragonManageInfo:init()
    local vars = self:load('dragon_management_info.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageInfo')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageInfo:initUI()
    self:init_dragonTableView()
    self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageInfo:initButton()
    local vars = self.vars
    
    do -- 우상단 버튼들 초기화
        -- 승급
        vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)

        -- 진화
        vars['evolutionBtn']:registerScriptTapHandler(function() self:click_evolutionBtn() end)

        -- 친밀도
        vars['friendshipBtn']:registerScriptTapHandler(function() self:click_friendshipBtn() end)

        -- 장비
        vars['equipmentBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"장비" 미구현') end)

        -- 강화
        vars['reinforceBtn']:registerScriptTapHandler(function() self:click_reinforceBtn() end)
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
        vars['collectionBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"도감" 미구현') end)
        
        -- 정렬
        vars['sortBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"정렬" 미구현') end)
        
        -- 오름차순, 내림차순
        vars['sortOrderBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"오름차순, 내림차순" 미구현') end)

        -- 진화 단계 보기
        vars['evolutionViewBtn']:registerScriptTapHandler(function() self:click_evolutionViewBtn() end)
    end

    do -- 기타 버튼
        -- 능력치 상세보기
        vars['detailBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"능력치 상세보기" 미구현') end)

        -- 스킬 상세보기
        vars['skillBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"스킬 상세보기" 미구현') end)

        -- 장비 개별 버튼 1~3
        vars['equipSlotBtn1']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"장비" 미구현') end)
        vars['equipSlotBtn2']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"장비" 미구현') end)
        vars['equipSlotBtn3']:registerScriptTapHandler(function() UIManager:toastNotificationRed('"장비" 미구현') end)
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
    self:refresh_dragonSkillsInfo(t_dragon_data, t_dragon)

    -- 아이콘 갱신
    self:refresh_icons(t_dragon_data, t_dragon)

    -- 능력치 정보 갱신
    self:refresh_status(t_dragon_data, t_dragon)
end

-------------------------------------
-- function refresh_dragonBasicInfo
-- @brief 드래곤 기본 정보 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_dragonBasicInfo(t_dragon_data, t_dragon)
    local vars = self.vars

    do -- 드래곤 이름
        local evolution_lv = t_dragon_data['evolution']
        vars['nameLabel']:setString(Str(t_dragon['t_name']) .. '-' .. evolutionName(evolution_lv))
    end

    do -- 드래곤 등급
        vars['starNode']:removeAllChildren()
        local star_res = 'res/ui/icon/star020' .. t_dragon_data['grade'] .. '.png'
        local star_icon = cc.Sprite:create(star_res)
        star_icon:setDockPoint(cc.p(0.5, 0.5))
        star_icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['starNode']:addChild(star_icon)
    end

    do -- 드래곤 실리소스
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
        local lv_str = Str('{1}/{2}', t_dragon_data['lv'], dragonMaxLevel(t_dragon_data['grade']))
        vars['lvLabel']:setString(lv_str)
    end

    do -- 경혐치 exp
        local lv = t_dragon_data['lv']
        local table_exp = TABLE:get('exp_dragon')
        local t_exp = table_exp[lv] 
        local max_exp = t_exp['exp_d']
        local percentage = (t_dragon_data['exp'] / max_exp) * 100
        percentage = math_floor(percentage)
        vars['expLabel']:setString(Str('{1}%', percentage))

        vars['expGauge']:stopAllActions()
        vars['expGauge']:setPercentage(0)
        vars['expGauge']:runAction(cc.ProgressTo:create(0.2, percentage)) 
    end

    do -- 승급 경험치
        vars['upgradeLabel']:setString('')
        vars['upgradeGauge']:setPercentage(0)
    end

    do -- 친밀도
        vars['friendshipLabel']:setString(Str('무관심'))
        vars['friendshipGauge']:setPercentage(0)
    end
end

-------------------------------------
-- function refresh_dragonSkillsInfo
-- @brief 드래곤 스킬 정보 갱신
-------------------------------------
function UI_DragonManageInfo:refresh_dragonSkillsInfo(t_dragon_data, t_dragon)
    local vars = self.vars
    local dragon_id = t_dragon_data['did']

    do -- 스킬 아이콘 생성
        local skill_mgr = DragonSkillManager('dragon', dragon_id, t_dragon_data['grade'])
        local l_skill_icon = skill_mgr:getSkillIconList()
        for i=0, MAX_DRAGON_EVOLUTION do
            if l_skill_icon[i] then
                vars['skillNode' .. i]:removeAllChildren()
                vars['skillNode' .. i]:addChild(l_skill_icon[i].root)
                local lock = (t_dragon_data['evolution'] < i)
                l_skill_icon[i]:setLockSpriteVisible(lock)

                if lock then
                    vars['skllLvLabel' .. i]:setString('0')
                else
                    vars['skllLvLabel' .. i]:setString('1')
                end
            end
        end
    end
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
    local dragon_id = t_dragon['did']
    local lv = t_dragon_data['lv']
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']

    -- 능력치 계산기
    local status_calc = MakeDragonStatusCalculator(dragon_id, lv, grade, evolution)

    vars['atk_label']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['def_label']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageInfo:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_upgradeBtn
-- @brief 승급 버튼
-------------------------------------
function UI_DragonManageInfo:click_upgradeBtn()
    local ui = UI_DragonManageUpgrade(doid)

    -- 선탠된 드래곤 설정
    local doid = self.m_selectDragonOID
    ui:setSelectDragonData(doid)

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
        self:sceneFadeInAction()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_evolutionBtn
-- @brief 진화 버튼
-------------------------------------
function UI_DragonManageInfo:click_evolutionBtn()
    local ui = UI_DragonManagementEvolution(doid)

    -- 선탠된 드래곤 설정
    local doid = self.m_selectDragonOID
    ui:setSelectDragonData(doid)

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
        self:sceneFadeInAction()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_friendshipBtn
-- @brief 친밀도 버튼
-------------------------------------
function UI_DragonManageInfo:click_friendshipBtn()
    local ui = UI_DragonManagementFriendship(doid)

    -- 선탠된 드래곤 설정
    local doid = self.m_selectDragonOID
    ui:setSelectDragonData(doid)

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
        self:sceneFadeInAction()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_reinforceBtn
-- @brief 강화 버튼 (임시로 드래곤 개발 API 팝업 호출)
-------------------------------------
function UI_DragonManageInfo:click_reinforceBtn()
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
-- function click_leaderBtn
-- @brief 대표드래곤 지정
-------------------------------------
function UI_DragonManageInfo:click_leaderBtn()
    if (not self.m_selectDragonOID) then
        return
    end

    local leader_dragon = g_dragonsData:getLeaderDragon()
    if (leader_dragon['id'] == self.m_selectDragonOID) then
        UIManager:toastNotificationRed(Str('이미 대표 드래곤으로 설정되어 있습니다.'))
        return
    end

    local function yes_cb()
        local uid = g_userData:get('uid')

        local function success_cb(ret)
            if ret['leader_dragon'] then
                local doid = ret['leader_dragon']
                g_dragonsData:setLeaderDragon(doid)
            end
            UIManager:toastNotificationGreen(Str('대표 드래곤으로 설정되었습니다.'))
        end

        local ui_network = UI_Network()
        ui_network:setUrl('/users/set_leader_dragon')
        ui_network:setParam('uid', uid)
        ui_network:setParam('doid', self.m_selectDragonOID)
        ui_network:setRevocable(true)
        ui_network:setSuccessCB(success_cb)
        ui_network:request()
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('대표 드래곤으로 설정하시겠습니까?'), yes_cb)
end

-------------------------------------
-- function click_sellBtn
-- @brief 작별 (드래곤 판매)
-------------------------------------
function UI_DragonManageInfo:click_sellBtn()
    if (not self.m_selectDragonOID) then
        return
    end
    
    local func_popup    -- 여부 묻기
    local func_network  -- 네트워크 통신
    local func_finish   -- 종료 후 적용 (ret)

    -- 여부 묻기
    func_popup = function()
        MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('드래곤을 떠나보내시겠습니까?'), func_network)
    end

    -- 네트워크 통신
    func_network = function()
        local uid = g_userData:get('uid')

        local ui_network = UI_Network()
        ui_network:setUrl('/dragons/del')
        ui_network:setParam('uid', uid)
        ui_network:setParam('doid', self.m_selectDragonOID)
        ui_network:setSuccessCB(func_finish)
        ui_network:setRevocable(true)
        ui_network:request()
    end

    -- 종료 후 적용 (ret)
    func_finish = function(ret)
        -- 테이블 뷰에서 삭제
        self.m_tableViewExt:delItem(self.m_selectDragonOID)
        self.m_tableViewExt:update()

        g_dragonsData:delDragonData(self.m_selectDragonOID)
        self.m_selectDragonOID = nil

        -- 기본 선택 드래곤 다시 지정
        self:setDefaultSelectDragon()
    end

    -- 시작
    func_popup()
end

-------------------------------------
-- function click_evolutionViewBtn
-- @brief 드래곤 진화 단계 보기 팝업
-------------------------------------
function UI_DragonManageInfo:click_evolutionViewBtn()
    if (not self.m_selectDragonData) then
        return
    end

    local dragon_id = self.m_selectDragonData['did']
    UI_DragonManageInfoView(dragon_id)
end

--@CHECK
UI:checkCompileError(UI_DragonManageInfo)
