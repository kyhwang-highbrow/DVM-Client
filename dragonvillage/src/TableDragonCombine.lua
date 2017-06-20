local PARENT = TableClass

-- Å×ÀÌºí Æû
-- ['material_1']=120071;
-- ['t_name']='ºí·¢Âô¶Ç';
-- ['t_name_m2']='¾ÆÄí¾Æ ¼­ÆÝÆ®µå·¡°ï';
-- ['material_grade']=4;
-- ['t_name_m3']='¾ÆÄí¾Æ ¿ÉÅ¸Æ¼¿À';
-- ['material_evolution']=3;
-- ['material_4']=120354;
-- ['t_name_m4']='·ç½º Ä¹Ã÷°ï';
-- ['did']=120585;
-- ['material_3']=120412;
-- ['req_gold']=100000;
-- ['material_2']=120332;
-- ['t_name_m1']='½ºÆÄÀÎ';

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

    ccdump(self.m_orgTable)
end

