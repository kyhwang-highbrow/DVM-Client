local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

----------------------------------------------------------------------
-- class UI_LeagueRaidScene
----------------------------------------------------------------------
UI_LeagueRaidScene = class(PARENT, {
    m_allowBackKey = 'boolean',
})

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  Init functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////

----------------------------------------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_LeagueRaidScene:initParentVariable()
    self.m_uiName = 'UI_LeagueRaidScene'
    self.m_titleStr = Str('레이드')
    self.m_subCurrency = ''
    self.m_bVisible = true              
    self.m_bUseExitBtn = true
end

----------------------------------------------------------------------
-- function init
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_LeagueRaidScene:init()
    local vars = self:load('league_raid.ui')
    UIManager:open(self, UIManager.SCENE)
    self.m_allowBackKey = true


    g_currScene:pushBackKeyListener(
        self, 
        function() 
            if (self.m_allowBackKey) then
                self:click_exitBtn()
            end
        end, 
        'UI_LeagueRaidScene')    

    self:doActionReset()
    self:doAction(nil, false)

    self:initMember()
    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

----------------------------------------------------------------------
-- function initMember
----------------------------------------------------------------------
function UI_LeagueRaidScene:initMember()

end


--[[
 ['my_info']={
    "cannotPlay":false,
    "rune_g7_percent":20,
    "cost_type":"st",
    "team":1,
    "rank_last_index":{
      "up_last_rank":3,
      "down_last_rank":10,
      "stay_last_rank":6
    },
    "todayscore":2262,
    "finishtimestamp":1636901999059,
    "stage":1801001,
    "max_play_count":10,
    "today_play_count":3,
    "last_league":"C",
    "cost_value":2000,
    "season":8,
    "score":2262,
    "reward":{
      "704322":1
    },
    "season_reward":{
      "stay_season_reward":{
        "700001":2500
      },
      "up_season_reward":{
        "700001":3500
      },
      "down_season_reward":{
        "700001":1500
      }
    },
    "league":"B"
        }
]]--


----------------------------------------------------------------------
-- function initUI
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_LeagueRaidScene:initUI()
    local vars = self.vars

    local member_count = g_leagueRaidData:getMemberCount()
    local my_info = g_leagueRaidData:getMyInfo()
    local member_list = g_leagueRaidData:getMemberList()

    if (vars['timeLabel']) then 
        local server_time = Timer:getServerTime()
        time = (tonumber(my_info['finishtimestamp'])/1000 - server_time)
        local msg = Str('시즌 종료까지') .. ' ' .. Str('{1} 남음', datetime.makeTimeDesc(time, false, false))
        vars['timeLabel']:setString(msg)
    end

    if (vars['today_score_label']) then vars['today_score_label']:setString(Str('{1}점', comma_value(my_info['todayscore']))) end
    if (vars['season_score_label']) then vars['season_score_label']:setString(Str('{1}점', comma_value(my_info['score']))) end
    if (vars['runeRateLabel']) then vars['runeRateLabel']:setString('+' .. Str('{1}%', my_info['rune_g7_percent'])) end


    local stage_id = my_info['stage']

    local is_boss_stage, monster_id = g_stageData:isBossStage(stage_id)

    if (monster_id) then
        local icon = UI_MonsterCard(monster_id)
        vars['bossNode']:addChild(icon.root)
        --[[
        local res, attr, evolution = TableMonster:getMonsterRes(monster_id)
        local animator = AnimatorHelper:makeMonsterAnimator(res, attr, evolution)
        animator:changeAni('idle', true)
        animator:setScale(0.8)
        vars['bossNode']:addChild(animator.m_node)]]

        -- 보스 이름, 속성 아이콘
        -- 이름
        local name = TableMonster:getMonsterName(monster_id)
        vars['bossLabel']:setString(name)

        local desc = g_stageData:getStageDesc(stage_id)
    end

    self:updateDeckDotImage()
    
    local display_reward = my_info['raid_reward_display']
    local l_reward = pl.stringx.split(display_reward, ';')

    for index, item_id in pairs(l_reward) do
        local node_name = 'itemNode' .. index
        if (vars[node_name]) then
            local icon = UI_ItemCard(tonumber(item_id))
            vars[node_name]:addChild(icon.root)
        end
    end

    self:setRankImage()
    self:setRankView()
    
    if (g_leagueRaidData:isNewSeason()) then
        UI_LeagueRaidCurSeasonPopup()
    end

    if (g_leagueRaidData:getRewardInfo()) then
        UI_LeagueRaidSeasonRewardPopup()
    end
end

----------------------------------------------------------------------
-- function initButton
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_LeagueRaidScene:initButton()
    local vars = self.vars

    if (vars['infoBtn']) then vars['infoBtn']:registerScriptTapHandler(function() UI_LeagueRaidInfoPopup() end) end
    if (vars['rateBtn']) then vars['rateBtn']:registerScriptTapHandler(function() UI_LeagueRaidRatePopup() end) end

    if (vars['enterBtn']) then vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end) end

    if (vars['teamTabBtn1']) then vars['teamTabBtn1']:registerScriptTapHandler(function() self:click_deckBtn(1) end) end
    if (vars['teamTabBtn2']) then vars['teamTabBtn2']:registerScriptTapHandler(function() self:click_deckBtn(2) end) end
    if (vars['teamTabBtn3']) then vars['teamTabBtn3']:registerScriptTapHandler(function() self:click_deckBtn(3) end) end

    if (vars['clearTicketBtn']) then vars['clearTicketBtn']:registerScriptTapHandler(function() self:click_quickClearBtn() end) end
    
end

----------------------------------------------------------------------
-- function refresh
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_LeagueRaidScene:refresh()
    local vars = self.vars
    local my_info = g_leagueRaidData:getMyInfo()

    local today_play_count = my_info['today_play_count']
    local max_play_count = my_info['max_play_count']
    local count_str = Str('{1}/{2}', today_play_count, max_play_count)
        if (vars['countLabel']) then 
        vars['countLabel']:setString(count_str)
        if (today_play_count >= max_play_count) then vars['countLabel']:setColor(COLOR['RED']) else vars['countLabel']:setColor(COLOR['green']) end
    end
    
    -- 날개
    local wing_cost = my_info['cost_value']

    if (vars['actingPowerLabel']) then vars['actingPowerLabel']:setString(comma_value(wing_cost)) end
end


----------------------------------------------------------------------
-- function initTableView
-- brief : 유저별로 UIC_TableView 생성을 위한 help function
----------------------------------------------------------------------
function UI_LeagueRaidScene:initTableView()


end


function UI_LeagueRaidScene:canQuickClear()
    local my_info = g_leagueRaidData:getMyInfo()

    return my_info and my_info['today_play_count'] > 0
end


function UI_LeagueRaidScene:setRankView()
    local vars = self.vars
    local ui = UI_LeagueRaidRankMenu()

    if (vars['league_raidTabMenu']) then 
        vars['league_raidTabMenu']:addChild(ui.root)
        ui.root:setPosition(ZERO_POINT)
    end

end


function UI_LeagueRaidScene:setRankImage()
    local vars = self.vars
    local my_info = g_leagueRaidData:getMyInfo()
    if (not vars['rankNode']) then return end

    -- 로고 sprite를 만들고 scene에 add한다
    local leagueImgName = 'res/ui/icons/rank/league_raid_rank_' .. string.lower(my_info['league'] .. '.png')
    local sprite = cc.Sprite:create(leagueImgName)

    if (sprite) then 
        sprite:setPosition(ZERO_POINT)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['rankNode']:addChild(sprite)
    end

    if (vars['rankVisual']) then
        if (my_info['league'] == 'S') then
            local purple = 'tier_06'
            vars['rankVisual']:setVisible(true)
            vars['rankVisual']:changeAni(purple, true)
        
        elseif (my_info['league'] == 'U') then
            local gold = 'tier_07'
            vars['rankVisual']:setVisible(true)
            vars['rankVisual']:changeAni(gold, true)

        else
            vars['rankVisual']:setVisible(false)
        end
    end
end



function UI_LeagueRaidScene:updateDeckDotImage()
    local vars = self.vars

    local deck_1_cnt = table.count(g_leagueRaidData.m_deck_1)
    local deck_2_cnt = table.count(g_leagueRaidData.m_deck_2)
    local deck_3_cnt = table.count(g_leagueRaidData.m_deck_3)
    local l_deck_cnt = {}
    table.insert(l_deck_cnt, deck_1_cnt)
    table.insert(l_deck_cnt, deck_2_cnt)
    table.insert(l_deck_cnt, deck_3_cnt)

    for i = 1, #l_deck_cnt do
        for j = 1, 5 do
            local node_name = 'slotSprite' .. tostring(i) .. '_' .. tostring(j)
            local is_active = l_deck_cnt[i] >= j
        
            vars[node_name]:setVisible(is_active)
        end
    end
end


----------------------------------------------------------------------
-- function onClose
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_LeagueRaidScene:onClose() 
    self:releaseI_TopUserInfo_EventListener()
    g_currScene:removeBackKeyListener(self)
end

----------------------------------------------------------------------
-- function onFocus
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_LeagueRaidScene:onFocus() 
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  click functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////


----------------------------------------------------------------------
-- function click_deckBtn
----------------------------------------------------------------------
function UI_LeagueRaidScene:click_deckBtn(deck_number)
    local my_info = g_leagueRaidData:getMyInfo()
    local stage_id = my_info['stage']
    local deck_name = 'league_raid_' .. tostring(deck_number)

    g_deckData:setSelectedDeck(deck_name)
    local ui = UI_LeagueRaidDeckSettings(stage_id, deck_name, true)

    -- 닫을때 항상 체크
    ui:setCloseCB(function()
        g_leagueRaidData:updateDeckInfo()
        self:updateDeckDotImage()
    end)
end

----------------------------------------------------------------------------
-- function click_quickClearBtn
----------------------------------------------------------------------------
function UI_LeagueRaidScene:click_quickClearBtn()
    local my_info = g_leagueRaidData:getMyInfo()

    if (not self:canQuickClear()) or (my_info['score'] <= 0) then
        local msg = Str('소탕 기능을 이용하기 위해서는 하루 1회 이상 플레이 해야 합니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)

        return
    end
    
    local today_play_count = my_info['today_play_count']
    local max_play_count = my_info['max_play_count']  

    if (today_play_count >= max_play_count) then
        local msg = Str('하루 입장 제한을 초과했습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end
    
    -- 날개
    local wing_cost = my_info['cost_value']


    if not g_staminasData:hasStaminaCount('st', wing_cost) then
        local function finish_cb()
        end
        local b_use_cash_label = false
        local b_open_spot_sale = true
        local st_charge_popup = UI_StaminaChargePopup(b_use_cash_label, b_open_spot_sale, finish_cb)
        UIManager:toastNotificationRed(Str('날개가 부족합니다.'))
        return
    end


    local function success_cb(ret)
        -- UI연출에 필요한 테이블들
        function proceeding_end_cb()
            -- reward popup
            local text = Str('보상을 획득 했습니다.')
            ItemObtainResult(ret, text)
            self:refresh()
            self.m_allowBackKey = true
        end

        local proceeding_ui = UI_Proceeding()
        proceeding_ui.root:runAction(cc.Sequence:create(cc.DelayTime:create(2.1), 
            cc.CallFunc:create(function() 
                proceeding_ui:setCloseCB(function() 
                    proceeding_end_cb()
                end)
                proceeding_ui:close()
            end)))
    end


    
    local function ok_btn_callback()
        self.m_allowBackKey = false;

        -- /raid/clear
        g_leagueRaidData:request_raidClear(success_cb)
    end


    -- 전투를 시작합니다.
    UI_ConfirmPopup('staminas_st', wing_cost, Str('소탕은 오늘 획득한 최고 점수를 기준으로 보상을 획득합니다.\n소탕하시겠습니까?'), ok_btn_callback)
    --[[
    local msg = Str("소탕")
    local submsg = Str("소탕은 오늘 획득한 최고 점수를 기준으로 보상을 획득합니다.\n소탕하시겠습니까?")
    MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_callback)]]
end


----------------------------------------------------------------------
-- function click_exitBtn
-- @brief pure virtual function of ITopUserInfo_EventListener 
----------------------------------------------------------------------
function UI_LeagueRaidScene:click_exitBtn()
    self:close()
end



----------------------------------------------------------------------------
-- function click_enterBtn
----------------------------------------------------------------------------
function UI_LeagueRaidScene:click_enterBtn()
    local my_info = g_leagueRaidData:getMyInfo()
    local today_play_count = my_info['today_play_count']
    local max_play_count = my_info['max_play_count']  

    if (today_play_count >= max_play_count) then
        local msg = Str('하루 입장 제한을 초과했습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end


    local deck_1_cnt = table.count(g_leagueRaidData.m_deck_1)
    local deck_2_cnt = table.count(g_leagueRaidData.m_deck_2)
    local deck_3_cnt = table.count(g_leagueRaidData.m_deck_3)

    if (deck_1_cnt <= 0) or (deck_2_cnt <= 0) or (deck_3_cnt <= 0) then
        local msg = Str('세개의 출전덱 모두 설정 되어야 게임 진행이 가능합니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
    
        return
    end

    local wing_cost = my_info['cost_value']
    if not g_staminasData:hasStaminaCount('st', wing_cost) then
        local function finish_cb()
        end
        local b_use_cash_label = false
        local b_open_spot_sale = true
        local st_charge_popup = UI_StaminaChargePopup(b_use_cash_label, b_open_spot_sale, finish_cb)
        UIManager:toastNotificationRed(Str('날개가 부족합니다.'))
        return
    end

    local my_info = g_leagueRaidData:getMyInfo()
    local stage_id = my_info['stage']
    local stage_name = 'stage_' .. stage_id

    local finish_cb = function(ret)
        g_deckData:setSelectedDeck('league_raid_1')
        g_leagueRaidData.m_curStageData = ret
        local scene = SceneGame(ret, stage_id, stage_name, true)
        scene:runScene()
    end


    local function ok_btn_callback()
        self.m_allowBackKey = false;

        -- /raid/clear
        g_stageData:requestGameStart(stage_id, nil, nil, finish_cb)
    end


    -- 전투를 시작합니다.
    UI_ConfirmPopup('staminas_st', wing_cost, Str('전투를 시작합니다.'), ok_btn_callback)
end

----------------------------------------------------------------------------
-- function click_devBtn
----------------------------------------------------------------------------
function UI_LeagueRaidScene:click_devBtn()

end






--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  UI_LeagueRaidInfoPopup
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_LeagueRaidInfoPopup = class(UI, {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_LeagueRaidInfoPopup:init()
    local vars = self:load('league_raid_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRouletteInfoPopup')    

    self.m_uiName = 'UI_EventRouletteInfoPopup' 
     
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end





--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  UI_LeagueRaidCurSeasonPopup
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_LeagueRaidCurSeasonPopup = class(UI, {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_LeagueRaidCurSeasonPopup:init()
    local vars = self:load('league_raid_season_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRouletteInfoPopup')    

    self.m_uiName = 'UI_LeagueRaidCurSeasonPopup' 
     
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)

    self:initUI()
end




----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_LeagueRaidCurSeasonPopup:initUI()
    local vars = self.vars

    if (not vars['rankNode']) then return end

    local my_info = g_leagueRaidData:getMyInfo()
    local season = 'c'

    if (my_info and my_info['league']) then
        season = my_info['league']
    end
    
    -- 로고 sprite를 만들고 scene에 add한다
    local leagueImgName = 'res/ui/icons/rank/league_raid_rank_' .. string.lower(season .. '.png')
    local sprite = cc.Sprite:create(leagueImgName)

    if (sprite) then 
        sprite:setPosition(ZERO_POINT)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['rankNode']:addChild(sprite)
    end
end




--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  UI_LeagueRaidRatePopup
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_LeagueRaidRatePopup = class(UI, {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_LeagueRaidRatePopup:init()
    local vars = self:load('league_raid_rate_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_LeagueRaidRatePopup')    

    self.m_uiName = 'UI_LeagueRaidRatePopup' 
     
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)

    self:initUI()
end






--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  UI_LeagueRaidSeasonOpenPopup
--////////////////////////////////////////////////////////////////////////////////////////////////////////
UI_LeagueRaidSeasonOpenPopup = class(UI, {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_LeagueRaidSeasonOpenPopup:init()
    local vars = self:load('league_raid_season_open_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_LeagueRaidSeasonOpenPopup')

    self.m_uiName = 'UI_LeagueRaidSeasonOpenPopup' 

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['joinBtn']:registerScriptTapHandler(function() 
        UINavigator:goTo('league_raid')
        self:close()
    end)
end