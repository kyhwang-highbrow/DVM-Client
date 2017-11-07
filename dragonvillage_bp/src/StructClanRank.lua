local PARENT = Structure

-------------------------------------
-- class StructClanRank
-------------------------------------
StructClanRank = class(PARENT, {
        id = 'string',

        name = 'string', -- 클랜 이름
        mark = 'string', -- 클랜 문장
        master = 'string', -- 클랜 마스터 닉네임
        m_structClanMark = 'StructClanMark',

        intro = 'string', -- 클랜 소개.. 없어도 되는데 보내주셔서 저장
        info = '', -- ??

        rank = 'number',
        score = 'number',
    })

local THIS = StructClanRank

-------------------------------------
-- function init
-------------------------------------
function StructClanRank:init(t_data)
    if (t_data) then
        self:applySetting(t_data)
    end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructClanRank:getClassName()
    return 'StructClanRank'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructClanRank:getThis()
    return THIS
end

-------------------------------------
-- function getClanObjectID
-------------------------------------
function StructClanRank:getClanObjectID()
    return self['id']
end

-------------------------------------
-- function getClanName
-------------------------------------
function StructClanRank:getClanName()
    return self['name']
end

-------------------------------------
-- function getClanIntro
-------------------------------------
function StructClanRank:getClanIntro()
    return self['intro']
end

-------------------------------------
-- function getMasterNick
-------------------------------------
function StructClanRank:getMasterNick()
    return self['master']
end

-------------------------------------
-- function getMasterNick
-------------------------------------
function StructClanRank:getClanRank()
    local rank = self['rank']
    if (not rank) or (rank <= 0) then
        rank = '-'
    else
        rank = Str('{1}위', rank)
    end
    return rank
end

-------------------------------------
-- function getMasterNick
-------------------------------------
function StructClanRank:getClanScore()
    local score = self['score']
    if (not score) or (score <= 0) then
        score = '-'
    else
        score = Str('{1}점', comma_value(score))
    end
    return score
end

-------------------------------------
-- function isMyClan
-------------------------------------
function StructClanRank:isMyClan()
    local struct_clan = g_clanData:getClanStruct()
    local my_clan_id = 'not_exist'
    if (struct_clan) then
        my_clan_id = struct_clan:getClanObjectID()
    end

    return (self['id'] == my_clan_id)
end

-------------------------------------
-- function makeClanMarkIcon
-------------------------------------
function StructClanRank:makeClanMarkIcon()
    local icon = self.m_structClanMark:makeClanMarkIcon()
    return icon
end

-------------------------------------
-- function applySetting
-------------------------------------
function StructClanRank:applySetting(t_data)
    for i,v in pairs(self) do
        if (t_data[i] ~= nil) then
            self[i] = v
        end
    end

    if (t_data['mark']) then
        self.m_structClanMark = StructClanMark:create(t_data['mark'])
    else
        self.m_structClanMark = StructClanMark()
    end
end