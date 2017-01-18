-- cclog
cclog_sound = function(...)
    -- cclog(...)
end

local SOUND_LIST_FILE = 'sound_list'

-- 사운드 품질
SOUND_QUALITY_TOKEN_HIGH = 'res'
SOUND_QUALITY_TOKEN_MID = 'res_mid'
SOUND_QUALITY_TOKEN_LOW = 'res_low'

-- BGM 볼륨 상태
VOLUME_STATE_NONE = 0
VOLUME_STATE_NORMAL = 1
VOLUME_STATE_FADE_IN = 2
VOLUME_STATE_FADE_OUT = 3

-------------------------------------
-- class SoundMgr
-------------------------------------
SoundMgr = {
    m_soundList = {},    -- txt파일에서 읽어들인 사운드 파일 목록
    m_preload = {},
    m_loadedBgm = {},
    m_loadedSfx = {},

    -- 배경음(BGM)
    m_prevBgm = nil,
    m_currBgm = nil,
    
    -- 효과음을 반복재생 했을경우 해당 재생 id를 저장
    m_loopSfx = {},

    -- 한 프레임에 재생하는 사운드를 관리
    m_scheduledSfx = {},
    m_scheduledCount = 0,
    m_sfxCooltime = {},

    -- 옵션
    m_enableBgm = true,
    m_enableSfx = true,

    -- 사운드 품질
    m_quality = SOUND_QUALITY_TOKEN_HIGH, --SOUND_QUALITY_TOKEN_LOW

    -- 보이스 사운드
    m_tVoiceSoundID = {},

    m_volumeMusic = 1,
    m_volumeEffect = 1,
    m_bSlowMode = false,

    m_titleBgmName = 'BGM_background',

    -- fadein fadeout
    m_volumeState = VOLUME_STATE_NONE,
    m_multiplVolume = 1,
    }

-- 디버깅용
SoundMgr.m_skipCount = 0
SoundMgr.m_time = 0
SoundMgr.m_totalSfxCall = 0

function SoundMgr:assert(...)
    assert(...)
end

-------------------------------------
-- function entry
-------------------------------------
function SoundMgr:entry()
    cclog_sound('#################################################')
    cclog_sound('SoundMgr:entry()')
    cclog_sound('#################################################')

    self:loadSoundList()
end

-------------------------------------
-- function loadSoundList
-------------------------------------
function SoundMgr:loadSoundList()
    --local file_stream = FileUtil.load(SOUND_LIST_FILE)
    --self.m_soundList = json.decode(file_stream)

    self.m_soundList = TABLE:loadJsonTable(SOUND_LIST_FILE)

    -- 배경음 프리로드
    for i,v in pairs(self.m_soundList.BG) do
        local res = self:getResName(v)
        if res then
            --cc.SimpleAudioEngine:getInstance():preloadMusic(res)
            --cclog(res)
        end
    end

    for i,v in pairs(self.m_soundList['EFFECT']) do
        local res = self:getResName(v)
        if res then
            self.m_preload[res] = true
        end
    end

    --[[
    for i,v in pairs(self.m_soundList.GAME) do
        local res = self:getResName(v)
        if res then
            self.m_preload[res] = true
        end
    end
    --]]

    self:setTitleBgm()
    --self:loadSoundCategory(self.m_soundList)
end

-------------------------------------
-- function isExistSound
-- @param category
-- @param sound
-------------------------------------
function SoundMgr:isExistSound(category, sound)
    if (not self.m_soundList[category]) then return false end

    return (self.m_soundList[category][sound] ~= nil)
end

-------------------------------------
-- function update
-- @param dt
-------------------------------------
function SoundMgr:update(dt)
    SoundMgr.m_time = SoundMgr.m_time + dt

    for res,_ in pairs(self.m_preload) do
        cc.SimpleAudioEngine:getInstance():preloadEffect(res)
        self.m_loadedSfx[res] = true
        cclog_sound('SoundLoad : %s', res)
        self.m_preload[res] = nil
        break
    end
    
    -- 정렬을 위한 임시 테이블 생성
    local sorted_sfx = {}
    for i,v in pairs(self.m_scheduledSfx) do
        sorted_sfx[#sorted_sfx + 1] = v
    end

    -- 우선순위가 높을 수록 먼저, 등록 횟수가 많을 수록 먼저, 등록순서가 빠를 수록 먼저
    -- 세가지 조건으로 정렬
    table.sort(sorted_sfx,
        function(a, b)
            if a.priority ~= b.priority then
                return a.priority > b.priority    -- 우선순위가 높을 수록 먼저
            else
                if a.count ~= b.count then
                    return a.count > b.count    -- 등록 횟수가 많을 수록 먼저
                else
                    return a.idx < b.idx        -- 등록순서가 빠를 수록 먼저
                end
            end
        end)


    --cclog(luadump(sorted_sfx))
    local play_count = 0
    local max = 5
    local curr_time = SoundMgr.m_time
    for i,v in ipairs(sorted_sfx) do
        if max <= play_count then
            break
        end

        if (not self.m_sfxCooltime[v.res]) or ((curr_time - self.m_sfxCooltime[v.res]) > 0.1) then
            self.m_sfxCooltime[v.res] = curr_time

            -- play
            local _id = cc.SimpleAudioEngine:getInstance():playEffect(v.res, v.loop)
            play_count = play_count + 1
            --cclog(v.res)

            -- loop
            if v.loop then
                self.m_loopSfx[v.res] = _id
            end
        end
    end

    --[[
    if self.m_scheduledCount > 5 then
        cclog('####################################################')
        cclog('m_scheduledCount ' .. self.m_scheduledCount)
        for i,v in ipairs(sorted_sfx) do
            cclog(v.res .. ' : ' .. v.count)
        end
        cclog('####################################################\n')
    end

    do -- 절약횟수 ---------------------------------------------
        self.m_totalSfxCall = self.m_totalSfxCall + self.m_scheduledCount
        local skip_count = self.m_scheduledCount - play_count
        
        if skip_count ~= 0 then
            self.m_skipCount = self.m_skipCount + skip_count
            cclog('self.m_skipCount ' .. self.m_skipCount .. ' / ' .. self.m_totalSfxCall)
        end
        
    end--------------------------------------------------------
    --]]
    
    
    -- 초기화 
    self.m_scheduledSfx = {}
    self.m_scheduledCount = 0

    --SoundMgr:updateVolumeState(dt)
end

--SoundMgr:entry()

-- 스케쥴에 등록
if (not sound_coroutine_handler_id) then
    sound_coroutine_handler_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) SoundMgr:update(dt) end, 0, false)
end

--SoundMgr:entry()
--SoundMgr:playTitleBGM()

-------------------------------------
-- function playBgmImmediately
-------------------------------------
function SoundMgr:playBgmImmediately(res, loop)
    cc.SimpleAudioEngine:getInstance():playMusic(res, loop)
end

-------------------------------------
-- function playEffectImmediately
-------------------------------------
function SoundMgr:playEffectImmediately(res, loop)
    cc.SimpleAudioEngine:getInstance():preloadEffect(res)
    cc.SimpleAudioEngine:getInstance():playEffect(res, loop)
end