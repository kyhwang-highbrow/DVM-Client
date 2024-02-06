local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_WorldRaidBoard
-------------------------------------
UI_WorldRaidBoard = class(PARENT, {    
    m_rewardTableView = 'TableView',
    m_rankingTableView = 'TableView',
    m_searchType = 'number',
    m_rankOffset = 'number',
    m_worldRaidId = 'number',
    m_profileFrameid = 'number',
    m_complimentCount = 'number',

    m_tRankingRewardInfo = 'Table',
    })

-------------------------------------
--- @function initParentVariable
--- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_WorldRaidBoard:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_WorldRaidBoard'
    self.m_titleStr = Str('월드 레이드')
	--self.m_staminaType = 'cldg'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    --self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

local SCORE_OFFSET_GAP = 30
-------------------------------------
--- @function init
-------------------------------------
function UI_WorldRaidBoard:init(world_raid_id, ret)
    local vars = self:load('world_raid_total_ranking.ui')
    self.m_searchType = 1
    self.m_rankOffset = 1
    self.m_worldRaidId = world_raid_id
    self.m_profileFrameid = 0
    self.m_tRankingRewardInfo = {}
    self.m_complimentCount = ret['compliment_cnt'] or 0
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
        self:makeRankingRewardInfo(ret)
        self:checkEnterEvent()
        self:initDevPanel()
    end

    self:sceneFadeInAction(nil, finich_cb)
end

-------------------------------------
--- @function makeRankingRewardInfo
-------------------------------------
function UI_WorldRaidBoard:makeRankingRewardInfo(ret)
    self.m_tRankingRewardInfo = {}

    if ret['my_info'] == nil then
        return
    end

    self.m_tRankingRewardInfo['user_info'] = StructUserInfoClanRaid:create_forRanking(ret['my_info'])
    self.m_tRankingRewardInfo['rank'] = StructUserInfoClanRaid:create_forRanking(ret['my_info'])
    local prev_rank = ret['my_info']['rank'] or 0
    local prev_ratio = ret['my_info']['rate'] or 0

    local reward_info = g_worldRaidData:getPossibleReward(prev_rank, prev_ratio)
    local l_reward = g_itemData:parsePackageItemStr(reward_info['sh_reward'])
    local profile_frame = reward_info['profile_frame'] or ''

    if profile_frame ~= '' then
        local t_item = {item_id=profile_frame, count=1}
        self.m_profileFrameid = profile_frame
        table.insert(l_reward, 1, t_item)
    end

    self.m_tRankingRewardInfo['reward_info'] = l_reward
end

-------------------------------------
--- @function checkEnterEvent
-------------------------------------
function UI_WorldRaidBoard:checkEnterEvent()
    if g_worldRaidData:isAvailableWorldRaidRewardRanking() == true then
        local wrid = self.m_worldRaidId
        local finish_cb = function(ret)
            if self.m_tRankingRewardInfo == nil then
                return
            end

            local profile_frames = ret['profile_frames']
            if profile_frames == nil then
                return
            end

            -- 랭킹 정산 보상은 프레임만 있다고 함
            local t_reward = {}
            local profile_frame_id = 0
            for item_id, _ in pairs(profile_frames) do               
                local t_item = {item_id = tonumber(item_id), count = 1}
                table.insert(t_reward, t_item)
                profile_frame_id = tonumber(item_id)
                break                
            end

            local t_item = {item_id = 700330, count = 30}
            table.insert(t_reward, t_item)

            self.m_tRankingRewardInfo['reward_info'] = t_reward
            UI_WorldRaidRewardPopup(self.m_tRankingRewardInfo, profile_frame_id)
        end

        local fail_cb = function(ret)
        end

        g_worldRaidData:request_WorldRaidReward(wrid, finish_cb, fail_cb)
    end
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
    local l_rank_list = rank_data['list'] or {}
    local rank_info = l_rank_list[1]

    if rank_info == nil then
      return
    end
		
    if (vars['itemNode'] ~= nil) then
        local ui = UI_HallOfFameListItem(rank_info, 1)
        ui.vars['scoreLabel']:setVisible(false)
        ui.vars['userNameLabel']:setVisible(false)
        ui.vars['rankingLabel']:setVisible(false)
        vars['itemNode']:addChild(ui.root)
    end

    local t_rank_info = StructUserInfoArena:create_forRanking(rank_info)

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(rank_info['nick'])

    -- 점수 표시
    local score = tonumber(rank_info['score'])

    if (score < 0) then
        score = '-'
    else
        score = comma_value(score)
    end

    vars['scoreLabel']:setString(score)

    -- 순위 표시
    local rankStr = tostring(comma_value(rank_info['rank']))
    if (rank_info['rank'] < 0) then
        rankStr = '-'
    end
    vars['rankLabel']:setString(rankStr)

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
    local my_rank_data = data['my_info'] or g_userData:makeDummyProfileRankingData()

    local make_my_rank_cb = function()        
        local me_rank = UI_WorldRaidRankingListItem(my_rank_data)
        vars['rankMeNode']:addChild(me_rank.root)
        me_rank.vars['meSprite']:setVisible(true)
    end
    
    local l_rank_list = rank_data['list'] or {}
    
    -- -- 이전 랭킹 버튼 누른 후 콜백
    -- local function func_prev_cb(offset)
    --     self.m_rankOffset = offset
    --     self:request_total_ranking()
    -- end

    -- -- 다음 랭킹 버튼 누른 후 콜백
    -- local function func_next_cb(offset)
    --     self.m_rankOffset = offset
    --     self:request_total_ranking()
    -- end

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
    --rank_list:makeRankMoveBtn(func_prev_cb, func_next_cb, 20)
    rank_list:makeRankList(rank_node, cc.size(550, (55 + 5)))

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
    local compliment_cnt = self.m_complimentCount
    vars['likeLabel']:setString(comma_value(compliment_cnt))

    

    local is_available = g_worldRaidData:isAvailableWorldRaidRewardCompliment()
    if is_available == false then
        vars['cheerBtn']:setBlockMsg(Str("이미 축하를 보냈습니다."))
    else
        vars['cheerBtn']:setBlockMsg(nil)
    end

    vars['rewardMenu']:setVisible(is_available)
    vars['notiSprite']:setVisible(is_available)
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
  local l_reward_item = {{item_id = 700001, count = 500}}

  local finish_cb = function(ret)
    self.m_complimentCount = ret['compliment_cnt']
    local ui = UI_ObtainToastPopup(l_reward_item)
    ui.vars['rewardTitleLabel']:setString(Str('축하 보상 획득'))
    self:refresh()
  end

  g_worldRaidData:request_WorldRaidCompliment(self.m_worldRaidId, finish_cb)
end

-------------------------------------
--- @function click_resetBtn
-------------------------------------
function UI_WorldRaidBoard:click_resetBtn(type)
    local vars = self.vars

    local finish_cb = function(ret)
        UIManager:toastNotificationRed('초기화 완료')

        self:close()

        if type ~= 'ranking' then
            UI_WorldRaidBoard.open()
        end
    end
  
    g_worldRaidData:request_WorldRaidReset(self.m_worldRaidId, type, finish_cb)
end

-------------------------------------
--- @function request_total_ranking
-------------------------------------
function UI_WorldRaidBoard:request_total_ranking()
  local searchType = 'world' 
  local function success_cb(ret)
      -- 밑바닥 유저를 위한 예외처리
      -- 마침 현재 페이지에 20명이 차있어서 다음 페이지 버튼 클릭이 가능한 상태
      -- 이전에 저장된 오프셋이 1보다 큰 값을 가질 때
      -- 내 랭킹 조회 혹은 페이징을 통한 행위가 있었다고 판단
      if (self.m_rankOffset > 1) then
          -- 랭킹 리스트가 비어있는지 확인한다
          local l_rank_list = ret['total_list'] or {}
          -- 비어있으면 리스트 업뎃을 안하고 팝업만 띄워주자
          if (l_rank_list and #l_rank_list <= 0) then
              MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
              return
          end
      end

      -- 랭킹 테이블 다시 만듬
      self:makeRankTableView(ret)      
      self.m_rankOffset = tonumber(ret['total_offset'])
  end

  g_worldRaidData:request_WorldRaidRanking(self.m_worldRaidId, searchType, self.m_rankOffset, SCORE_OFFSET_GAP, success_cb)
end

-------------------------------------
-- function initDevPanel
-- @brief 개발용 코드
-------------------------------------
function UI_WorldRaidBoard:initDevPanel()
    local vars = self.vars
    
    if (IS_TEST_MODE()) then
        local dev_panel = UI_DevPanel()
        self.root:addChild(dev_panel.root)

        do -- 칭찬 초기화
            local t_component = StructDevPanelComponent:create('normal')
            local function func()
                self:click_resetBtn('compliment')
            end
        
            t_component['cb1'] = func
            t_component['str'] = '칭찬 초기화'
            dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
        end

        do -- 랭킹 정산 보상 초기화
            local t_component = StructDevPanelComponent:create('coop')
            local function func()
                self:click_resetBtn('ranking')
            end

            t_component['cb1'] = func
            t_component['str'] = '랭킹 정산 보상 초기화'
            dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
        end

        do -- 칭찬 횟수 초기화
            local t_component = StructDevPanelComponent:create('linger')
            local function func()
                self:click_resetBtn('compliment_cnt')
            end
        
            t_component['cb1'] = func
            t_component['str'] = '칭찬 횟수 초기화'
            dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
        end

        do -- 칭찬 초기화
            local t_component = StructDevPanelComponent:create('del_frames')
            local function func()
                self:click_resetBtn('frame')
            end
        
            t_component['cb1'] = func
            t_component['str'] = '보유 프레임 제거'
            dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
        end

    end
end


-------------------------------------
--- @function open
-------------------------------------
function UI_WorldRaidBoard.open(lobby_milestone)

  local wrid = g_worldRaidData:getPrevSeasonWrid()
    local function finish_cb(ret)
        local ui = UI_WorldRaidBoard(wrid, ret)
    end    
    g_worldRaidData:request_WorldRaidRanking(wrid, 'world', 1, SCORE_OFFSET_GAP, finish_cb)
end

--@CHECK
UI:checkCompileError(UI_WorldRaidBoard)