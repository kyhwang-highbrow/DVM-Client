local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarSelectSceneListItem
-------------------------------------
UI_ClanWarSelectSceneListItem = class(PARENT,{
        m_structMatchItem = 'StructClanWarMatch',
        m_endTime = 'number',
        m_structMatch = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelectSceneListItem:init(data)
    local vars = self:load('clan_war_match_select_scene_item.ui')
    self.m_structMatchItem = data

    self:initUI()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarSelectSceneListItem:initUI()
    local vars = self.vars
    local struct_match_item = self.m_structMatchItem


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

    for i = 1,3 do
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(StructClanWarMatch.STATE_COLOR['DEFAULT'])
            vars['setResult'..i]:setVisible(true)
        end
    end

    for i, result in ipairs(l_result) do
        local color
        if (result == '1') then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        else
            color = StructClanWarMatch.STATE_COLOR['WIN']
        end
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(color)
            vars['setResult'..i]:setVisible(true)
        end
    end
end


-------------------------------------
-- function setStructMatch
-------------------------------------
function UI_ClanWarSelectSceneListItem:setStructMatch(struct_match, is_my_clan)
    local vars = self.vars
    self.m_structMatch = struct_match
    local struct_match_item = self.m_structMatchItem

    -- ������� ���� ��� ��� �г���
    -- ����� ������ StructClanWar���� ��� �ֱ� ������ ���⼭ �������ش�.
    local defend_enemy_uid = struct_match_item:getDefendEnemyUid()

    if (defend_enemy_uid) then
        local struct_enemy_match_item = self.m_structMatch:getMatchMemberDataByUid(defend_enemy_uid)
        local enemy_nick = 'VS ' .. struct_enemy_match_item:getMyNickName() or ''
        vars['userNameLabel2']:setString(enemy_nick)
        vars['userNameLabel2']:setVisible(true)

        -- ��/��/�� ����
        local l_game_result = struct_enemy_match_item:getGameResult()
        self:setGameResult(l_game_result, is_my_clan)

        -- ���� �ð� ����
        local end_date = struct_enemy_match_item:getEndDate()
        self:setEndTime(end_date)        
    

        -- ���� �г���
        local my_nick = struct_match_item:getMyNickName()
        local defend_state = struct_match_item:getDefendState(struct_enemy_match_item:getAttackState())
        local defend_state_text = struct_match_item:getDefendStateText(defend_state)
        vars['userNameLabel1']:setString(my_nick .. '    ' ..defend_state_text)
    
    else
        local my_nick = struct_match_item:getMyNickName()
        vars['userNameLabel1']:setString(my_nick)
        vars['userNameLabel2']:setString('')
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

    -- ���� ���� �� ���� ���� �ð� = ���� ���� �ð� + 1�ð�
    local cur_time = Timer:getServerTime_Milliseconds()
    local remain_time = (end_time - cur_time)/1000
    if (remain_time > 0) then
        local hour = math.floor(remain_time / 3600)
        local min = math.floor(remain_time / 60) % 60
        vars['lastTimeLabel1']:setString(hour .. ':' .. min)
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

