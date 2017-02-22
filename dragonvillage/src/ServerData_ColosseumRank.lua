-------------------------------------
-- class ServerData_ColosseumRank
-------------------------------------
ServerData_ColosseumRank = class({
        m_serverData = 'ServerData',

        -- 글로벌 랭킹 (나의 랭킹)
        m_lGlobalRank = 'list',
        m_globalRankOffset = 'number', -- 서버에 랭킹 요청용 offse
        m_bDirtyGlobalRank = 'boolean',

        -- 탑랭킹
        m_lTopRank = 'list',
        m_bDirtyTopRank = 'boolean',

        -- 친구랭킹
        m_lFriendRank = 'list',
        m_bDirtyFriendRank = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ColosseumRank:init(server_data)
    self.m_serverData = server_data
    self.m_bDirtyGlobalRank = true
    self.m_bDirtyTopRank = true
    self.m_bDirtyFriendRank = true
end

-------------------------------------
-- function ckechUpdateGlobalRank
-- @brief 갱신이 필요한지 체크
-------------------------------------
function ServerData_ColosseumRank:ckechUpdateGlobalRank()
    if self.m_bDirtyGlobalRank then
        return
    end

    -- 추후에 time stamp등을 확인해서 여부를 설정할 것
    -- self.m_bDirtyGlobalRank = true
end

-------------------------------------
-- function ckechUpdateTopRank
-- @brief 갱신이 필요한지 체크
-------------------------------------
function ServerData_ColosseumRank:ckechUpdateTopRank()
    if self.m_bDirtyTopRank then
        return
    end

    -- 추후에 time stamp등을 확인해서 여부를 설정할 것
    -- self.m_bDirtyTopRank = true
end

-------------------------------------
-- function ckechUpdateFriendRank
-- @brief 갱신이 필요한지 체크
-------------------------------------
function ServerData_ColosseumRank:ckechUpdateFriendRank()
    if self.m_bDirtyFriendRank then
        return
    end

    -- 추후에 time stamp등을 확인해서 여부를 설정할 것
    -- self.m_bDirtyFriendRank = true
end

-------------------------------------
-- function request_globalRank
-------------------------------------
function ServerData_ColosseumRank:request_globalRank(finish_cb)
    -- 갱신되어야하는지 여부를 확인
    self:ckechUpdateGlobalRank()

    -- 갱신할 필요가 없으면 즉시 리턴
    if (self.m_bDirtyGlobalRank == false) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self.m_bDirtyGlobalRank = false

        self.m_lGlobalRank = {}
        self:initRankList(self.m_lGlobalRank, ret['list'])

        self.m_globalRankOffset = ret['offset']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('limit', 30)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_topRank
-------------------------------------
function ServerData_ColosseumRank:request_topRank(finish_cb)
    -- 갱신되어야하는지 여부를 확인
    self:ckechUpdateTopRank()

    -- 갱신할 필요가 없으면 즉시 리턴
    if (self.m_bDirtyTopRank == false) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self.m_bDirtyTopRank = false

        self.m_lTopRank = {}
        self:initRankList(self.m_lTopRank, ret['list'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('limit', 30)
    ui_network:setParam('offset', 1)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_friendRank
-------------------------------------
function ServerData_ColosseumRank:request_friendRank(finish_cb)
    -- 갱신되어야하는지 여부를 확인
    self:ckechUpdateFriendRank()

    -- 갱신할 필요가 없으면 즉시 리턴
    if (self.m_bDirtyFriendRank == false) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self.m_bDirtyFriendRank = false

        self.m_lFriendRank = {}
        self:initRankList(self.m_lFriendRank, ret['list'])
        self:solveFriendRank()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/ranking_friends')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function initRankList
-------------------------------------
function ServerData_ColosseumRank:initRankList(target_list, data_list)
    for i,v in ipairs(data_list) do
        local user_info = ColosseumUserInfo()
        user_info:setLv(v['lv'])
        user_info:setRankPercent(v['rate'])
        user_info:setRank(v['rank'])
        user_info:setUid(v['uid'])
		user_info:setIsPlayer()
        user_info:setNickname(v['nick'])
        user_info:setRP(v['rp'] or v['score']) -- 서버에서 rp와 score를 함께 사용 중
        user_info:setTier(v['tier'])
        
        -- 리더 드래공 정보
        user_info:setLeaderDragonData(v['leader'])

        local uid = v['uid']
        target_list[uid] = user_info
    end
end

-------------------------------------
-- function sortColosseumRank
-------------------------------------
function ServerData_ColosseumRank:sortColosseumRank(sort_target_list)
    local sort_manager = SortManager()

    -- 시간
    sort_manager:addSortType('time', true, function(a, b, ascending)
            local a_data = a['data']
            local b_data = b['data']

            local a_value = a_data.m_rank
            local b_value = b_data.m_rank

            if (a_value == 'prev') then
                return true
            elseif (b_value == 'prev') then
                return false
            elseif (a_value == 'next') then
                return false
            elseif (b_value == 'next') then
                return true
            end

            return a_value < b_value
        end)

    sort_manager:sortExecution(sort_target_list)
end

-------------------------------------
-- function solveFriendRank
-------------------------------------
function ServerData_ColosseumRank:solveFriendRank()
    local l_friend_list = {}
    
    for i,v in pairs(self.m_lFriendRank) do
        table.insert(l_friend_list, v)
    end

    do -- 정렬
        local sort_manager = SortManager()
        sort_manager:addSortType('default', true, function(a, b, ascending)
                local a_value = a.m_rank
                local b_value = b.m_rank

                return a_value < b_value
            end)

        sort_manager:sortExecution(l_friend_list)
    end


    local curr_rank = nil
    for i,v in ipairs(l_friend_list) do
        if (v.m_rank ~= curr_rank) then
            curr_rank = i
        end

        v.m_friendRank = curr_rank
    end
end

-------------------------------------
-- function request_rankManual
-------------------------------------
function ServerData_ColosseumRank:request_rankManual(offset, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    local offset = math_max(offset, 1)

    -- 성공 콜백
    local function success_cb(ret)
        local rank_list = {}
        self:initRankList(rank_list, ret['list'])

        if finish_cb then
            finish_cb(ret, rank_list)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('limit', 30)
    ui_network:setParam('offset', offset)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end