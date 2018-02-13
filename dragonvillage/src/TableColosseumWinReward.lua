local PARENT = TableClass

-------------------------------------
-- class TableColosseumWinReward
-------------------------------------
TableColosseumWinReward = class(PARENT, {
    })

local THIS = TableColosseumWinReward

-------------------------------------
-- function init
-------------------------------------
function TableColosseumWinReward:init()
    self.m_tableName = 'table_colosseum_reward'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getNextReawardInfo
-- @brief 현재 승수와 비교하여 다음에 받을 승리 보상을 찾는다
-------------------------------------
function TableColosseumWinReward:getNextReawardInfo(curr_win)
    if (self == THIS) then
        self = THIS()
    end

	local t_ret
	for win, t_reward in pairs(self.m_orgTable) do
		if (win > curr_win) then
			if (not t_ret) then
				t_ret = t_reward
			elseif (t_ret['win'] > win) then
				t_ret = t_reward
			end
		end
	end

	-- 세미클론 문자열을 활용하기 편하도록 t_item으로 바꿔준다
	-- 나중에 함수로 만들어 두자
	if (t_ret) then
		local l_item = plSplit(t_ret['reward'], ';')
		t_ret['t_item'] = {
			['item_id'] = l_item[1],
			['count'] = tonumber(l_item[2])
		}
	end

    return t_ret
end