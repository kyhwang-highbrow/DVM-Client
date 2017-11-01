local PARENT = Structure

-------------------------------------
-- class StructClan
-------------------------------------
StructClan = class(PARENT, {
        id = 'string',
        
        name = 'string', -- 클랜 이름
        intro = 'string', -- 클랜 설명

        member_cnt = 'number',
        join = 'boolean', -- 자동 가입 여부
        
        last_attd = 'number', -- 전날 출석 횟수

        master = 'string', -- 클랜 마스터 닉네임
    })

local THIS = StructClan

-------------------------------------
-- function init
-------------------------------------
function StructClan:init(data)
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructClan:getClassName()
    return 'StructClan'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructClan:getThis()
    return THIS
end