local PARENT = TableClass

-------------------------------------
-- class TableLoadingGuide
-------------------------------------
TableLoadingGuide = class(PARENT, {
    })

local THIS = TableLoadingGuide

-------------------------------------
-- function init
-------------------------------------
function TableLoadingGuide:init()
    self.m_tableName = 'loading_guide'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getGuideList
-------------------------------------
function TableLoadingGuide:getGuideList(guide_type)
	return self:filterList('type', guide_type)
end

-------------------------------------
-- function getGuideListFilteredByLevel
-------------------------------------
function TableLoadingGuide:getGuideListFilteredByLevel(l_guide)
	local l_guide_checked_level = {}
	local default_max_level = 999
	local default_min_level = 0
	local user_level = g_userData:get('lv')
    if (not user_level) then
        user_level = 0
    end

	-- 레벨 조건에 맞는 로딩정보를 필터링
	for i, v in pairs(l_guide) do
        local min_level = v['min_level']
		
		-- 판단할 레벨 값 없을 경우 예외처리
		if (not v['min_level']) or (not v['max_level']) then
			table.insert(l_guide_checked_level, v)
	    else
            local min_level = tonumber(v['min_level'])
			if (v['min_level'] == '') then
				min_level = default_min_level
			end

			local max_level = tonumber(v['max_level'])
			if (v['max_level'] == '') then
				max_level = default_max_level
			end
            
			if (user_level < max_level) and (user_level > min_level) then
				table.insert(l_guide_checked_level, v)
            end
		end
	end

	return l_guide_checked_level
end

-------------------------------------
-- function getFilteredGuidList
-------------------------------------
function TableLoadingGuide:getFilteredGuidList(guide_type)
	local l_guide = self:getGuideList(guide_type)
	-- 레벨로 필터링
	l_guide = self:getGuideListFilteredByLevel(l_guide)

	-- 그 외 다른 조건으로 필터링

	return l_guid
end

-------------------------------------
-- function getGuideDataByWeight
-- @brief weight 반영한 getter
-------------------------------------
function TableLoadingGuide:getGuideDataByWeight(guide_type)
	local l_guide = self:getFilteredGuidList(guide_type)

	-- 조건에 맞는 로딩가이드가 하나도 없어 에러가 나면 안됨, 그런 경우, 조건 체크 안한 리스트 불러오도록 예외처리함
	if (#l_guide == 0) then
		l_guide = self:getGuideList(guide_type)
		cclog('### error ### 조건에 맞는 로딩가이드가 없습니다. table_loading_guid.csv를 확인하세요')
	end
	
	local weight_sum = 0

	-- weight 의 합계를 구한다.
	for i, v in pairs(l_guide) do
        local weight = 10
        if (v['weight'] ~= '') then -- 테이블이 비어있을 경우 디폴트로 10 세팅
            weight = v['weight']
        end
		weight_sum = weight_sum + v['weight']
	end

	-- weigth에 의한 뽑기
	local ret_data
	local rand = math_random(weight_sum)
	for i, v in pairs(l_guide) do
		rand = rand - v['weight']
		if (rand <= 0) then
			ret_data = v
			break
		end
	end

	return ret_data
end

-------------------------------------
-- function getGuideData_Order
-- @brief 단순 util로 사용 .. 
-------------------------------------
function TableLoadingGuide:getGuideData_Order(l_table, order)
	local ret_data
	for i, v in pairs(l_table) do
		if (v['order'] == order) then
			ret_data = v
			break
		end
	end
	return ret_data
end	

-------------------------------------
-- function getLoadingImg
-------------------------------------
function TableLoadingGuide:getLoadingImg(gid)
	local t_loading = self:get(gid)
	local tip_icon = IconHelper:getIcon(t_loading['res'])

	return tip_icon
end

-------------------------------------
-- function getLoadingDesc
-------------------------------------
function TableLoadingGuide:getLoadingDesc(gid)
	local t_loading = self:get(gid)
	local tip_str = Str(t_loading['t_desc'])

	return tip_str
end

-------------------------------------
-- function getRandomStageGuid
-- @breif 모험모드에서 랜덤으로 가이드 설명 리턴
-------------------------------------
function TableLoadingGuide:getRandomStageGuid()
    if (self == THIS) then
        self = THIS()
    end
    
    local l_guid_list = self:getFilteredGuidList('in_adventure')
    local idx = math_random(1, #l_guid_list)
    local str = Str(l_guid_list[idx]['t_desc'])
    return str
end
