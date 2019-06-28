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
-- function getGuideDataByWeight
-- @brief weight 반영한 getter
-------------------------------------
function TableLoadingGuide:getGuideDataByWeight(guide_type)
	local l_guide = self:getGuideList(guide_type)
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

    local l_guid_list = self:filterList('type', 'in_adventure')
    local idx = math_random(1, #l_guid_list)
    local str = Str(l_guid_list[idx]['t_desc'])
    return str
end
