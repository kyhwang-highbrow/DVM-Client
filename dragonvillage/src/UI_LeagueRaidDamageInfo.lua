local PARENT = UI

-------------------------------------
-- class UI_LeagueRaidDamageInfo
-------------------------------------
UI_LeagueRaidDamageInfo = class(PARENT, {
    m_uiTooltip = '',

    m_damageTable = 'table',

    m_curDamageData = 'table',

    m_ingamedUI = 'UI',

    m_targetMonster = 'Monster',

    m_curLv = 'number',

})

-------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidDamageInfo:init(parent)
    self.m_uiTooltip = nil
    self:load('ingame_boss_hp.ui')

    self.m_ingamedUI = parent
    self.m_curLv = 0

    self.m_damageTable = TABLE:get('table_league_raid_data')
    self:initUI()
    self:refresh()
end


-------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidDamageInfo:findDamageItem(damage)
    local last_item
    local next_item
    local last_total_damage = 0
    local next_total_damage = 0
    local table_item_count = table.count(self.m_damageTable)

    final_lv = 0
    
    if (damage <= self.m_damageTable[1]['hp']) then
        last_item = nil
        next_item = self.m_damageTable[1]
        last_total_damage = 0
        next_total_damage = 100000
        final_lv = 1

        return last_item, next_item, last_total_damage, next_total_damage, final_lv
    end

    for lv = 1, table_item_count do
        final_lv = lv
        local data = self.m_damageTable[lv]

        next_item = data
        next_total_damage = next_total_damage + data['hp']

        if (damage <= next_total_damage) then
            last_item = self.m_damageTable[lv - 1]

            if (not last_item) then
                last_item = next_item
                last_total_damage = 0
            else
                last_total_damage = next_total_damage - next_item['hp']
            end

            break
        end
    end

    -- 마지막 단계 도달했을 때
    -- 마지막 레벨 기준으로 무한 + 해준다
    if (not last_item) then
        next_item = self.m_damageTable[table_item_count]

        while (not last_item) do
            final_lv = final_lv + 1

            next_total_damage = next_total_damage + next_item['hp']

            if (damage <= next_total_damage) then
                last_item = self.m_damageTable[table_item_count - 1]
                last_total_damage = next_total_damage - next_item['hp']
                break
            end
        end
    end

    if (not next_item) then
        
        next_item = self.m_damageTable[table_item_count]
        last_item = self.m_damageTable[table_item_count - 1]
    end

    return last_item, next_item, last_total_damage, next_total_damage, final_lv
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LeagueRaidDamageInfo:initUI()
    local vars = self.vars

    if (vars['bossSkillSprite']) then vars['bossSkillSprite']:setVisible(false) end
    if (vars['bossHpGauge1']) then vars['bossHpGauge1']:setScaleX(0) end

    if (vars['bossHpLabel']) then
        vars['bossHpLabel']:setVisible(true)
        vars['bossHpLabel']:setString('')
    end

    if (vars['bossStatusNode']) then 
        vars['bossStatusNode']:setPosition(125, -25) 
        vars['bossStatusNode']:setScale(0.5) 
    end

    if (self.m_ingamedUI and self.m_ingamedUI.vars) then
        self.m_ingamedUI.vars['runeRewardLabel']:setString(1)
    end
end


function UI_LeagueRaidDamageInfo:refresh()
    local vars = self.vars

    local total_damage = g_leagueRaidData.m_currentDamage
    local last_item, next_item, last_total_damage, next_total_damage, final_lv = self:findDamageItem(total_damage)

    local molecular = next_total_damage - total_damage
    local denominator = (next_total_damage - last_total_damage)

    --cclog(tostring(molecular) .. ' / ' .. tostring(denominator))

    local percentage = math.min(math_abs(molecular / denominator), 1)


    -- 체력 수치 표시
    do
        local str

        if (next_total_damage <= 0) then
            str = string.format('%s (100%%)', comma_value(math_floor(total_damage)))
        else
            str = string.format('%s / %s (%.2f%%)', comma_value(math_floor(total_damage)), comma_value(next_total_damage), percentage * 100)
        end

        vars['bossHpLabel']:setString(str)
    end

    if (self.m_ingamedUI and self.m_ingamedUI.vars) then
        local last_lv = self.m_ingamedUI.vars['runeRewardLabel']:getString()
        local is_run_action = false

        last_lv = pl.stringx.replace(last_lv, 'Lv. ', '')
        last_lv = tonumber(last_lv)

        -- 현재 레벨 0 부터 시작
        local cur_lv = last_item == nil and 0 or last_item['lv']
        local cur_lv_str = cur_lv == 0 and '' or 'Lv. ' .. cur_lv

        if (not self.m_ingamedUI.vars['league_raidMenu']:isVisible() and total_damage > 0) then
            self.m_ingamedUI.vars['runeRewardLabel']:setString(cur_lv_str)
            self.m_ingamedUI.vars['league_raidMenu']:setVisible(true)
            self.m_ingamedUI.vars['boxVisual']:changeAni('box_league_raid_idle', true)
            self.m_ingamedUI.vars['boxVisual']:runAction(cca.buttonShakeAction(2, 2))
            self.m_ingamedUI.vars['clanRaidNode']:setVisible(true)

            is_run_action = true
        end    

        local cur_hp_percentage = vars['bossHpGauge1']:getScaleX()

        if (next_item['lv'] ~= self.m_curLv) then
            self.m_ingamedUI.vars['runeRewardLabel']:setString(next_item['lv'])
            self.m_ingamedUI.vars['boxVisual']:changeAni('box_02', false)
            self.m_ingamedUI.vars['boxVisual']:addAniHandler(function()
                self.m_ingamedUI.vars['boxVisual']:changeAni('box_league_raid_idle', true)
            end)
            --[[
            local skill_overlap = final_lv - self.m_curLv

            -- do boss skill
            for i = 1, skill_overlap do
                if (self.m_targetMonster) then
                    self.m_targetMonster:doSkill(271009)
                end
            end]]

            is_run_action = true
        end

        self.m_ingamedUI.vars['damageLabel']:setString(comma_value(math_floor(total_damage)))

        if (is_run_action) then
            local action = cc.Sequence:create(cc.ScaleTo:create(0.1, 1), cc.ScaleTo:create(0.2, 0.3))
            cca.runAction(self.m_ingamedUI.vars['boxVisual'], action)
        end
    end


    -- 체력바 가감 연출
    if (vars['bossHpGauge1']) then
        --local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, percentage, 1))
        --vars['bossHpGauge1']:stopAllActions()
        --vars['bossHpGauge1']:runAction(cc.EaseIn:create(action, 1))
        vars['bossHpGauge1']:setScaleX(percentage)
    end

	if (vars['bossHpGauge2']) then
        local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, percentage, 1))
        vars['bossHpGauge2']:stopAllActions()
        vars['bossHpGauge2']:runAction(cc.EaseIn:create(action, 2))
    end

    self.m_curLv = final_lv
end


-------------------------------------
-- function getPositionForStatusIcon
-------------------------------------
function UI_LeagueRaidDamageInfo:getPositionForStatusIcon(bLeftFormation, idx)
    local x = 50 * (idx - 1)
    local y = 0
    	
    return x, y
end

-------------------------------------
-- function getScaleForStatusIcon
-------------------------------------
function UI_LeagueRaidDamageInfo:getScaleForStatusIcon()
    return 0.9
end