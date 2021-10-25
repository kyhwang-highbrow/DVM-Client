local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

----------------------------------------------------------------------
-- class UI_LeagueRaidScene
----------------------------------------------------------------------
UI_LeagueRaidScene = class(PARENT, {
    
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
    --self.m_subCurrency = 'raid_coin'
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

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_LeagueRaidScene')    
    self:doActionReset()
    self:doAction(nil, false)

    self:initMember()
    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()

    g_dmgateData:MakeSeasonResetPopup(nil, true)
end

----------------------------------------------------------------------
-- function initMember
----------------------------------------------------------------------
function UI_LeagueRaidScene:initMember()

end


--[[
 ['my_info']={
                ['todayscore']=0;
                ['stage']=1801001;
                ['league']='C';
                ['day']=0;
                ['team']=1;
                ['score']=0;
                ['userinfo']={
                        ['lv']=99;
                        ['uid']='ochoi';
                        ['nick']='애니바니티티';
                        ['status']=0;
                        ['leader']={
                                ['transform']=3;
                                ['did']=180061;
                                ['evolution']=3;
                        };
                        ['score']=0;
                };
                ['season']=1;
                ['nextleague']='C';
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
        local msg = Str('{1} 남음', datetime.makeTimeDesc(time, false, false))
        vars['timeLabel']:setString(msg)
    end

    if (vars['today_score_label']) then vars['today_score_label']:setString(Str('{1}점', my_info['todayscore'])) end
    if (vars['season_score_label']) then vars['season_score_label']:setString(Str('{1}점', my_info['score'])) end
    if (vars['runeRateLabel']) then vars['runeRateLabel']:setString(Str('{1}%', my_info['rune_g7_percent'])) end

    local stage_id = my_info['stage']
    if (IS_DEV_SERVER) then
        stage_id = 3011005
    end

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
        cclog(desc)
    end

    self:updateDeckDotImage()

    -- 날개
    local wing_cost = 500

    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id)

    if t_drop then
        wing_cost = t_drop['cost_value'] == 0 and 500 or t_drop['cost_value']
    end

    if (vars['actingPowerLabel']) then vars['actingPowerLabel']:setString(comma_value(wing_cost)) end

    local l_reward = my_info['reward']
    local index = 1

    for item_id, count in pairs(l_reward) do
        local node_name = 'itemNode' .. index
        if (vars[node_name]) then
            local icon = UI_ItemCard(tonumber(item_id), count)
            vars[node_name]:addChild(icon.root)
        end

        index = index + 1
    end

    self:setRankImage()
    self:setRankView()
    

end

----------------------------------------------------------------------
-- function initButton
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_LeagueRaidScene:initButton()
    local vars = self.vars

    if (vars['infoBtn']) then vars['infoBtn']:registerScriptTapHandler(function() UI_LeagueRaidInfoPopup() end) end

    if (vars['enterBtn']) then vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end) end

    if (vars['teamTabBtn1']) then vars['teamTabBtn1']:registerScriptTapHandler(function() self:click_deckBtn(1) end) end
    if (vars['teamTabBtn2']) then vars['teamTabBtn2']:registerScriptTapHandler(function() self:click_deckBtn(2) end) end
    if (vars['teamTabBtn3']) then vars['teamTabBtn3']:registerScriptTapHandler(function() self:click_deckBtn(3) end) end
end

----------------------------------------------------------------------
-- function refresh
-- @brief virtual function of UI
----------------------------------------------------------------------
function UI_LeagueRaidScene:refresh()

end


----------------------------------------------------------------------
-- function initTableView
-- brief : 유저별로 UIC_TableView 생성을 위한 help function
----------------------------------------------------------------------
function UI_LeagueRaidScene:initTableView()


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
    local deck_1_cnt = table.count(g_leagueRaidData.m_deck_1)
    local deck_2_cnt = table.count(g_leagueRaidData.m_deck_2)
    local deck_3_cnt = table.count(g_leagueRaidData.m_deck_3)

    if (deck_1_cnt <= 0) or (deck_2_cnt <= 0) or (deck_3_cnt <= 0) then
        local msg = Str('세개의 출전덱 모두 설정 되어야 게임 진행이 가능합니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
    
        return
    end

    local scene = SceneGame(nil, DEV_STAGE_ID, 'stage_dev', true)
    scene:runScene()
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


