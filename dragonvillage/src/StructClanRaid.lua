local PARENT = Structure

CLAN_RAID_STATE = {
    NORMAL = 1, -- 입장 가능
    CHALLENGE = 2, -- 유저 도전중
    FINALBLOW = 3, -- 파이널 블로우 
    CLEAR = 4 -- 클리어
}

-------------------------------------
-- class StructClanRaid
-------------------------------------
StructClanRaid = class(PARENT, {
        id = 'string',
        stage = 'string', -- STAGE_ID : 150000
        finalblow = 'boolean', -- 파이널블로우 상태

        hp = 'SecurityNumberClass',
        max_hp = 'SecurityNumberClass',

        remain_time = 'number',
        rank_list = 'list',

        player = 'user', -- 현재 플레이중인 유저정보

        state = 'CLAN_RAID_STATE'
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
            local total_score = 0
            for _, user_data in ipairs(rank_list) do
                local user_info = StructUserInfoClanRaid:create_forRanking(user_data)
                total_score = total_score + user_info.m_score
                table.insert(self.rank_list, user_info)
            end

            for _, user_data in ipairs(self.rank_list) do
                user_data:setContribution(total_score)
            end

        elseif (key == 'hp' or key == 'max_hp') then
            self[key] = SecurityNumberClass(v)

        else
            self[key] = v
        end
    end

    self:setState()
end

-------------------------------------
-- function setState
-------------------------------------
function StructClanRaid:setState()
    local state = CLAN_RAID_STATE.NORMAL

    local player = self['player']
    -- 본인은 제외 (본인이 플레이 중일 경우 서버에서 끝난걸로 간주)
    if (player and player['uid'] ~= g_userData:get('uid')) then
        state = CLAN_RAID_STATE.CHALLENGE

    elseif (self['finalblow'] == true) and (self['hp']:get() > 0) then
        state = CLAN_RAID_STATE.FINALBLOW

    elseif (self['hp']:get() <= 0) then
        state = CLAN_RAID_STATE.CLEAR
    end

    self.state = state
end

-------------------------------------
-- function getState
-------------------------------------
function StructClanRaid:getState()
    return self.state
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
-- function getBossMid
-------------------------------------
function StructClanRaid:getBossMid()
    local name = ''
    local stage_id = self['stage']
    local is_boss, monster_id = g_stageData:isBossStage(stage_id)

    return monster_id
end

-------------------------------------
-- function getBossLv
-------------------------------------
function StructClanRaid:getBossLv()
    local lv = self:getLv()
    return string.format('Lv.%s', lv)
end

-------------------------------------
-- function getBossNameWithLv
-------------------------------------
function StructClanRaid:getBossNameWithLv(is_richlabel)
    local is_richlabel = is_richlabel or false
    local lv = self:getLv()
    local name = self:getBossName()
    
    local boss_mid = self:getBossMid()
    local attr = TableMonster:getMonsterAttr(boss_mid)

    local str = is_richlabel and
                string.format('{@apricot}Lv.%s {@%s}%s', lv, attr, name) or
                string.format('%s Lv.%s', name, lv)
    return str
end

-------------------------------------
-- function getHp
-------------------------------------
function StructClanRaid:getHp()
    return self['hp']:get()
end

-------------------------------------
-- function getMaxHp
-------------------------------------
function StructClanRaid:getMaxHp()
    return self['max_hp']:get()
end
-------------------------------------
-- function getHpRate
-------------------------------------
function StructClanRaid:getHpRate()
    local curr_hp = math_max(self['hp']:get(), 0)
    local max_hp = self['max_hp']:get()
    return (curr_hp/max_hp) * 100
end

-------------------------------------
-- function getRankList
-------------------------------------
function StructClanRaid:getRankList()
    return self['rank_list']
end

-------------------------------------
-- function getPlayer
-------------------------------------
function StructClanRaid:getPlayer()
    return self['player']
end

-------------------------------------
-- function getFinalblow
-------------------------------------
function StructClanRaid:getFinalblow()
    return self['finalblow']
end

-------------------------------------
-- function getStartTime
-- @brief 서버에서는 플레이 최대 시간을 줌 (시작시간은 10분 감소)
-------------------------------------
function StructClanRaid:getStartTime()
    return self['remain_time']/1000 - (60 * 10)
end

-------------------------------------
-- function getBonusSynastryInfo
-- @brief 해당 던전 보너스 상성 정보
-------------------------------------
function StructClanRaid:getBonusSynastryInfo()
    local stage_id = self:getStageID()
    local ret = TableStageData:getStageBuff(stage_id)

    local map_attr = {}
    local map_buff_type = {}
    local str = '' 
    for _, v in ipairs(ret) do
        local buff_attr = v['condition_value']
        local buff_type = v['buff_type']
        local buff_value = v['buff_value']

        -- 보너스
        if (buff_value) and (buff_value > 0) then
            if (map_buff_type[buff_type] == nil) then
                local str_buff = TableOption:getOptionDesc(buff_type, buff_value)
                str = (str == '') and str_buff or str..'\n'..str_buff

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
-- function getPenaltySynastryInfo
-- @brief 해당 던전 패널티 상성 정보
-------------------------------------
function StructClanRaid:getPenaltySynastryInfo()
    local stage_id = self:getStageID()
    local ret = TableStageData:getStageBuff(stage_id)

    local map_attr = {}
    local map_buff_type = {}
    local str = '' 
    for _, v in ipairs(ret) do
        local buff_attr = v['condition_value']
        local buff_type = v['buff_type']
        local buff_value = v['buff_value']

        -- 패널티
        if (buff_value) and (buff_value < 0) then
            if (map_buff_type[buff_type] == nil) then
                local str_buff = TableOption:getOptionDesc(buff_type, math_abs(buff_value))
                str = (str == '') and str_buff or str..'\n'..str_buff

                map_buff_type[buff_type] = true
            end 

            if (map_attr[buff_attr] == nil) then
                map_attr[buff_attr] = true
            end
        end
    end

    return str, map_attr
end
