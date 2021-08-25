local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_GachaResult_Dragon
-------------------------------------
UI_GachaResult_Dragon = class(PARENT, {
    m_type = 'string',

    m_lGachaDragonList = 'list',
    m_lGachaDragonListOrg = 'list',
    m_lDragonCardList = 'list',
    m_tDragonCardEffectTable = 'table',

    m_currDragonAnimator = 'UIC_DragonAnimator',

    -- 연출 관련
    m_isDirecting = 'bool',
    m_hideUIList = '',
    m_bSkip = 'bool',           -- 완전히 끝까지 연출 스킵
    m_bSkipClicked = 'bool',    -- 스킵을 클릭했을 때의 액션을 취해주기 위함
    m_selectedDragonData = 'StructDragonObject',

    -- 알 소환 연출
    m_eggID = 'number',
    m_eggRes = 'string',

    -- 소환 정보
    m_tSummonData = 'table',

    m_isClearMasterRoad = 'bool',

        -- 마일리지
    m_added_mileage = 'number',

    m_shownMythDid = 'table',

    m_canRetry = 'boolean', -- 다시 뽑기 가능?

    m_animatedDragonIdTable = 'table',  -- 애니메이션 연출이 있었던 신화드래곤 테이블


    -- {1} 확정 소환까지 {@yellow}{2}{@default}회 남음
    m_originCeilingNotiLabel = 'string',

    m_pickupID = 'string',

    m_bIsVisibleCeilingInfo = 'boolean',
})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_GachaResult_Dragon:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_bVisible = false -- onFocus 용도로만 쓰임
end

-------------------------------------
-- function init
-------------------------------------
function UI_GachaResult_Dragon:init(gacha_type, l_gacha_dragon_list, l_slime_list, egg_id, egg_res, t_summon_data, added_mileage, pickup_id)
    --[[
    local list = {}
    for i, v in ipairs(l_gacha_dragon_list) do
        if i == 5 then v['did'] = 121752 v['grade'] = 6 end
        if i == 6 then v['did'] = 121754 v['grade'] = 6 end
        if i == 7 then v['did'] = 121752 v['grade'] = 6 end

        table.insert(list, v)
    end
    l_gacha_dragon_list = list]]
    

    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData_checkNumber()

    self.m_type = gacha_type
    self.m_eggID = egg_id
    self.m_eggRes = egg_res
    self.m_bSkip = false
    self.m_tSummonData = t_summon_data
    self.m_added_mileage = added_mileage or 0
    self.m_pickupID = pickup_id
    self.m_shownMythDid = {}

    
    self.m_bSkipClicked = false
    self.m_canRetry = true
    self.m_bIsVisibleCeilingInfo = false
    self.m_animatedDragonIdTable = {}

    -- 연출없이 즉시 단일 결과 보여주는 타입..
    if (self.m_type == 'immediately') then
        self.m_bSkip = true
    end

    -- 드래곤리스트, 슬라임 리스트 copy
    local copy_dragon_list = l_gacha_dragon_list and clone(l_gacha_dragon_list) or {}
    local copy_slime_list = l_slime_list and clone(l_slime_list) or {}

    -- 연출에 사용될 리스트 merge
    self.m_lGachaDragonList = {}
    for idx,v in ipairs(copy_dragon_list) do
        local dragon_data

        if (v['id']) then
            dragon_data = v
        else
            dragon_data = v
            dragon_data['id'] = dragon_data['did'] .. '_' .. tostring(idx)
        end

        local struct = StructDragonObject(dragon_data)
        table.insert(self.m_lGachaDragonList, struct)
    end
    for i,v in ipairs(copy_slime_list) do
        local struct = StructSlimeObject(v)
        table.insert(self.m_lGachaDragonList, struct)
    end

    -- 연출 제어용으로 원본 따로 저장
    self.m_lGachaDragonListOrg = clone(self.m_lGachaDragonList)

    self.m_uiName = 'UI_GachaResult_Dragon'
    local vars = self:load('dragon_summon_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- @UI_ACTION
    self:doActionReset()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_GachaResult_Dragon')

    -- 멤버 변수
    self.m_lDragonCardList = {}
    self.m_tDragonCardEffectTable = {}
    self.m_isDirecting = false
    self.m_hideUIList = {}

    if vars['ceilingNotiLabel'] then
        self.m_originCeilingNotiLabel = vars['ceilingNotiLabel']:getString()
    end

    self:initUI()  
    self:initButton()
    self:refresh()

    SoundMgr:stopBGM()

        -- @ MASTER ROAD
    local t_data = {clear_key = 'egg'}
        local function cb_func(b)
            self.m_isClearMasterRoad = b or false
        end
    g_masterRoadData:updateMasterRoad(t_data, cb_func)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GachaResult_Dragon:initUI()
    local vars = self.vars

    vars['skipBtn']:setVisible(true)

    -- 연차일 경우 처리
    if (table.count(self.m_lGachaDragonList) > 1) then
        self:setDragonCardList()
        vars['blackSprite']:setVisible(true)
    end

    -- 이것저것..
    self:initEverything()

    -- 사용 재화 표기
    self:refresh_wealth()

    -- 드래곤 수량 표시
    self:refresh_inventoryLabel()
end


-------------------------------------
-- function initEverything
-- @brief 여기저기 흩어져 있던 외부에서 조작하던 것들 한곳으로 모음
-------------------------------------
function UI_GachaResult_Dragon:initEverything()
    local vars = self.vars

    -- 공통 데이터
    local t_egg_data = self.m_tSummonData
    local egg_id = self.m_eggID

    -- 선택권, 뽑기권 등..
    if (self.m_type == 'mail') or (self.m_type == 'immediately') or (self.m_type == 'summon_ticket') then

        self.m_canRetry = false

        if (self.m_type == 'summon_ticket') then
            self.m_bIsVisibleCeilingInfo = true
            
            if vars['ceilingNotiMenu'] then
                vars['ceilingNotiMenu']:setPositionY(vars['againBtn']:getPositionY())
            end
        end

    -- 부화
    elseif (self.m_type == 'incubate') then
        local cnt = t_egg_data['count']
        local remain_cnt = t_egg_data['remain_cnt']
        
        self.m_canRetry = false
        
        -- 이어서 뽑기 (단차 뽑기만 지원함)
        if (cnt == 1) and (1 <= remain_cnt) then
            local al egg_icon = IconHelper:getEggIconByEggID(egg_id)
            vars['summonEggNode']:addChild(egg_icon)
            vars['summonEggLabel']:setString(Str('{1}', remain_cnt))

            self:registerOpenNode('summonBtn')
        end

        -- 연출 조정
        self:registerOpenNode('inventoryBtn')

        return

    -- 고급 소환 / 우정 소환
    else
        local is_cash = (self.m_type == 'cash' or self.m_type == 'pickup')
        local is_ad = t_egg_data['is_ad']

        if is_cash and (not is_ad) then
            self.m_bIsVisibleCeilingInfo = true
        end
        
        do -- 아이콘
            local price_icon
            if (is_cash) then
                price_icon = IconHelper:getIcon('res/ui/icons/item/cash.png')
            else
                price_icon = IconHelper:getIcon('res/ui/icons/item/fp.png')
            end
            price_icon:setScale(0.5)
            vars['priceIconNode']:removeAllChildren()
            vars['priceIconNode']:addChild(price_icon)
        end

        do -- 가격
            local price = t_egg_data['price']

            -- 광고 무료 소환
            if (is_ad) then
                self.m_canRetry = false
                vars['againBtn']:setVisible(false)

            else 
                vars['priceLabel']:setString(comma_value(price))
            end
        end

        -- UI 연출 조정
        do
            -- 공통
            self:registerOpenNode('inventoryBtn')

            self:registerOpenNode('ceilingNotiMenu')

            -- 광고인 경우 다시 소환 숨김
            self:registerOpenNode('againBtn')


            -- 마일리지
            --[[
            if (self.m_added_mileage > 0) then
                self:registerOpenNode('mileageNode')
            end]]

            -- 캐시 혹은 우정포인트
            if (is_cash) then
                self:registerOpenNode('diaNode')
            else
                self:registerOpenNode('fpNode')
            end
        end
    end

    if vars['ceilingNotiMenu'] and vars['ceilingNotiLabel'] and self.m_originCeilingNotiLabel then
        local struct_pickup = g_hatcheryData:getPickupStructByPickupID(self.m_pickupID)

        local did = struct_pickup and struct_pickup:getTargetDragonID() or nil

        local left_ceiling_num = g_hatcheryData:getLeftCeilingNum(self.m_pickupID)
        local target_dragon_name = did and TableDragon:getChanceUpDragonName(did) or ('{@yellow}' .. Str('신화 드래곤') .. '{@default}')

        if (not left_ceiling_num) then
            self.m_bIsVisibleCeilingInfo = false
        end

        if (not self.m_bIsVisibleCeilingInfo) then
            vars['ceilingNotiMenu']:setVisible(false)
        elseif (left_ceiling_num == 0) then
            vars['ceilingNotiLabel']:setString(Str('{1} {@default}확정 소환', target_dragon_name))
        else
            vars['ceilingNotiLabel']:setString(Str(self.m_originCeilingNotiLabel, target_dragon_name, left_ceiling_num))
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GachaResult_Dragon:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:refresh() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_skipBtn() end)
    vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)
    vars['lockBtn']:registerScriptTapHandler(function() self:click_lockBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GachaResult_Dragon:refresh()
    if (#self.m_lGachaDragonList <= 0) then
        self:click_closeBtn()
        return
    end

    local t_gacha_dragon = self.m_lGachaDragonList[1]
    table.remove(self.m_lGachaDragonList, 1)
    local is_last = (#self.m_lGachaDragonList <= 0)

    local vars = self.vars

    self.m_selectedDragonData = nil

    -- 연출을 위한 준비
    self.m_isDirecting = true
    vars['starVisual']:setVisible(false)
        vars['okBtn']:setEnabled(false)
    vars['bgNode']:removeAllChildren()
    local function start_directing_cb()
        -- 플래시 연출
        do
            vars['splashLayer']:setLocalZOrder(1)
            vars['splashLayer']:setVisible(true)
            vars['splashLayer']:stopAllActions()
            vars['splashLayer']:setOpacity(255)
            vars['splashLayer']:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.Hide:create()))
        end

        -- 드래곤 애니메이터 및 정보 갱신
        self:refresh_dragon(t_gacha_dragon)

        -- 항상 모든 등급 이펙트 off
        for card, rarity_effect in pairs(self.m_tDragonCardEffectTable) do
            rarity_effect:setOpacity(0)
        end

        --self:doActionReverse(set_card_visible_cb, 3.0)
    end

    -- 마지막에만 보여야 하는 UI들을 관리
    for i,v in pairs(self.m_hideUIList) do
        v:setVisible(is_last)
    end

    if self.m_bSkip then
        start_directing_cb()
    else
        -- ui 다시 집어넣고 연출 시작
    self:doActionReverse(start_directing_cb, 0.2)
    end
end

-------------------------------------
-- function refresh_dragon
-------------------------------------
function UI_GachaResult_Dragon:refresh_dragon(t_dragon_data)
    local vars = self.vars

    local did = t_dragon_data['did']
    local grade = t_dragon_data['grade']
    
    local evolution = t_dragon_data['evolution']

    local is_lock_visible
    if g_hatcheryData.m_isAutomaticFarewell then
        is_lock_visible = (t_dragon_data['grade'] > 3)
    else
        is_lock_visible = (t_dragon_data['grade'] > 2)
    end
    vars['lockMenu']:setVisible(is_lock_visible)

    -- 이름
    local name = t_dragon_data:getDragonNameWithEclv()
    vars['nameLabel']:setString(name .. '-' .. evolutionName(evolution))

    local attr = t_dragon_data:getAttr()
    local role_type = t_dragon_data:getRole()
    local rarity_type = t_dragon_data:getRarity()
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    do -- 능력치
        self:refresh_status(t_dragon_data)
    end

    do -- 희귀도
        vars['rarityNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRarityBtn(rarity_type, vars['rarityNode'], vars['rarityLabel'], t_info)
    end

    do -- 드래곤 속성
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        vars['roleNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['roleNode'], vars['roleLabel'], t_info)
    end

    do -- 드래곤 실리소스
        vars['dragonNode']:removeAllChildren()
        local dragon_animator = UIC_DragonAnimatorDirector_Summon(self)
        vars['dragonNode']:addChild(dragon_animator.m_node)
        
        -- 드래곤 등장 후의 연출
        local function cb()

            -- 등급
            vars['starVisual']:setVisible(true)
            local ani_name = TableDragon:getStarAniName(did, evolution)
            ani_name = ani_name .. grade
            vars['starVisual']:changeAni(ani_name)
            
            -- 배경
            local attr = TableDragon:getDragonAttr(did)

            if self:checkVarsKey('bgNode', attr) then
                local animator = ResHelper:getUIDragonBG(attr, 'idle')
                vars['bgNode']:addChild(animator.m_node)
            end

            -- 연출 이후 드래곤 카드 visible, button on
            local doid = t_dragon_data:getObjectId()
            local card = self.m_lDragonCardList[doid]
            
            if (card) then
                card.root:setVisible(true)
                card.root:setEnabled(true)
                card.vars['clickBtn']:setEnabled(true)
            end

            -- ui 연출
            local function directing_done()
                self.m_isDirecting = false
                
                -- 잠금
                local doid = t_dragon_data:getObjectId()
                self.m_selectedDragonData = g_dragonsData:getDragonDataFromUid(doid)

                if (self.m_selectedDragonData and doid) then
                    self:setLockSprite(self.m_selectedDragonData:getLock())
                else
                    self.m_selectedDragonData = t_dragon_data
                end
                    
                -- 중복 클릭을 방지하기 위해 막았던 버튼을 풀어줌
                vars['okBtn']:setEnabled(true)

                -- 고등급 드래곤 이펙트 on
                for card, rarity_effect in pairs(self.m_tDragonCardEffectTable) do
                    if (card.root:isVisible()) then
                        rarity_effect:runAction(cc.FadeIn:create(0.5))
                    end
                end

                -- @ TUTORIAL : 1-1 end, 알 부화 후 wait 처리
                if (table.count(self.m_lGachaDragonList) <= 0) then
                    if (TutorialManager.getInstance():isDoing()) then
                        TutorialManager.getInstance():nextIfPlayerWaiting()
                    end
                end
            end

            self:doAction(directing_done, false)

            -- 사운드
            if (vars['skipBtn']:isVisible()) then
                SoundMgr:playEffect('UI', 'ui_grow_result')
            end

            -- 마지막 드래곤이었을 경우 스킵 버튼 숨김
            if (table.count(self.m_lGachaDragonList) <= 0) then
                vars['skipBtn']:setVisible(false)
                local is_ad = self.m_tSummonData and self.m_tSummonData['is_ad'] or false
                local is_fp_type = (self.m_type == 'fp')
                local is_ceiling_info_exist = g_hatcheryData:checkCeilingInfoExist()

                vars['againBtn']:setVisible(self.m_canRetry and (not is_ad))
                --vars['ceilingNotiMenu']:setVisible((not is_ad) and (not is_fp_type) and is_ceiling_info_exist)
                vars['ceilingNotiMenu']:setVisible(self.m_bIsVisibleCeilingInfo)
            else
                vars['againBtn']:setVisible(false)
                vars['ceilingNotiMenu']:setVisible(false)
            end
        end

        dragon_animator:bindEgg(self.m_eggID, self.m_eggRes)
        dragon_animator:setDragonAppearCB(cb)
        dragon_animator:setDragonAnimator(t_dragon_data['did'], evolution, nil)
        dragon_animator:startDirecting()

        -- 자코 드래곤 크기 조절 (드래곤 중 태생이 1인 경우 자코)
        if (t_dragon_data.m_objectType == 'dragon') then
            if (TableDragon:isUnderling(t_dragon_data['did'])) then
                local dragon_node = dragon_animator.vars['dragonNode']
                local scale = dragon_node:getScale()
                scale = (scale * 0.7)
                dragon_node:setScale(scale)
            end
        end

        self.m_currDragonAnimator = dragon_animator

        if (self.m_bSkip == true) then
            dragon_animator:forceSkipDirecting()
        end
    end
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_GachaResult_Dragon:refresh_status(t_dragon_data)
    local vars = self.vars

    local is_slime_object = (t_dragon_data.m_objectType == 'slime')

    if is_slime_object then
        vars['atk_label']:setString('0')
        vars['def_label']:setString('0')
        vars['hp_label']:setString('0')
    else
        local dragon_id = t_dragon_data['did']
        local lv = t_dragon_data['lv'] or 1
        local grade = t_dragon_data['grade'] or 1
        local evolution = t_dragon_data['evolution'] or 1
        local eclv = eclv

        -- 능력치 계산기
        local status_calc = MakeDragonStatusCalculator(dragon_id, lv, grade, evolution, eclv)

        vars['atk_label']:setString(status_calc:getFinalStatDisplay('atk'))
        vars['def_label']:setString(status_calc:getFinalStatDisplay('def'))
        vars['hp_label']:setString(status_calc:getFinalStatDisplay('hp'))
    end
end

-------------------------------------
-- function setDragonCardList
-------------------------------------
function UI_GachaResult_Dragon:setDragonCardList()
    self.m_lDragonCardList = {}

    local card_node = self.vars['dragonIconNode']

    local gap = 10								-- 카드 간격
    local total_card = #self.m_lGachaDragonList	-- 총 카드 수
    local card_width = 150						-- 카드 넓이

    -- 시작 좌표
    local pos_x = - 720 - (total_card * gap / 2)

    for i, t_data in pairs(self.m_lGachaDragonList) do
        t_data['lv'] = nil

        -- 드래곤 카드 생성
        local card = UI_DragonCard(t_data)
        
        -- 카드..처리
        card.root:setPositionX(pos_x)
        card.root:setVisible(false)
        card.root:setEnabled(false)
        card_node:addChild(card.root, 2)

        -- 자동작별 시 노출할 경험치 UI 추가
        if (self.m_type == 'cash') or (self.m_type == 'pickup') then
            if g_hatcheryData.m_isAutomaticFarewell and (t_data['grade'] <= 3) then
                local dragon_exp_table = TableDragonExp()
                local exp = dragon_exp_table:getDragonGivingExp(3, 1)	
                local exp_card = UI_ItemCard(700017, exp)
                local tint_action = cca.repeatFadeInOutRuneOpt(3.2)
                card.root:addChild(exp_card.root)
                exp_card:setEnabledClickBtn(false)
                exp_card.root:runAction(tint_action)
            end
        end


        -- 등급에 따른 연출
        if (t_data['grade'] > 3) then
            local rarity_effect = MakeAnimator('res/ui/a2d/card_summon/card_summon.vrp')
            if (t_data['grade'] > 5) then
                rarity_effect:changeAni('summon_mythical', true)
            elseif (t_data['grade'] == 5) then
                rarity_effect:changeAni('summon_regend', true)
            else
                rarity_effect:changeAni('summon_hero', true)
            end
            rarity_effect:setScale(1.7)
            rarity_effect:setAlpha(0)
            card.root:addChild(rarity_effect.m_node)
            self.m_tDragonCardEffectTable[card] = rarity_effect
        end

        -- 카드 클릭시 드래곤을 보여준다.
        card.vars['clickBtn']:registerScriptTapHandler(function()
            if (not self.m_isDirecting) then
                local doid = t_data:getObjectId()
                local refreshed_data = g_dragonsData:getDragonDataFromUid(doid)

                local is_lock_visible
                if g_hatcheryData.m_isAutomaticFarewell then
                    is_lock_visible = (t_data['grade'] > 3)
                else
                    is_lock_visible = (t_data['grade'] > 2)
                end

                self.vars['lockMenu']:setVisible(is_lock_visible)

                if (refreshed_data) then
                    card.m_dragonData = refreshed_data
                    card:refresh_lock()
                    self:setLockSprite(refreshed_data:getLock())
                else
                    refreshed_data = t_data
                end

                self:refresh_dragon(refreshed_data)

    
                self.m_currDragonAnimator:forceSkipDirecting()

                self.m_selectedDragonData = refreshed_data
            end
        end)
        card.vars['clickBtn']:setEnabled(false)

        -- 리스트에 저장 (연출을 위해)
        local itemKey = t_data:getObjectId()

        if (not itemKey) then 
            itemKey = tostring(t_data:getDid()) .. '_' .. tostring(i) 
            t_data['id'] = itemKey
        end

        self.m_lDragonCardList[itemKey] = card

        -- 다음 좌표 계산
        pos_x = pos_x + (card_width + gap)
    end

    doAllChildren(card_node, function(node) node:setCascadeOpacityEnabled(true) end)
end

-------------------------------------
-- function refresh_wealth
-------------------------------------
function UI_GachaResult_Dragon:refresh_wealth()
    local vars = self.vars

    if (self.m_type == 'cash' or self.m_type == 'pickup') then
        -- 캐시
        local cash = g_userData:get('cash')
        vars['diaLabel']:setString(comma_value(cash))

        -- 마일리지
        local mileage = g_userData:get('mileage')
        vars['mileageLabel']:setString(comma_value(mileage))
        
        -- 적립한 마일리지
        local added_mileage = self.m_added_mileage
        vars['mileageLabel2']:setString(comma_value(self.m_added_mileage))
        
        -- 마일리지 상태에 따른 애니메이션 
        local ani_key_1 = g_hatcheryData:getMileageAnimationKey()
        vars['mileageVisual1']:changeAni(ani_key_1, true)

    elseif (self.m_type == 'fp') then
        -- 우정 포인트
        local fp = g_userData:get('fp')
        vars['fpLabel']:setString(comma_value(fp))

    end
end

-------------------------------------
-- function refresh_inventoryLabel
-- @brief
-------------------------------------
function UI_GachaResult_Dragon:refresh_inventoryLabel()
    local vars = self.vars
    local inven_type = 'dragon'
    local dragon_count = g_dragonsData:getDragonsCnt()
    local max_count = g_inventoryData:getMaxCount(inven_type)
    self.vars['inventoryLabel']:setString(string.format('%d/%d', dragon_count, max_count))
end

-------------------------------------
-- function click_inventoryBtn
-- @brief 인벤 확장
-------------------------------------
function UI_GachaResult_Dragon:click_inventoryBtn()
    local item_type = 'dragon'
    local function finish_cb()
        self:refresh_inventoryLabel()
        self:refresh_wealth()
    end

    g_inventoryData:extendInventory(item_type, finish_cb)
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UI_GachaResult_Dragon:click_skipBtn()
    --self.m_bSkip = true
    self.m_bSkipClicked = true

    if (#self.m_lGachaDragonList > 1) then
        local has_myth = false

        for i, t_dragon_data in ipairs(self.m_lGachaDragonListOrg) do
            if (t_dragon_data:getRarity() == 'myth') and (not self.m_animatedDragonIdTable[t_dragon_data['did']]) then
                has_myth = true
                break
            end
        end

        --cclog('test myth is on')
        --has_myth = true

        if (has_myth) then
            self:onSkip_special()

        else
            self:onSkip_standard()

        end
    else
        self.m_bSkip = true
        -- 마지막 드래곤 animator를 띄우고 마지막 연출을 실행한다.
        if self.m_currDragonAnimator then
            self.m_currDragonAnimator:appearDragonAnimator(function() self.m_currDragonAnimator:forceSkipDirecting() end)
            
        end

        -- 스킵을 했다면 스킵 버튼을 가린다.
        self.vars['skipBtn']:setVisible(false)
    end
end


-------------------------------------
-- function onSkip_special
-------------------------------------
function UI_GachaResult_Dragon:onSkip_special()
    local l_myth_dragon = {}
    local top_idx
    local top_grade = 0
    local is_final_index = true
    local showing_idx = 1
    local showing_dragon_data

    for i, t_dragon_data in ipairs(self.m_lGachaDragonListOrg) do
        local rarity = t_dragon_data:getRarity()
        local doid = t_dragon_data:getObjectId()
        local did = t_dragon_data:getDid()
        local card = self.m_lDragonCardList[doid]

        if (top_grade < t_dragon_data['grade']) then  
            top_grade = t_dragon_data['grade']
            top_idx = i
        end

        if (not card) then
            -- Do nothing
        elseif (rarity == 'myth') and (not card.root:isVisible()) and (not self.m_shownMythDid[did]) then
            card.root:setVisible(true)
            card.root:setEnabled(true)
            is_final_index = false
            self:refresh_dragon(t_dragon_data)
            showing_idx = i
            
            self.m_shownMythDid[did] = true

            break
        elseif (not card.root:isVisible()) then
            card.root:setVisible(true)
            card.root:setEnabled(true)
        end
            
        if (card) then
            card.vars['clickBtn']:setEnabled(true)
            if (self.m_tDragonCardEffectTable[card]) then
                self.m_tDragonCardEffectTable[card]:runAction(cc.FadeIn:create(2))
            end
        end

        if (i >= #self.m_lGachaDragonListOrg) then is_final_index = true end
        showing_idx = i
    end

    if (is_final_index) then
        local t_dragon_data

        -- 가장 높은 등급의 드래곤
        if (top_idx) then
            t_dragon_data = self.m_lGachaDragonListOrg[top_idx]
            self.m_lGachaDragonList = {t_dragon_data}
        
        -- 마지막 데이터만 남긴다.
        else
            t_last_data = self.m_lGachaDragonList[#self.m_lGachaDragonList]
            self.m_lGachaDragonList = {t_last_data}

        end

        self.m_bSkip = true

    elseif (showing_idx) then
        self.m_lGachaDragonList = {}

        for i, t_dragon_data in ipairs(self.m_lGachaDragonListOrg) do
            if (i == showing_idx) then
                showing_dragon_data = t_dragon_data
            end

            if (i >= showing_idx) then
                table.insert(self.m_lGachaDragonList, t_dragon_data)
            end
        end
    end

    table.remove(self.m_lGachaDragonList, 1)
    --self:refresh()
    --if (showing_dragon_data) then self:refresh_dragon(showing_dragon_data) end
    
    
    -- 마지막 드래곤 animator를 띄우고 마지막 연출을 실행한다.
    if self.m_currDragonAnimator then
        if (is_final_index) then
            self.m_currDragonAnimator:forceSkipDirecting()

            -- 스킵을 했다면 스킵 버튼을 가린다.
            self.vars['skipBtn']:setVisible(false)

        else
            self.m_currDragonAnimator:appearDragonAnimator()

        end
    end
end


-------------------------------------
-- function onSkip_standard
-------------------------------------
function UI_GachaResult_Dragon:onSkip_standard()
    self.m_bSkip = true

    local grade = 0
    local idx
    for i, t_dragon_data in ipairs(self.m_lGachaDragonListOrg) do 
        if (grade < t_dragon_data['grade']) then  
            grade = t_dragon_data['grade']
            idx = i
        end
    end

    -- 가장 높은 등급의 드래곤
    if (idx) then
        local t_dragon_data = self.m_lGachaDragonListOrg[idx]
        self.m_lGachaDragonList = {t_dragon_data}
        
    -- 마지막 데이터만 남긴다.
    else
        local t_last_data = self.m_lGachaDragonList[#self.m_lGachaDragonList]
        self.m_lGachaDragonList = {t_last_data}

    end

    -- 남은 드래곤 카드들도 오픈한다.
    for _, card in pairs(self.m_lDragonCardList) do
        card.root:setVisible(true)
        card.root:setEnabled(true)
            
        card.vars['clickBtn']:setEnabled(true)
        if (self.m_tDragonCardEffectTable[card]) then
            self.m_tDragonCardEffectTable[card]:runAction(cc.FadeIn:create(2))
        end
    end

    self:refresh()
end


-------------------------------------
-- function click_lockBtn
-------------------------------------
function UI_GachaResult_Dragon:click_lockBtn()
    if (not self.m_selectedDragonData) then
        return
    end

    local doid = self.m_selectedDragonData:getObjectId()
    local is_locked = (not self.m_selectedDragonData:getLock())

    local function callback_function(ret)
        self.vars['lockSprite']:setVisible(is_locked)

        local refreshed_data = g_dragonsData:getDragonDataFromUid(doid)

        -- 연차 뽑기 인 경우
        if (table.count(self.m_lDragonCardList) > 0) then
            local card = self.m_lDragonCardList[doid]
        
            card.m_dragonData = refreshed_data
            card:refresh_lock()
        end

		-- 잠금 안내 팝업
		local msg = is_locked and Str('잠금되었습니다.') or Str('잠금이 해제되었습니다.')
		UIManager:toastNotificationGreen(msg)

        self:setLockSprite(refreshed_data:getLock())


        self.m_selectedDragonData = refreshed_data
    end

    

    g_dragonsData:request_dragonLock(doid, '', is_locked, callback_function)
end
-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_GachaResult_Dragon:click_closeBtn()
    if (self.m_currDragonAnimator and self.m_currDragonAnimator.m_bActingAnimation) then
        return
    end

    local skip_btn = self.vars['skipBtn']
    if (skip_btn:isEnabled() and skip_btn:isVisible()) then
        self:click_skipBtn()
    else
        if (self.m_isClearMasterRoad) then 
            --UI_MasterRoadRewardPopup()
            OpenMasterRoadRewardPopup()
        end
        SoundMgr:playPrevBGM()
        self:close()
    end
end

-------------------------------------
-- function onFocus
-- @brief 탑바가 Lobby UI에 포커싱 되었을 때
-------------------------------------
function UI_GachaResult_Dragon:onFocus()
    self:refresh_wealth()
end

-------------------------------------
-- function setLockSprite
-------------------------------------
function UI_GachaResult_Dragon:setLockSprite(is_locked)
    local vars = self.vars

    
    vars['lockSprite']:setVisible(is_locked)
    if is_locked then
        --vars['lockSprite']:
    else
        
    end
end


function UI_GachaResult_Dragon:isShownAppearAnimation(did)
    local is_shown = false

    if (not did) then return false end

    if (self.m_animatedDragonIdTable and self.m_animatedDragonIdTable[did]) then
        is_shown = true
    end

    return is_shown
end






-------------------------------------
-- function registerOpenNode
-------------------------------------
function UI_GachaResult_Dragon:registerOpenNode(lua_name)
    local node = self.vars[lua_name]
    if (node) then 
        table.insert(self.m_hideUIList, node)
    end
end