local PARENT = UI
-------------------------------------
--- @class UI_WorldRaidAttrPopup
-------------------------------------
UI_WorldRaidAttrPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaidAttrPopup:init()
    local vars = self:load('world_raid_attr_popup.ui')
    UIManager:open(self, UIManager.POPUP)

	-- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
    self:doActionReset()
    self:doAction(nil, false)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_WorldRaidAttrPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidAttrPopup:initUI()
    local vars = self.vars

    local world_raid_id = g_worldRaidData:getWorldRaidId()
    local stage_id = g_worldRaidData:getWorldRaidStageId()
    local monster_id_list = g_stageData:getMonsterIDList(stage_id)
    local boss_id = monster_id_list[1]
    local attr = TableStageData:getStageAttr(stage_id)

    -- -- -- 보스 이름
    -- local boss_name = TableMonster():getMonsterName(boss_id)
    -- vars['bossNameLabel']:setString(boss_name)
    vars['bossNameLabel']:setVisible(false)
    vars['attrNode']:setVisible(false)
    vars['bossAttrLabel']:setVisible(false)
    vars['bossLevelLabel']:setVisible(false)
    
    -- do -- 보스 속성    
    --     local icon = IconHelper:getAttributeIconButton(attr)
    --     vars['attrNode']:removeAllChildren()
    --     vars['attrNode']:addChild(icon)
    -- end

    -- do -- 속성        
    --     vars['bossAttrLabel']:setString(dragonAttributeName(attr))
    -- end

    -- do -- 보스 레벨
    --     local level = TableStageData:getStageLevel(stage_id) - 1
    --     vars['bossLevelLabel']:setString(string.format('Lv.%d', level))
    -- end

    do -- 보너스 속성
        local buff_key = TableWorldRaidInfo:getInstance():getBuffKey(world_raid_id)
        local bonus_str, map_attr = TableContentAttr:getInstance():getBonusInfo(buff_key, true)
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
        local debuff_key = TableWorldRaidInfo:getInstance():getDebuffKey(world_raid_id)
        local penalty_str, map_attr = TableContentAttr:getInstance():getBonusInfo(debuff_key , false)
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

    -- do  -- 몬스터 스파인
    --     for _, mid in ipairs(monster_id_list) do
    --         local res, attr, evolution = TableMonster:getMonsterRes(mid)
    --         local animator = AnimatorHelper:makeMonsterAnimator(res, attr, evolution)
    --         if (animator) then
    --             ---animator:setScale(0.5)
    --             vars['bossNode']:addChild(animator.m_node)
    --             animator:changeAni('idle', true)
                
    --             --animator:setPositionY(-800)
    --             local action = cc.EaseExponentialOut:create(cc.MoveTo:create(1.0, cc.p(0, 0)))
    --             animator:stopAllActions()
    --             animator:runAction(action)
    --         end
    --     end
    -- end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaidAttrPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function () self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaidAttrPopup:refresh()
	local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_WorldRaidAttrPopup)
