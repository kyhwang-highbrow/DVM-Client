-------------------------------------
-- file SoundMgrProtected
-- @brief 내부 함수에서 호출되는 함수들(protected or private)
-------------------------------------


-------------------------------------
-- function loadSoundCategory
-- @param file_json
-------------------------------------
function SoundMgr:loadSoundCategory(file_json)
    for category, sound_list in pairs(file_json) do
        self:loadSoundFile(category, sound_list)
    end
end

-------------------------------------
-- function loadSoundFile
-- @param category
-- @param sound_list
-------------------------------------
function SoundMgr:loadSoundFile(category, sound_list)
    for id, info in pairs(sound_list) do
        --cclog(category .. '.' .. id .. ' ' .. info.res)
    end
end

-------------------------------------
-- function getSoundInfo
-- @param category
-- @param sound
-------------------------------------
function SoundMgr:getSoundInfo(category, sound)
    -- category
    local category_ = self.m_soundList[category]
    if not category_ then
        cclog('ERROR : SoundMgr:getSoundInfo() - category "' .. category .. '" 가 존재하지 않습니다.')
        if PASS_NO_SOUND_FILE then return end
    end
    self:assert(category_)

    -- sound_info
    local sound_info_ = category_[sound]
    if not sound_info_ then
        cclog('ERROR : SoundMgr:getSoundInfo() - category.sound "' .. category .. '.' .. sound .. '" 가 존재하지 않습니다.')
        if PASS_NO_SOUND_FILE then return end
    end
    self:assert(sound_info_)

    -- res
    local res_ = self:getResName(sound_info_)
    if not res_ then
        cclog('ERROR : SoundMgr:getSoundInfo() - res "' .. res_ .. '" 가 존재하지 않습니다.')
        if PASS_NO_SOUND_FILE then return end
    end
    self:assert(res_)

    return category_, sound_info_, res_
end

-------------------------------------
-- function getResName
-- @brief sound_info에서 quality에 해당하는 실제 리소스명을 얻어온다.
--          low리소스명이 없을 경우 mid에서, mid리소스명이 없을 경우 high에서 얻어 온다.
-- @param sound_info
-- @param quality
-------------------------------------
function SoundMgr:getResName(sound_info, quality)
    -- quality가 없을 경우 기본 quality(m_quality)
    local quality = quality or self.m_quality

    local res = sound_info[quality]

    -- 리소스명이 있을 경우 리턴
    if res and (res ~= 'none') then
        local path = cc.FileUtils:getInstance():fullPathForFilename(res)
        local is_exist = cc.FileUtils:getInstance():isFileExist(path)
        if not is_exist then
            cclog('ERROR : SoundMgr:getResName() - "' .. res .. '" 가 존재하지 않습니다.')
        end
        -- self:assert(is_exist)
        -- sgkim 2017-08-28
        -- APK Expansion적용 시 obb파일에 사운드 파일을 찾지 못하는 케이스가 있어서 일단 주석 처리
        return res
    -- 리소스명이 없을 경우 low, mid, high순으로 재귀적으로 검색한다.
    else
        -- LOW에서 없을 경우 MID에서 재검색
        if quality == SOUND_QUALITY_TOKEN_LOW then
            return self:getResName(sound_info, SOUND_QUALITY_TOKEN_MID)
        -- MID에서 없을 경우 HIGH에서 재검색
        elseif quality == SOUND_QUALITY_TOKEN_MID then
            return self:getResName(sound_info, SOUND_QUALITY_TOKEN_HIGH)
        end
    end
    
    -- 리소스명이 없으면 에러 리턴
    return nil
end

-------------------------------------
-- function scheduleSfx
-- @param sound_info
-------------------------------------
function SoundMgr:scheduleSfx(sound_info, res, loop)

    self.m_scheduledCount = self.m_scheduledCount + 1

    if self.m_scheduledSfx[res] then
        self.m_scheduledSfx[res].priority = math_max(self.m_scheduledSfx[res].priority, sound_info.priority or 0)
        self.m_scheduledSfx[res].loop = self.m_scheduledSfx[res].loop or loop
        self.m_scheduledSfx[res].count = self.m_scheduledSfx[res].count + 1
    else
        local value = {    res = res,
                        priority = sound_info.priority or 0,
                        loop = loop, 
                        idx = self.m_scheduledCount,
                        count = 1}
        self.m_scheduledSfx[res] = value
    end
end