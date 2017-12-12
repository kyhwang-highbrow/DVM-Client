local PARENT = UI

-------------------------------------
-- class UI_DailyMisson_Clan
-------------------------------------
UI_DailyMisson_Clan = class(PARENT,{
		m_lDailyMissionItem = 'list', -- idx가 숫자라 list로..
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DailyMisson_Clan:init()
	local vars = self:load('event_clan_quest.ui')
	self.m_lDailyMissionItem = {}
	
	local function cb_func()
		self:initUI()
		self:initButton()
		self:refresh()
	end
	g_dailyMissionData:request_dailyMissionInfo(cb_func)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DailyMisson_Clan:initUI()
    local vars = self.vars

	local key = 'clan'
	local mission_list = TableDailyMission:getMissionList(key)
	local function click_func()
		self:refresh()
	end

	for i, t_mission in ipairs(mission_list) do
		local ui = self.makeCell(t_mission, click_func)
		vars['itemNode' .. i]:addChild(ui.root)
		self.m_lDailyMissionItem[i] = ui
	end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DailyMisson_Clan:initButton()
    local vars = self.vars
    --vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DailyMisson_Clan:refresh()
    local vars = self.vars

	local struct_mission = g_dailyMissionData:getMissionStruct('clan')
	if (not struct_mission) then
		return 
	end

	local curr_day = struct_mission['curr_day']

	-- 출석 미션 시작하기 전
	if (not curr_day) then
		for i, ui in ipairs(self.m_lDailyMissionItem) do
			ui.vars['readySprite']:setVisible(true)
			ui.vars['checkSprite']:setVisible(false)
		end
		return
	end

	-- 출석 미션 진행 중
	for i, ui in ipairs(self.m_lDailyMissionItem) do
		ui.vars['receiveBtn']:setEnabled(false)
		ui.vars['readySprite']:setVisible(false)
		ui.vars['checkSprite']:setVisible(false)

		-- 다음날 들
		if (i > curr_day) then
			ui.vars['checkSprite']:setVisible(true)

		-- 전날 들
		elseif (i < curr_day) then
			ui.vars['readySprite']:setVisible(true)

		-- 당일
		else
			if (struct_mission['is_clear']) then
				ui.vars['receiveBtn']:setEnabled(not struct_mission['reward'])
			end
		end
	end


end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_DailyMisson_Clan:onEnterTab()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DailyMisson_Clan:click_exitBtn()

end

--@CHECK
UI:checkCompileError(UI_DailyMisson_Clan)

-------------------------------------
-- function makeCell
-- @static
-------------------------------------
function UI_DailyMisson_Clan.makeCell(t_data, click_func)
    local ui = UI()
    local vars = ui:load('event_clan_quest_item.ui')

	-- 일차
	local day = t_data['day']
	vars['dayLabel']:setString(Str('{1}일 차', day)) 

	-- 미션 설명
	local desc = Str(t_data['t_desc'], t_data['clear_value'])
	vars['questLabel']:setString(desc)

    -- 보상 정보
    local l_reward = g_itemData:parsePackageItemStr(t_data['reward'])
	local t_reward = l_reward[1]
	local item_id = t_reward['item_id']
	local cnt = t_reward['count']
    local item_card = UI_ItemCard(item_id, cnt)
    vars['itemNode']:addChild(item_card.root)

    -- 보상 수령
    vars['receiveBtn']:registerScriptTapHandler(function()
		g_dailyMissionData:request_dailyMissionReward(click_func)
    end)
	vars['receiveBtn']:setEnabled(false)

    return ui
end

