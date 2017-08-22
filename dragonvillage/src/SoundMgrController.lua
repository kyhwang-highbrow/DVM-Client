-------------------------------------
-- file SoundMgrController
-- @brief 사운드 재생, 정지 등 외부에서 호출하는 함수
-------------------------------------

-------------------------------------
-- function playBGM
-- @param sound
-- @param loop
-------------------------------------
function SoundMgr:playBGM(sound, loop)
    local category, sound_info, res = self:getSoundInfo('BG', sound)

    if not self.m_enableBgm then
        self.m_prevBgm = self.m_currBgm
        self.m_currBgm = sound 
        return
    end

    if self.m_currBgm == sound then return end

    local loop = (loop==nil) and true
    cc.SimpleAudioEngine:getInstance():playMusic(res, loop)
    self.m_prevBgm = self.m_currBgm
    self.m_currBgm = sound

    SoundMgr:setVolumeState(VOLUME_STATE_NORMAL)
end

-------------------------------------
-- function playPrevBGM
-- @brief 이전 bgm을 재생한다.
-------------------------------------
function SoundMgr:playPrevBGM(loop)
    if (self.m_prevBgm) then
        self:playBGM(self.m_prevBgm, loop)
    end
end

-------------------------------------
-- function setTitleBgm
-------------------------------------
function SoundMgr:setTitleBgm()
    if math_random(1, 2) == 1 then
        self.m_titleBgmName = 'BGM_background'
    else
        self.m_titleBgmName = 'BGM_background'
    end
end

-------------------------------------
-- function pauseBGM
-- @param bReleaseData
-------------------------------------
function SoundMgr:stopBGM(bReleaseData)

    self.m_prevBgm = self.m_currBgm
    self.m_currBgm = nil

    local bReleaseData = bReleaseData or false
    cc.SimpleAudioEngine:getInstance():stopMusic(bReleaseData)
end

-------------------------------------
-- function pauseBGM
-------------------------------------
function SoundMgr:pauseBGM()
    if self.m_currBgm then
        cc.SimpleAudioEngine:getInstance():pauseBackgroundMusic()
    end
end

-------------------------------------
-- function resumeBGM
-------------------------------------
function SoundMgr:resumeBGM()
    if self.m_currBgm then
        cc.SimpleAudioEngine:getInstance():resumeBackgroundMusic()
    end
end

-------------------------------------
-- function playEffect
-- @param category
-- @param sound
-- @param loop
-------------------------------------
function SoundMgr:playEffect(category, sound, loop)
    if self.m_enableSfx == false then return end

    local loop = loop or false
    local category, sound_info, res = self:getSoundInfo(category, sound)
    if (PASS_NO_SOUND_FILE and not res) then return end

    self:scheduleSfx(sound_info, res, loop)
end

-------------------------------------
-- function playRandomEffect
-- @brief 특정 사운드에 랜덤의 '_%d'를 붙여 사운드를 재생
-- @param category
-- @param sound
-- @param min
-- @param max
-------------------------------------
function SoundMgr:playRandomEffect(category, sound, min, max)
    if self.m_enableSfx == false then return end

    local loop = false
    local idx = math_random(min, max)
    local sound = sound .. '_' .. idx

    self:playEffect(category, sound, loop)
end

-------------------------------------
-- function stopEffect
-- @param category
-- @param sound
-------------------------------------
function SoundMgr:stopEffect(category, sound)
    local category, sound_info, res = self:getSoundInfo(category, sound)

    local _id = self.m_loopSfx[res]
    if _id then
        cc.SimpleAudioEngine:getInstance():stopEffect(_id)
        self.m_loopSfx[res] = nil
    end
end

-------------------------------------
-- function stopAllEffects
-------------------------------------
function SoundMgr:stopAllEffects()
    cc.SimpleAudioEngine:getInstance():stopAllEffects()

    -- 초기화
    self.m_loopSfx = {}
end

-------------------------------------
-- function enableSfx
-------------------------------------
function SoundMgr:enableSfx()
    self.m_enableSfx = true
    
end

-------------------------------------
-- function disableSfx
-------------------------------------
function SoundMgr:disableSfx()
    self:stopAllEffects()
    self.m_enableSfx = false
end

-------------------------------------
-- function getBgmOnOff
-------------------------------------
function SoundMgr:getBgmOnOff()
    return self.m_enableBgm
end

-------------------------------------
-- function setBgmOnOff
-------------------------------------
function SoundMgr:setBgmOnOff(is_on)
    if self.m_enableBgm == is_on then
        return
    end

    self.m_enableBgm = is_on

    if not self.m_enableBgm then
        self:stopBGM()
    else
        local sound = self.m_prevBgm

        if (not sound) then
            sound = self.m_currBgm
        end

        if sound then
            SoundMgr:playBGM('bgm_dummy')
            SoundMgr:playBGM(sound)
        end
    end
end

-------------------------------------
-- function gsetSfxOnOff
-------------------------------------
function SoundMgr:gsetSfxOnOff()
    return self.m_enableSfx
end

-------------------------------------
-- function setSfxOnOff
-------------------------------------
function SoundMgr:setSfxOnOff(is_on)
    self.m_enableSfx = is_on

    if not self.m_enableSfx then
        self:stopAllEffects()
    end
end

-------------------------------------
-- function setVolume
-------------------------------------
function SoundMgr:setVolume()
--    if UserData:get('bgm') then cc.SimpleAudioEngine:getInstance():setBackgroundMusicVolume(1.0)
--    else cc.SimpleAudioEngine:getInstance():setBackgroundMusicVolume(0.0) end

--    if UserData:get('effect') then cc.SimpleAudioEngine:getInstance():setEffectsVolume(1.0)
--    else cc.SimpleAudioEngine:getInstance():setEffectsVolume(0.0) end
end

-------------------------------------
-- function setMusicVolume
-------------------------------------
function SoundMgr:setMusicVolume(volume)
    self.m_volumeMusic = volume

    --local real_volume = self.m_volumeMusic * self.m_multiplVolume
    local real_volume = self.m_volumeMusic
    if self.m_bSlowMode then
        real_volume = real_volume * 0.5
    end

    -- BGM사운드가 너무 커서 70%로 줄였음
    real_volume = real_volume * 0.7
    cc.SimpleAudioEngine:getInstance():setMusicVolume(real_volume)
end

-------------------------------------
-- function setEffectVolume
-------------------------------------
function SoundMgr:setEffectVolume(volume)
    self.m_volumeEffect = volume

    if self.m_bSlowMode then
        cc.SimpleAudioEngine:getInstance():setEffectsVolume(self.m_volumeEffect * 0.5)
    else
        cc.SimpleAudioEngine:getInstance():setEffectsVolume(self.m_volumeEffect)
    end
end

-------------------------------------
-- function setSlowMode
-------------------------------------
function SoundMgr:setSlowMode(is_slow_mode)
    self.m_bSlowMode = is_slow_mode
    
    self:setMusicVolume(self.m_volumeMusic)
    self:setEffectVolume(self.m_volumeEffect)
end

-------------------------------------
-- function isLoadDone
-------------------------------------
function SoundMgr:isLoadDone()
    for i,v in pairs(self.m_preload) do
        return false
    end

    return true
end

-------------------------------------
-- function setVolumeState
-------------------------------------
function SoundMgr:setVolumeState(volume_state)
    self.m_volumeState = volume_state

    if self.m_volumeState == VOLUME_STATE_NONE then

    elseif self.m_volumeState == VOLUME_STATE_NORMAL then
        self.m_multiplVolume = 1

    elseif self.m_volumeState == VOLUME_STATE_FADE_IN then
        self.m_multiplVolume = 0

    elseif self.m_volumeState == VOLUME_STATE_FADE_OUT then
        self.m_multiplVolume = 1

    end
end

-------------------------------------
-- function updateVolumeState
-------------------------------------
function SoundMgr:updateVolumeState(dt)
    if self.m_volumeState == VOLUME_STATE_NONE then

    elseif self.m_volumeState == VOLUME_STATE_NORMAL then

    elseif self.m_volumeState == VOLUME_STATE_FADE_IN then
        self.m_multiplVolume = self.m_multiplVolume + dt
        if self.m_multiplVolume >= 1 then
            self.m_multiplVolume = 1
            SoundMgr:setVolumeState(VOLUME_STATE_NONE)
        end
        self:setMusicVolume(self.m_volumeMusic)

    elseif self.m_volumeState == VOLUME_STATE_FADE_OUT then
        self.m_multiplVolume = self.m_multiplVolume - dt
        if self.m_multiplVolume <= 0 then
            self.m_multiplVolume = 0
            SoundMgr:setVolumeState(VOLUME_STATE_NONE)
        end
        self:setMusicVolume(self.m_volumeMusic)

    end
end