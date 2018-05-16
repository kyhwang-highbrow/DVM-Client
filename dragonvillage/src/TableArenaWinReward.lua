local PARENT = TableClass

-------------------------------------
-- class TableArenaWinReward
-------------------------------------
TableArenaWinReward = class(PARENT, {
    })

local THIS = TableArenaWinReward
local L_REWARD
-------------------------------------
-- function init
-------------------------------------
function TableArenaWinReward:init()
    self.m_tableName = 'table_arena_reward'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getNextReawardInfo
-- @brief 현재 판수와 비교하여 다음에 받을 승리 보상을 찾는다
-------------------------------------
function TableArenaWinReward:getNextReawardInfo(curr_cnt)
    if (self == THIS) then
        self = THIS()
    end

	-- 최초 호출 할 때 정렬된 인덱스 테이블을 생성한다
	if (not L_REWARD) then
		L_REWARD = {}
		for _, t_reward in pairs(self.m_orgTable) do
			table.insert(L_REWARD, t_reward)
		end
		table.sort(L_REWARD, function(a, b)
			return tonumber(a['play_cnt']) < tonumber(b['play_cnt'])
		end)
	end

	-- 다음 승수의 보상 테이블을 찾는다
	local t_ret
	for _, t_reward in ipairs(L_REWARD) do
		if (t_reward['play_cnt'] > curr_cnt) then
			t_ret = t_reward
			break
		end
	end

	-- 세미클론 문자열을 활용하기 편하도록 t_item으로 바꿔준다
	-- 나중에 함수로 만들어 두자
	if (t_ret) then
		local l_item = plSplit(t_ret['reward'], ';')
		t_ret['t_item'] = {
			['item_id'] = tonumber(l_item[1]) or l_item[1],
			['count'] = tonumber(l_item[2])
		}
	end

    return t_ret
end