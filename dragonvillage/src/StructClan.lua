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
    
    -- @ generator
    getsetGenerator_simple('StructClan', {'name', 'intro', 'notice', 'master'})
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
-- function getClanName
-------------------------------------
function StructClan:getClanName()
    return self['name']
end

-------------------------------------
-- function getMasterNick
-------------------------------------
function StructClan:getMasterNick()
    return self['master']
end

-------------------------------------
-- function getMemberCntText
-------------------------------------
function StructClan:getMemberCntText()
    local text = Str('클랜원 {1}/{2}', self['member_cnt'], 20)
    return text
end

-------------------------------------
-- function isAutoJoin
-------------------------------------
function StructClan:isAutoJoin()
    return self['join']
end

-------------------------------------
-- function getClanIntroText
-------------------------------------
function StructClan:getClanIntroText()
    local intro_text = self['intro']

    if (not intro_text) or (intro_text == '') then
        intro_text = Str('클랜 소개가 없습니다.')
    end

    return intro_text
end

-------------------------------------
-- function makeClanMarkIcon
-------------------------------------
function StructClan:makeClanMarkIcon()
    local icon = self.m_structClanMark:makeClanMarkIcon()
    return icon
end