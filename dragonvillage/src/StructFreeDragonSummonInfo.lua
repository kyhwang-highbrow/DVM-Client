-------------------------------------
-- class StructFreeDragonSummonInfo
-- @brief 드래곤 무료 소환 정보 구조체
-------------------------------------
StructFreeDragonSummonInfo = class({
        normal_dsmid = '',          -- 일반 드래곤 소환 ID
        normal_daily_limit = '',    -- 일반 무료 소환 일일 제한 횟수
        normal_cnt = '',            -- 일일 무료 소환 횟수
        normal_cooltime = '',       -- 다음 무료 소환 가능한 시간

        premium_dsmid = '',         -- 프리미엄 드래곤 소환 ID
        premium_cooltime = '',     -- 다음 무료 소환 가능한 시간
    })

-------------------------------------
-- function init
-------------------------------------
function StructFreeDragonSummonInfo:init(data)
    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructFreeDragonSummonInfo:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    --replacement['id'] = 'doid'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function getFreeDragonSummonType
-------------------------------------
function StructFreeDragonSummonInfo:getFreeDragonSummonType(dsmid)
    if (dsmid == self['normal_dsmid']) then
        return 'normal'

    elseif (dsmid == self['premium_dsmid']) then
        return 'premium'

    else
        return nil
    end
end

-------------------------------------
-- function getFreeDragonSummonTimeText
-------------------------------------
function StructFreeDragonSummonInfo:getFreeDragonSummonTimeText(free_type)
    if (free_type == 'normal') then
        local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        if (self['normal_cnt'] >= self['normal_daily_limit']) then
            return Str('일일 무료 {1}회 종료', self['normal_daily_limit'])
        end

        
        local normal_cooltime = (self['normal_cooltime'] / 1000)
        if (normal_cooltime == 0) or (normal_cooltime <= server_time) then
            return Str('')
        else
            local showSeconds = true
            local time_text = datetime.makeTimeDesc((normal_cooltime - server_time) + 0.5, showSeconds)
            local text = Str('{1} 후 무료소환', time_text)
            return text
        end


    elseif (free_type == 'premium') then
        local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        local premium_cooltime = (self['premium_cooltime'] / 1000)
        if (premium_cooltime == 0) or (premium_cooltime <= server_time) then
            return Str('')
        else
            local showSeconds = true
            local time_text = datetime.makeTimeDesc((premium_cooltime - server_time) + 0.5, showSeconds)
            local text = Str('{1} 후 무료소환', time_text)
            return text
        end

    else
        return ''
    end
end

-------------------------------------
-- function canFreeDragonSummon
-------------------------------------
function StructFreeDragonSummonInfo:canFreeDragonSummon(free_type)
    if (free_type == 'normal') then
        local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        if (self['normal_cnt'] >= self['normal_daily_limit']) then
            return false
        end

        local normal_cooltime = (self['normal_cooltime'] / 1000)
        if (normal_cooltime == 0) or (normal_cooltime <= server_time) then
            return true
        else
            return false
        end


    elseif (free_type == 'premium') then
        local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        local premium_cooltime = (self['premium_cooltime'] / 1000)
        if (premium_cooltime == 0) or (premium_cooltime <= server_time) then
            return true
        else
            return false
        end

    else
        return false
    end
end