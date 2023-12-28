local PARENT = Structure

MAX_STAGE_ID = 1500200
MAX_STAGE = 200

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

        state = 'CLAN_RAID_STATE',
        finish = 'bool',

        clan_raid_type = 'string',
        attr = 'string',
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

    if (not data['finish']) then
        self.finish = false -- 초기화
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

    return g_clanData:getCurSeasonBossAttr()
    --return TableStageData:getStageAttr(stage_id) -- @jhakim 20190207 table_stage에 있는 속성 정보를 따르지 않음
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
-- function getBossNameWithLv
-------------------------------------
function StructClanRaid:getBossNameWithLv(is_richlabel)
    local is_richlabel = is_richlabel or false
    local lv = self:getLv()
    local name = self:getBossName()
    
    local boss_mid = self:getBossMid()

    local attr = TableMonster:getMonsterAttr(boss_mid)

    if (self['attr']) then
        attr = self['attr']
    end

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
    local ret = self:getClanAttrBuffList()

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
                -- 드래그 스킬은 맨 처음 출력
                if (buff_type == 'drag_cool_add') then
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
-- function getPenaltySynastryInfo
-- @brief 해당 던전 패널티 상성 정보
-------------------------------------
function StructClanRaid:getPenaltySynastryInfo()
    local stage_id = self:getStageID()
    local ret = self:getClanAttrBuffList()

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

                -- 드래그 스킬은 맨 처음 출력
                if (buff_type == 'drag_cool_add_debuff') then
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
-- function getClanAttrBuffList
-------------------------------------
function StructClanRaid:getClanAttrBuffList()
    local stage_id = self:getStageID()
    local cur_clan_raid_attr 
    if ((self:isTrainingMode()) or (self:isEventIncarnationOfSinsMode())) then
        cur_clan_raid_attr = self['attr']      
    else
        cur_clan_raid_attr = g_clanData:getCurSeasonBossAttr()
    end

    local bonus_attr_list, penalty_attr_list

    -- ex) 보스가 물 속성인 경우 (어둠/빛 제외)
    -- ex) 유저 드래곤 에게 땅 +버프, 보스에게는 땅 -버프, 유저 중심으로 버프를 계산해야하기 떄문에 패널티, 보너스 속성을 반대로 적용
    if (cur_clan_raid_attr ~= 'dark' and cur_clan_raid_attr ~= 'light') then
        penalty_attr_list, bonus_attr_list = self:getSynastryAttrList(cur_clan_raid_attr)
    else
        bonus_attr_list, penalty_attr_list = self:getSynastryAttrList(cur_clan_raid_attr)
    end

    local synastry_info_list = self:makeClanBuffList(stage_id, bonus_attr_list, penalty_attr_list)
    return synastry_info_list
end

-------------------------------------
-- function getSynastryAttrList
-- @brief 클랜 던전 속성의 상성/역상성 리스트 반환
-------------------------------------
function StructClanRaid:getSynastryAttrList(attr_str)
    local bonus_attr = getAttrAdvantageList(attr_str)
    local penalty_attr = {}

    -- 클랜 던전 빛, 어둠의 역상성은 자신을 제외한 전체
    if (attr_str == 'light' or attr_str == 'dark') then
        local all_attr_list = getAttrTextList()
        for _, attr in ipairs(all_attr_list) do
            if (attr ~= getAttrAdvantage(attr_str)) then
                table.insert(penalty_attr, attr)
            end
        end
    else
        penalty_attr = getAttrDisadvantageList(attr_str)
    end

    return bonus_attr, penalty_attr
end

-------------------------------------
-- function makeClanBuffList
-- @brief 
-------------------------------------
function StructClanRaid:makeClanBuffList(stage_id, bonus_attr_list, penalty_attr_list)
    
    -- 1. 수치가 양수이면 보너스, 음수이면 패널티 버프로 분류
    -- 2. 속성이 여러개일 경우, 해당 버프를 속성마다 부여 ex)  풀 : 공격력 증가 10%, 물 : 공격력 증가 10% ...
    -- 3. drag_cool이 아니고 보스가 light or dark 속성이라면 수치의 반만 적용
    -- 4. 아래와 같은 값을 가지는 버프 테이블 생성
    --[[
        {
                ['condition_type']='attr';
                ['condition_value']='light';
                ['buff_type']='atk_multi';
                ['buff_value']=5;
        };
    --]]

    local table_buff = TABLE:get('table_clan_dungeon_buff')
    local cur_clan_raid_attr = g_clanData:getCurSeasonBossAttr()
    local l_buff = {}

    for buff_name, value in pairs(table_buff[stage_id]) do
        if (buff_name ~= 'r_value' and buff_name ~= 'stage') then
            local attr_list
            
            -- 1. 수치가 양수이면 보너스, 음수이면 패널티 버프로 분류
            if (tonumber(value) < 0) then
                attr_list = penalty_attr_list
            else
                attr_list = bonus_attr_list
            end

            -- 2. 속성이 여러개일 경우, 해당 버프를 속성마다 부여
            for _, attr in ipairs(attr_list) do
                local _ret = {}
                _ret['condition_type'] = 'attr'
                _ret['condition_value'] = attr
                _ret['buff_type'] = buff_name
                _ret['buff_value'] = value

                -- 3. drag_cool이 아니고 light, dark 속성이라면 수치의 반만 적용, (light 와 dark의 보너스 속성은 그대로)
                if (not string.match(buff_name, 'drag_cool')) then
                    if (cur_clan_raid_attr == 'light' or cur_clan_raid_attr == 'dark') then
                        if (getAttrAdvantage(cur_clan_raid_attr) == attr and tonumber(value) > 0) then
                            _ret['buff_value'] = _ret['buff_value']
                        else
                            _ret['buff_value'] = _ret['buff_value']/2
                        end
                    end
                end
                table.insert(l_buff, _ret)
            end
        end
    end

    return l_buff

end

-------------------------------------
-- function isOverMaxStage
-- @brief 각 스테이지가 마지막 스테이지인지 판단
-------------------------------------
function StructClanRaid:isOverMaxStage(stage_id)   
    if (not stage_id) then
        stage_id = self.stage
    end

    if (tonumber(stage_id) > MAX_STAGE_ID) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function isClearAllClanRaidStage
-- @brief 마지막 스테이지 클리어 여부 서버에서 내려준 값 반환
-------------------------------------
function StructClanRaid:isClearAllClanRaidStage()   
    return self.finish
end

-------------------------------------
-- function resetTrainingSettingInfo
-------------------------------------
function StructClanRaid:resetTrainingSettingInfo()   
    self.clan_raid_type = nil
    self.attr = nil
end

-------------------------------------
-- function isTrainingMode
-------------------------------------
function StructClanRaid:isTrainingMode()   
    return self.clan_raid_type == 'training'
end

-------------------------------------
-- function isEventIncarnationOfSinsMode
-- @brief 죄악의 화신 토벌작전 이벤트 모드인지 판단
-------------------------------------
function StructClanRaid:isEventIncarnationOfSinsMode()   
    return (self.clan_raid_type == 'incarnation_of_sins')
end
