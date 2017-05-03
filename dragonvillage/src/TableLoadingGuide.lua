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
-- @brief weight �ݿ��� getter
-------------------------------------
function TableLoadingGuide:getGuideDataByWeight(guide_type)
	local l_guide = self:getGuideList(guide_type)
	local weight_sum = 0

	-- weight �� �հ踦 ���Ѵ�.
	for i, v in pairs(l_guide) do
		weight_sum = weight_sum + v['weight']
	end

	-- weigth�� ���� �̱�
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
-- @brief �ܼ� util�� ��� .. 
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