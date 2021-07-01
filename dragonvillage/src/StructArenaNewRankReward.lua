
--[[    
    ex) table_arena_rank.csv
        m_lRankRewardData의 구성물 구조

        rank_id = 'number',
        rank_min = 'number',
        rank_max = 'number',
        ratio_min = 'number',
        ratio_max = 'number',
        reward = 'string', -- cash;6000,valor;100
        week = 'number',
--]]


-------------------------------------
-- class StructArenaNewRankReward
-- @brief 콜로세움 랭킹 보상 리스트
-------------------------------------
StructArenaNewRankReward = class({
		m_lRankRewardData = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function StructArenaNewRankReward:init()
    self:makeRankRewardList()    
end

-------------------------------------
-- function makeRankRewardList
-------------------------------------
function StructArenaNewRankReward:makeRankRewardList()
    local table_arena_rank = TABLE:get('table_arena_new_rank')
    local l_rank_reward = {}

    l_rank_reward = table.MapToList(table_arena_rank)

    local sort_func = function(a, b)
        return a['tier_id'] > b['tier_id']
    end
    -- 테이블 정렬
    table.sort(l_rank_reward, sort_func) 

    self.m_lRankRewardData = l_rank_reward or {}
end

-------------------------------------
-- function getRankRewardList
-------------------------------------
function StructArenaNewRankReward:getRankRewardList()
    return self.m_lRankRewardData or {}
end

-------------------------------------
-- function getPossibleReward
-------------------------------------
function StructArenaNewRankReward:getPossibleReward(my_tier, my_ratio)
    local my_rank = my_tier
    local my_rank_rate = tonumber(my_ratio) * 100

    local l_rank_list = self.m_lRankRewardData

    -- 한번도 플레이 하지 않은 경우, 최하위 보여줌
    if (not my_rank) then
        return l_rank_list[#l_rank_list], #l_rank_list
    end
    
    for i,data in ipairs(l_rank_list) do

        if (my_rank == data['tier']) then return data, i end

        --[[
        local rank_min = tonumber(data['rank_min'])
        local rank_max = tonumber(data['rank_max'])

        local ratio_min = tonumber(data['ratio_min'])
        local ratio_max = tonumber(data['ratio_max'])

        -- 순위 필터
        if (rank_min and rank_max) then
            if (rank_min <= my_rank) and (my_rank <= rank_max) then
                return data, i
            end

        -- 비율 필터
        elseif (ratio_min and ratio_max) then
            if (ratio_min < my_rank_rate) and (my_rank_rate <= ratio_max) then
                return data, i
            end
        end
        ]]--
    end

    -- 마지막 보상 리턴
    local last_ind = #l_rank_list
    return l_rank_list[last_ind], last_ind or 0  
end

-------------------------------------
-- function getRankName
-- @brief 순위 값으로 21위 ~ 30위 와 같은 형식의 순위 이름 생성
-- @param
-- {
--      ['tier_id']=17;
--      ['r_name']='21위~30위';
--      ['ratio_min']='';
--      ['rank_min']=21;
--      ['ratio_max']='';
--      ['rank_max']=30;
--      ['r_comment']='';
--      ['week']=1;
--      ['rank_id']=7;
--      ['reward']='cash;4100,valor;50';
--}
-------------------------------------
function StructArenaNewRankReward.getRankName(t_list_item)
    local tierInfo = t_list_item or {}
    local strRankRange = ''
    if (tierInfo['rank_min'] and tierInfo['rank_max'] and tierInfo['rank_min'] ~= '' and tierInfo['rank_max'] ~= '') then
        local isSameRank = tierInfo['rank_min'] == tierInfo['rank_max']

        if (isSameRank) then
            strRankRange = Str('{1}위', tierInfo['rank_min'])  .. '\n' .. Str('{1}점 이상', tierInfo['score_min'])
        else
            strRankRange = Str('{1}위', tierInfo['rank_min']) .. " ~ " .. Str('{1}위', tierInfo['rank_max']) .. '\n' .. Str('{1}점 이상', tierInfo['score_min'])
        end
    end

    if (tierInfo['ratio_max'] and tierInfo['ratio_max'] ~= '') then
        strRankRange = Str('상위 {1}%', tierInfo['ratio_max']) .. '\n' .. Str('{1}점 이상', tierInfo['score_min'])
    end

    if (not strRankRange or strRankRange == '') then
        if (not tierInfo['score_min'] or tierInfo['score_min'] == '' or tierInfo['score_min'] <= 0) then
            strRankRange = '-'
        else
            strRankRange = Str('{1}점 이상', tierInfo['score_min'])
        end 
    end

	return strRankRange
end