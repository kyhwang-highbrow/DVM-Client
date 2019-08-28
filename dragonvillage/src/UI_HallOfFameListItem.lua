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
    local data = self.m_tUserInfo

    if (not data) then
        vars['noRankMenu']:setVisible(true)
        vars['rankMenu']:setVisible(false)

        local random_num = math_random(1, 3)
        local no_tamer = cc.Sprite:create(string.format('res/ui/icons/tamer/hall_of_fame_no_rank_010%d.png', random_num))
		if (no_tamer) then        
			vars['noRankTamerNode']:addChild(no_tamer)
        end
		return
    end

	local score = descBlank(data['score'])

	local user_name = data['nick']
	local rank = descBlank(data['rank'])

	vars['scoreLabel']:setString(Str('{1}점', score))
	vars['userNameLabel']:setString(Str(user_name))
	vars['rankingLabel']:setString(rank)

	-- 테이머 애니
	local tamer_id = data['tamer']
    local tamer_info = data['tamer_info']
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

    if (data['clan_info']) then
	    -- 클랜 마크
        local t_clan_info = data['clan_info']
        local clan_name = t_clan_info['name']
        vars['clanNameLabel']:setString(clan_name)

        local clan_mark = StructClanMark:create(t_clan_info['mark'])
        local icon = clan_mark:makeClanMarkIcon()
        if (icon) then
            vars['clanMarkNode']:addChild(icon)
        end
    else
        vars['clanNameLabel']:setVisible(false)
    end

    if (not self.m_tUserInfo['clan_info']) then
        vars['userNameLabel']:setPositionY(-68)
        vars['rankingLabel']:setPositionY(-62)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameListItem:initButton()
    local vars = self.vars
    if (self.m_tUserInfo['clan_info']) then
	    vars['clanBtn']:registerScriptTapHandler(function()
		    local struct_clan = StructClan(self.m_tUserInfo['clan_info'])
            local clan_object_id = struct_clan:getClanObjectID()
            g_clanData:requestClanInfoDetailPopup(clan_object_id)
        end)
    end
end

