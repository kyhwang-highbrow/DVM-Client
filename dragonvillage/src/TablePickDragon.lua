local PARENT = TableClass

-------------------------------------
-- class TablePickDragon
-------------------------------------
TablePickDragon = class(PARENT, {
    })

local THIS = TablePickDragon

-------------------------------------
-- function init
-------------------------------------
function TablePickDragon:init()
    self.m_tableName = 'table_pick_dragon'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonList
-------------------------------------
function TablePickDragon:getDragonList(item_id)
	if (self == THIS) then
        self = THIS()
    end

	local t_condition = self:get(item_id)

	local l_ret = {}
	local table_dragon = TableDragon()
	local t_dragon

	-- 종류 지정 (나머지 조건은 무시한다..!)
	local l_did = t_condition['custom_dids']
	if (l_did) and (l_did ~= '') then
		for _, did  in ipairs(l_did) do
			t_dragon = table_dragon:get(did)
			if (t_dragon) and (t_dragon['test'] == 1) then
				table.insert(l_ret, t_dragon)
			end
		end
		return l_ret
	end

	-- 필터
	local birth_grade = t_condition['birthgrade']
	local attr = t_condition['attr']
	local weight_key = t_condition['weight_key']

	-- 태생 조건은 웬만하면 있을테니... 아닌 경우가 있다면 수정해주자
	local l_dragon = table_dragon:filterList('birthgrade', birth_grade)
	for _, t_dragon in ipairs(l_dragon) do
		local b = true

		-- test 체크
		if (t_dragon['test'] == 0) then
			b = false
		end

		-- 한정/카드 체크
		local weight = t_dragon[weight_key .. '_weight']
		if (not weight) or (weight == 0) then
			b = false
		end

		-- 속성 체크
		if (attr) and (attr ~= '') and (t_dragon['attr'] ~= attr) then
			b = false
		end

		-- 조건 확인 후 추가
		if (b) then
			table.insert(l_ret, t_dragon)
		end
	end

	return l_ret
end
