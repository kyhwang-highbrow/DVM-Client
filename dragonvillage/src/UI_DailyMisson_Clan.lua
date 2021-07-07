local PARENT = UI

-------------------------------------
-- class UI_DailyMisson_Clan
-------------------------------------
UI_DailyMisson_Clan = class(PARENT,{
		m_lDailyMissionItem = 'list', -- idx가 숫자라 list로..

		
        m_tabButtonCallback = 'function',
    })

local MISSION_KEY = 'clan'

-------------------------------------
-- function init
-------------------------------------
function UI_DailyMisson_Clan:init()
	local vars = self:load('event_clan_quest.ui')
	self.m_lDailyMissionItem = {}
	
	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DailyMisson_Clan:initUI()
    local vars = self.vars

	local key = MISSION_KEY
	local mission_list = TableDailyMission:getMissionList(key)
	local function click_func()
		self:refresh()
		
		if self.m_tabButtonCallback then
			self.m_tabButtonCallback()
		end
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

	local struct_mission = g_dailyMissionData:getMissionStruct(MISSION_KEY)
	
	if (not struct_mission) then
		return 
	end

	local status = struct_mission['status']
	-- 출석 미션 시작하기 전
	if (status == 'set') then
		for i, ui in ipairs(self.m_lDailyMissionItem) do
			ui.vars['receiveBtn']:setEnabled(false)
			ui.vars['readySprite']:setVisible(true)
			ui.vars['checkSprite']:setVisible(false)
		end
		return

	-- 출석 미션 완료
	elseif (status == 'done') then
		for i, ui in ipairs(self.m_lDailyMissionItem) do
			ui.vars['receiveBtn']:setEnabled(false)
			ui.vars['readySprite']:setVisible(false)
			ui.vars['checkSprite']:setVisible(true)
		end
		return

	end

	-- 출석 미션 진행 중
	local curr_day = struct_mission['curr_day']
	for i, ui in ipairs(self.m_lDailyMissionItem) do
		local ui_vars = ui.vars

		ui_vars['receiveBtn']:setEnabled(false)
		ui_vars['readySprite']:setVisible(false)
		ui_vars['checkSprite']:setVisible(false)

		-- 다음날 들
		if (i > curr_day) then
			ui_vars['readySprite']:setVisible(true)

		-- 전날 들
		elseif (i < curr_day) then
			ui_vars['checkSprite']:setVisible(true)

		-- 당일
		else
			UIHelper:makeHighlightFrame(ui_vars['rootNode'])

			-- 클리어한 상태
			if (struct_mission['is_clear']) then
				-- 보상 받음 (모두 완료)
				if (struct_mission['reward']) then
					ui_vars['checkSprite']:setVisible(true)

				-- 보상 수령 가능 상태
				else
					ui_vars['receiveBtn']:setEnabled(true)
				end

			-- 미션 진행 중
			else
				ui_vars['readySprite']:setVisible(true)

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
	vars['dayLabel']:setString(Str('{1}일차', day)) 

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
		g_dailyMissionData:request_dailyMissionReward(MISSION_KEY, day, click_func)
    end)
	vars['receiveBtn']:setEnabled(false)

    return ui
end

