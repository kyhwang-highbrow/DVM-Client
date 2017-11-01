local PARENT = Structure

-------------------------------------
-- class StructClan
-------------------------------------
StructClan = class(PARENT, {
        id = 'string',
        
        name = 'string', -- 클랜 이름
        intro = 'string', -- 클랜 설명
        mark = 'string', -- 클랜 문장
        notice = 'string', -- 클랜 공지

        member_cnt = 'number',
        join = 'boolean', -- 자동 가입 여부
        
        last_attd = 'number', -- 전날 출석 횟수

        master = 'string', -- 클랜 마스터 닉네임
        empty = '', -- ??

        m_structClanMark = 'StructClanMark',
    })

local THIS = StructClan

-------------------------------------
-- function init
-------------------------------------
function StructClan:init(data)

    if (data['mark']) then
        self.m_structClanMark = StructClanMark:create(data['mark'])
    else
        self.m_structClanMark = StructClanMark()
    end
    
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

-------------------------------------
-- function getClanObjectID
-------------------------------------
function StructClan:getClanObjectID()
    return self['id']
end

-------------------------------------
-- function makeClanMarkIcon
-------------------------------------
function StructClan:makeClanMarkIcon()
    local icon = self.m_structClanMark:makeClanMarkIcon()
    return icon
end