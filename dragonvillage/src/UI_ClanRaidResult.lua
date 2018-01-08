-------------------------------------
-- class UI_ClanRaidResult
-------------------------------------
UI_ClanRaidResult = class(UI, {
        m_stageID = 'number',
        m_bSuccess = 'boolean',
        m_grade = 'number',

        m_reward_list = '', -- 보상 정보

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
    self.m_reward_list = t_data
    self.m_grade = math_floor(#t_data/3)

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

    local new_score = NumberLabel(total_score, 0, 0.5)
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

    self:doNextWorkWithDelayTime(0.8)
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
    local grade = self.m_grade

    -- 보상없는 경우 임시처리
    if (grade <= 0) then
        self:doNextWork()
        return
    end

    local ui = UI()
    ui:load('clan_raid_result_reward.ui')
    local target_menu = ui.vars['rewardNode'..grade]
    target_menu:setVisible(false)
    vars['dropRewardMenu']:addChild(ui.root)

    self.m_sub_menu = vars['dropRewardMenu']

    local ani_duration = 1.0 
    local ani_interval = 0.2
    local box_visual = vars['boxVisual']

    local ani_1 
    local ani_2
    local result
    local show_reward

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
            result()
        end)
    end

    -- 아이템 카드 보여주는 액션
    local show_reward = function(item_card, is_last)
        item_card:setVisible(true)
        cca.stampShakeAction(item_card, ITEM_CARD_SCALE * 1.1, 0.1, 0, 0, ITEM_CARD_SCALE)

        if (is_last) then
            self:doNextWorkWithDelayTime(0.5)
        end
    end

    result = function()
        -- 드랍한 아이템 만큼 연출
        local reward_list = self.m_reward_list
        for i, v in ipairs(reward_list) do
            local item_id = v[1]
            local count = v[2]
            local sub_data = v[3]

            local item_card = UI_ItemCard(item_id, count, sub_data)
            item_card.root:setScale(ITEM_CARD_SCALE)
            item_card.root:setVisible(false)

            local target_node = ui.vars['rewardNode'..grade..'_'..i]
            target_node:addChild(item_card.root)

            local is_last = (i == #reward_list)
            cca.reserveFunc(self.root, ani_duration * ((i - 1) + ani_interval), function() show_reward(item_card.root, is_last) end)
        end
    end

    ani_1()
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

        local reward_list = self.m_reward_list

        for i, v in ipairs(reward_list) do
            local item_id = v[1]
            local count = v[2]
            local sub_data = v[3]

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