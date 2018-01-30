local PARENT = TableClass

-- Ĺ×ŔĚşí Ćű
-- ['material_1']=120071;
-- ['t_name']='şíˇ˘ÂôśÇ';
-- ['t_name_m2']='žĆÄížĆ ź­ĆÝĆŽľĺˇĄ°ď';
-- ['material_grade']=4;
-- ['t_name_m3']='žĆÄížĆ żÉĹ¸ĆźżŔ';
-- ['material_evolution']=3;
-- ['material_4']=120354;
-- ['t_name_m4']='ˇç˝ş ÄšĂ÷°ď';
-- ['did']=120585;
-- ['material_3']=120412;
-- ['req_gold']=100000;
-- ['material_2']=120332;
-- ['t_name_m1']='˝şĆÄŔÎ';

-------------------------------------
-- class TableDragonCombine
-------------------------------------
TableDragonCombine = class(PARENT, {
    })

local THIS = TableDragonCombine

-------------------------------------
-- function init
-------------------------------------
function TableDragonCombine:init()
    self.m_tableName = 'table_dragon_combine'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getCombinationDid
-- @brief 받아온 did가 재료인 조합 드래곤 did를 찾는다
-------------------------------------
function TableDragonCombine:getCombinationDid(did)
	if (self == THIS) then
        self = THIS()
    end

	for _, t_data in pairs(self.m_orgTable) do
		for i = 1, 4 do
			local mtrl_did = t_data['material_' .. i]
			if (mtrl_did == did) then
				return t_data['did']
			end
		end
	end

	return nil
end
