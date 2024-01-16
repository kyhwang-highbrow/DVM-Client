local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_WorldRaidBoard
-------------------------------------
UI_WorldRaidBoard = class(PARENT, {    
    m_rewardTableView = 'TableView',
    m_rankingTableView = 'TableView',
    m_searchType = 'number',
    m_rankOffset = 'number',
    })

-------------------------------------
--- @function initParentVariable
--- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_WorldRaidBoard:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_WorldRaidBoard'
    self.m_titleStr = Str('월드 레이드')
	self.m_staminaType = 'cldg'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
--- @function init
-------------------------------------
function UI_WorldRaidBoard:init(ret)
    local vars = self:load_keepZOrder('world_raid_total_ranking.ui')
    self.m_searchType = 1
    self.m_rankOffset = 1
    UIManager:open(self, UIManager.SCENE)
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_WorldRaidBoard')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()    
    self:refresh()
    
    self:makeRankHallOfFameView(ret)
    self:makeRankTableView(ret)

    -- 보상 안내 팝업
    local function finich_cb()
        self:checkEnterEvent()
    end

    self:sceneFadeInAction(nil, finich_cb)
end

-------------------------------------
--- @function checkEnterEvent
-------------------------------------
function UI_WorldRaidBoard:checkEnterEvent()
end

-------------------------------------
--- @function click_exitBtn
-------------------------------------
function UI_WorldRaidBoard:click_exitBtn()
    self:close()
end

-------------------------------------
--- @function initButton
-------------------------------------
function UI_WorldRaidBoard:initButton()
    local vars = self.vars    

    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['cheerBtn']:registerScriptTapHandler(function() self:click_cheerBtn() end)
end

-------------------------------------
--- @function initUI
-------------------------------------
function UI_WorldRaidBoard:initUI()
    local vars = self.vars
end

-------------------------------------
--- @function makeRankHallOfFameView
--- @brife 명예의 전당 형식으로 노출
-------------------------------------
function UI_WorldRaidBoard:makeRankHallOfFameView(rank_data)
    local vars = self.vars
    --vars['fameMenu']:setVisible(true)
    local l_rank_list = rank_data['total_list'] or {}
    local rank_info = l_rank_list[1]
    -- if (l_rank_list[idx]) then
    -- else
    --     -- 랭킹 정보가 없다면 없다는 표시를 출력
    --     local ui = UI_HallOfFameListItem(nil)
    -- end
    --local rank = rank_info['rank']
    if (vars['itemNode'] ~= nil) then
        local ui = UI_HallOfFameListItem(rank_info, 1)
        vars['itemNode']:addChild(ui.root)
    end

    local t_rank_info = StructUserInfoArena:create_forRanking(rank_info)

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(t_rank_info:getUserText())

    -- 점수 표시
    vars['scoreLabel']:setString(t_rank_info:getRPText())

    -- 순위 표시
    vars['rankLabel']:setString(t_rank_info:getRankText())

    do -- 리더 드래곤 아이콘
        local ui = t_rank_info:getLeaderDragonCard()
        if ui then
            ui.root:setSwallowTouch(false)
            vars['profileNode']:addChild(ui.root)
            
			ui.vars['clickBtn']:registerScriptTapHandler(function() 
				local is_visit = true
				UI_UserInfoDetailPopup:open(t_rank_info, is_visit, nil)
			end)
        end
    end

    -- 클랜 정보
    local struct_clan = t_rank_info:getStructClan()
    if (struct_clan) then
        
        local clan_name = struct_clan:getClanName()
        vars['clanLabel']:setString(clan_name)
        
        -- 클랜 마크
        local icon = struct_clan:makeClanMarkIcon()
        if (icon) then
            vars['markNode']:addChild(icon)
        end
    else
        vars['clanLabel']:setVisible(false)
    end
end

-------------------------------------
--- @function makeRankTableView
-------------------------------------
function UI_WorldRaidBoard:makeRankTableView(data)
    local vars = self.vars
    local rank_node = vars['rankListNode']
    local rank_data = data
    local my_rank_data = data['total_my_info'] or g_worldRaidData:getCurrentMyRanking()    

    local make_my_rank_cb = function()        
        local me_rank = UI_WorldRaidRankingListItem(my_rank_data)
        vars['rankMeNode']:addChild(me_rank.root)
        me_rank.vars['meSprite']:setVisible(true)
    end
    
    local l_rank_list = rank_data['total_list'] or {}
    
    -- 이전 랭킹 버튼 누른 후 콜백
    local function func_prev_cb(offset)
        self.m_rankOffset = offset
        self:request_ranking()
    end

    -- 다음 랭킹 버튼 누른 후 콜백
    local function func_next_cb(offset)
        self.m_rankOffset = offset
        self:request_ranking()
    end

    local uid = g_userData:get('uid')
    local create_cb = function(ui, data)
        if (data['uid'] == uid) then
            ui.vars['meSprite']:setVisible(true)
        end
    end
    
    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_WorldRaidRankingListItem, create_cb)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr(Str('랭킹 정보가 없습니다.'))
    rank_list:setMyRank(make_my_rank_cb)
    rank_list:setOffset(self.m_rankOffset)
    rank_list:makeRankMoveBtn(func_prev_cb, func_next_cb, 20)
    rank_list:makeRankList(rank_node)

    
    local idx = 0
    for i,v in ipairs(l_rank_list) do
		 if (v['uid'] == uid) then
             idx = i
             break
         end
    end

   -- 최상위 랭킹일 경우에는 포커싱을 1위에 함
   if (self.m_searchType == 'world') and (self.m_rankOffset == 1) then
        idx = 1
   end

   rank_list.m_rankTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
   rank_list.m_rankTableView:relocateContainerFromIndex(idx)
end

-------------------------------------
--- @function refresh
-------------------------------------
function UI_WorldRaidBoard:refresh()
    local vars = self.vars
    vars['likeLabel']:setString(comma_value(0))
end

-------------------------------------
--- @function request_ranking
-------------------------------------
function UI_WorldRaidBoard:request_ranking()

end

-------------------------------------
--- @function open
-------------------------------------
function UI_WorldRaidBoard.open()
    local function finish_cb(ret)
        local ui = UI_WorldRaidBoard(UI_WorldRaidBoard.getDummyRanking())
    end
   
    local function fail_cb()
    end

    -- 삼뉴체크
    g_adventureData:request_adventureInfo(finish_cb, fail_cb)
end

-------------------------------------
--- @function getDummyRanking
-------------------------------------
function UI_WorldRaidBoard.getDummyRanking()

    
    local list = { {
        lv = 31,
        tier = "bronze_3",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110002,
        costume = 730204,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = false,
        un = 9463,
        score = -1,
        total = 0,
        nick = "ksjang3",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 6,
          eclv = 0,
          dragon_skin = 0,
          did = 121854,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "ksjang3",
        rank = -1
      }, {
        lv = 99,
        tier = "bronze_3",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110003,
        costume = 730300,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = false,
        un = 130839362,
        score = -1,
        total = 0,
        nick = "l은달lHenesK",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 122055,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "MFqooDQK9maoJkK3UzMKQ5zFhLB2",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110001,
        costume = 730100,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 9443,
        score = -1,
        total = 0,
        nick = "ksjang112",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 6,
          eclv = 0,
          dragon_skin = 0,
          did = 121683,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "ksjang",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110004,
        costume = 730406,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 1956459,
        score = -1,
        total = 0,
        nick = "TEST001",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 121962,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "vEH4nldukuRKrj032pVBAhetafz1",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110004,
        costume = 730400,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 9223,
        score = -1,
        total = 0,
        nick = "고니",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 121752,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "ykil",
        rank = -1
      }, {
        lv = 34,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110002,
        costume = 730200,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 9698,
        score = -1,
        total = 0,
        nick = "test1228",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 121954,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "test1228",
        rank = -1
      }, {
        lv = 97,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110003,
        costume = 730300,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 141049,
        score = -1,
        total = 0,
        nick = "HeinCheese",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 122055,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "2I5hY6XUrnTnEjnixGUkVrbUSB73",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110005,
        costume = 730502,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 71984,
        score = -1,
        total = 0,
        nick = "꿔바로우",
        leader = {
          lv = 60,
          mastery_lv = 10,
          grade = 6,
          rlv = 6,
          eclv = 0,
          dragon_skin = 0,
          did = 121595,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 10
        },
        uid = "1hFq4remJYO0v85189RfUbofist1",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110004,
        costume = 730403,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 130862025,
        score = -1,
        total = 0,
        nick = "kamari",
        leader = {
          lv = 60,
          mastery_lv = 0,
          grade = 6,
          rlv = 0,
          eclv = 0,
          dragon_skin = 0,
          did = 121792,
          transform = 3,
          mastery_skills = { },
          evolution = 3,
          mastery_point = 0
        },
        uid = "YeoFSrDmUxZY3nM02LEjh5zrSft2",
        rank = -1
      }, {
        lv = 99,
        tier = "beginner",
        clan_info = {
          id = "5ddb4931970c6204bef38543",
          name = "testctwar56",
          mark = ""
        },
        tamer = 110005,
        costume = 730503,
        rp = -1,
        clear_time = -1,
        challenge_score = 0,
        rate = "-Infinity",
        last_tier = "beginner",
        arena_score = 0,
        ancient_score = 0,
        beginner = true,
        un = 2176990,
        score = -1,
        total = 0,
        nick = "I은달I동그라미",
        leader = {
          lv = 60,
          mastery_lv = 10,
          grade = 6,
          rlv = 6,
          eclv = 0,
          dragon_skin = 0,
          did = 120185,
          transform = 3,
          mastery_skills = {
            ["110301"] = 3,
            ["110101"] = 3,
            ["110203"] = 3,
            ["110402"] = 1
          },
          evolution = 3,
          mastery_point = 0
        },
        uid = "cqKc3TF98AZDRsmjfBBiF3OcwK62",
        rank = -1
      } }

    local t_data = {}
    t_data['total_list'] = list
    return t_data
end

-------------------------------------
--- @function click_infoBtn
-------------------------------------
function UI_WorldRaidBoard:click_infoBtn()
    local vars = self.vars
    local str = Str('테이머들로부터 축하를 받은 횟수입니다.')
    local tool_tip = UI_Tooltip_Skill(0, 0, str)
    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['infoBtn'])
end

-------------------------------------
--- @function click_cheerBtn
-------------------------------------
function UI_WorldRaidBoard:click_cheerBtn()
    local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_WorldRaidBoard)