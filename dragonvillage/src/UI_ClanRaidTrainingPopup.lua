local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaidTrainingPopup
-------------------------------------
UI_ClanRaidTrainingPopup = class(PARENT, {
        m_curStageLv = 'number',
        m_curHp = 'number',

        m_selectStageLv = 'number',
        m_selectedAttr = 'string',
        m_selectedHp = 'number',
        m_isMaxHp = 'boolean',

         m_hpRadioBtn = 'UIC_RadioBtn',
     })

-- 1903026 @jhakim 150층까지 있지만 너무 많은 스테이지를 보여주지 않음
local STAGE_MAX = 100

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidTrainingPopup:init()
    local vars = self:load('clan_raid_training.ui')
    UIManager:open(self, UIManager.POPUP)

    local struct_clan_raid =  g_clanRaidData:getClanRaidStruct()
    self.m_curStageLv = struct_clan_raid:getLv()
    self.m_curHp = struct_clan_raid:getHp()
    
    self.m_isMaxHp = nil
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanRaidTrainingPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initTab()
    self:initRadioBtn()
    self:initButton()
    self:initSlideBar()
    self:refresh(true)
    self:refreshInfo(self.m_curStageLv, self.m_curHp)
    self:setCurrCount(self.m_curStageLv, false)
    self.m_selectStageLv = self.m_curStageLv
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanRaidTrainingPopup:initTab()
    local vars = self.vars
    self:addTab('earth', vars['attrBtn1'])
    self:addTab('water', vars['attrBtn2'])
    self:addTab('fire', vars['attrBtn3'])
    self:addTab('light', vars['attrBtn4'])
    self:addTab('dark', vars['attrBtn5'])

    local cur_attr = g_clanData:getCurSeasonBossAttr()
    self:setTab(cur_attr)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidTrainingPopup:initUI()
    local vars = self.vars
    --vars['actingPowerLabel']:setString(Str('{1}/{2}', g_clanRaidData.m_triningTicketCnt, g_clanRaidData.m_triningTicketMaxCnt))

    -- 시작 위치 초기화
    vars['quantityGuage']:setPercentage(0)
    vars['quantityBtn2']:setPositionX(0)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanRaidTrainingPopup:onChangeTab(tab, first)
    local vars = self.vars
    self.m_selectedAttr = tab
    self:refreshBoss(self.m_selectedAttr)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidTrainingPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_applyBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['quantityBtn1']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['quantityBtn3']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['quantityBtn4']:registerScriptTapHandler(function() self:click_maxBtn() end)
    vars['resetBtn']:registerScriptTapHandler(function() self:click_resetBtn() end)
    vars['synastryInfoBtn']:registerScriptTapHandler(function() UI_HelpClan('clan_dungeon','clan_dungeon_summary', 'cldg_attr_bonus') end)
end

-------------------------------------
-- function initSlideBar
-- @brief 터치 레이어 생성
-------------------------------------
function UI_ClanRaidTrainingPopup:initSlideBar()
    local node = self.vars['sliderBar']

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function UI_ClanRaidTrainingPopup:onTouchBegan(touch, event)
    local vars = self.vars

    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['quantityBtn2']:getBoundingBox()
    local local_location = vars['quantityBtn2']:getParent():convertToNodeSpace(location)
    local is_contain = cc.rectContainsPoint(bounding_box, local_location)

    return is_contain
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function UI_ClanRaidTrainingPopup:onTouchMoved(touch, event)
    local vars = self.vars

    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['quantityBtn2']:getBoundingBox()
    local local_location = vars['quantityBtn2']:getParent():convertToNodeSpace(location)

    local content_size = vars['quantityBtn2']:getParent():getContentSize()

    local x = math_clamp(local_location['x'], 0, content_size['width'])
    local percentage = x / content_size['width']

    vars['quantityBtn2']:stopAllActions()
    vars['quantityBtn2']:setPositionX(x)

    vars['quantityGuage']:stopAllActions()
    vars['quantityGuage']:setPercentage(percentage * 100)

    local count = math_floor(STAGE_MAX * percentage)
    local ignore_slider_bar = true
    self:setCurrCount(count, ignore_slider_bar)
end

-------------------------------------
-- function setCurrCount
-------------------------------------
function UI_ClanRaidTrainingPopup:setCurrCount(count, ignore_slider_bar)
    local vars = self.vars
    local count = math_clamp(count, 1, STAGE_MAX)
    
    if (self.m_selectStageLv == count) then
        return
    end

    self.m_selectStageLv = count

    -- 퍼센트 지정
    if (not ignore_slider_bar) then
        local percentage = (self.m_selectStageLv / STAGE_MAX) * 100
        vars['quantityGuage']:stopAllActions()
        vars['quantityGuage']:runAction(cc.ProgressTo:create(0.2, percentage))
    
        local pos_x = (self.m_selectStageLv / STAGE_MAX) * 300
        vars['quantityBtn2']:stopAllActions()
        vars['quantityBtn2']:runAction(cc.MoveTo:create(0.2, cc.p(pos_x, 0)))
    end

    -- 지원 레벨
    vars['quantityLabel']:setString(comma_value(self.m_selectStageLv))
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function UI_ClanRaidTrainingPopup:onTouchEnded(touch, event)
    self:setLevel()
end

-------------------------------------
-- function getMaxHp
-------------------------------------
function UI_ClanRaidTrainingPopup:getMaxHp(stage_lv)
    local stage_id = 1500000 + stage_lv
    local table_clan_raid = TABLE:get('table_clan_dungeon')
    local max_hp = table_clan_raid[stage_id]['boss_hp']
    return max_hp
end

-------------------------------------
-- function refreshInfo
-------------------------------------
function UI_ClanRaidTrainingPopup:refreshInfo(lv, hp)
    local vars = self.vars   
    
    local stage_lv = self.m_selectStageLv
    if (not self.m_selectStageLv) then
        stage_lv = self.m_curStageLv
    end

    if (lv) then
        stage_lv = lv
    end

    local stage_id = 1500000 + stage_lv
    local max_hp = self:getMaxHp(stage_lv)
    local stage_hp = max_hp

    if (self.m_isMaxHp == false) then
        stage_hp = max_hp * 0.05
    end

    if (hp) then
        stage_hp = hp
    end

    local hp_ratio = stage_hp/max_hp * 100
    self.m_selectedHp = stage_hp
    vars['lvLabel']:setString(Str('Lv.{1}', comma_value(stage_lv)))
    vars['hpLabel2']:setString(Str('{1}/{2}', comma_value(stage_hp), comma_value(max_hp)))

    local hp_ratio_str = string.format('%0.2f%%', hp_ratio)
    vars['hpLabel1']:setString(hp_ratio_str, false)
    vars['hpGauge']:setPercentage(hp_ratio)
    
    local is_final_blow = (hp_ratio <= 5) 
    vars['fbVisual']:setVisible(is_final_blow)

    local struct_clan_raid = self:getCostumedStructClanRaid()
    
    -- 보너스 속성    
    local str, map_attr = struct_clan_raid:getBonusSynastryInfo()
    vars['bonusTipsDscLabel']:setString(str)
    
    -- 패널티 속성  
    local str, map_attr = struct_clan_raid:getPenaltySynastryInfo()
    vars['panaltyTipsDscLabel']:setString(str)

end

-------------------------------------
-- function refreshBoss
-------------------------------------
function UI_ClanRaidTrainingPopup:refreshBoss(attr)
    local vars = self.vars
    
    local icon = IconHelper:getAttributeIconButton(attr)
    vars['attrNode']:removeAllChildren()
    vars['attrNode']:addChild(icon)

    vars['bossNode']:removeAllChildren()

    local l_monster = TableStageDesc():getMonsterIDList_ClanMonster(attr)
    for _, mid in ipairs(l_monster) do
        local res, attr, evolution = TableMonster:getMonsterRes(mid)
        local animator = AnimatorHelper:makeMonsterAnimator(res, attr, evolution)
        if (animator) then
            local zOrder = WORLD_Z_ORDER.BOSS
            local idx = getDigit(mid, 10, 1)
            if (idx == 1) and (mid == boss_mid) then
                zOrder = WORLD_Z_ORDER.BOSS     
            elseif (idx == 1) then
                zOrder = WORLD_Z_ORDER.BOSS + 1
            elseif (idx == 7) then
                zOrder = WORLD_Z_ORDER.BOSS
            else
                zOrder = WORLD_Z_ORDER.BOSS + 1 + 7 - idx
            end
            vars['bossNode']:addChild(animator.m_node, zOrder)

            animator:changeAni('idle', true)
        end
    end

    local struct_clan_raid = self:getCostumedStructClanRaid()
    
    -- 보너스 속성
    local str, map_attr = struct_clan_raid:getBonusSynastryInfo()
    for k, v in pairs(map_attr) do
        -- 속성 아이콘
        local icon = IconHelper:getAttributeIconButton(k)
        local target_node = vars['bonusTipsNode']
        target_node:removeAllChildren()
        target_node:addChild(icon)
    end

    -- 패널티 속성  
    local str, map_attr = struct_clan_raid:getPenaltySynastryInfo()
    local cnt = table.count(map_attr)
    local idx = 0

    vars['panaltyTipsNode']:removeAllChildren()
    for i=1,4 do
        vars['panaltyTipsNode'..i]:removeAllChildren()
    end
    for k, v in pairs(map_attr) do
        idx = idx + 1
        -- 속성 아이콘
        local icon = IconHelper:getAttributeIconButton(k)
        local target_node = (cnt == 1) and 
                            vars['panaltyTipsNode'] or 
                            vars['panaltyTipsNode'..idx]
        target_node:addChild(icon)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidTrainingPopup:refresh(force)

end

------------------------
-- function getCostumedStructClanRaid
-------------------------------------
function UI_ClanRaidTrainingPopup:getCostumedStructClanRaid()
    local struct_clan_raid = StructClanRaid()
    struct_clan_raid['clan_raid_type'] = 'training'                        -- 타입 지정 (연습 모드인지 구분 용도)
    struct_clan_raid['attr'] = self.m_selectedAttr                         -- 연습 모드에서 커스텀한 속성
    
    local selected_stage_id 
    if (self.m_selectStageLv) then
        selected_stage_id = self.m_selectStageLv + 1500000
    else
        selected_stage_id = self.m_curStageLv + 1500000
    end
    struct_clan_raid['stage'] = selected_stage_id
    return struct_clan_raid
end
-------------------------------------
-- function initRadioBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:initRadioBtn()
    local vars = self.vars

    local radio_button = UIC_RadioButton()
    radio_button:setChangeCB(function(hp_type)          
        self.m_isMaxHp = (hp_type == 'maxHp')
        self:refreshInfo()
    end)

    local btn = vars['contentBtn1']
    local label = vars['contentSprite1']
	radio_button:addButton('maxHp', btn, label)

    local btn = vars['contentBtn2']
    local label = vars['contentSprite2']
	radio_button:addButton('finalBlow', btn, label)

    self.m_hpRadioBtn = radio_button
    -- 디폴트로 일반 강화 선택
    --radio_button:setSelectedButton('maxHp')  
end

-------------------------------------
-- function click_minusBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_minusBtn()
    self:setCurrCount(self.m_selectStageLv - 1, false)
    self:setLevel()
end

-------------------------------------
-- function click_plusBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_plusBtn()
    self:setCurrCount(self.m_selectStageLv + 1, false)
    self:setLevel()
end

-------------------------------------
-- function setLevel
-------------------------------------
function UI_ClanRaidTrainingPopup:setLevel()
    if (self.m_isMaxHp == nil) then
        self.m_hpRadioBtn:setSelectedButton('maxHp') -- 리셋 후 레벨 조정시 라디오 버튼 - 최대생명력 체크
    end
    self:refreshInfo()
end

-------------------------------------
-- function click_maxBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_maxBtn()
    self:setCurrCount(STAGE_MAX)
    self:refreshInfo()
end

-------------------------------------
-- function click_attrBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_attrBtn(ind)
    local l_attr = getAttrOrderMap()
    self.m_selectedAttr = l_attr[ind]
end

-------------------------------------
-- function click_resetBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_resetBtn()
    local cur_attr = g_clanData:getCurSeasonBossAttr()

    self.m_selectedAttr = cur_attr
    self.m_selectedHp = self.m_curHp
    self.m_isMaxHp = nil

    self:setTab(cur_attr)
    self:refreshInfo(self.m_curStageLv, self.m_curHp)
    self:setCurrCount(self.m_curStageLv, false)
    
    --  라디오 버튼 리셋
    self.m_hpRadioBtn:inactivate('maxHp')
    self.m_hpRadioBtn:inactivate('finalBlow')
    self.m_hpRadioBtn.m_selectedButton = '' 
end

-------------------------------------
-- function click_applyBtn
-------------------------------------
function UI_ClanRaidTrainingPopup:click_applyBtn()

    -- 서버 데이터가 들고 있는 StructClanRaid 정보에 커스텀한 정보를 덮어씌움
    local training_info = g_clanRaidData.m_structClanRaid    
    training_info['clan_raid_type'] = 'training'                        -- 타입 지정 (연습 모드인지 구분 용도)
    training_info['attr'] = self.m_selectedAttr                         -- 연습 모드에서 커스텀한 속성
    training_info['hp'] = SecurityNumberClass(self.m_selectedHp)        -- 연습 모드에서 커스텀한 체력
    training_info['max_hp'] = SecurityNumberClass(self:getMaxHp(self.m_selectStageLv))
    
    local selected_stage_id = self.m_selectStageLv + 1500000
    training_info['stage'] = selected_stage_id                          -- 연습 모드에서 커스텀한 스테이지
    
    g_clanRaidData.m_structClanRaid = training_info

    -- UI_ReadySceneNew UI가 열려있을 경우, 닫고 다시 연다
    local is_opend, idx, ui = UINavigatorDefinition:findOpendUI('UI_ReadySceneNew')
    if (is_opend == true) then
        ui:close()
        UI_ReadySceneNew(selected_stage_id, nil)
        self:close()
    else
        UI_ReadySceneNew(selected_stage_id, nil)
    end
     
end

--@CHECK
UI:checkCompileError(UI_ClanRaidTrainingPopup)







