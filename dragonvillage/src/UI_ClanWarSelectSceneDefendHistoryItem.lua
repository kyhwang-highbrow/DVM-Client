local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarSelectSceneDefendHistoryItem
-------------------------------------
UI_ClanWarSelectSceneDefendHistoryItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelectSceneDefendHistoryItem:init(data)
    local vars = self:load('clan_war_match_select_defense_item.ui')

	-- 초기화
    self:initUI(data)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarSelectSceneDefendHistoryItem:initUI(data)
    local vars = self.vars
    local struct_match_item = data
    

    local l_result = struct_match_item:getGameResult()
    for i = 1,3 do
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(StructClanWarMatch.STATE_COLOR['DEFAULT'])
            vars['setResult'..i]:setVisible(true)
        end
    end

    for i, result in ipairs(l_result) do
        local color
        if (result == '0') then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        else
            color = StructClanWarMatch.STATE_COLOR['WIN']
        end
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(color)
            vars['setResult'..i]:setVisible(true)
        end
    end

    local end_date = struct_match_item:getEndDate()
    if (end_date) then
        local date = pl.Date()
	    date:set(end_date/1000)

	    -- 날짜 포맷 세팅
	    local date_format = pl.Date.Format('HH:MM:SS')
	    local time_str = date_format:tostring(date)
        vars['timeLogLabel']:setString(time_str)
    end

    local nick_name = struct_match_item:getMyNickName()
    vars['userNameLabel']:setString(nick_name)

    local attack_state = struct_match_item:getAttackState()
    local icon
    if (attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']) then
        icon = cc.Sprite:create('res/ui/icons/clan_war_icon_defense_0102.png')
    else
        icon = cc.Sprite:create('res/ui/icons/clan_war_icon_defense_0101.png')
    end
    
    vars['resultIconNode']:addChild(icon)
end
