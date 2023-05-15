-------------------------------------
-- class UI_ClanRaidResult
-------------------------------------
UI_ClanRaidResult = class(UI, {
        m_stageID = 'number',
        m_bSuccess = 'boolean',
        m_grade = 'number',

        m_data = '', -- 등급, 보상 정보

        m_damage = 'number', -- 피해량
        m_grade = 'number', -- 보상 등급

        m_workIdx = 'number',
        m_lWorkList = 'list',

        m_sub_menu = 'cc.Menu', -- 보상이 올라가는 ui
     })

local ITEM_CARD_SCALE = 0.65
local ANI_DURATION = 0.2 -- 아이템 카드 보여주는 애니메이션 속도
-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_ClanRaidResult:init(stage_id, is_success, damage, t_data)
    self.m_stageID = stage_id
    self.m_bSuccess = is_win
    self.m_damage = damage
    self.m_data = t_data
    self.m_grade = t_data['dmg_rank']
    
    local vars = self:load('clan_raid_result.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_ClanRaidResult'

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_ClanRaidResult')

    self:initUI()
    self:initButton()

    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidResult:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
    if (vars['infoBtn']) then
        vars['infoBtn']:registerScriptTapHandler(function() self:click_statusInfo() end)
        vars['infoBtn']:setVisible(true)
    end
end

-------------------------------------
-- function setWorkList
-------------------------------------
function UI_ClanRaidResult:setWorkList()
    self.m_workIdx = 0
    self.m_lWorkList = {}
    -- 테이머 연출 미정
    --table.insert(self.m_lWorkList, 'direction_showTamer')
    --table.insert(self.m_lWorkList, 'direction_hideTamer')
    table.insert(self.m_lWorkList, 'direction_start')
    table.insert(self.m_lWorkList, 'direction_showScore')
    table.insert(self.m_lWorkList, 'direction_showStar')
    table.insert(self.m_lWorkList, 'direction_showReward')
    table.insert(self.m_lWorkList, 'direction_end')
end

-------------------------------------
-- function direction_showTamer
-------------------------------------
function UI_ClanRaidResult:direction_showTamer()
end

-------------------------------------
-- function direction_showTamer_click
-------------------------------------
function UI_ClanRaidResult:direction_showTamer_click()
end

-------------------------------------
-- function direction_hideTamer
-------------------------------------
function UI_ClanRaidResult:direction_hideTamer()
end

-------------------------------------
-- function direction_hideTamer_click
-------------------------------------
function UI_ClanRaidResult:direction_hideTamer_click()
end

-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_ClanRaidResult:direction_start()
    local is_win = self.m_bSuccess
    local vars = self.vars
    local visual_node = vars['resultVisual']
    visual_node:setVisible(true)

    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local clear = (struct_raid:getState() == CLAN_RAID_STATE.CLEAR)
    local appear_name = clear and 'clear_appear' or 'result_appear'
    local idle_name = clear and 'clear_idle' or 'result_idle'

    SoundMgr:playBGM('bgm_dungeon_victory', false)    
    visual_node:changeAni(appear_name, false)
    visual_node:addAniHandler(function()
        visual_node:changeAni(idle_name, true)
    end)

    self:doNextWorkWithDelayTime(0.8)
end

-------------------------------------
-- function direction_start_click
-------------------------------------
function UI_ClanRaidResult:direction_start_click()
end

-------------------------------------
-- function direction_showScore
-- @brief 점수 연출
-------------------------------------
function UI_ClanRaidResult:direction_showScore()
    local is_win = self.m_bSuccess
    local vars = self.vars

    local total_score = cc.Label:createWithBMFont('res/font/tower_score.fnt', '')
    total_score:setAnchorPoint(cc.p(0.5, 0.5))
    total_score:setDockPoint(cc.p(0.5, 0.5))
    total_score:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    total_score:setAdditionalKerning(0)
    vars['scoreNode']:addChild(total_score)

    local new_score = NumberLabel(total_score, 0, 0.3)
    new_score:setNumber(self.m_damage, false)

    self:doNextWorkWithDelayTime(0.8)
end

-------------------------------------
-- function direction_showScore_click
-------------------------------------
function UI_ClanRaidResult:direction_showScore_click()
end

-------------------------------------
-- function direction_showStar
-- @brief 등급별 연출
-------------------------------------
function UI_ClanRaidResult:direction_showStar()
    local vars = self.vars

    -- 등급별로 연출 다름 test
    local grade = self.m_grade
    local ani = string.format('result_star_%02d', grade)
    local visual_node = vars['starVisual']
    visual_node:setVisible(true)
    visual_node:changeAni(ani, false)

    self:doNextWorkWithDelayTime(1.5)
end

-------------------------------------
-- function direction_showStar_click
-------------------------------------
function UI_ClanRaidResult:direction_showStar_click()
end

-------------------------------------
-- function direction_showReward
-- @brief 보상 연출
-------------------------------------
function UI_ClanRaidResult:direction_showReward()
    local vars = self.vars
    local reward_list = self.m_data['drop_reward_list']

    -- 보상없는 경우 -> 보스의 남은 체력 보여줌
    if (#reward_list == 0) then
        self:show_boss_hp()
        return
    end

    local grade = self.m_grade

    local ui = UI()
    ui:load('clan_raid_result_reward.ui')
    local target_menu = ui.vars['rewardNode'..grade]
    target_menu:setVisible(false)
    vars['dropRewardMenu']:addChild(ui.root)
    self.m_sub_menu = vars['dropRewardMenu']

    local box_visual = vars['boxVisual']

    local ani_1 
    local ani_2
    local result
    
    -- 박스 연출
    ani_1 = function()
        box_visual:setVisible(true)
        box_visual:changeAni('box_01', false)
        box_visual:addAniHandler(function()
            ani_2()
        end)
    end

    ani_2 = function()
        box_visual:changeAni('box_03', false)
        box_visual:addAniHandler(function()
            box_visual:setVisible(false)
            target_menu:setVisible(true)
            self:show_item_reward(ui)
        end)
    end

    ani_1()
end

-------------------------------------
-- function show_item_reward
-- @brief 아이템 팡팡 박히는 애니메이션
-------------------------------------
function UI_ClanRaidResult:show_item_reward(reward_menu)
    local ani_duration = ANI_DURATION    
    local ani_interval = 0.0

    -- 아이템 카드 보여주는 액션
    local function show_reward(item_card, item_grade, is_last)
        local item_node = item_card.root
        item_node:setVisible(true)
        cca.stampShakeAction(item_node, ITEM_CARD_SCALE * 1.1, 0.1, 0, 0, ITEM_CARD_SCALE)
        self:setItemCardRarity(item_card, item_grade)

        if (is_last) then
            self:doNextWorkWithDelayTime(0.5)
        end
    end

    -- 드랍한 아이템 만큼 연출
    local reward_list = self.m_data['drop_reward_list']
    for i, v in ipairs(reward_list) do
        local item_card, item_grade = self:getItemCard(v)
        item_card.root:setVisible(false)

        local target_node = reward_menu.vars['rewardNode'..self.m_grade..'_'..i]
        target_node:addChild(item_card.root)

        local is_last = (i == #reward_list)
        cca.reserveFunc(self.root, 
                        ani_duration * ((i - 1) + ani_interval), 
                        function() show_reward(item_card, item_grade, is_last) end)
    end
end

-------------------------------------
-- function setItemCardRarity
-------------------------------------
function UI_ClanRaidResult:setItemCardRarity(item_card, grade)
	if (grade > 3) then
		local rarity_effect = MakeAnimator('res/ui/a2d/card_summon/card_summon.vrp')
		if (grade == 5) then
			rarity_effect:changeAni('summon_regend', true)
		else
			rarity_effect:changeAni('summon_hero', true)
		end
		rarity_effect:setScale(1.7)
		rarity_effect:setAlpha(0)
		item_card.root:addChild(rarity_effect.m_node)
        rarity_effect.m_node:runAction(cc.FadeIn:create(ANI_DURATION))
	end
end

-------------------------------------
-- function getItemCard
-------------------------------------
function UI_ClanRaidResult:getItemCard(data)
    local visible = visible
    local item_id = data[1]
    local count = data[2]            
    local from = data[3]
    local sub_data = data[4]

    local item_grade = string.find(from, 'grade_') and 
                        string.gsub(from, 'grade_', '') or 1

    local item_card = UI_ItemCard(item_id, count, sub_data)
    item_card.root:setScale(ITEM_CARD_SCALE)

    return item_card, tonumber(item_grade)
end

-------------------------------------
-- function show_boss_hp
-- @brief 보상이 없는 경우 보스의 남은 체력 보여줌
-------------------------------------
function UI_ClanRaidResult:show_boss_hp()
    local vars = self.vars

    local struct_raid = g_clanRaidData:getClanRaidStruct()
    vars['bossHpNode']:setVisible(true)

    -- 레벨, 이름
    local is_rich_label = true
    local name = struct_raid:getBossNameWithLv(is_rich_label)
    vars['levelLabel']:setString(name)

    -- 속성 아이콘
    local attr = struct_raid:getAttr()
    local icon = IconHelper:getAttributeIconButton(attr)
    vars['attrNode']:removeAllChildren()
    vars['attrNode']:addChild(icon)

    -- 체력 퍼센트
    local tween_cb = function(number, label)
        label:setString(string.format('%0.2f%%', number))
    end

    local hp_label = vars['hpLabel']
    hp_label = NumberLabel(hp_label, 0, 0.3)
    hp_label:setTweenCallback(tween_cb)

    local rate = struct_raid:getHpRate()
    hp_label:setNumber(rate, false)

    -- 체력 게이지
    local gauge = vars['bossHpGauge1']
    gauge:setPercentage(0)
    local action = cc.ProgressTo:create(0.3, rate)
    gauge:runAction(action)

    self:doNextWork()
end

-------------------------------------
-- function direction_showReward_click
-- @brief 클릭시 보상 애니메이션 스킵
-------------------------------------
function UI_ClanRaidResult:direction_showReward_click()
    self.root:stopAllActions()
    self:doNextWork()
    self:initReward()
end

-------------------------------------
-- function initReward
-- @brief 클릭시 아이템 정보 바로 다 나오게 일딴 처리
-------------------------------------
function UI_ClanRaidResult:initReward()
    local vars = self.vars
    local grade = self.m_grade

    if (self.m_sub_menu) then
        self.m_sub_menu:removeAllChildren()
        local box_visual = vars['boxVisual']
        box_visual:stopAllActions()
        box_visual:setVisible(false)
        box_visual:addAniHandler(nil)

        local ui = UI()
        ui:load('clan_raid_result_reward.ui')
        ui.vars['rewardNode'..grade]:setVisible(true)
        vars['dropRewardMenu']:addChild(ui.root)

        local reward_list = self.m_data['drop_reward_list']

        for i, v in ipairs(reward_list) do
            local item_card, item_grade = self:getItemCard(v)
            self:setItemCardRarity(item_card, item_grade)

            local target_node = ui.vars['rewardNode'..grade..'_'..i]
            target_node:addChild(item_card.root)
        end
    end
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_ClanRaidResult:direction_end()
    local vars = self.vars
    vars['okBtn']:setVisible(true)
    vars['statsBtn']:setVisible(true)

    local func_show_leader = function()
        local struct_raid = g_clanRaidData:getClanRaidStruct()
        -- 연습모드에선 리더보드 안보여줌
        if (not struct_raid:isTrainingMode()) then
            
            -- 죄악의 화신 토벌작전 이벤트에선 최고기록을 세웠을 때에만 보여줌
            if (struct_raid:isEventIncarnationOfSinsMode()) then
                self:showLeaderBoard_IncarnationOfSins()

            else
                self:showLeaderBoard()
            end
        end
    end

    local reward_info = self.m_data['mail_reward_list'] or {}
    if (#reward_info > 0) then
        local action = cc.Sequence:create(cc.DelayTime:create(0.5),
            cc.CallFunc:create(function() self:show_finalblowReward(reward_info, func_show_leader) end))
        self.root:runAction(action)
    else
        func_show_leader()
    end
end

-------------------------------------
-- function direction_end_click
-------------------------------------
function UI_ClanRaidResult:direction_end_click()
end

-------------------------------------
-- function showLeaderBoard
-------------------------------------
function UI_ClanRaidResult:showLeaderBoard()
    local vars = self.vars
    
    -- 게임 후, 앞/뒤 랭커 정보
    local t_upper, t_me, t_lower = g_clanRaidData:getCloseRankers()
    if (not t_me) then
        self:doNextWork()
        return
    end

    -- 게임 전 내 정보
    local t_ex_me = g_clanRaidData.m_tExMyClanInfo
    if (not t_ex_me) then
        self:doNextWork()
        return
    end

    local ui_leader_board = UI_ResultLeaderBoard('clan_raid', true, true) -- type, is_move, is_popup
    ui_leader_board:setScore(self.m_damage, t_me['score']) -- param : add_score, current_score (전투 후)데미지 값(=점수), (전투 후)최종 종합 점수
    ui_leader_board:setRatio(t_ex_me['rate'], t_me['rate'])
    ui_leader_board:setRank(t_ex_me['rank'], t_me['rank'])
    ui_leader_board:setRanker(t_upper, t_me, t_lower)
    ui_leader_board:setCurrentInfo()
    ui_leader_board:startMoving()
end

-------------------------------------
-- function showLeaderBoard_IncarnationOfSins
-- @brief 죄악의 화신 토벌작전 전용 리더보드 생성
-------------------------------------
function UI_ClanRaidResult:showLeaderBoard_IncarnationOfSins()
    local vars = self.vars
    
    -- 게임 후, 앞/뒤 랭커 정보
    local t_upper, t_me, t_lower = g_eventIncarnationOfSinsData:getCloseRankers()
    if (not t_me) then
        self:doNextWork()
        return
    end

    -- 게임 전 내 정보
    local t_ex_me = g_eventIncarnationOfSinsData.m_tMyRankInfo['total']
    local t_ex_me = nil
    if (not t_ex_me) then -- 처음 때린 사람
        t_ex_me = {['score'] = 0, ['rank'] = t_me['rank'] + 1000, ['rate'] = 1}
    end

    
    local ui_leader_board = UI_ResultLeaderBoard_IncarnationOfSins('incarnation_of_sins', true, true) -- type, is_move, is_popup
    ui_leader_board:setScore(t_me['score'] - t_ex_me['score'], t_me['score']) -- param : 더해진 점수, 더해진 점수가 반영된 최종 점수
    ui_leader_board:setRatio(t_ex_me['rate'], t_me['rate'])
    ui_leader_board:setRank(t_ex_me['rank'], t_me['rank'])
    ui_leader_board:setRanker(t_upper, t_me, t_lower)
    ui_leader_board:setCurrentInfo()
    ui_leader_board:startMoving()
end

-------------------------------------
-- function direction_showLeaderBoard_click
-------------------------------------
function UI_ClanRaidResult:direction_showLeaderBoard_click()
end

-------------------------------------
-- function show_finalblowReward
-- @brief 파이널 블로우 추가 보상 팝업
-------------------------------------
function UI_ClanRaidResult:show_finalblowReward(reward_info, cb_ok)
    local ui = UI()
	ui:load('clan_raid_clear_reward.ui')
	UIManager:open(ui, UIManager.POPUP)

    -- 닫힐 때, 콜백함수 있다면 호출
    local cb_close = function()
        ui:close() 
        if (cb_ok) then
            cb_ok()
        end
    end

    local vars = ui.vars
    vars['okBtn']:registerScriptTapHandler(function() cb_close() end)

    table.sort(reward_info, function(a, b)
		local a_item_id = tonumber(a['item_id'])
        local b_item_id = tonumber(b['item_id'])
        return a_item_id < b_item_id
	end)

    for i, item_data in ipairs(reward_info) do
        local item_id = item_data['item_id']
        local item_cnt = item_data['count']

        local icon = IconHelper:getItemIcon(item_id, item_cnt)
        if (vars['rewardNode'..i]) then
            vars['rewardNode'..i]:addChild(icon)
            vars['rewardLabel'..i]:setString(comma_value(item_cnt))
        end
    end
end

-------------------------------------
-- function doNextWork
-------------------------------------
function UI_ClanRaidResult:doNextWork()
    self.m_workIdx = (self.m_workIdx + 1)
    local func_name = self.m_lWorkList[self.m_workIdx]

    if func_name and (self[func_name]) then
        self[func_name](self)
        return
    end
end

-------------------------------------
-- function doNextWorkWithDelayTime
-------------------------------------
function UI_ClanRaidResult:doNextWorkWithDelayTime(second)
    local second = second or 1
    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function click_okBtn
-- @brief "확인" 버튼
-------------------------------------
function UI_ClanRaidResult:click_okBtn()
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    
    -- 죄악의 화신 토벌작전 이벤트로 들어온 경우
    if (struct_raid ~= nil) and (struct_raid:isEventIncarnationOfSinsMode()) then
        UINavigator:goTo('event_incarnation_of_sins')
    else
	    UINavigator:goTo('clan_raid')
    end
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_ClanRaidResult:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_statusInfo
-------------------------------------
function UI_ClanRaidResult:click_statusInfo()
    UI_HelpStatus()
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_ClanRaidResult:click_screenBtn()
    if (not self.m_lWorkList[self.m_workIdx]) then
        return
    end

    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        self[func_name](self)
    end
end