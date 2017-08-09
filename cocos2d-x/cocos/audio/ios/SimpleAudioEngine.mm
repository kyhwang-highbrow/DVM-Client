/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/

#include "audio/include/SimpleAudioEngine.h"
#include "audio/ios/SimpleAudioEngine_objc.h"
#include "platform/CCFileUtils.h"

#include "audio/include/AudioEngine.h"
using namespace cocos2d::experimental;

USING_NS_CC;


static int s_EngineMode = 1;

static int s_BGMusicId = -1;
static bool s_IsBGMPlaying = false;

static int s_VoiceId = -1;


static bool __isAudioPreloadOrPlayed = false;

static void static_end()
{
    if (__isAudioPreloadOrPlayed)
    {
        [SimpleAudioEngine end];
    }

    __isAudioPreloadOrPlayed = false;
}

static void static_preloadBackgroundMusic(const char* pszFilePath)
{
    __isAudioPreloadOrPlayed = true;

    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic: [NSString stringWithUTF8String: pszFilePath]];
}

static void static_playBackgroundMusic(const char* pszFilePath, bool bLoop)
{
    __isAudioPreloadOrPlayed = true;

    [[SimpleAudioEngine sharedEngine] playBackgroundMusic: [NSString stringWithUTF8String: pszFilePath] loop: bLoop];
}

static void static_stopBackgroundMusic()
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

static void static_pauseBackgroundMusic()
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

static void static_resumeBackgroundMusic()
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

static void static_rewindBackgroundMusic()
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] rewindBackgroundMusic];
}

static bool static_willPlayBackgroundMusic()
{
    if (!__isAudioPreloadOrPlayed)
        return false;

    return [[SimpleAudioEngine sharedEngine] willPlayBackgroundMusic];
}

static bool static_isBackgroundMusicPlaying()
{
    if (!__isAudioPreloadOrPlayed)
        return false;

    return [[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying];
}

static float static_getBackgroundMusicVolume()
{
    if (!__isAudioPreloadOrPlayed)
        return 0.0f;

    return [[SimpleAudioEngine sharedEngine] backgroundMusicVolume];
}

static void static_setBackgroundMusicVolume(float volume)
{
    if (!__isAudioPreloadOrPlayed)
        return;

    volume = MAX( MIN(volume, 1.0), 0 );
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = volume;
}

static float static_getEffectsVolume()
{
    if (!__isAudioPreloadOrPlayed)
        return 0.0f;

    return [[SimpleAudioEngine sharedEngine] effectsVolume];
}

static void static_setEffectsVolume(float volume)
{
    if (!__isAudioPreloadOrPlayed)
        return;

    volume = MAX( MIN(volume, 1.0), 0 );
    [SimpleAudioEngine sharedEngine].effectsVolume = volume;
}

static unsigned int static_playEffect(const char* pszFilePath, bool bLoop, Float32 pszPitch, Float32 pszPan, Float32 pszGain)
{
    __isAudioPreloadOrPlayed = true;

    return [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithUTF8String: pszFilePath] loop:bLoop pitch:pszPitch pan: pszPan gain:pszGain];
}

static void static_stopEffect(int nSoundId)
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] stopEffect: nSoundId];
}

static void static_preloadEffect(const char* pszFilePath)
{
    __isAudioPreloadOrPlayed = true;

    [[SimpleAudioEngine sharedEngine] preloadEffect: [NSString stringWithUTF8String: pszFilePath]];
}

static void static_unloadEffect(const char* pszFilePath)
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] unloadEffect: [NSString stringWithUTF8String: pszFilePath]];
}

static void static_pauseEffect(unsigned int uSoundId)
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] pauseEffect: uSoundId];
}

static void static_resumeEffect(unsigned int uSoundId)
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] resumeEffect: uSoundId];
}

static void static_pauseAllEffects()
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] pauseAllEffects];
}

static void static_resumeAllEffects()
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] resumeAllEffects];
}

static void static_stopAllEffects()
{
    if (!__isAudioPreloadOrPlayed)
        return;

    [[SimpleAudioEngine sharedEngine] stopAllEffects];
}

namespace CocosDenshion {

static SimpleAudioEngine *s_pEngine = nullptr;

SimpleAudioEngine::SimpleAudioEngine()
{

}

SimpleAudioEngine::~SimpleAudioEngine()
{

}

SimpleAudioEngine* SimpleAudioEngine::getInstance()
{
    if (!s_pEngine)
    {
        s_pEngine = new (std::nothrow) SimpleAudioEngine();
    }
    
    return s_pEngine;
}

void SimpleAudioEngine::end()
{
    if (s_EngineMode == 1)
    {
        AudioEngine::end();
    }
    else
    {
        if (s_pEngine)
        {
            delete s_pEngine;
            s_pEngine = nullptr;
        }

        static_end();
    }
}

void SimpleAudioEngine::preloadBackgroundMusic(const char* pszFilePath)
{
    // Changing file path to full path
    std::string fullPath = FileUtils::getInstance()->fullPathForFilename(pszFilePath);

    if (s_EngineMode == 1)
    {
        AudioEngine::preload(pszFilePath);
    }
    else
    {
        static_preloadBackgroundMusic(fullPath.c_str());
    }
}

void SimpleAudioEngine::playBackgroundMusic(const char* pszFilePath, bool bLoop)
{
    // Changing file path to full path
    std::string fullPath = FileUtils::getInstance()->fullPathForFilename(pszFilePath);
    if (s_EngineMode == 1)
    {
        if (s_BGMusicId != -1)
        {
            stopBackgroundMusic();
        }

        s_BGMusicId = AudioEngine::play2d(pszFilePath, bLoop);
        s_IsBGMPlaying = true;
    }
    else
    {
        static_playBackgroundMusic(fullPath.c_str(), bLoop);
    }
}

void SimpleAudioEngine::stopBackgroundMusic(bool bReleaseData)
{
    if (s_EngineMode == 1)
    {
        if (s_BGMusicId != -1)
        {
            AudioEngine::stop(s_BGMusicId);
            s_BGMusicId = -1;
            s_IsBGMPlaying = false;
        }
    }
    else
    {
        static_stopBackgroundMusic();
    }
}

void SimpleAudioEngine::pauseBackgroundMusic()
{
    if (s_EngineMode == 1)
    {
        if (s_BGMusicId != -1)
        {
            AudioEngine::pause(s_BGMusicId);
            s_IsBGMPlaying = false;
        }
    }
    else
    {
        static_pauseBackgroundMusic();
    }
}

void SimpleAudioEngine::resumeBackgroundMusic()
{
    if (s_EngineMode == 1)
    {
        if (s_BGMusicId != -1)
        {
            AudioEngine::resume(s_BGMusicId);
            s_IsBGMPlaying = true;
        }
    }
    else
    {
        static_resumeBackgroundMusic();
    }
}

void SimpleAudioEngine::rewindBackgroundMusic()
{
    if (s_EngineMode == 1)
    {
        if (s_BGMusicId != -1)
        {
            AudioEngine::setCurrentTime(s_BGMusicId, 0);
        }
    }
    else
    {
        static_rewindBackgroundMusic();
    }
}

bool SimpleAudioEngine::willPlayBackgroundMusic()
{
    if (s_EngineMode == 1)
    {
        return false;
    }
    else
    {
        return static_willPlayBackgroundMusic();
    }
}

bool SimpleAudioEngine::isBackgroundMusicPlaying()
{
    if (s_EngineMode == 1)
    {
        return s_IsBGMPlaying;
    }
    else
    {
        return static_isBackgroundMusicPlaying();
    }
}

float SimpleAudioEngine::getBackgroundMusicVolume()
{
    if (s_EngineMode == 1)
    {
        return 0.0f;
    }
    else
    {
        return static_getBackgroundMusicVolume();
    }
}

void SimpleAudioEngine::setBackgroundMusicVolume(float volume)
{
    if (s_EngineMode == 1)
    {
    }
    else
    {
        static_setBackgroundMusicVolume(volume);
    }
}

float SimpleAudioEngine::getEffectsVolume()
{
    if (s_EngineMode == 1)
    {
        return 0.0f;
    }
    else
    {
        return static_getEffectsVolume();
    }
}

void SimpleAudioEngine::setEffectsVolume(float volume)
{
    if (s_EngineMode == 1)
    {
    }
    else
    {
        static_setEffectsVolume(volume);
    }
}

unsigned int SimpleAudioEngine::playEffect(const char *pszFilePath, bool bLoop,
                                           float pitch, float pan, float gain)
{
    // Changing file path to full path
    std::string fullPath = FileUtils::getInstance()->fullPathForFilename(pszFilePath);
    if (s_EngineMode == 1)
    {
        return AudioEngine::play2d(pszFilePath, bLoop);
    }
    else
    {
        return static_playEffect(fullPath.c_str(), bLoop, pitch, pan, gain);
    }
}

void SimpleAudioEngine::stopEffect(unsigned int nSoundId)
{
    if (s_EngineMode == 1)
    {
        AudioEngine::stop(nSoundId);
    }
    else
    {
        static_stopEffect(nSoundId);
    }
}

void SimpleAudioEngine::preloadEffect(const char* pszFilePath)
{
    // Changing file path to full path
    std::string fullPath = FileUtils::getInstance()->fullPathForFilename(pszFilePath);
    if (s_EngineMode == 1)
    {
        AudioEngine::preload(pszFilePath);
    }
    else
    {
        static_preloadEffect(fullPath.c_str());
    }
}

void SimpleAudioEngine::unloadEffect(const char* pszFilePath)
{
    // Changing file path to full path
    std::string fullPath = FileUtils::getInstance()->fullPathForFilename(pszFilePath);
    if (s_EngineMode == 1)
    {
        AudioEngine::uncache(pszFilePath);
    }
    else
    {
        static_unloadEffect(fullPath.c_str());
    }
}

void SimpleAudioEngine::pauseEffect(unsigned int uSoundId)
{
    if (s_EngineMode == 1)
    {
        AudioEngine::pause(uSoundId);
    }
    else
    {
        static_pauseEffect(uSoundId);
    }
}

void SimpleAudioEngine::resumeEffect(unsigned int uSoundId)
{
    if (s_EngineMode == 1)
    {
        AudioEngine::resume(uSoundId);
    }
    else
    {
        static_resumeEffect(uSoundId);
    }
}

void SimpleAudioEngine::pauseAllEffects()
{
    if (s_EngineMode == 1)
    {
        AudioEngine::pauseAll();
        if (s_BGMusicId != -1)
        {
            s_IsBGMPlaying = false;
        }
    }
    else
    {
        static_pauseAllEffects();
    }
}

void SimpleAudioEngine::resumeAllEffects()
{
    if (s_EngineMode == 1)
    {
        AudioEngine::resumeAll();
        if (s_BGMusicId != -1)
        {
            s_IsBGMPlaying = true;
        }
    }
    else
    {
        static_resumeAllEffects();
    }
}

void SimpleAudioEngine::stopAllEffects()
{
    if (s_EngineMode == 1)
    {
        AudioEngine::stopAll();
    }
    else
    {
        static_stopAllEffects();
    }
}

void SimpleAudioEngine::playVoice(const char* pszFilePath, bool bLoop)
{
    if (s_EngineMode == 1)
    {
        if (s_VoiceId != -1)
        {
            stopVoice();
        }

        s_VoiceId = AudioEngine::play2d(pszFilePath, bLoop);
    }
    else
    {
        s_VoiceId = playEffect(pszFilePath, bLoop);
    }
}

void SimpleAudioEngine::stopVoice(bool bReleaseData)
{
    if (s_EngineMode == 1)
    {
        if (s_VoiceId != -1)
        {
            AudioEngine::stop(s_VoiceId);
            s_VoiceId = -1;
        }
    }
    else
    {
        stopEffect(s_VoiceId);
        s_VoiceId = -1;
    }
}

void SimpleAudioEngine::playVibrate(long millisecond)
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

void SimpleAudioEngine::cancelVibrate()
{
}

void SimpleAudioEngine::setEngineMode(int mode)
{
    s_EngineMode = mode;
}

int SimpleAudioEngine::getEngineMode()
{
    return s_EngineMode;
}

} // endof namespace CocosDenshion {
