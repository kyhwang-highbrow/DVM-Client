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
-- @brief 최초에 한번 기획에서 관리 편하도록 작성된 테이블을
-- 클라에서 사용하기 편하게 변환한다.
-------------------------------------
function TableHelp:makeArrangedList()
    if (arranged_help_list) then
        return
    end

    -- 테이블 변환
    local t_ret = {}
    local idx = 1
    local category, t_temp
    for i, t_help in ipairs(self.m_orgTable) do
        category = t_help['category']
        t_temp = {
            ['title'] = t_help['t_title'],
            ['content'] = t_help['t_content']
        }

        if (t_ret[category]) then
            table.insert(t_ret[category]['l_content'], t_temp)
        else
            t_ret[category] = {
                ['category'] = category, -- 영문 key
                ['t_category'] = t_help['t_category'], -- 카테고리 한글
                ['l_content'] = {t_temp},
                ['idx'] = idx,
            }
            idx = idx + 1
        end
    end

    -- 인덱스 테이블로 변경한다.
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
