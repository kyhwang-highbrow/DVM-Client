-------------------------------------
-- class UI_WorldRaidResult
-------------------------------------
UI_WorldRaidResult = class(UI, {
    m_stageID = 'number',
    m_bSuccess = 'boolean',
    m_data = '', -- 등급, 보상 정보
    m_bossMonster = 'Monster',
    m_bossType = 'number',
    m_damage = 'number', -- 피해량
    m_grade = 'number', -- 보상 등급
    m_workIdx = 'number',
    m_lWorkList = 'list',
    m_sub_menu = 'cc.Menu', -- 보상이 올라가는 ui
    m_lCloseRankers = 'Table', -- 가까운 랭커
})

local ITEM_CARD_SCALE = 0.65
local ANI_DURATION = 0.2 -- 아이템 카드 보여주는 애니메이션 속도
-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_WorldRaidResult:init(stage_id, boss, damage, t_data, ret)
    self.m_stageID = stage_id    
    self.m_damage = damage
    self.m_bossMonster = boss
    self.m_bossType = math_floor((stage_id - 3100000)/100)
    self.m_data = t_data
    self.m_grade = t_data['dmg_rank']    
    self.m_lCloseRankers = {}

    local vars = self:load('event_dealking_result.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_WorldRaidResult'

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_WorldRaidResult')

    self:initUI()
    self:initButton()
    self:makeCloseRankers(ret)

    self:setWorkList()
    self:doNextWork()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidResult:initUI()
    local vars = self.vars
    if vars['infiniteHpSprite'] ~= nil then
        vars['infiniteHpSprite']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaidResult:initButton()
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
function UI_WorldRaidResult:setWorkList()
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
function UI_WorldRaidResult:direction_showTamer()
end

-------------------------------------
-- function direction_showTamer_click
-------------------------------------
function UI_WorldRaidResult:direction_showTamer_click()
end

-------------------------------------
-- function direction_hideTamer
-------------------------------------
function UI_WorldRaidResult:direction_hideTamer()
end

-------------------------------------
-- function direction_hideTamer_click
-------------------------------------
function UI_WorldRaidResult:direction_hideTamer_click()
end

-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_WorldRaidResult:direction_start()
    local is_win = self.m_bSuccess
    local vars = self.vars
    local visual_node = vars['resultVisual']
    visual_node:setVisible(true)

    local appear_name =  'result_appear'
    local idle_name = 'result_idle'

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
function UI_WorldRaidResult:direction_start_click()
end

-------------------------------------
-- function direction_showScore
-- @brief 점수 연출
-------------------------------------
function UI_WorldRaidResult:direction_showScore()
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
function UI_WorldRaidResult:direction_showScore_click()
end

-------------------------------------
-- function direction_showStar
-- @brief 등급별 연출
-------------------------------------
function UI_WorldRaidResult:direction_showStar()
    local vars = self.vars

--[[     -- 등급별로 연출 다름 test
    local grade = self.m_grade
    local ani = string.format('result_star_%02d', grade)
    local visual_node = vars['starVisual']
    visual_node:setVisible(true)
    visual_node:changeAni(ani, false) ]]

    self:doNextWorkWithDelayTime(1.5)
end

-------------------------------------
-- function direction_showStar_click
-------------------------------------
function UI_WorldRaidResult:direction_showStar_click()
end

-------------------------------------
-- function direction_showReward
-- @brief 보상 연출
-------------------------------------
function UI_WorldRaidResult:direction_showReward()
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
function UI_WorldRaidResult:show_item_reward(reward_menu)
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
function UI_WorldRaidResult:setItemCardRarity(item_card, grade)
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
function UI_WorldRaidResult:getItemCard(data)
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
function UI_WorldRaidResult:show_boss_hp()
    local vars = self.vars
    vars['bossHpNode']:setVisible(true)

    -- 레벨, 이름
    local boss = self.m_bossMonster
    local name = boss:getName()
    vars['levelLabel']:setString(name)

    -- 속성 아이콘
    local attr = boss:getAttribute()
    local icon = IconHelper:getAttributeIconButton(attr)
    vars['attrNode']:removeAllChildren()
    vars['attrNode']:addChild(icon)

    --vars['bossHpGauge1']:setVisible(false)
    --hp_label = NumberLabel(hp_label, 0, 0.3)
    --hp_label:setTweenCallback(tween_cb)
    --local hp_label = vars['hpLabel']
    --hp_label:setString(Str('체력 무한'))
    self:doNextWork()
end

-------------------------------------
-- function direction_showReward_click
-- @brief 클릭시 보상 애니메이션 스킵
-------------------------------------
function UI_WorldRaidResult:direction_showReward_click()
    self.root:stopAllActions()
    self:doNextWork()
    self:initReward()
end

-------------------------------------
-- function initReward
-- @brief 클릭시 아이템 정보 바로 다 나오게 일딴 처리
-------------------------------------
function UI_WorldRaidResult:initReward()
    local vars = self.vars
    local grade = self.m_grade
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_WorldRaidResult:direction_end()
    local vars = self.vars

    vars['okBtn']:setVisible(true)
    vars['statsBtn']:setVisible(true)

    -- 이벤트 아이템 표시
    local t_data = self.m_data
    local event_act = cc.CallFunc:create(function()
        if (not t_data['event_goods_list']) then 
            return 
        end
        local drop_list = t_data['event_goods_list'] or {}
        local idx = 1
        for _, item in ipairs(drop_list) do
            -- 보호 장치
            if (idx > 2) then
                break
            end

            -- item_id 로 직접 체크한다
            if (item['from'] == 'event') then
                -- visible on
                vars['eventNode' .. idx]:setVisible(true)

                -- 재화 아이콘
                local item_id = item['item_id']
                local icon = IconHelper:getItemIcon(item_id)
                vars['eventIconNode' .. idx]:addChild(icon)

                -- 재화 이름
                local item_name = TableItem:getItemName(item_id)
                vars['eventNameLabel' .. idx]:setString(item_name)

                -- 재화 수량
                local cnt = item['count']
                vars['eventLabel' .. idx]:setString(comma_value(cnt))

                idx = idx + 1
            end
        end

        -- 특정 상황에선 노드 이동
        if (vars['eventNode1']:isVisible() == false) and (vars['eventNode2']:isVisible() == true) then
            vars['eventNode2']:setPositionY(100)
        end
    end)

    -- 내 순위 정보가 내려오면 무조건 노출
    if self.m_lCloseRankers['me_ranker'] ~= nil then
        local my_ranking = g_worldRaidData:getCurrentMyRanking()
        local prev_score = my_ranking['score']
        local new_score = self.m_lCloseRankers['me_ranker']['score']
        if new_score > prev_score then
            local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function() 
                self:showLeaderBoard()
            end))
            self.root:runAction(action)
            self.root:runAction(event_act)
        end
    end
end

-------------------------------------
-- function direction_showLeaderBoard_click
-------------------------------------
function UI_WorldRaidResult:direction_showLeaderBoard_click()
end

-------------------------------------
-- function direction_end_click
-------------------------------------
function UI_WorldRaidResult:direction_end_click()
end


-------------------------------------
-- function doNextWork
-------------------------------------
function UI_WorldRaidResult:doNextWork()
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
function UI_WorldRaidResult:doNextWorkWithDelayTime(second)
    local second = second or 1
    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc:create(function() self:doNextWork() end)))
end

-------------------------------------
-- function click_okBtn
-- @brief "확인" 버튼
-------------------------------------
function UI_WorldRaidResult:click_okBtn()
    UINavigator:goTo('world_raid')
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_WorldRaidResult:click_statsBtn()
    -- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
    UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_statusInfo
-------------------------------------
function UI_WorldRaidResult:click_statusInfo()
    UI_HelpStatus()
end

-------------------------------------
-- function click_screenBtn
-------------------------------------
function UI_WorldRaidResult:click_screenBtn()
    if (not self.m_lWorkList[self.m_workIdx]) then
        return
    end

    local func_name = self.m_lWorkList[self.m_workIdx] .. '_click'
    if func_name and (self[func_name]) then
        self[func_name](self)
    end
end

-------------------------------------
--- @function makeCloseRankers
--- @brief 자신과 가까운 순위 계산
-------------------------------------
function UI_WorldRaidResult:makeCloseRankers(ret)
    local l_rankers = ret['rank_list']
    if l_rankers == nil then
        return
    end
    
    local uid = g_userData:get('uid')
    self.m_lCloseRankers = {}
    self.m_lCloseRankers['me_ranker'] = nil
    self.m_lCloseRankers['upper_ranker'] = nil
    self.m_lCloseRankers['lower_rank'] = nil

    for _,data in ipairs(l_rankers) do
        if (data['uid'] == uid) then
            self.m_lCloseRankers['me_ranker'] = data
        end
    end

    if (self.m_lCloseRankers['me_ranker'] == nil) then return end
    local my_rank = self.m_lCloseRankers['me_ranker']['rank']
    local upper_rank = my_rank - 1
    local lower_rank = my_rank + 1

    for _,data in ipairs(l_rankers) do
        if (tonumber(data['rank']) == tonumber(upper_rank)) then
            self.m_lCloseRankers['upper_ranker'] = data
        end

        if (tonumber(data['rank']) == tonumber(lower_rank)) then
            self.m_lCloseRankers['lower_rank'] = data
        end
    end
end

-------------------------------------
--- @function showLeaderBoard
--- @brief 리더 보드 생성
-------------------------------------
function UI_WorldRaidResult:showLeaderBoard(ret)
    -- 게임 후, 앞/뒤 랭커 정보
    local t_upper = self.m_lCloseRankers['upper_ranker']
    local t_me = self.m_lCloseRankers['me_ranker'] 
    local t_lower = self.m_lCloseRankers['lower_rank']

    if (not t_me) then
        return
    end

    -- 게임 전 내 정보    
    local t_ex_me = g_worldRaidData:getCurrentMyRanking()
    if (not t_ex_me) then -- 처음 때린 사람
        t_ex_me = {['score'] = 0, ['rank'] = t_me['rank'] + 1000, ['rate'] = 1}
    end

    -- 리더 보드 추가
    local ui_leader_board = UI_ResultLeaderBoard_EventDealking('event_dealking', true, true) -- type, is_move, is_popup
    ui_leader_board:setScore(t_me['score'] - t_ex_me['score'], t_me['score']) -- param : 더해진 점수, 더해진 점수가 반영된 최종 점수
    ui_leader_board:setRatio(t_ex_me['rate'], t_me['rate'])
    ui_leader_board:setRank(t_ex_me['rank'], t_me['rank'])
    ui_leader_board:setRanker(t_upper, t_me, t_lower)
    ui_leader_board:setCurrentInfo()
    ui_leader_board:startMoving()
end
