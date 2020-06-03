-------------------------------------
-- interface ISkillSound
-------------------------------------
ISkillSound = {
    m_skillSoundTimer = 'number',
    m_mPlayTimesPerRes = 'table',    -- 리소스별 재생시간 리스트

    m_recentTimePerRes = 'table',    -- 리소스별 가장 가까운 재생시간
}

-------------------------------------
-- function init
-------------------------------------
function ISkillSound:init(sid)
    self.m_skillSoundTimer = 0
    self.m_mPlayTimesPerRes = {}
    self.m_recentTimePerRes = {}
end

-------------------------------------
-- function initSkillSound
-------------------------------------
function ISkillSound:initSkillSound(sid)
    local t_info = TableSkillSound():get(sid)
    if (not t_info) then return end

    for i = 1, 2 do
        local res = t_info['res_' .. i]
        local delay = t_info['delay_' .. i]
        if (res and res ~= '' and delay ~= '') then
            self.m_mPlayTimesPerRes[res] = {}

            local l_time = {}

            if (type(delay) == 'string') then
                l_time = pl.stringx.split(delay, ';')
            else
                l_time = { delay }
            end
            
            for _, v in ipairs(l_time) do
                local time = tonumber(v)
                table.insert(self.m_mPlayTimesPerRes[res], time)
            end

            -- 시간 순서대로 정렬
            --table.sort(self.m_mPlayTimesPerRes[res], function(a, b) return (a < b) end)
        end
    end

    -- 가장 먼저 재생될 리소스별 시간값을 저장
    for res, list in pairs(self.m_mPlayTimesPerRes) do
        self.m_recentTimePerRes[res] = table.remove(list, 1)
    end
end

-------------------------------------
-- function updateSkillSound
-------------------------------------
function ISkillSound:updateSkillSound(dt)
    self.m_skillSoundTimer = self.m_skillSoundTimer + dt

    for res, time in pairs(self.m_recentTimePerRes) do
        if (time <= self.m_skillSoundTimer) then
            -- 사운드 재생
            self:playSkillSound(res)
            
            -- 다음 재생될 시간값을 가져옴
            local list = self.m_mPlayTimesPerRes[res]
            self.m_recentTimePerRes[res] = table.remove(list, 1)
        end
    end
end

-------------------------------------
-- function playSkillSound
-------------------------------------
function ISkillSound:playSkillSound(res)
    local category
    
    if (pl.stringx.startswith(res, 'sfx_')) then
        category = 'SFX'
    elseif (pl.stringx.startswith(res, 'efx_')) then
        category = 'EFX'
    elseif (pl.stringx.startswith(res, 'ui_')) then
        category = 'UI'
    else
        category = 'EFFECT'
    end

    --cclog('ISkillSound:playSkillSound res = ' .. res)
    SoundMgr:playEffect(category, res)
end

-------------------------------------
-- function isEndSkillSound
-------------------------------------
function ISkillSound:isEndSkillSound()
    return (table.count(self.m_recentTimePerRes) == 0)
end


-------------------------------------
-- function getCloneTable
-------------------------------------
function ISkillSound:getCloneTable()
	return clone(ISkillSound)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function ISkillSound:getCloneClass()
	return class(clone(ISkillSound))
end