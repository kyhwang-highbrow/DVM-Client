local PARENT = UI
-------------------------------------
-- class UI_EventDealkingEntryPopup
-------------------------------------
UI_EventDealkingEntryPopup = class(PARENT, {
        m_selectedAttr = 'string',
        m_bossType = 'number',
        m_stageId = 'number',
     })

-------------------------------------
-- function init
-- @param selected_attr 선택한 속성
-------------------------------------
function UI_EventDealkingEntryPopup:init(selected_attr, selected_boss)
    self.m_selectedAttr = selected_attr
    self.m_bossType = selected_boss
    self.m_stageId = g_eventDealkingData:getEventDealkingStageId(selected_boss, selected_attr)

    local vars = self:load('event_dealking_ready.ui')
    UIManager:open(self, UIManager.SCENE)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_EventDealkingEntryPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    
    self:refresh()
    self:refreshInfo()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EventDealkingEntryPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealkingEntryPopup:initUI()
    local vars = self.vars
    local stage_id = self.m_stageId
    local monster_id_list = g_stageData:getMonsterIDList(stage_id)
    local boss_id = monster_id_list[1]

    -- 보스 이름
    local boss_name = TableMonster():getMonsterName(boss_id)
    vars['bossNameLabel']:setString(boss_name)

    -- 속성
    local attr = self.m_selectedAttr
    local icon = IconHelper:getAttributeIconButton(attr)
    vars['attrNode']:addChild(icon)

    -- 랭크
    local rank = g_eventDealkingData:getMyRank(attr)
    if (rank < 0) then
        vars['rankLabel']:setString(Str('순위 없음'))
    else
        local ratio = g_eventDealkingData:getMyRate(attr)
        local percent_text = string.format('%.2f', ratio * 100)
        vars['rankLabel']:setString(Str('{1}위 ({2}%)', comma_value(rank), percent_text))
    end
    
    -- 점수
    local score = g_eventDealkingData:getMyScore(attr)
    if (score < 0) then 
        score = 0
    else
        score = comma_value(score)
    end
    vars['scoreLabel']:setString(Str('{1}점', score))


    -- 몬스터 스파인
    for _, mid in ipairs(monster_id_list) do
        local res, attr, evolution = TableMonster:getMonsterRes(mid)
        local animator = AnimatorHelper:makeMonsterAnimator(res, attr, evolution)
        if (animator) then
--[[             local zOrder = WORLD_Z_ORDER.BOSS
            local idx = getDigit(mid, 10, 1)
            if (idx == 1) and (mid == boss_mid) then
                zOrder = WORLD_Z_ORDER.BOSS     
            elseif (idx == 1) then
                zOrder = WORLD_Z_ORDER.BOSS + 1
            elseif (idx == 7) then
                zOrder = WORLD_Z_ORDER.BOSS
            else
                zOrder = WORLD_Z_ORDER.BOSS + 1 + 7 - idx
            end ]]

            animator:setScale(0.5)
            vars['bossNode']:addChild(animator.m_node)
            animator:changeAni('idle', true)
        end
    end

    do -- 보너스 속성
        local bonus_str, map_attr = 
            TableDealkingBuff:getInstance():getDealkingBonusInfo(self.m_stageId, self.m_selectedAttr, true)
        for k, v in pairs(map_attr) do
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIconButton(k)
            local target_node = vars['bonusTipsNode']
            target_node:removeAllChildren()
            target_node:addChild(icon)
        end

        -- 보너스 속성        
        vars['bonusTipsDscLabel']:setString(bonus_str)    
    end

    do -- 패널티 속성  
        local penalty_str, map_attr = 
            TableDealkingBuff:getInstance():getDealkingBonusInfo(self.m_stageId, self.m_selectedAttr, false)
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

        -- 패널티 속성      
        vars['panaltyTipsDscLabel']:setString(penalty_str)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventDealkingEntryPopup:initButton()
    local vars = self.vars
    vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['synastryInfoBtn']:setVisible(false)
end

-------------------------------------
-- function getMaxHp
-------------------------------------
function UI_EventDealkingEntryPopup:getMaxHp(stage_lv)
    local stage_id = 1500000 + stage_lv
    local table_clan_raid = TABLE:get('table_clan_dungeon')
    local max_hp = table_clan_raid[stage_id]['boss_hp']
    return max_hp
end

-------------------------------------
-- function refreshInfo
-------------------------------------
function UI_EventDealkingEntryPopup:refreshInfo()
    local vars = self.vars   
    

--[[     local max_hp = self:getMaxHp(stage_lv)
    local stage_hp = max_hp

    local hp_ratio = 100
    vars['levelLabel']:setString(Str('Lv.{1}', comma_value(stage_lv)))
    vars['hpLabel2']:setString(Str('{1}/{2}', comma_value(stage_hp), comma_value(max_hp)))

    local hp_ratio_str = string.format('%0.2f%%', hp_ratio)
    vars['hpLabel']:setString(hp_ratio_str, false)
    vars['bossHpGauge1']:setPercentage(hp_ratio) ]]
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventDealkingEntryPopup:refresh()
    local vars = self.vars
end

------------------------
-- function getCostumedStructClanRaid
-------------------------------------
function UI_EventDealkingEntryPopup:getCostumedStructClanRaid()
    local struct_clan_raid = StructClanRaid()
    struct_clan_raid['clan_raid_type'] = 'training'                        -- 타입 지정 (연습 모드인지 구분 용도)
    struct_clan_raid['attr'] = 'earth'                         -- 연습 모드에서 커스텀한 속성
    struct_clan_raid['stage'] = 1500001
    return struct_clan_raid
end

-------------------------------------
-- function click_attrBtn
-------------------------------------
function UI_EventDealkingEntryPopup:click_attrBtn(ind)
    local l_attr = getAttrOrderMap()
    self.m_selectedAttr = l_attr[ind]
end

-------------------------------------
-- function click_applyBtn
-------------------------------------
function UI_EventDealkingEntryPopup:click_readyBtn()
--[[     
    -- 스테이지 정보 세팅
    local struct_clan_raid = g_clanRaidData.m_structClanRaid or StructClanRaid()
    local max_hp = self:getMaxHp(self.m_selectStageLv)
    local selected_stage_id = self.m_selectStageLv + 1500000
    
    struct_clan_raid['clan_raid_type'] = 'incarnation_of_sins'       
    struct_clan_raid['attr'] = self.m_selectedAttr              -- 현재 선택된 속성
    struct_clan_raid['stage'] = selected_stage_id               -- 선택한 레벨
    struct_clan_raid['hp'] = SecurityNumberClass(max_hp)        -- 선택한 레벨의 체력
    struct_clan_raid['max_hp'] = SecurityNumberClass(max_hp)
    
    g_clanRaidData.m_structClanRaid = struct_clan_raid ]]

    -- 스테이지 시간 세팅
    -- UI_ReadySceneNew UI가 열려있을 경우, 닫고 다시 연다
    local is_opend, idx, ui = UINavigatorDefinition:findOpendUI('UI_ReadySceneNew')
    if (is_opend == true) then
        ui:close()
        UI_ReadySceneNew(self.m_stageId, nil)
        self:close()
    else
        UI_ReadySceneNew(self.m_stageId, nil)
    end
end

--@CHECK
UI:checkCompileError(UI_EventDealkingEntryPopup)







