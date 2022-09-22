local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())
local SCORE_OFFSET_GAP = 20

-------------------------------------
-- class UI_EventIncarnationOfSinsRankingServerTotalTab
-------------------------------------
UI_EventIncarnationOfSinsRankingServerTotalTab = class(PARENT,{
    m_rewardTableView = 'UIC_TableView',
    m_structRankReward = 'StructRankReward',

    m_ownerUI = 'UI_EventIncarnationOfSinsRankingPopup', -- 현재 검색 타입에 대해 받아올 때 필요
    m_searchType = 'string', -- 검색 타입 (world, clan, friend)
    ------------------------------------------------
    m_tRankData = 'table', -- 전체 랭크 정보
    m_rankOffset = 'number', -- 오프셋
    ------------------------------------------------
    m_reward = 'table' -- 보상 정보
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:init(owner_ui)
    local vars = self:load('event_incarnation_of_sins_rank_popup_server.ui')

    self.m_ownerUI = owner_ui
    self.m_searchType = owner_ui.m_rankType
    self.m_tRankData = {}
    self.m_rankOffset = 1

end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:onEnterTab(first)
    if (first == true) then
        self:initReward()
        self:initUI()
        self:initButton()
        self.m_searchType = self.m_ownerUI.m_rankType

        self:refreshRank(self.m_searchType)
    end

    self:refresh()
end

-------------------------------------
-- function initReward
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:initReward()
    self.m_reward = g_eventIncarnationOfSinsData:getNewServerEventReward()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:initUI()
    local vars = self.vars
    vars['serverInfoLabel']:setString(Str('신규 글로벌 서버 외 모든 서버 통합 랭킹입니다.'))

    if g_localData:isGlobalServer() then
        vars['serverInfoLabel']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:initButton()
    local vars = self.vars

    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:refresh()
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:click_infoBtn()
    g_fullPopupManager:showFullPopup('event_newserver')
end

-------------------------------------
-- function makeRankTableView
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:makeRankTableView(data, type)
    local vars = self.vars
    local rank_node = vars['rankListNode']
    local rank_data = data
    local my_rank_data = data[type .. '_my_info']
    
    local l_rank_list = rank_data[type .. '_list'] or rank_data[type .. '_my_info']

    local reward_info = self.m_reward

    local my_rank = my_rank_data['rank']

    -- 상위 보상 정보
    local pre_reward_rank = nil
    local pre_reward = nil
    -- 하위 보상 정보
    local back_reward_rank = nil
    local back_reward = nil

    if my_rank > 0 then
        for rank, reward in pairs(reward_info) do
            local reward_rank = tonumber(rank)

            -- 상위 보상 정보 저장
            if reward_rank < my_rank then
                if pre_reward_rank == nil then
                    pre_reward_rank = reward_rank
                    pre_reward = Str(reward)
                elseif pre_reward_rank < reward_rank then
                    pre_reward_rank = reward_rank
                    pre_reward = Str(reward)
                end
            end
    
            -- 하위 보상 정보 저장
            if reward_rank > my_rank then
                if back_reward_rank == nil then
                    back_reward_rank = reward_rank
                    back_reward = Str(reward)
                elseif back_reward_rank > reward_rank then
                    back_reward_rank = reward_rank
                    back_reward = Str(reward)
                end
            end
        end
        if pre_reward_rank == nil then
            pre_reward_rank = '1'
            pre_reward = Str('애플 맥북 프로 14 (2021)')
        end
    
        vars['rewardUpLabel']:setString(Str('{@yellow}{1}{@default}위 {@yellow}{2}{@default}', pre_reward_rank, pre_reward))
        if back_reward_rank == nil then
            vars['rewardDownLabel']:setVisible(false)
        else
            vars['rewardDownLabel']:setString(Str('{@yellow}{1}{@default}위 {@yellow}{2}{@default}', back_reward_rank, back_reward))
        end

    else
        vars['rewardUpLabel']:setString(Str('죄악의 화신 토벌하고 {@yellow}경품{@default} 받아가세요!'))
        vars['rewardDownLabel']:setString(Str('죄악의 화신 토벌하고 {@yellow}경품{@default} 받아가세요!'))
    end 

    

    -- 이전 랭킹 버튼 누른 후 콜백
    local function func_prev_cb(offset)
        self.m_rankOffset = offset
        self:request_EventIncarnationOfSinsAttrRanking()
    end

    -- 다음 랭킹 버튼 누른 후 콜백
    local function func_next_cb(offset)
        self.m_rankOffset = offset
        self:request_EventIncarnationOfSinsAttrRanking()
    end

    local uid = g_userData:get('uid')
    local create_cb = function(ui, data)
        if (data['uid'] == uid) then
            ui.vars['meSprite']:setVisible(true)
        end
    end

    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_EventIncarnationOfSinsRankingServerTotalTabRankingListItem, create_cb)
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr(Str('랭킹 정보가 없습니다.'))
    rank_list:setOffset(self.m_rankOffset)
    rank_list:makeRankMoveBtn(func_prev_cb, func_next_cb, SCORE_OFFSET_GAP)
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
-- function makeRewardTableView
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:makeRewardUI(ret, type)
    local vars = self.vars

    local my_info = ret[type .. '_my_info']
    local my_rank = my_info['rank']
    local is_org_server = not g_localData:isGlobalServer()

    if ((my_rank > 1000) and is_org_server) then
        vars['rankLabel']:setString(Str('{1}위 미만', 1000))
    elseif my_rank > 0 then
        vars['rankLabel']:setString(Str('{@yellow}{1}위{@default}', my_rank))
    else
        vars['rankLabel']:setString('-')
    end

    -- local remain_time = g_eventIncarnationOfSinsData:getTimeText()
    -- vars['timeLabel']:setString(remain_time)
    
    --------------------------------------------------------------------------------
    -- local node = vars['rewardNode']

    -- if (self.m_rewardTableView) then
    --     return
    -- end

    -- local create_func = function(ui, data)
    --     self:createRewardFunc(ui, data, my_info)
    -- end

    -- local reward_list = {}
    -- for key, data in pairs(self.m_reward) do
    --     local t_data = {}
    --     t_data['rank'] = key
    --     t_data['reward'] = data
    --     table.insert(reward_list, t_data) 
    -- end

    -- local sort_func = function(a, b)
    --     return a['rank'] < b['rank']
    -- end

    -- table.sort(reward_list, sort_func)

    -- local table_view = UIC_TableView(node)
    -- table_view.m_defaultCellSize = cc.size(640, 60 + 5)
    -- table_view:setCellUIClass(UI_EventIncarnationOfSinsRankingServerTotalTabRewardListItem, create_func)
    -- table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- table_view:setItemList(reward_list)

    -- table_view:update(0)

    -- self.m_rewardTableView = table_view

end

-------------------------------------
-- function createRewardFunc
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:createRewardFunc(ui, data, my_info)
    local vars = ui.vars
    
    vars['rankLabel']:setString(Str('{1}위', data['rank']))
    vars['rewardLabel']:setString(Str('{1}', data['reward']))
end



-------------------------------------
-- function request_EventIncarnationOfSinsAttrRanking
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:request_EventIncarnationOfSinsAttrRanking()
    
    local type = 'total'

    if g_localData:isGlobalServer() then 
        -- type이 total
            -- Global 서버일 경우 Global 합산 점수
            -- 그 외 서버일 경우 전서버 합산 점수
        type = 'total'
    else 
        type = 'unified'
    end

    local function success_cb(ret)
        -- 밑바닥 유저를 위한 예외처리
        -- 마침 현재 페이지에 20명이 차있어서 다음 페이지 버튼 클릭이 가능한 상태
        -- 이전에 저장된 오프셋이 1보다 큰 값을 가질 때
        -- 내 랭킹 조회 혹은 페이징을 통한 행위가 있었다고 판단
        if (self.m_rankOffset > 1) then
            
            -- 랭킹 리스트가 비어있는지 확인한다
            local l_rank_list = ret['total_list'] or ret['unified_list'] or {}

            -- 비어있으면 리스트 업뎃을 안하고 팝업만 띄워주자
            if (l_rank_list and #l_rank_list <= 0) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
                return
            end        
        end

        -- 랭킹 테이블 다시 만듬
        self:makeRankTableView(ret, type)
        self:makeRewardUI(ret, type)

        self.m_rankOffset = tonumber(ret['total_offset'])
    end  

    local searchType = (self.m_searchType == 'my' or self.m_searchType == 'top') and 'world' or self.m_searchType

    g_eventIncarnationOfSinsData:request_EventIncarnationOfSinsAttrRanking(type, searchType, self.m_rankOffset, SCORE_OFFSET_GAP, success_cb, nil)
end

-------------------------------------
-- function refreshRank
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTab:refreshRank(type) -- 다음/이전 버튼 눌렀을 경우 offset계산되어서 param으로 줌
    
    self.m_searchType = type
    self.m_rankOffset = (type == 'my') and -1 or 1

    self:request_EventIncarnationOfSinsAttrRanking()
end







-- tableview cell class
local CELL_PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_EventIncarnationOfSinsRankingServerTotalTabRankingListItem
-------------------------------------
UI_EventIncarnationOfSinsRankingServerTotalTabRankingListItem = class(CELL_PARENT,{
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTabRankingListItem:init(m_rankInfo)
    local vars = self:load('event_incarnation_of_sins_rank_popup_all_item_02.ui')
    self.m_rankInfo = m_rankInfo

    -- 닉네임 정보가 없다면, 다음/이전 버튼 데이터
    if (not self.m_rankInfo['nick']) then
        return    
    end

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTabRankingListItem:initUI()
    local vars = self.vars
    local t_rank_info = StructUserInfoArena:create_forRanking(self.m_rankInfo)


    local rank_info = self.m_rankInfo
    local uid = rank_info['uid']
    local uid_server = pl.stringx.split(uid, '@')
    local server_name = uid_server[2]

    -- 서버 표시
    vars['serverLabel']:setVisible(true)
    if server_name then
        vars['serverLabel']:setString(Str(string.upper(server_name)))
    else
        vars['serverLabel']:setString(Str('KOREA'))
    end

    -- 점수 표시
    local score = tonumber(self.m_rankInfo['score'])

    if (score < 0) then
        score = '-'
    else
        score = comma_value(score)
    end

    vars['scoreLabel']:setString(score)

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(self.m_rankInfo['nick'])

    -- 순위 표시
    local rankStr = tostring(comma_value(self.m_rankInfo['rank']))
    if (self.m_rankInfo['rank'] < 0) then
        rankStr = '-'
    end

    vars['rankingLabel']:setString(rankStr)


    do -- 리더 드래곤 아이콘
        local ui = t_rank_info:getLeaderDragonCard()
        if ui then
            ui.root:setSwallowTouch(false)
            vars['profileNode']:addChild(ui.root)
            
			-- ui.vars['clickBtn']:registerScriptTapHandler(function() 
			-- 	local is_visit = true
			-- 	UI_UserInfoDetailPopup:open(t_rank_info, is_visit, nil)
			-- end)
        end
    end

    local struct_clan = t_rank_info:getStructClan()
    if (struct_clan) then
        -- 클랜 이름
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

    vars['itemMenu']:setSwallowTouch(false)
end



-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTabRankingListItem:initButton()
    local vars = self.vars
    
    local t_rank_info = self.m_rankInfo
    local t_clan_info = t_rank_info['clan_info']

    -- if (t_clan_info) then
	--     vars['clanBtn']:registerScriptTapHandler(function()
    --         g_clanData:requestClanInfoDetailPopup(t_clan_info['id'])
    --     end)
    -- end
end








-- tableview cell class
local CELL_PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_EventIncarnationOfSinsRankingServerTotalTabRewardListItem
-------------------------------------
UI_EventIncarnationOfSinsRankingServerTotalTabRewardListItem = class(CELL_PARENT,{
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTabRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('event_incarnation_of_sins_rank_popup_all_item_01.ui')
    
    self:initUI()
end



-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsRankingServerTotalTabRewardListItem:initUI()
    local vars = self.vars
    local t_data = self.m_rewardInfo
    
    vars['rewardLabel']:setVisible(true)
end