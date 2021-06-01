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
function TablePickDragon:getDragonList(item_id, map_released)
	if (self == THIS) then
        self = THIS()
    end

    local map_released = map_released or {}
	local t_condition = self:get(item_id)

	local l_ret = {}
	local table_dragon = TableDragon()
	local t_dragon

	-- 종류 지정 (나머지 조건은 무시한다..!)
	local did_str = t_condition['custom_dids']
	if (did_str) and (did_str ~= '') then
		local l_did = plSplit(did_str, ',')
		for _, did  in ipairs(l_did) do
			t_dragon = table_dragon:get(tonumber(did))
			
            if (t_dragon) then
                local b = false
		
                if (t_dragon['test'] == 2) then
			        b = true
		        elseif (t_dragon['test'] == 1 and map_released[tostring(did)]) then
                    b = true
                end

                if (b) then
				    table.insert(l_ret, t_dragon)
			    end
            end
		end
		return l_ret
	end

	-- 필터
	local birth_grade = isNullOrEmpty(t_condition['birthgrade']) and 5 or t_condition['birthgrade']
	local attr = t_condition['attr']
	local weight_key = t_condition['weight_key']

    -- 제외할 드래곤 리스트
    local not_include_dids = tostring(t_condition['not_include_dids'])
    local l_exclude_dids = isNullOrEmpty(not_include_dids) == true and {} or plSplit(not_include_dids, ',')

	-- 태생 조건은 웬만하면 있을테니... 아닌 경우가 있다면 수정해주자
	local l_dragon = table_dragon:filterList('birthgrade', birth_grade)
	for _, t_dragon in ipairs(l_dragon) do
		local b = true

		-- test 체크
		if (t_dragon['test'] == 0) then
			b = false
        elseif (t_dragon['test'] == 1 and not map_released[tostring(t_dragon['did'])]) then
            b = false
		end

		-- 한정/카드 체크
		local weight = t_dragon[weight_key .. '_weight']
        if (weight_key == 'lm_cardpack') then
            local is_card_pack = t_dragon['category'] == 'cardpack'
            weight = t_dragon['lm_weight']

            if (not is_card_pack) and (not weight or weight <= 0) then b = false end
		elseif (not weight) or (weight == 0) then
			b = false
		end

		-- 속성 체크
		if (isNullOrEmpty(attr) == false) and (t_dragon['attr'] ~= attr) then
			b = false
		end

        -- 특별히 제외시키는 드래곤
	    for _, did in ipairs(l_exclude_dids) do
            if (tostring(did) == tostring(t_dragon['did'])) then 
                b = false 
            end
        end

		-- 조건 확인 후 추가
		if (b) then
			table.insert(l_ret, t_dragon)
		end
	end

	return l_ret
end

-------------------------------------
-- function isCustomPick
-- @brief did 지정 타입 선택권 여부
-------------------------------------
function TablePickDragon:isCustomPick(item_id)
	if (self == THIS) then
        self = THIS()
    end

	local t_pick = self:get(item_id)
	return t_pick['custom_dids'] and (t_pick['custom_dids'] ~= '')
end

-------------------------------------
-- function getCustomList
-- @brief 커스텀된 드래곤 목록 반환
-------------------------------------
function TablePickDragon:getCustomList(item_id)
	if (self == THIS) then
        self = THIS()
    end

	local t_pick = self:get(item_id)
	return t_pick['custom_dids']
end