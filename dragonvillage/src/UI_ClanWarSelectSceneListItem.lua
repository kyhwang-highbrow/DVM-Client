local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarSelectSceneListItem
-------------------------------------
UI_ClanWarSelectSceneListItem = class(PARENT,{
        m_structMatchItem = 'StructClanWarMatch',
        m_endTime = 'number',

        m_noTime = 'boolean',
        m_hasResult = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelectSceneListItem:init(data)
    local vars = self:load('clan_war_match_select_item_rival.ui')
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
-- function setNoTime
-------------------------------------
function UI_ClanWarSelectSceneListItem:setNoTime()
    self.m_noTime = true
end

-------------------------------------
-- function setGameResult
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
-- function setStructMatch
-------------------------------------
function UI_ClanWarSelectSceneListItem:setStructMatch(is_my_clan)
    local vars = self.vars
    local struct_match_item = self.m_structMatchItem

    if (not struct_match_item) then
        return
    end

    local defend_cnt = struct_match_item:getDefendCount()
    vars['defenseNoti']:setVisible(false)

	if (defend_cnt > 0) then
		vars['defenseNoti']:setVisible(true)
		vars['defenseLabel']:setString(tostring(defend_cnt))
    end

	-- 나의 닉네임
    local my_nick = struct_match_item:getMyNickName() or ''
    vars['defenseNameLabel']:setString(my_nick)
	vars['defenseNameLabel']:setVisible(true)

	vars['gameScoreSprite']:setVisible(false)
    vars['setMenu']:setVisible(false)

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
        vars['attackNameLabel']:setVisible(true)

		vars['arrowSprite']:setVisible(true)
        -- 승/패/승 세팅
        local l_game_result = struct_attack_enemy_match_item:getGameResult()
        self:setGameResult(l_game_result, is_my_clan)

        -- 남은 시간 세팅
        local end_date = struct_attack_enemy_match_item:getEndDate()
        self:setEndTime(end_date)
    else
        local my_nick = struct_match_item:getMyNickName() or ''
        vars['attackNameLabel']:setString('')
		vars['defenseNameLabel']:setPositionX(-125)
        vars['arrowSprite']:setVisible(false)
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanWarSelectSceneListItem:update(dt)
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
    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
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
-- function setEndTime
-------------------------------------
function UI_ClanWarSelectSceneListItem:setEndTime(end_time)
    self.m_endTime = end_time or 0
end

-------------------------------------
-- function setSelected
-------------------------------------
function UI_ClanWarSelectSceneListItem:setSelected(is_selected)
	local struct_match_item = self.m_structMatchItem
	local struct_attack_enemy_match_item = struct_match_item:getLastDefender()

    if (not struct_attack_enemy_match_item) then
        self.vars['selectNode1']:setVisible(is_selected)
        return
    else
        if (struct_attack_enemy_match_item:getAttackState() == StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']) then
            struct_attack_enemy_match_item = nil
        end
    end

	if (struct_attack_enemy_match_item) then
        if (self.m_hasResult) then
	        self.vars['selectNode2']:setVisible(is_selected)
        else
            self.vars['selectNode1']:setVisible(is_selected)
        end
		return
	end

    self.vars['selectNode1']:setVisible(is_selected)
end


local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarSelectSceneListItem_Me
-------------------------------------
UI_ClanWarSelectSceneListItem_Me = class(PARENT,{
        m_structMatchItem = 'StructClanWarMatch',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelectSceneListItem_Me:init(data)
    local vars = self:load('clan_war_match_select_item_me.ui')
    self.m_structMatchItem = data

    -- 나의 닉네임
    local my_nick = self.m_structMatchItem:getMyNickName()
    vars['userNameLabel']:setString(my_nick)
	if (self.m_structMatchItem:getAttackState() == StructClanWarMatchItem.ATTACK_STATE['ATTACKING']) then
		local icon = cc.Sprite:create('res/ui/icons/clan_war_icon_attack.png')
		if (icon) and (vars['attackIconNode']) then
			vars['attackIconNode']:addChild(icon)
            vars['attackIconNode']:setDockPoint(CENTER_POINT)
            vars['attackIconNode']:setAnchorPoint(CENTER_POINT)
			vars['attackIconNode']:setVisible(true)
		end
	end

    local my_uid = g_userData:get('uid')
    vars['meNode']:setVisible(my_uid == self.m_structMatchItem['uid'])
end

-------------------------------------
-- function setSelected
-------------------------------------
function UI_ClanWarSelectSceneListItem_Me:setSelected(is_selected)
	self.vars['selectNode']:setVisible(is_selected)
end

