local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_WorldRaidUserDeckInfoPopup
-------------------------------------
UI_WorldRaidUserDeckInfoPopup = class(PARENT, {
    m_tData  = 'table',
    m_structUserInfoWorldRaid = '',
    m_structUser = '',
    m_tableView = 'UIC_TableViewTD',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:init(struct_user, ret)
    self.m_uiName = 'UI_WorldRaidUserDeckInfoPopup'
    self.m_tData = ret
    self.m_structUserInfoWorldRaid = StructUserInfoWorldRaid:createUserInfo(ret)
    self.m_structUser = struct_user
    
    local vars = self:load('world_raid_user.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_WorldRaidUserDeckInfoPopup')

    self:initUI()
    self:initButton()
    --self:refresh()
    --self:makeTableView()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:initUI()
    local vars = self.vars
    self:addTabAuto(1, vars)
    self:addTabAuto(2, vars)
    self:addTabAuto(3, vars)
    self:setTabLabelChangeColor(false)
    self:setTab(1)

    for i = 1,3 do
        local deck = self.m_structUserInfoWorldRaid:getDeck(i)
        vars[string.format('%dTabBtn', i)]:setVisible(deck ~= nil)
    end

    self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:initButton()
    local vars = self.vars
    vars['teamBonusBtn']:registerScriptTapHandler(function() self:click_teamBonusBtn() end)
    vars['lairInfoBtn']:registerScriptTapHandler(function() self:click_lairInfoBtn() end)
    vars['researchInfoBtn']:registerScriptTapHandler(function() self:click_researchInfoBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:refresh()
    local vars = self.vars
    local struct_user_info = self.m_structUserInfoWorldRaid
    local curr_tab = self.m_currTab
    
    do -- 레벨, 닉네임
        local lv = self.m_structUser['lv']
        local nick = self.m_structUser['nick']
        local str = Str('Lv.{1} {2}', lv, nick)
        vars['nameLabel']:setString(str)
    end

    -- -- 전투력 
    local combat_power = struct_user_info:getDeckCombatPower(curr_tab)
    vars['powerLabel']:setString(Str('전투력 : {1}', comma_value(combat_power)))

    do
        -- 테이머 애니
        local tamer_id = self.m_structUser['tamer']
        local tamer_info = self.m_structUser['tamer_info']
        local costume_id = (tamer_info) and tamer_info['costume'] or nil

        local sd_res
        if (costume_id) then
            sd_res = TableTamerCostume:getTamerResSD(costume_id)
        else
            sd_res = TableTamer:getTamerResSD(tamer_id)
        end

        local sd_animator = MakeAnimator(sd_res)
        sd_animator:changeAni('idle', true)
        vars['tamerNode']:addChild(sd_animator.m_node)
    end

    -- 드래곤
    self:refresh_dragons()
    self:makeTableView()
end

-------------------------------------
-- function refresh_dragons
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:refresh_dragons()
    local vars = self.vars
    local curr_tab = self.m_currTab

    local struct_user_info = self.m_structUserInfoWorldRaid
    local player_2d_deck = UI_2DDeck()
    player_2d_deck:setDirection('right')
    vars['formationNode']:removeAllChildren()
    vars['formationNode']:addChild(player_2d_deck.root)
    
    player_2d_deck:initUI()

    local t_pvp_deck = struct_user_info:getDeck(curr_tab)
    local l_dragons = struct_user_info:getDeck_dragonList(curr_tab)
    local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
    player_2d_deck:setDragonObjectList(l_dragons, leader)

    -- 진형 설정
    local formation = 'attack'
    if t_pvp_deck then
        formation = t_pvp_deck['formation'] or 'attack'
    end
    local force_arena = true -- 아레나 진형 체크
    player_2d_deck:setFormation(formation, force_arena)
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:makeTableView()
    local vars = self.vars
    local struct_user_info = self.m_structUserInfoWorldRaid
    local curr_tab = self.m_currTab

    local _, l_dragons = struct_user_info:getDeck_dragonList(curr_tab)

    local node = vars['dragonList']
    node:removeAllChildren()

    local function create_func(ui, data)
    end
    
    local table_view = UIC_TableViewTD(node)
    table_view.m_cellSize = cc.size(600, 100)
    table_view:setCellUIClass(UI_WorldRaidUserDeckInfoRuneListItem, create_func)
    table_view.m_nItemPerCell = 1
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_dragons)
    table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    --table_view:setCellCreatePerTick(3)
    self.m_tableView = table_view
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:onChangeTab(tab, first)

    self:refresh()
end

-------------------------------------
-- function click_teamBonusBtn
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:click_teamBonusBtn()
    local struct_user_info = self.m_structUserInfoWorldRaid
    local l_dragons = struct_user_info:getDeck_dragonList()
    local ui = UI_TeamBonus(TEAM_BONUS_MODE.TOTAL, l_dragons)
    ui:setOnlyMyTeamBonus()
end

-------------------------------------
-- function click_lairInfoBtn
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:click_lairInfoBtn()    
    local struct_user_info = self.m_structUserInfoWorldRaid

    do -- 능력치 텍스트
        local ui = MakePopup('research_ability_popup.ui')
        local lair_stats = struct_user_info:getLairStats()
        local str = TableLairBuffStatus:getInstance():getLairStatStrByIds(lair_stats, true)

        if str == '' then
            ui.vars['infoLabel']:setString(Str('아직 축복 정보가 없습니다.'))
        else
            ui.vars['infoLabel']:setString(str)
        end

        ui.vars['titleLabel']:setString(Str('축복 정보'))
    end
end

-------------------------------------
-- function click_researchInfoBtn
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:click_researchInfoBtn()
    
    local struct_user_info = self.m_structUserInfoWorldRaid

    do -- 능력치 텍스트
        local ui = MakePopup('research_ability_popup.ui')
        local map = TableResearch:getInstance():getAccumulatedBuffList(struct_user_info:getResearchStats())
        local str = TableResearch:getInstance():getResearchBuffMapToStr(map)
        if str == '' then
            ui.vars['infoLabel']:setString(Str('아직 연구 정보가 없습니다.'))
        else
            ui.vars['infoLabel']:setString(str)
        end

        ui.vars['titleLabel']:setString(Str('연구 정보'))
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:click_closeBtn()
    self:close()
end

-------------------------------------
--- @function open
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup.open(user_info , hoid)
    local success_cb = function(ret)

        -- ret = {
        --     pvpuser_info = {
        --       lv = 31,
        --       dragons = { {
        --         lv = 59,
        --         mastery_lv = 10,
        --         train_max_reward = { },
        --         eclv = 0,
        --         reinforce = {
        --           exp = 0,
        --           lv = 6
        --         },
        --         uid = "ksjang3",
        --         mastery_skills = { },
        --         transform = 3,
        --         leader = { },
        --         skill_2 = 5,
        --         skill_1 = 5,
        --         skill_0 = 5,
        --         lock = false,
        --         skill_3 = 1,
        --         grade = 6,
        --         dragon_skin = 0,
        --         exp = 0,
        --         friendship = {
        --           lv = 9,
        --           exp = 0,
        --           atk = 225,
        --           hp = 13500,
        --           def = 225,
        --           feel = 0
        --         },
        --         updated_at = 1701308167150,
        --         mastery_point = 10,
        --         created_at = 1692346897450,
        --         runes = { },
        --         did = 120101,
        --         played_at = 1701308167150,
        --         evolution = 3,
        --         train_slot = { },
        --         id = "64df2a11e89193394c44c7a1"
        --       }, {
        --         lv = 59,
        --         mastery_lv = 0,
        --         train_max_reward = { },
        --         eclv = 0,
        --         reinforce = {
        --           exp = 0,
        --           lv = 6
        --         },
        --         uid = "ksjang3",
        --         mastery_skills = { },
        --         transform = 3,
        --         leader = { },
        --         skill_2 = 5,
        --         skill_1 = 5,
        --         skill_0 = 5,
        --         lock = false,
        --         skill_3 = 1,
        --         grade = 6,
        --         dragon_skin = 0,
        --         exp = 0,
        --         friendship = {
        --           lv = 9,
        --           exp = 0,
        --           atk = 225,
        --           hp = 13500,
        --           def = 225,
        --           feel = 0
        --         },
        --         updated_at = 1704269132906,
        --         mastery_point = 0,
        --         created_at = 1692346965599,
        --         runes = { },
        --         did = 121933,
        --         played_at = 1704269097828,
        --         evolution = 3,
        --         train_slot = { },
        --         id = "64df2a55e89193394c44c7a2"
        --       }, {
        --         lv = 59,
        --         mastery_lv = 0,
        --         train_max_reward = { },
        --         eclv = 0,
        --         reinforce = {
        --           exp = 0,
        --           lv = 6
        --         },
        --         uid = "ksjang3",
        --         mastery_skills = { },
        --         transform = 3,
        --         leader = { },
        --         skill_2 = 5,
        --         skill_1 = 5,
        --         skill_0 = 5,
        --         lock = false,
        --         skill_3 = 1,
        --         grade = 6,
        --         dragon_skin = 0,
        --         exp = 0,
        --         friendship = {
        --           lv = 9,
        --           exp = 0,
        --           atk = 225,
        --           hp = 13500,
        --           def = 225,
        --           feel = 0
        --         },
        --         updated_at = 1704269132917,
        --         mastery_point = 0,
        --         created_at = 1692346865798,
        --         runes = { },
        --         did = 121913,
        --         played_at = 1704269097839,
        --         evolution = 3,
        --         train_slot = { },
        --         id = "64df29f1e89193394c44c79f"
        --       } },
        --       deck = {
        --         tamerInfo = {
        --           skill_lv4 = 1,
        --           tid = 110002,
        --           skill_lv3 = 1,
        --           skill_lv2 = 1,
        --           costume = 730204,
        --           skill_lv1 = 1
        --         },
        --         formationlv = 1,
        --         tamer = 110002,
        --         power = 97577,
        --         deck = {
        --           ["2"] = "64df2a55e89193394c44c7a2",
        --           ["1"] = "64df2a11e89193394c44c7a1",
        --           ["3"] = "64df29f1e89193394c44c79f",
        --           ["4"] = "64df29f1e89193394c44c79f",
        --           ["5"] = "64df29f1e89193394c44c79f"
        --         },
        --         formation = "attack",
        --         leader = 2,
        --         deckName = "arena_new_d"
        --       },
        --       rank = -1,
        --       clan_info = {
        --         id = "5ddb4931970c6204bef38543",
        --         name = "testctwar56",
        --         mark = ""
        --       },
        --       uid = "ksjang3",
        --       max_cnt = 0,
        --       rp = -1,
        --       research_stats = { 10336, 20335 },
        --       rate = "-Infinity",
        --       score = 0,
        --       revenge = false,
        --       tier = "beginner",
        --       lair_stats = { 10210004, 10220001, 10230001, 10240028, 10250023 },
        --       retry_cnt = 0,
        --       tamer = 110002,
        --       runes = { },
        --       nick = "ksjang3",
        --       leader = {
        --         eclv = 0,
        --         lv = 60,
        --         grade = 6,
        --         rlv = 6,
        --         evolution = 3,
        --         did = 121792
        --       },
        --       match = -1,
        --       match_at = 0
        --     }
        --   }

        UI_WorldRaidUserDeckInfoPopup(user_info, ret['detail'])
    end

    g_worldRaidData:request_WorldRaidUserDeck(hoid, success_cb)
end