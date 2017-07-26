local PARENT = TableClass

-------------------------------------
-- class TableHelp
-------------------------------------
TableHelp = class(PARENT, {
    })

local THIS = TableHelp

local arranged_help_list
-------------------------------------
-- function init
-------------------------------------
function TableHelp:init()
    self.m_tableName = 'table_help'
    self.m_orgTable = TABLE:get(self.m_tableName)
    self:makeArrangedList()
end

-------------------------------------
-- function makeArrangedList
-- @brief ���ʿ� �ѹ� ��ȹ���� ���� ���ϵ��� �ۼ��� ���̺���
-- Ŭ�󿡼� ����ϱ� ���ϰ� ��ȯ�Ѵ�.
-------------------------------------
function TableHelp:makeArrangedList()
    if (arranged_help_list) then
        return
    end

    -- ���̺� ��ȯ
    local t_ret = {}
    local idx = 1
    local category, t_temp
    for i, t_help in pairs(self.m_orgTable) do
        category = t_help['category']
        t_temp = {
            ['title'] = t_help['t_title'],
            ['content'] = t_help['t_content']
        }

        if (t_ret[category]) then
            table.insert(t_ret[category]['l_content'], t_temp)
        else
            t_ret[category] = {
                ['category'] = category, -- ���� key
                ['t_category'] = t_help['t_category'], -- ī�װ� �ѱ�
                ['l_content'] = {t_temp},
                ['idx'] = idx,
            }
            idx = idx + 1
        end
    end

    -- �ε��� ���̺�� �����Ѵ�.
    arranged_help_list = {}
    local idx
    for category, v in pairs(t_ret) do
        idx = v['idx']
        arranged_help_list[idx] = v
    end
end


-------------------------------------
-- function getArrangedList
-------------------------------------
function TableHelp:getArrangedList()
    if (not arranged_help_list) then
        THIS()
    end

    return arranged_help_list
end
