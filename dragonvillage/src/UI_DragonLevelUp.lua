local PARENT = UI_DragonManage_Base
local MAX_DRAGON_LEVELUP_MATERIAL_MAX = 30 -- 한 번에 사용 가능한 재료 수

-------------------------------------
-- class UI_DragonLevelUp
-------------------------------------
UI_DragonLevelUp = class(PARENT,{
        m_dragonLevelUpUIHelper = 'UI_DragonLevelUpHelper',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonLevelUp:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonLevelUp'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 레벨업')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLevelUp:init(doid)
    local vars = self:load('dragon_levelup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonLevelUp')

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
function UI_DragonLevelUp:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    self:initStatusUI()
end

-------------------------------------
-- function initStatusUI
-------------------------------------
function UI_DragonLevelUp:initStatusUI()
    local vars = self.vars
    local l_pos = getSortPosList(30, 3)

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[1])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('공격력'))
    vars['atkStats'] = uic_stats

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[2])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('방어력'))
    vars['defStats'] = uic_stats

    local uic_stats = UIC_IndivisualStats()
    uic_stats:initUIComponent()
    uic_stats:setPositionY(l_pos[3])
    uic_stats:setParentNode(vars['statsNode'])
    uic_stats:setStatsName(Str('생명력'))
    vars['hpStats'] = uic_stats
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonLevelUp:initButton()
    local vars = self.vars
    vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLevelUp:refresh()
    if self.m_selectDragonOID then
        self.m_dragonLevelUpUIHelper = UI_DragonLevelUpHelper(self.m_selectDragonOID, MAX_DRAGON_LEVELUP_MATERIAL_MAX)
    end

    self:refresh_dragonInfo()
    self:refresh_selectedMaterial()
    
	self:refresh_dragonMaterialTableView()
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonLevelUp:refresh_dragonInfo()
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
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @override
-------------------------------------
function UI_DragonLevelUp:createMtrlDragonCardCB(ui, data)
	self:setAttrBonusLabel(ui)
end

-------------------------------------
-- function setAttrBonusLabel
-- @brief 레벨업 할 드래곤과 재료 드래곤의 속성이 같으면 50% 추가 텍스트 표시
-------------------------------------
function UI_DragonLevelUp:setAttrBonusLabel(dragon_card)
    local dragon_object = self.m_selectDragonData
    if (not dragon_object) then
        return
    end

    -- 레벨업 할 드래곤의 속성
    local attr = dragon_object:getAttr()

    -- 재료의 속성
    local attr2 = dragon_card.m_dragonData:getAttr()

    -- 속성이 도일할 경우
    if (attr == attr2) then
        dragon_card:setExpSpriteVisible(true)
    end
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 레벨업
-- @override
-------------------------------------
function UI_DragonLevelUp:getDragonMaterialList(doid)
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 자기 자신 드래곤 제외
    if doid then
        dragon_dic[doid] = nil
    end

    -- 재료로 사용 불가능한 드래곤 제외
    for oid,v in pairs(dragon_dic) do
        if (not g_dragonsData:possibleMaterialDragon(oid)) and (not g_slimesData:possibleMaterialSlime_exp(oid)) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonLevelUp:click_dragonMaterial(t_dragon_data)
    local doid = t_dragon_data['id']

    local helper = self.m_dragonLevelUpUIHelper

    if (not helper:isSelectedDragon(doid)) then
        local is_can_add, fail_type = helper:isCanAdd()

        if (not is_can_add) then
            if (fail_type == 'max_cnt') then
                UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리까지 가능합니다.', MAX_DRAGON_LEVELUP_MATERIAL_MAX))
            elseif (fail_type == 'max_lv') then
                UIManager:toastNotificationRed(Str('더 이상 레벨업할 수 없습니다.', MAX_DRAGON_LEVELUP_MATERIAL_MAX))
            end
            return
        end
    end

    self.m_dragonLevelUpUIHelper:modifyMaterial(doid)
    self:refresh_materialDragonIndivisual(doid)
    self:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonLevelUp:refresh_materialDragonIndivisual(doid)
    if (not self.m_mtrlTableViewTD) then
        return
    end

    local item = self.m_mtrlTableViewTD:getItem(doid)
    if (not item) then
        return
    end
    
    local ui = item['ui']
    if (not ui) then
        return
    end

    local helper = self.m_dragonLevelUpUIHelper
    local is_selected = helper:isSelectedDragon(doid)
    ui:setCheckSpriteVisible(is_selected)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonLevelUp:refresh_selectedMaterial()
    local vars = self.vars
    
    local helper = self.m_dragonLevelUpUIHelper
    if (not helper) then
        return
    end

    local t_dragon_data = self.m_selectDragonData
    local doid = t_dragon_data['id']
    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)

    vars['selectLabel']:setString(helper:getMaterialCountString())
    vars['priceLabel']:setString(comma_value(helper.m_price))
    vars['expGauge']:runAction(cc.ProgressTo:create(0.2, (helper.m_expPercentage)))

    vars['levelLabel']:setString(Str('레벨{1}/{2}', helper.m_changedLevel, helper.m_maxLevel))

    if possible then
        vars['expLabel']:setString(Str('{1}/{2}', helper.m_changedExp, helper.m_changedMaxExp))
    else
        vars['expLabel']:setString('')
        vars['expGauge']:runAction(cc.ProgressTo:create(0.2, 100))
    end

    local plus_level = helper:getPlusLevel()
    vars['gradeLabel']:setString(Str('+{1}', plus_level))

    -- 능력치 정보 갱신
    self:refresh_stats(t_dragon_data, helper.m_changedLevel)
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonLevelUp:refresh_stats(t_dragon_data, lv)
    local vars = self.vars
    local doid = t_dragon_data['id']

    -- 현재 레벨의 능력치 계산기
    local status_calc = MakeOwnDragonStatusCalculator(doid)

    -- 현재 레벨의 능력치
    local curr_atk = status_calc:getFinalStat('atk')
    local curr_def = status_calc:getFinalStat('def')
    local curr_hp = status_calc:getFinalStat('hp')
    local curr_cp = status_calc:getCombatPower()

    vars['atkStats']:setBeforeStats(curr_atk)
    vars['defStats']:setBeforeStats(curr_def)
    vars['hpStats']:setBeforeStats(curr_hp)

    -- 변경된 레벨의 능력치 계산기
    local chaged_dragon_data = {}
    chaged_dragon_data['lv'] = lv
    local changed_status_calc = MakeOwnDragonStatusCalculator(doid, chaged_dragon_data)

    -- 변경된 레벨의 능력치
    local changed_atk = changed_status_calc:getFinalStat('atk')
    local changed_def = changed_status_calc:getFinalStat('def')
    local changed_hp = changed_status_calc:getFinalStat('hp')
    local changed_cp = changed_status_calc:getCombatPower()

    vars['atkStats']:setAfterStats(changed_atk)
    vars['defStats']:setAfterStats(changed_def)
    vars['hpStats']:setAfterStats(changed_hp)
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-- @override
-------------------------------------
function UI_DragonLevelUp:createDragonCardCB(ui, data)
    local doid = data['id']

    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)
    if (not possible) then
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
function UI_DragonLevelUp:checkDragonSelect(doid)
    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)

    if possible then
        return true
    else
        UIManager:toastNotificationRed(msg)
        return false
    end
end

-------------------------------------
-- function click_levelupBtn
-- @brief
-------------------------------------
function UI_DragonLevelUp:click_levelupBtn()
    local helper = self.m_dragonLevelUpUIHelper

    if (helper.m_materialCount <= 0) then
        UIManager:toastNotificationRed(Str('재료 드래곤을 선택해주세요!'))
        return
    end

    -- 골드가 충분히 있는지 확인
    if (not ConfirmPrice('gold', self.m_dragonLevelUpUIHelper.m_price)) then
        return
    end

    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '드래곤 레벨업')

        local prev_lv = self.m_selectDragonData['lv']
        local prev_exp = self.m_selectDragonData['exp']
        local curr_lv = ret['modified_dragon']['lv']
        local bonus_rate = (ret['bonus'] or 100) -- 100일 경우 보너스 발동을 안한 상태

        if (prev_lv == curr_lv) then
            self:response_levelup(ret, bonus_rate)
        else
            -- 드래곤 정보 갱신 (임시 위치)
            g_dragonsData:applyDragonData(ret['modified_dragon'])
            local ui = UI_DragonLevelupResult(StructDragonObject(ret['modified_dragon']), prev_lv, prev_exp, bonus_rate)
            local function close_cb()
                self:response_levelup(ret)
            end
            ui:setCloseCB(close_cb)
        end

    end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID
    local src_doids = ''
    local src_soids = ''
    do
        for _doid,type in pairs(helper.m_materialDoidMap) do
            if (type == 'dragon') then
                if (src_doids == '') then
                    src_doids = tostring(_doid)
                else
                    src_doids = src_doids .. ',' .. tostring(_doid)
                end
            elseif (type == 'slime') then
                if (src_soids == '') then
                    src_soids = tostring(_doid)
                else
                    src_soids = src_soids .. ',' .. tostring(_doid)
                end
            end
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/levelup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setParam('src_soids', src_soids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function response_levelup
-- @brief
-------------------------------------
function UI_DragonLevelUp:response_levelup(ret, bonus_rate)

    -- 보너스 표시
    if bonus_rate and (100 < bonus_rate) then
        self.vars['bonusVisual']:setVisible(true)
        self.vars['bonusVisual']:changeAni('success_' .. tostring(bonus_rate))
        local function ani_handler()
            self.vars['bonusVisual']:setVisible(false)    
        end
        self.vars['bonusVisual']:addAniHandler(ani_handler)
    end

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
    g_serverData:networkCommonRespone(ret)

    self.m_bChangeDragonList = true

    self:setSelectDragonDataRefresh()

    local doid = self.m_selectDragonOID
    self:refresh_dragonIndivisual(doid)

    -- @ MASTER ROAD
    local t_data = {clear_key = 'd_lvup'}
    g_masterRoadData:updateMasterRoad(t_data)

    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)
    if (not possible) then
        MakeSimplePopup(POPUP_TYPE.OK, msg, function() self:close() end)
    end

end

--@CHECK
UI:checkCompileError(UI_DragonLevelUp)
