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

