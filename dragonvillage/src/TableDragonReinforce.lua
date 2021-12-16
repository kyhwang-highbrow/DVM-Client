local PARENT = TableClass

-------------------------------------
-- class TableDragonReinforce
-------------------------------------
TableDragonReinforce = class(PARENT, {
    })

local THIS = TableDragonReinforce

local S_GRADE_REINFORCE = nil

MAX_DRAGON_REINFORCE = 6

-------------------------------------
-- function init
-------------------------------------
function TableDragonReinforce:init()
    self.m_tableName = 'table_dragon_reinforce'
    self.m_orgTable = TABLE:get(self.m_tableName)

	if (not S_GRADE_REINFORCE) then
		S_GRADE_REINFORCE = {}
		for i = 1, 6 do
			local list = self:filterList('birth_grade', i)
			table.sort(list, function(a, b)
				return a['id'] < b['id']
			end)
			S_GRADE_REINFORCE[i] = list
		end
	end
end

-------------------------------------
-- function getReinforceRateTable
-------------------------------------
function TableDragonReinforce:getReinforceRateTable(did, rlv)
	if (self == THIS) then
        self = THIS()
    end

	-- 태생 등급으로 대상 리스트 구함
	local birth_grade = TableDragon:getBirthGrade(did)

	local t_r_rate = {}

	for _, key in pairs({'atk', 'def', 'hp'}) do
		local r_rate = 0
		for i, t in ipairs(S_GRADE_REINFORCE[birth_grade]) do
			-- 이전 레벨은 값을 전부 더해준다
			if (t['reinforce_step'] < rlv + 1) then
				r_rate = r_rate + t[key .. '_bonus']
			end
		end

		t_r_rate[key] = r_rate
	end

	return t_r_rate
end

-------------------------------------
-- function getCurrMaxExp
-------------------------------------
function TableDragonReinforce:getCurrMaxExp(did, rlv)
	if (self == THIS) then
        self = THIS()
    end

	-- 태생 등급으로 대상 리스트 구함
	local birth_grade = TableDragon:getBirthGrade(did)
	local t_reinforce = S_GRADE_REINFORCE[birth_grade][rlv + 1]
	
	if (not t_reinforce) then
		return
	end

	return t_reinforce['exp']
end


-------------------------------------
-- function getCurrMaxExp
-------------------------------------
function TableDragonReinforce:getAllMaxExp(did, rlv)
	if (self == THIS) then
        self = THIS()
    end

    local result = {}

	-- 태생 등급으로 대상 리스트 구함
    local index = 1
	local birth_grade = TableDragon:getBirthGrade(did)
	local t_reinforce = S_GRADE_REINFORCE[birth_grade][rlv + index]

    while (t_reinforce and t_reinforce['exp']) do
	    if (not t_reinforce) then break end

        table.insert(result, t_reinforce['exp'])
        index = index + 1
        t_reinforce = S_GRADE_REINFORCE[birth_grade][rlv + index]
    end
	

	return result
end

-------------------------------------
-- function getCurrCost
-------------------------------------
function TableDragonReinforce:getCurrCost(did, rlv)
	-- 태생 등급으로 대상 리스트 구함
	local birth_grade = TableDragon:getBirthGrade(did)
	local t_reinforce = S_GRADE_REINFORCE[birth_grade][rlv + 1]
	
	if (not t_reinforce) then
		return
	end

	return t_reinforce['reinforce_cost_gold']
end

-------------------------------------
-- function getTotalRateTable
-------------------------------------
function TableDragonReinforce:getTotalRateTable(did)
	if (self == THIS) then
        self = THIS()
    end
	
	-- 태생 등급으로 대상 리스트 구함
	local birth_grade = TableDragon:getBirthGrade(did)

	local t_r_rate = {}

	for _, key in pairs({'atk', 'def', 'hp'}) do
		local r_rate = 0
		for i, t in ipairs(S_GRADE_REINFORCE[birth_grade]) do
			r_rate = r_rate + t[key .. '_bonus']
		end
		t_r_rate[key] = r_rate
	end

	return t_r_rate
end

-------------------------------------
-- function getTotalExp
-------------------------------------
function TableDragonReinforce:getTotalExp()
	return 960
end
