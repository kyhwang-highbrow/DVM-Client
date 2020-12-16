local PARENT = TableClass

-------------------------------------
-- class TableTalkDeet
-- @brief 룬 관리 NPC인 디트의 대사 모음
--        'keyword', 'group', 'line'으로 분류하여 대사가 존재함
-------------------------------------
TableTalkDeet = class(PARENT, {
    })

local THIS = TableTalkDeet

-------------------------------------
-- function init
-------------------------------------
function TableTalkDeet:init()
    self.m_tableName = 'table_talk_deet'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDeetRandomTalkList
-- @brief 룬 관리 화면에서 키워드, 그룹별 대사를 랜덤으로 섞어 리스트를 리턴
-- @return table(list[str])
-------------------------------------
function TableTalkDeet:getDeetRandomTalkList()
    if (self == THIS) then
        self = THIS()
    end

    -- csv상의 데이터를 3중 테이블에 담기
    local t_talk = {}
    for i,v in pairs(self.m_orgTable) do
        local keyword = v['keyword']
        local group = v['group']
        local line = v['line']
        local t_text = v['t_text']

        if (t_talk[keyword] == nil) then
            t_talk[keyword] = {}
        end

        if (t_talk[keyword][group] == nil) then
            t_talk[keyword][group] = {}
        end

        t_talk[keyword][group][tonumber(line)] = t_text
    end

    -- 대사 묶음을 리스트에 담는다 (대사 묶음은 하나의 대사가 2개 이상의 메세지를 포함할 수 있다)
    local l_msg = {}
    for _,t_keyword in pairs(t_talk) do
       for _,t_group in pairs(t_keyword) do
            table.insert(l_msg, t_group)
       end
    end
    l_msg = randomShuffle(l_msg) -- 연결된 대사 묶음 리스트를 랜덤으로 섞기

    -- 대사 묶음 리스트를 순서대로 돌면서 개별 메세지를 리스트에 담는다
    local l_ret_talk_list = {}
    for _,t_group in ipairs(l_msg) do
        for _,talk in ipairs(t_group) do
            table.insert(l_ret_talk_list, talk)
        end
    end

    return l_ret_talk_list
end