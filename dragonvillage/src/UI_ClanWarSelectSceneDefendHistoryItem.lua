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

	local nick_name = struct_match_item:getMyNickName()
    vars['userNameLabel']:setString(nick_name)

	local l_result = struct_match_item:getGameResult()
    for i, result in ipairs(l_result) do
        local icon
        if (result == '0') then
            icon = cc.Sprite:create('res/ui/icons/clan_war_icon_defense_0101.png')
        elseif (result == '1') then
            icon = cc.Sprite:create('res/ui/icons/clan_war_icon_defense_0102.png')
        end
        if (vars['resultIconNode'..i]) then
			if (icon) then
				vars['resultIconNode'..i]:addChild(icon)
                vars['resultIconNode'..i]:setDockPoint(CENTER_POINT)
                vars['resultIconNode'..i]:setAnchorPoint(CENTER_POINT)
			end
		end
    end

	local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local end_date = struct_match_item:getEndDate()
	vars['timeLogLabel']:setString('')
    if (end_date) then
		if (cur_time > end_date) then
			local date = pl.Date()
			date:set(end_date/1000)

			-- 날짜 포맷 세팅
			local date_format = pl.Date.Format('HH:MM:SS')
			local time_str = date_format:tostring(date)
			vars['timeLogLabel']:setString(time_str)
		end
    end
end
