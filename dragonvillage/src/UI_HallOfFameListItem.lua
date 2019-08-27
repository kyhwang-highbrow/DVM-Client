local PARENT = UI

-------------------------------------
-- class UI_HallOfFameListItem
-------------------------------------
UI_HallOfFameListItem = class(PARENT,{
		m_tUserInfo = 'table',
	})

-------------------------------------
-- function initF
-------------------------------------
function UI_HallOfFameListItem:init(t_data)
    local vars = self:load('hall_of_fame_scene_item.ui')
    self.m_tUserInfo = t_data

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
function UI_HallOfFameListItem:initUI()
    local vars = self.vars

	local score = 1000
	local user_name = '명예의 전당 유저'
	local rank = 1

	vars['scoreLabel']:setString(Str('{1}점', score))
	vars['userNameLabel']:setString(Str(user_name))
	vars['rankingLabel']:setString(rank)

	-- 테이머 애니
	local tamer_id = self.m_tUserInfo['tamer']
    local tamer_info = self.m_tUserInfo['tamer_info']
    local costume_id = (tamer_info) and tamer_info['costume'] or nil

    local sd_res
    if (costume_id) then
        sd_res = TableTamerCostume:getTamerResSD(costume_id)
    else
        sd_res = TableTamer:getTamerResSD(tamer_id)
    end

	local sd_animator = MakeAnimator(sd_res)
	sd_animator:changeAni('idle', true)
	vars['tamerNode']:addChild(sd_animator.m_node)

	-- 클랜 마크
    local t_clan_info = self.m_tUserInfo['clan_info']
    local clan_name = t_clan_info['name']
    vars['clanNameLabel']:setString(clan_name)

    local clan_mark = StructClanMark:create(t_clan_info['mark'])
    local icon = clan_mark:makeClanMarkIcon()
    vars['clanMarkNode']:addChild(icon)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameListItem:initButton()
    local vars = self.vars
	--[[
	vars['clanBtn']:registerScriptTapHandler(function()
		local struct_clan = StructClan(self.m_tUserInfo['clan_info'])
        local clan_object_id = struct_clan:getClanObjectID()
        g_clanData:requestClanInfoDetailPopup(clan_object_id)
    end)
	--]]
end

