local PARENT = TableClass

-------------------------------------
-- class TableColosseumWinReward
-------------------------------------
TableColosseumWinReward = class(PARENT, {
    })

local THIS = TableColosseumWinReward
local L_REWARD
-------------------------------------
-- function init
-------------------------------------
function TableColosseumWinReward:init()
    self.m_tableName = 'table_colosseum_reward'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getNextReawardInfo
-- @brief ���� �¼��� ���Ͽ� ������ ���� �¸� ������ ã�´�
-------------------------------------
function TableColosseumWinReward:getNextReawardInfo(curr_win)
    if (self == THIS) then
        self = THIS()
    end

	-- ���� ȣ�� �� �� ���ĵ� �ε��� ���̺��� �����Ѵ�
	if (not L_REWARD) then
		L_REWARD = {}
		for _, t_reward in pairs(self.m_orgTable) do
			table.insert(L_REWARD, t_reward)
		end
		table.sort(L_REWARD, function(a, b)
			return tonumber(a['win']) < tonumber(b['win'])
		end)
	end

	-- ���� �¼��� ���� ���̺��� ã�´�
	local t_ret
	for _, t_reward in ipairs(L_REWARD) do
		if (t_reward['win'] > curr_win) then
			t_ret = t_reward
			break
		end
	end

	-- ����Ŭ�� ���ڿ��� Ȱ���ϱ� ���ϵ��� t_item���� �ٲ��ش�
	-- ���߿� �Լ��� ����� ����
	if (t_ret) then
		local l_item = plSplit(t_ret['reward'], ';')
		t_ret['t_item'] = {
			['item_id'] = tonumber(l_item[1]) or l_item[1],
			['count'] = tonumber(l_item[2])
		}
	end

    return t_ret
end