local PARENT = UI_ReadySceneNew
-------------------------------------
-- class UI_ReadySceneWorldRaid
-------------------------------------
UI_ReadySceneWorldRaid = class(PARENT,{
})

-------------------------------------
--- @function initUI
-------------------------------------
function UI_ReadySceneWorldRaid:init()
    g_worldRaidData:resetIngameData()
end

-------------------------------------
--- @function initUI
-------------------------------------
function UI_ReadySceneWorldRaid:initUI()
    local vars = self.vars

    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local vars = self.vars
        local type = TableDrop:getStageStaminaType(self.m_stageID)
        local icon = IconHelper:getStaminaInboxIcon(type)
        vars['staminaNode']:addChild(icon)
    end

    -- 배경
    local attr = TableStageData:getStageAttr(self.m_stageID)
    if self:checkVarsKey('bgNode', attr) then
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    do -- 각종 버튼 visible
        vars['synastryTipsMenu']:setVisible(true)
        vars['synastryInfoBtn']:setVisible(false)
        vars['attrInfoSprite']:setVisible(false)
        vars['attrInfoBtn']:setVisible(false)
    end
    
    do -- 보너스 속성
        local str, map_attr = g_worldRaidData:getWorldRaidBuff()
        vars['bonusTipsDscLabel']:setString(str)
        for k, v in pairs(map_attr) do
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIconButton(k)
            local target_node = vars['bonusTipsNode']
            target_node:addChild(icon)
        end
    end

    do -- 페널티 속성
        local str, map_attr = g_worldRaidData:getWorldRaidDebuff()
        vars['panaltyTipsDscLabel']:setString(str)
        local cnt = table.count(map_attr)
        local idx = 0
        for k, v in pairs(map_attr) do
            idx = idx + 1
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIconButton(k)
            local target_node = (cnt == 1) and vars['panaltyTipsNode'] or vars['panaltyTipsNode'..idx]
            target_node:addChild(icon)
        end
    end

    -- 연속전투 불가능할때 UI 처리        
    do
        vars['autoStartOnBtn']:setVisible(false)
        vars['manageBtn']:setPositionX(80)
        vars['teamBonusBtn']:setPositionX(-80)
    end
end

-------------------------------------
--- @function networkGameStart
--- @breif
-------------------------------------
function UI_ReadySceneWorldRaid:networkGameStart()
    local function finish_cb(game_key)
        self:replaceGameScene(game_key)
    end


    local world_raid_id = self.m_subInfo['world_raid_id']
    --local deck_name = g_deckData:getSelectedDeckName()
    g_worldRaidData:request_WorldRaidStart(world_raid_id, self.m_stageID, finish_cb)
end