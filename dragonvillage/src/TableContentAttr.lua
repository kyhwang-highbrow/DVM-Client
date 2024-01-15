local PARENT = TableClass
-------------------------------------
--- @class TableContentAttr
-------------------------------------
TableContentAttr = class(PARENT, {
})

local instance = nil
-------------------------------------
---@function init
-------------------------------------
function TableContentAttr:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_content_attr'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
---@function getInstance
---@return TableContentAttr instance
-------------------------------------
function TableContentAttr:getInstance()
    if (instance == nil) then
        instance = TableContentAttr()
    end
    return instance
end

-------------------------------------
---@function getAttrListByVal
---@brief 속성들 가져오기
function TableContentAttr:getAttrList(key)    
-------------------------------------
    local str_val = self:getValue(key, 'attr')
    if str_val == nil then
        return {}
    end

    local attr_list = plSplit(str_val, ',')
    return attr_list
end

-------------------------------------
--- @function getBonusInfo
--- @brief 보너스 상성 정보
-------------------------------------
function TableContentAttr:getBonusInfo(key, is_buff)
    local ret = self:makeBuffList(key)

    local map_attr = {}
    local map_buff_type = {}
    local str = ''
    for _, v in ipairs(ret) do
        local buff_attr = v['condition_value']
        local buff_type = v['buff_type']
        local buff_value = v['buff_value']

        -- 보너스
        if (buff_value) and ((is_buff == true and buff_value > 0) or ((is_buff == false and buff_value < 0))) then
            if (map_buff_type[buff_type] == nil) then
                local str_buff = TableOption:getOptionDesc(buff_type, math_abs(buff_value))
                -- 드래그 스킬은 맨 처음 출력
                if (string.find(buff_type, 'drag_cool_add')) then
                    str = (str == '') and str_buff or str_buff .. '\n' .. str
                else
                    str = (str == '') and str_buff or str..'\n'..str_buff
                end
                map_buff_type[buff_type] = true
            end 

            if (map_attr[buff_attr] == nil) then
                map_attr[buff_attr] = true
            end
        end
    end

    return str, map_attr
end

-------------------------------------
--- @function makeStageStageBuffList
--- @brief 버프 리스트
-------------------------------------
function TableContentAttr:makeBuffList(buff_key)
    local attr_list = self:getAttrList(buff_key)
    local l_buff = {}
    local table_buff_list = {
        'atk_multi',
        'def_multi',
        'hp_multi',
        'drag_cool_add',
    }

    for _, buff in ipairs(table_buff_list) do
        local value = self:getValue(buff_key, buff)
        local buff_name = buff

        if value < 0 then
            buff_name = buff_name .. '_debuff'
        end

        -- 속성이 여러개일 경우, 해당 버프를 속성마다 부여
        for _, attr in ipairs(attr_list) do
            local _ret = {}
            _ret['condition_type'] = 'attr'
            _ret['condition_value'] = attr
            _ret['buff_type'] = buff_name
            _ret['buff_value'] = value
            table.insert(l_buff, _ret)
        end
    end

    table.sort(l_buff, function(a, b)
        local sort_val_a = a['buff_type']
        local sort_val_b = b['buff_type']
        return sort_val_a < sort_val_b
    end)

    return l_buff
end