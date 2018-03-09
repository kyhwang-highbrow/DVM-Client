-------------------------------------
-- class StructWaveRegenGroup
-------------------------------------
StructWaveRegenGroup = class({
		m_key = 'number',

        m_data = 'table',
        m_mObjMap = 'table',        -- 몬스터의 존재 여부 정보를 저장하기 위한 맵

        m_interval = 'table',       -- 리젠 주기
        m_timer = 'table',          -- 리젠 시간
    })

-------------------------------------
-- function init
-------------------------------------
function StructWaveRegenGroup:init(key, data, interval, phys_group)
    self.m_key = key
    self.m_data = data
    self.m_mObjMap = nil

    self.m_timer = 0

    self:setInterval(interval)
end

-------------------------------------
-- function setInterval
-------------------------------------
function StructWaveRegenGroup:setInterval(interval)
    self.m_interval = interval
end

-------------------------------------
-- function update
-------------------------------------
function StructWaveRegenGroup:update(dt)
    if (not self:isEmpty()) then return end

    if (self.m_timer >= self.m_interval) then
        self.m_mObjMap = {}
        self.m_timer = 0
        return self.m_data
    else
        self.m_timer = self.m_timer + dt
    end

    return
end

-------------------------------------
-- function setObjInfo
-- @brief 리젠 가능 여부 설정
-------------------------------------
function StructWaveRegenGroup:setObjInfo(obj_key, b)
    if (b) then
        if (not self.m_mObjMap) then
            self.m_mObjMap = {}
        end

        self.m_mObjMap[obj_key] = b
    else
        if (not self.m_mObjMap) then
            return
        end

        self.m_mObjMap[obj_key] = nil

        if (table.count(self.m_mObjMap) == 0) then
            self.m_mObjMap = nil
        end
    end
end

-------------------------------------
-- function isEmpty
-- @brief 리젠 가능 여부
-------------------------------------
function StructWaveRegenGroup:isEmpty()
    return (self.m_mObjMap == nil)
end