local PARENT = UI

-------------------------------------
-- class UI_EventIncarnationOfSinsEntryPopup
-------------------------------------
UI_EventIncarnationOfSinsEntryPopup = class(PARENT, {
        m_selectedAttr = 'string',
        m_selectStageLv = 'number',
     })
-- 죄악의 화신 최대 스테이지
local STAGE_MAX = 120

-------------------------------------
-- function init
-- @param selected_attr 선택한 속성
-- @param stage_lv 초기 레벨값, nil이면 1
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:init(selected_attr, stage_lv)
    local vars = self:load('event_incarnation_of_sins_ready.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_selectedAttr = selected_attr
    self.m_selectStageLv = stage_lv or 1
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_EventIncarnationOfSinsEntryPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initSlideBar()
    self:refresh()
    self:refreshInfo()
    self:setCurrCount(self.m_selectStageLv, false)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:initUI()
    local vars = self.vars

    -- 시작 위치 초기화
    vars['quantityGuage']:setPercentage(0)
    vars['quantityBtn2']:setPositionX(0)

    -- 속성
    local attr = self.m_selectedAttr
    local icon = IconHelper:getAttributeIconButton(attr)
    vars['attrNode']:addChild(icon)

    -- 랭크
    local rank = g_eventIncarnationOfSinsData:getMyRank(attr)
    if (rank < 0) then
        vars['rankLabel']:setString(Str('순위 없음'))
    else
        local ratio = g_eventIncarnationOfSinsData:getMyRate(attr)
        local percent_text = string.format('%.2f', ratio * 100)
        vars['rankLabel']:setString(Str('{1}위 ({2}%)', comma_value(rank), percent_text))
    end
    
    -- 점수
    local score = g_eventIncarnationOfSinsData:getMyScore(attr)
    if (score < 0) then 
        score = 0
    else
        score = comma_value(score)
    end
    vars['scoreLabel']:setString(Str('{1}점', score))

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
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:initButton()
    local vars = self.vars

    vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['quantityBtn1']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['quantityBtn3']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['quantityBtn4']:registerScriptTapHandler(function() self:click_maxBtn() end)
    vars['prevBtn']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['nextBtn']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['synastryInfoBtn']:setVisible(false)
    --vars['resetBtn']:registerScriptTapHandler(function() self:click_resetBtn() end)
end

-------------------------------------
-- function initSlideBar
-- @brief 터치 레이어 생성
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:initSlideBar()
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
function UI_EventIncarnationOfSinsEntryPopup:onTouchBegan(touch, event)
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
function UI_EventIncarnationOfSinsEntryPopup:onTouchMoved(touch, event)
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
function UI_EventIncarnationOfSinsEntryPopup:setCurrCount(count, ignore_slider_bar)
    local vars = self.vars
    local count = math_clamp(count, 1, STAGE_MAX)
    
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
function UI_EventIncarnationOfSinsEntryPopup:onTouchEnded(touch, event)
    self:setLevel()
end

-------------------------------------
-- function getMaxHp
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:getMaxHp(stage_lv)
    local stage_id = 1500000 + stage_lv
    local table_clan_raid = TABLE:get('table_clan_dungeon')
    local max_hp = table_clan_raid[stage_id]['boss_hp']
    return max_hp
end

-------------------------------------
-- function refreshInfo
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:refreshInfo()
    local vars = self.vars   
    
    local stage_lv = self.m_selectStageLv
    local stage_id = 1500000 + stage_lv
    local max_hp = self:getMaxHp(stage_lv)
    local stage_hp = max_hp

    local hp_ratio = 100
    vars['levelLabel']:setString(Str('Lv.{1}', comma_value(stage_lv)))
    vars['hpLabel2']:setString(Str('{1}/{2}', comma_value(stage_hp), comma_value(max_hp)))

    local hp_ratio_str = string.format('%0.2f%%', hp_ratio)
    vars['hpLabel']:setString(hp_ratio_str, false)
    vars['bossHpGauge1']:setPercentage(hp_ratio)

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
function UI_EventIncarnationOfSinsEntryPopup:refreshBoss(attr)
    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:refresh()

end

------------------------
-- function getCostumedStructClanRaid
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:getCostumedStructClanRaid()
    local struct_clan_raid = StructClanRaid()
    struct_clan_raid['clan_raid_type'] = 'training'                        -- 타입 지정 (연습 모드인지 구분 용도)
    struct_clan_raid['attr'] = self.m_selectedAttr                         -- 연습 모드에서 커스텀한 속성
    
    local selected_stage_id = self.m_selectStageLv + 1500000
    struct_clan_raid['stage'] = selected_stage_id
    return struct_clan_raid
end

-------------------------------------
-- function click_minusBtn
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:click_minusBtn()
    self:setCurrCount(self.m_selectStageLv - 1, false)
    self:setLevel()
end

-------------------------------------
-- function click_plusBtn
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:click_plusBtn()
    self:setCurrCount(self.m_selectStageLv + 1, false)
    self:setLevel()
end

-------------------------------------
-- function setLevel
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:setLevel()
    self:refreshInfo()
end

-------------------------------------
-- function click_maxBtn
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:click_maxBtn()
    self:setCurrCount(STAGE_MAX)
    self:refreshInfo()
end

-------------------------------------
-- function click_attrBtn
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:click_attrBtn(ind)
    local l_attr = getAttrOrderMap()
    self.m_selectedAttr = l_attr[ind]
end

-------------------------------------
-- function click_resetBtn
-------------------------------------
function UI_EventIncarnationOfSinsEntryPopup:click_resetBtn()
    local cur_attr = g_clanData:getCurSeasonBossAttr()

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
function UI_EventIncarnationOfSinsEntryPopup:click_readyBtn()
    
    -- 스테이지 정보 세팅
    local struct_clan_raid = g_clanRaidData.m_structClanRaid or StructClanRaid()
    local max_hp = self:getMaxHp(self.m_selectStageLv)
    local selected_stage_id = self.m_selectStageLv + 1500000
    
    struct_clan_raid['clan_raid_type'] = 'incarnation_of_sins'       
    struct_clan_raid['attr'] = self.m_selectedAttr              -- 현재 선택된 속성
    struct_clan_raid['stage'] = selected_stage_id               -- 선택한 레벨
    struct_clan_raid['hp'] = SecurityNumberClass(max_hp)        -- 선택한 레벨의 체력
    struct_clan_raid['max_hp'] = SecurityNumberClass(max_hp)
    
    g_clanRaidData.m_structClanRaid = struct_clan_raid

    -- 스테이지 시간 세팅


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
UI:checkCompileError(UI_EventIncarnationOfSinsEntryPopup)







