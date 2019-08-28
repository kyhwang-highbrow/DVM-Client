local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_HallOfFameRankListItem
-------------------------------------
UI_HallOfFameRankListItem = class(PARENT,{
		m_tRankInfo = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFameRankListItem:init(data)
    local vars = self:load('hall_of_fame_rank_popup_item.ui')
	self.m_tRankInfo = data
    
	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFameRankListItem:initUI()
    local vars = self.vars

	-- 랭킹
    local rank = descBlank(self.m_tRankInfo['rank'])
	vars['rankingLabel']:setString(rank)

	-- 리더 드래곤 아이콘
	local dragon_icon = UI_DragonCard(self.m_tRankInfo['leader'])
	vars['profileNode']:addChild(dragon_icon.root)
	dragon_icon.root:setSwallowTouch(false)

	-- 유저 이름
	local user_name = self.m_tRankInfo['nick']
	vars['userLabel']:setString(user_name)

    if (self.m_tRankInfo['clan_info']) then
        -- 클랜 이름
        local t_clan_info = self.m_tRankInfo['clan_info']
        local clan_name = t_clan_info['name']
        vars['clanLabel']:setString(clan_name)
        
        -- 클랜 마크
        local clan_mark = StructClanMark:create(t_clan_info['mark'])
        local icon = clan_mark:makeClanMarkIcon()
        if (icon) then
            vars['markNode']:addChild(icon)
        end
    else
        vars['clanLabel']:setVisible(false)
    end

    vars['itemMenu']:setSwallowTouch(false)

	-- 스코어
    local is_hall = true
    if (not is_hall) then
	    vars['scoreLabel'] = NumberLabel(vars['scoreLabel'], 0, COMMON_UI_ACTION_TIME)
	    local score = self.m_tRankInfo['rp']
	    vars['scoreLabel']:setNumber(score)
        vars['hall_of_fameScoreMenu']:setVisible(false)
    else
        vars['hall_of_fameScoreMenu']:setVisible(true)
        vars['challengeModeScoreLabel']:setString(Str('{1}점', 1000))
        vars['sumScoreLabel']:setString(Str('{1}점', 1000))
        vars['towerScoreLabel']:setString(Str('{1}점', 1000))
        vars['arenaScoreLabel']:setString(Str('{1}점', 1000))
        vars['scoreLabel']:setVisible(false)
    end

	vars['meSprite']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameRankListItem:initButton()
    local vars = self.vars
	vars['clanBtn']:registerScriptTapHandler(function()
		local struct_clan = StructClan(self.m_tRankInfo['clan_info'])
        local clan_object_id = struct_clan:getClanObjectID()
        g_clanData:requestClanInfoDetailPopup(clan_object_id)
    end)
end