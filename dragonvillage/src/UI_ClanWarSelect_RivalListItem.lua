local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarSelect_RivalListItem
-- @brief 클랜전 공격 대상 선택 화면에서 상대방 리스트
-------------------------------------
UI_ClanWarSelect_RivalListItem = class(PARENT,{
        m_structMatchItem = 'StructClanWarMatch',
        m_endTime = 'number',

        m_noTime = 'boolean',
        m_hasResult = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelect_RivalListItem:init(data)
    local vars = self:load('clan_war_match_select_item_rival_new.ui')
    self.m_structMatchItem = data

    self:initUI()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarSelect_RivalListItem:initUI()
    local vars = self.vars
    local struct_match_item = self.m_structMatchItem
end

-------------------------------------
-- function setNoTime
-------------------------------------
function UI_ClanWarSelect_RivalListItem:setNoTime()
    self.m_noTime = true
end

-------------------------------------
-- function setStructMatch
-------------------------------------
function UI_ClanWarSelect_RivalListItem:setStructMatch(is_my_clan)
    local vars = self.vars
    local struct_match_item = self.m_structMatchItem

    if (not struct_match_item) then
        return
    end

    do -- 방어자 정보 (이 리스트 아이템의 주인이 방어자)
        do -- 닉네임
            local name = struct_match_item:getMyNickName() or ''
            vars['defenseNameLabel']:setString(name)
        end

        do -- 티어 아이콘
            local struct_user_info_clan = struct_match_item:getUserInfo()
            local icon
            if (struct_user_info_clan) then
	            icon = struct_user_info_clan:getLastTierIcon('big')       
            end
            if (icon) then
                vars['clanMarkNode2']:addChild(icon)
            end
        end

        do -- 방어자의 방어 횟수 뱃지
            local defend_cnt = struct_match_item:getDefendCount()
	        if (0 < defend_cnt) then
		        vars['defenseNoti']:setVisible(true)
		        vars['defenseLabel']:setString(tostring(defend_cnt))
            else
                vars['defenseNoti']:setVisible(false)
            end
        end
    end

    --[[
    do -- 공격자 정보 (이 리스트 아이템의 주인이 방어자)
        -- 진 경우 공격 상대 표시하지 않는다
	    local struct_attack_enemy_match_item = struct_match_item:getLastDefender()
        if (struct_attack_enemy_match_item) then
            if (struct_attack_enemy_match_item:getAttackState() == StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']) then
                struct_attack_enemy_match_item = nil
            end
        end

	    if (struct_attack_enemy_match_item) then
            local enemy_nick = struct_attack_enemy_match_item:getMyNickName() or ''
            vars['attackNameLabel']:setString(enemy_nick)
		    vars['arrowSprite']:setVisible(true)
            -- 승/패/승 세팅
            local l_game_result = struct_attack_enemy_match_item:getGameResult()
            self:setGameResult(l_game_result, is_my_clan)

            -- 남은 시간 세팅
            local end_date = struct_attack_enemy_match_item:getEndDate()
            self:setEndTime(end_date)
        else
            local my_nick = struct_match_item:getMyNickName() or ''
            vars['attackNameLabel']:setString(Str('미정'))
            --vars['arrowSprite']:setVisible(false)
        end
    end
    --]]
end

-------------------------------------
-- function setGameResult
-------------------------------------
function UI_ClanWarSelect_RivalListItem:setGameResult(l_result)
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
            vars['setResult'..i]:setVisible(false)
        end
    end

    for i, result in ipairs(l_result) do
        local color
        local sprite
        if (result == '0') then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        elseif (result == '1') then
            color = StructClanWarMatch.STATE_COLOR['WIN']
        elseif (result == '-1') then
            sprite = cc.Sprite:create('res/ui/icons/clan_war_score_no_game.png')
            sprite:setAnchorPoint(CENTER_POINT)
            sprite:setDockPoint(CENTER_POINT)
            sprite:setRotation(-45)
        end

        if (vars['setResult'..i]) then
            if (color) then
                vars['setResult'..i]:setVisible(true)
                vars['setResult'..i]:setColor(color)
            end

            if (sprite) then
                vars['setResult'..i]:setVisible(true)
                vars['setResult'..i]:setOpacity(0)
                vars['setResult'..i]:addChild(sprite)
            end
        end

        vars['setMenu']:setVisible(true)
        vars['gameScoreSprite']:setVisible(true)
        self.m_hasResult = true
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanWarSelect_RivalListItem:update(dt)
    local vars = self.vars
    local end_time = self.m_endTime

    if (self.m_noTime) then
        vars['lastTimeLabel']:setString('')
        return
    end

    if (not end_time) then
        vars['lastTimeLabel']:setString('')
        return
    end

    -- 공격 끝날 때 까지 남은 시간 = 공격 시작 시간 + 1시간
    local cur_time = Timer:getServerTime_Milliseconds()
    local remain_time = (end_time - cur_time)/1000
    if (remain_time > 0) then
        local hour = math.floor(remain_time / 3600)
        local min = math.floor(remain_time / 60) % 60
        vars['lastTimeLabel']:setString(Str('{1}:{2}', hour, min))
        vars['lastTimeLabel']:setVisible(true)
    else
        vars['lastTimeLabel']:setString('')
    end
end

-------------------------------------
-- function setEndDate
-------------------------------------
function UI_ClanWarSelect_RivalListItem:setEndTime(end_time)
    self.m_endTime = end_time or 0
end

-------------------------------------
-- function setSelected
-------------------------------------
function UI_ClanWarSelect_RivalListItem:setSelected(is_selected)
    local vars = self.vars
    vars['selectNode']:setVisible(is_selected)
end