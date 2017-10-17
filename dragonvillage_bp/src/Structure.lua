-------------------------------------
-- class Structure
-------------------------------------
Structure = class({
    })

local THIS = Structure

-------------------------------------
-- function init
-------------------------------------
function Structure:init(data)
    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function getClassName
-- @brief 클래스명 리턴
-------------------------------------
function Structure:getClassName()
    error('상속받은 클래스에서 getClassName를 재정의하세요')
    return 'Structure'
end

-------------------------------------
-- function getThis
-- @brief 클래스를 리턴 (classDef)
-------------------------------------
function Structure:getThis()
    error('상속받은 클래스에서 getThis를 재정의하세요')
    return THIS
end

-------------------------------------
-- function applyTableData
-- @brief table형태의 데이터를 맴버 변수에 초기화
-- @param data table
-------------------------------------
function Structure:applyTableData(data)
    local l_unknown_member = {}

    -- 클래스를 얻어옴 (classDef)
    local this = self:getThis()

    -- data에 넘어온 데이터를 맴버 변수에 적용
    for key,value in pairs(data) do
        -- unknown member 확인
        if this[key] then
            self[key] = value
        else
            table.insert(l_unknown_member, key)
        end
    end

    -- unknown member일 경우 에러 메시지 출력
    if (0 < #l_unknown_member) then
        cclog('----------------------------------------')
        local error_msg = 'LUA ERROR:\n' .. '            class name : ' .. self:getClassName()
                
        for i,v in ipairs(l_unknown_member) do
            error_msg = error_msg .. '\n            ' .. 'unknown member: ' .. tostring(v)
        end
        cclog(error_msg)
        cclog('----------------------------------------')
    end
end