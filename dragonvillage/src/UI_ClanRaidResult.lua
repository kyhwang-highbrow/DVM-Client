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
    vars['skipBtn']:registerScriptTapHandler(function() self:click_screenBtn() end)
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

    SoundMgr:playBGM('bgm_dungeon_victory', false)    
    visual_node:changeAni('result_appear', false)
    visual_node:addAniHandler(function()
        visual_node:changeAni('result_idle', true)
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
    local ani_duration = 0.5    
    local ani_interval = 0.0

    -- 아이템 카드 보여주는 액션
    local function show_reward(item_card, item_grade, is_last)
        item_card:setVisible(true)
        cca.stampShakeAction(item_card, ITEM_CARD_SCALE * 1.1, 0.1, 0, 0, ITEM_CARD_SCALE)

        -- 등급에 따른 연출
		if (item_grade and item_grade > 3) then
			local rarity_effect = MakeAnimator('res/ui/a2d/card_summon/card_summon.vrp')
			if (item_grade == 5) then
				rarity_effect:changeAni('summon_regend', true)
			else
				rarity_effect:changeAni('summon_hero', true)
			end
			rarity_effect:setScale(1.7)
			rarity_effect:setAlpha(0)
			item_card:addChild(rarity_effect.m_node)
            rarity_effect.m_node:runAction(cc.FadeIn:create(ani_duration))
		end

        if (is_last) then
            self:doNextWorkWithDelayTime(0.5)
        end
    end

    -- 드랍한 아이템 만큼 연출
    local reward_list = self.m_data['drop_reward_list']
    for i, v in ipairs(reward_list) do
        local item_id = v[1]
        local count = v[2]            
        local from = v[3]
        local sub_data = v[4]

        local item_grade = string.find(from, 'grade_') and 
                           string.gsub(from, 'grade_', '') or nil

        local item_card = UI_ItemCard(item_id, count, sub_data)
        item_card.root:setScale(ITEM_CARD_SCALE)
        item_card.root:setVisible(false)

        local target_node = reward_menu.vars['rewardNode'..self.m_grade..'_'..i]
        target_node:addChild(item_card.root)

        local is_last = (i == #reward_list)
        cca.reserveFunc(self.root, 
                        ani_duration * ((i - 1) + ani_interval), 
                        function() show_reward(item_card.root, tonumber(item_grade), is_last) end)
    end
end

-------------------------------------
-- function show_boss_hp
-- @brief 보상이 없는 경우 보스의 남은 체력 보여줌
-------------------------------------
function UI_ClanRaidResult:show_boss_hp()
    local vars = self.vars
    self:initReward()

    local struct_raid = g_clanRaidData:getClanRaidStruct()
    vars['bossHpNode']:setVisible(true)

    -- 레벨, 이름
    local is_rich_label = true
    local name = struct_raid:getBossNameWithLv(is_rich_label)
    vars['levelLabel']:setString(name)

    -- 속성 아이콘
    local attr = struct_raid:getAttr()
    local icon = IconHelper:getAttributeIcon(attr)
    vars['attrNode']:removeAllChildren()
    vars['attrNode']:addChild(icon)

    -- 체력 퍼센트
    local rate = struct_raid:getHpRate()
    vars['hpLabel']:setString(string.format('%0.2f%%', rate))

    -- 체력 게이지
    local action = cc.ProgressTo:create(0.3, rate)
    vars['bossHpGauge1']:runAction(action)

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
            local item_id = v[1]
            local count = v[2]
            local from = v[3]
            local sub_data = v[4]

            local item_card = UI_ItemCard(item_id, count, sub_data)
            item_card.root:setScale(ITEM_CARD_SCALE)

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
end

-------------------------------------
-- function direction_end_click
-------------------------------------
function UI_ClanRaidResult:direction_end_click()
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
	UINavigator:goTo('clan_raid')
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