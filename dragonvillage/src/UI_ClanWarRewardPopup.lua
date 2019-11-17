local PARENT = UI

-------------------------------------
-- class UI_ClanWarRewardPopup
-------------------------------------
UI_ClanWarRewardPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarRewardPopup:init(data)
    local vars = self:load('clan_war_reward_popup.ui')
	UIManager:open(self, UIManager.POPUP)
	self:initUI(data)

	-- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarRewardPopup')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarRewardPopup:initUI(data)
    local vars = self.vars

	local struct_clan = g_clanData:getClanStruct()

	-- 클랜 이름
	local clan_name = struct_clan:getClanName()
	vars['clanNameLabel']:setString(clan_name)

    -- 클랜 마스터 닉네임
    local clan_master = struct_clan:getMasterNick()
    vars['masterNameLabel']:setString(clan_master)
	
	-- 클랜 마크 
	local clan_icon = struct_clan:makeClanMarkIcon()
	if (clan_icon) then
		vars['clanMarkNode']:addChild(clan_icon)
	end
	
	local l_reward = g_claWarData.seasonRewardInfo['reward_clan_info']
	for i, data in ipairs(l_reward) do
		local item_id = data['item_id']
		local item_cnt = data['count']

		local ui = UI_ItemCard(item_id, 0)
		vars['rewardNode'..i]:addChild(ui.root)
		vars['rewardLabel'..i]:setString(tostring(item_cnt))
	end

	local is_tournament = g_claWarData.seasonRewardInfo['is_tournament']
	local last_clanwar_rank = g_claWarData.seasonRewardInfo['last_clanwar_rank']
	local category = 'clanwar_league'
	if (is_tournament) then
		category = 'clanwar_tournament'
	end

	local t_cur_reward
	for rank_id, t_data in pairs(TABLE:get('table_clan_reward')) do
        if (t_data['category'] == category) then
            if (t_data['rank_max'] >= last_clanwar_rank) and (t_data['rank_min'] <= last_clanwar_rank) then
                t_cur_reward = t_data
				break
            end
        end
	end

	local last_rank_name = t_cur_reward['t_name'] or ''
	vars['rankLabel']:setString(Str(last_rank_name))
	local exp_cnt = t_cur_reward['clan_exp'] or 0
	local ui = UI_ItemCard('clan_exp', exp_cnt)
	vars['rewardNode2']:addChild(ui.root)
	vars['rewardLabel2']:setString(last_rank_name)
	vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end
