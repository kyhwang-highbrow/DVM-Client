local PARENT = UI

-------------------------------------
-- class UI_LeagueRaidDamageInfo
-------------------------------------
UI_LeagueRaidDamageInfo = class(PARENT, {
    m_uiTooltip = '',

    m_damageTable = 'table',

    m_curDamageData = 'table',

})

-------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidDamageInfo:init()
    self.m_uiTooltip = nil
    self:load('ingame_boss_hp.ui')

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

    for lv = 1, table_item_count do
        local data = self.m_damageTable[lv]

        next_total_damage = next_total_damage + data['hp']

        if (damage <= next_total_damage) then
            next_item = data

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

    return last_item, next_item, last_total_damage, next_total_damage
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
end


function UI_LeagueRaidDamageInfo:refresh()
    local vars = self.vars

    local is_prepared = g_gameScene and g_gameScene.m_gameWorld and g_gameScene.m_gameWorld.m_logRecorder
    local ingame_damage = is_prepared and math_floor(g_gameScene.m_gameWorld.m_logRecorder:getLog('total_damage_to_enemy')) or 0
    local add_damage = g_leagueRaidData.m_currentDamage and g_leagueRaidData.m_currentDamage or 0
    local total_damage = ingame_damage + add_damage
    local last_item, next_item, last_total_damage, next_total_damage = self:findDamageItem(total_damage)


    local molecular = (total_damage - last_total_damage)
    local denominator = (next_total_damage - last_total_damage)

    cclog(tostring(molecular) .. ' / ' .. tostring(denominator))

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

    -- 체력바 가감 연출
    if (vars['bossHpGauge1']) then
        vars['bossHpGauge1']:setScaleX(percentage)
    end

	if (vars['bossHpGauge2']) then
        local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, percentage, 1))
        vars['bossHpGauge2']:runAction(cc.EaseIn:create(action, 2))
    end
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
    return 1
end