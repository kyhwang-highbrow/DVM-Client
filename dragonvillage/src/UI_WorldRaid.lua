local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_WorldRaid
-------------------------------------
UI_WorldRaid = class(PARENT, {
    m_stageId =  'number',
    m_rewardTableView = 'TableView',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_WorldRaid:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_WorldRaid'
    self.m_titleStr = Str('월드 레이드')
	self.m_staminaType = 'cldg'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaid:init()
    local vars = self:load_keepZOrder('world_raid_scene.ui')
    self.m_stageId = 3100101
    UIManager:open(self, UIManager.SCENE)
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_WorldRaid')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()    
    self:refresh()
    self:update()

    self.root:scheduleUpdateWithPriorityLua(function () self:update() end, 1)

    -- 보상 안내 팝업
    local function finich_cb()
        self:checkEnterEvent()
    end

    self:sceneFadeInAction(nil, finich_cb)
end

-------------------------------------
-- function checkEnterEvent
-------------------------------------
function UI_WorldRaid:checkEnterEvent()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_WorldRaid:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaid:initUI()
    local vars = self.vars

    local stage_id = self.m_stageId
    local monster_id_list = g_stageData:getMonsterIDList(stage_id)
    local boss_id = monster_id_list[1]
    local attr = 'fire'

    -- -- 보스 이름
    -- local boss_name = TableMonster():getMonsterName(boss_id)
    -- vars['bossNameLabel']:setString(boss_name)

    -- -- 속성
    -- local attr = self.m_selectedAttr
    -- local icon = IconHelper:getAttributeIconButton(attr)
    -- vars['attrNode']:addChild(icon)

    -- 랭크
    -- local rank = g_eventDealkingData:getMyRank(self.m_bossType, attr)
    -- if (rank < 0) then
    --     vars['rankLabel']:setString(Str('순위 없음'))
    -- else
    --     local ratio = g_eventDealkingData:getMyRate(self.m_bossType, attr)
    --     local percent_text = string.format('%.2f', ratio * 100)
    --     vars['rankLabel']:setString(Str('{1}위 ({2}%)', comma_value(rank), percent_text))
    -- end
    
    -- -- 점수
    -- local score = g_eventDealkingData:getMyScore(self.m_bossType, attr)
    -- if (score < 0) then 
    --     score = 0
    -- else
    --     score = comma_value(score)
    -- end
    -- vars['scoreLabel']:setString(Str('{1}점', score))


    do -- 보너스 속성
        local bonus_str, map_attr = 
                TableWorldRaidBuff:getInstance():getBonusInfo(self.m_stageId, attr, true)
        for k, v in pairs(map_attr) do
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIconButton(k)
            local target_node = vars['bonusTipsNode']
            target_node:removeAllChildren()
            target_node:addChild(icon)
        end

        -- 보너스 속성        
        vars['bonusTipsDscLabel']:setString(bonus_str)    
    end

    do -- 패널티 속성  
        local penalty_str, map_attr =
            TableWorldRaidBuff:getInstance():getBonusInfo(self.m_stageId, attr, false)
        local cnt = table.count(map_attr)
        local idx = 0

        vars['panaltyTipsNode']:removeAllChildren()
        for i=1,4 do
            vars['panaltyTipsNode'..i]:removeAllChildren()
        end
        for k, v in pairs(map_attr) do
            idx = idx + 1
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIconButton(k)
            local target_node = (cnt == 1) and 
                                vars['panaltyTipsNode'] or 
                                vars['panaltyTipsNode'..idx]
            target_node:addChild(icon)
        end

        -- 패널티 속성      
        vars['panaltyTipsDscLabel']:setString(penalty_str)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaid:initButton()
    local vars = self.vars
end

-------------------------------------
-- function makeRewardTableView
-------------------------------------
function UI_WorldRaid:makeRewardTableView()
    local vars = self.vars
    local node = vars['reawardNode']

    -- 최조 한 번만 생성
    if (self.m_rewardTableView) then
        return
    end

    -- 랭킹 보상 테이블
    local table_event_rank = g_eventDealkingData.m_tRewardInfo
    local struct_rank_reward = StructRankReward(table_event_rank, true)
    local l_event_rank = self.m_bossType == 0 and struct_rank_reward:getRankRewardList() or {}
    self.m_structRankReward = struct_rank_reward

    local my_rank = myRankInfo['rank'] or 0
    local my_ratio = myRankInfo['rate'] or 0

    local create_func = function(ui, data)
        self:createRewardFunc(ui, data, myRankInfo)
	end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(640, 60 + 5)
    table_view:setCellUIClass(UI_EventDealkingRankingTotalTabRewardListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_event_rank)
    --table_view:makeDefaultEmptyDescLabel(Str('보스에 대한 랭킹 보상은 제공되지 않습니다.'))

    table_view:update(0) -- 맨 처음 각 아이템별 위치값을 계산해줌
    table_view:relocateContainerFromIndex(idx) -- 해당하는 보상에 포커싱

    self.m_rewardTableView = table_view
    local reward_data, ind = self.m_structRankReward:getPossibleReward(my_rank, my_ratio)

    self.m_rewardTableView:update(0) -- 인덱스 포커싱을 위해 한번의 계산이 필요하다고 한다.
    self.m_rewardTableView:relocateContainerFromIndex(ind)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaid:refresh()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaid:update()
    local vars = self.vars
    local str = g_eventDealkingData:getRemainTimeString()
    vars['timeLabel']:setString(str)
end

--@CHECK
UI:checkCompileError(UI_WorldRaid)







