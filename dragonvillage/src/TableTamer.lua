local PARENT = TableClass

-------------------------------------
-- class TableTamer
-------------------------------------
TableTamer = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableTamer:init()
    self.m_tableName = 'tamer'
    --self.m_orgTable = TABLE:get(self.m_tableName)

    self.m_orgTable = {}

    self.m_orgTable[1] = {type='goni', t_name=Str('고니')}
    self.m_orgTable[2] = {type='nuri', t_name=Str('누리')}
    self.m_orgTable[3] = {type='mokoji', t_name=Str('모코지')}
    self.m_orgTable[4] = {type='kesath', t_name=Str('케사스')}
    self.m_orgTable[5] = {type='durun', t_name=Str('두른')}
    self.m_orgTable[6] = {type='dede', t_name=Str('데데')}
end