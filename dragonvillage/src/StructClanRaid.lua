local PARENT = Structure

-------------------------------------
-- class StructClanRaid
-------------------------------------
StructClanRaid = class(PARENT, {
        id = 'string',
        stage = 'string', -- STAGE_ID : 150000
        finalblow = 'boolean', -- 파이널블로우 상태

        hp = 'number',
        max_hp = 'number',

        remain_time = 'number',
        rank_list = 'list',
    })

local THIS = StructClanRaid

-------------------------------------
-- function applyTableData
-------------------------------------
function StructClanRaid:applyTableData(data)
    local replacement = {}
    replacement['remaintime'] = 'remain_time'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i

        -- 해당 던전 참여한 유저 랭킹 리스트
        if (key == 'scores') then
            self.rank_list = {}
            local rank_list = v
            for _, user_data in ipairs(rank_list) do
                local user_info = StructUserInfoClanRaid:create_forRanking(user_data)
                table.insert(self.rank_list, user_info)
            end
        else
            self[key] = v
        end
    end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructClanRaid:getClassName()
    return 'StructClanRaid'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructClanRaid:getThis()
    return THIS
end

-------------------------------------
-- function getStageID
-------------------------------------
function StructClanRaid:getStageID()
    return self['stage']
end

-------------------------------------
-- function getAttr
-------------------------------------
function StructClanRaid:getAttr()
    local stage_id = self['stage']
    return TableStageData:getStageAttr(stage_id)
end

-------------------------------------
-- function getLv
-------------------------------------
function StructClanRaid:getLv()
    return self['stage']%1000
end

-------------------------------------
-- function getBossName
-------------------------------------
function StructClanRaid:getBossName()
    local name = ''
    local stage_id = self['stage']
    local is_boss, monster_id = g_stageData:isBossStage(stage_id)

    if (is_boss) then
        name = TableMonster:getMonsterName(monster_id)
    end

    return name
end

-------------------------------------
-- function getBossNameWithLv
-------------------------------------
function StructClanRaid:getBossNameWithLv()
    local lv = Str('Lv.{1}', self:getLv())
    local name = self:getBossName()
    
    return string.format('%s %s', lv, name)
end

-------------------------------------
-- function getHpRate
-------------------------------------
function StructClanRaid:getHpRate()
    local curr_hp = math_max(self['hp'], 0)
    local max_hp = self['max_hp']
    return (curr_hp/max_hp) * 100
end

-------------------------------------
-- function getRankList
-------------------------------------
function StructClanRaid:getRankList()
    return self['rank_list']
end