local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarSelectSceneListItem
-------------------------------------
UI_ClanWarSelectSceneListItem = class(PARENT,{
        m_structMatch = 'StructClanWarMatch',
        m_endTime = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelectSceneListItem:init(data)
    local vars = self:load('clan_war_match_select_scene_item.ui')
    self.m_structMatch = data

    self:initUI()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarSelectSceneListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarSelectSceneListItem:setGameResult(l_result)
    local vars = self.vars
    if (not l_result) then
        return
    end
    --[[
        {'1', '0', '1'}
    --]]
    for i, result in ipairs(l_result) do
        local color
        if (result == '0') then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        else
            color = StructClanWarMatch.STATE_COLOR['WIN']
        end
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(color)
        end
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanWarSelectSceneListItem:update(dt)
    local vars = self.vars
    local end_time = self.m_endTime

    if (not end_time) then
        vars['lastTimeLabel1']:setString('')
        return
    end

    -- 공격 끝날 때 까지 남은 시간 = 공격 시작 시간 + 1시간
    local cur_time = Timer:getServerTime_Milliseconds()
    local remain_time = end_time - cur_time 
    if (remain_time > 0) then
        local minutes = math.floor(remain_time / 3600)
        local seconds = math.floor(remain_time / 60) % 60
        vars['lastTimeLabel1']:setString(minutes .. ':' .. seconds)
    else
        vars['lastTimeLabel1']:setString('')
    end
end

-------------------------------------
-- function setEndDate
-------------------------------------
function UI_ClanWarSelectSceneListItem:setEndTime(end_time)
    self.m_endTime = end_time or 0
end

