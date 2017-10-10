-------------------------------------
-- table AdsManager
-- @brief 광고 SDK 매니져
-------------------------------------
AdsManager = {
    callback,
    adcolonyZoneId,
    tapjoyAdPlacementId,
}

-------------------------------------
-- function skip
-------------------------------------
local function skip()
    if (isWin32()) then 
        return true
    end

    return false
end

-------------------------------------
-- function result
-------------------------------------
function AdsManager:result(ret, info)
    cclog('UnityAds Callback - ret:' .. ret .. ', info:' .. info)

    if self.callback ~= nil then
        self.callback(ret, info)
    end
end

-------------------------------------
-- function start
-- placementIds: 'rewardedVideo', 'lobbyGiftBox', 'storeGiffbox'
-------------------------------------
function AdsManager:start(placementId, result_cb)
    if (skip()) then 
        return
    end

    self.callback = result_cb

    local mode = ''
    if (IS_TEST_MODE()) then
        mode = 'test'
    end

    local function _result_cb(ret, info)
        self:result(ret, info)
    end

    -- @unity ads
    PerpleSDK:unityAdsStart(mode, '', _result_cb)

    -- AdColony, Tapjoy 광고 프리로드
    --[[
    -- @adcolony
    -- Value Exchange/V4VC 타입
    adcolonyAosZoneId = 'vze55a6191fd844b4cae'
    adcolonyIosZoneId = 'vza8efd1ab2da9422ba9'
    -- Preroll/Interstitial 타입
    --adcolonyAosZoneId = 'vzbedbcd794ef94f77b0'
    --adcolonyIosZoneId = 'vz2314b25936404e30b7'
    self.adcolonyZoneId = ''
    if isAndroid() then
        self.adcolonyZoneId = adcolonyAosZoneId
    elseif isIos() then
        self.adcolonyZoneId = adcolonyIosZoneId
    end
    PerpleSDK:adColonyStart(self.adcolonyZoneId, '')

    -- @tapjoy ads
    self.tapjoyAdPlacementId = 'TapjoyAd_video'
    PerpleSDK:tapjoySetPlacement(self.tapjoyAdPlacementId, function(ret, info) end)
    --]]
end

-------------------------------------
-- function show
-- placementIds: 'rewardedVideo', 'lobbyGiftBox', 'storeGiffbox'
-------------------------------------
function AdsManager:show(placementId, result_cb)
    if (skip()) then 
        return
    end

    self.callback = result_cb

    PerpleSDK:unityAdsShow(placementId, '')
end

-------------------------------------
-- function prepare
-------------------------------------
function AdsManager:prepare()
    if (skip()) then 
        return
    end

    self:start('')
end

-------------------------------------
-- function showPlacement
-------------------------------------
function AdsManager:showPlacement(placementId, result_cb)
    if (skip()) then 
        return
    end

    -- UnityAds 광고를 못 보여줄 경우, Tapjoy 광고 보기 시도 샘플 코드
    --[[
    local function _result_cb(ret, info)
        if ret == 'finish' then
            SoundMgr:playCurrBGM()
        end

        if (ret == 'error') then

            local tapjoyPlacement = 'TapjoyAd_video'
            PerpleSDK:tapjoySetPlacement(tapjoyPlacement, function(ret_, info_)
                cclog('TapjoyAds setPlacement callback - ret:' .. ret_ .. ', info:' .. info_)

                if ret_ == 'ready' then
                    PerpleSDK:tapjoyShowPlacement(tapjoyPlacement, function(ret__, info__)
                        cclog('TapjoyAds showPlacement callback - ret:' .. ret__ .. ', info:' .. info__)

                        if ret__ == 'show' then
                            -- do nothing
                        else
                            SoundMgr:playCurrBGM()

                            -- error
                            self:showErrorPopup(info, function()
                                result_cb(ret, info)
                            end)
                        end
                    end)
                elseif ret_ == 'success' then
                    -- do nothing
                else
                    SoundMgr:playCurrBGM()

                    -- fail, error
                    self:showErrorPopup(info, function()
                        result_cb(ret, info)
                    end)
                end
            end)

        else
            result_cb(ret, info)
        end
    end
    --]]

    local function _result_cb(ret, info)
        if ret == 'finish' or ret == 'error' then
            SoundMgr:playCurrBGM()
        end

        if (ret == 'error') then
            self:showErrorPopup(info, function()
                result_cb(ret, info)
            end)
        else
            result_cb(ret, info)
        end
    end

    SoundMgr:stopBGM()
    self:show(placementId, _result_cb)
end

-------------------------------------
-- function showErrorPopup
-------------------------------------
function AdsManager:showErrorPopup(errorCode, result_cb)
    local msg = ''

    if (errorCode == 'INITIALIZE_FAILED') then
        msg = Str('광고 모듈 초기화에 실패하였습니다.')
    elseif (errorCode == 'NOT_INITIALIZED') then
        msg = Str('광고 모듈이 아직 초기화되지 않았습니다. 잠시 후 다시 시도해 주세요.')
    elseif (errorCode == 'VIDEO_PLAYER_ERROR') then
        msg = Str('광고를 재생하는 비디오 플레이어에서 오류가 발생하였습니다.')
    elseif (errorCode == 'AD_BLOCKER_DETECTED') then
        msg = Str('광고가 차단되었습니다. 광고를 보시려면 광고 차단기를 해제하고 다시 시도해 주세요.')
    elseif (errorCode == 'FILE_IO_ERROR') then
        msg = Str('저장공간이 부족하여 광고를 다운로드받지 못했습니다. 불필요한 앱이나 파일을 삭제 후 다시 시도해 주세요.')
    elseif (errorCode == 'DEVICE_ID_ERROR') then
        msg = Str('디바이스 설정에 문제가 있어 광고를 보실 수 없습니다.')
    elseif (errorCode == 'INIT_SANITY_CHECK_FAIL') then
        msg = Str('디바이스 환경 설정에 문제가 있어 광고를 보실 수 없습니다.')
    elseif (errorCode == 'INVALID_ARGUMENT') then
        msg = Str('광고 API 호출시 잘못된 인자를 전달하였습니다.')
    elseif (errorCode == 'SHOW_ERROR') then
        msg = Str('광고 재생 과정에서 오류가 발생하였습니다. 잠시 후 다시 시도해 주세요.')
    elseif (errorCode == 'INTERNAL_ERROR') then
        msg = Str('광고 모듈에 오류가 발생하였습니다. 잠시 후 다시 시도해 주세요.')
    elseif (errorCode == 'NOT_READY') then
        result_cb()
        return
    else
        -- 'ALREADY_INITIALIZED'
        result_cb()
        return
    end

    MakeSimplePopup(POPUP_TYPE.OK, msg, result_cb)
end

-- 호출 방법
--[[
    AdsManager:showPlacement('rewardedVideo', function(ret, info)
        if ret == 'finish' then
            local t_info = dkjson.decode(info)
            ccdump(t_info)
            if t_info.placementId == 'rewardedVideo' then
                if t_info.result ~= 'SKIPPED' then
                    -- 보상 처리
                    MakeSimplePopup(POPUP_TYPE.OK, Str('광고 시청 완료!'))
                end
            end
        elseif ret == 'error' then
            if info == 'NOT_READY' then
                -- 광고가 없는 경우 또는 못 가져오는 경우
                MakeSimplePopup(POPUP_TYPE.OK, Str('광고 없음!'))
            end
        end
    end)
--]]

-- Tapjoy 광고 보기 샘플 코드
--[[
PerpleSDK:tapjoySetPlacement(self.tapjoyAdPlacementId, function(ret_, info_)
    cclog('TapjoyAds setPlacement callback - ret:' .. ret_ .. ', info:' .. info_)

    if ret_ == 'ready' then
        PerpleSDK:tapjoyShowPlacement(self.tapjoyAdPlacementId, function(ret__, info__)
            cclog('TapjoyAds showPlacement callback - ret:' .. ret__ .. ', info:' .. info__)
            if ret__ == 'wait' then
                -- 광고가 없거나 다운로드 중일 때
                -- setPlacement에서 'ready'인 경우에 showPlacement를 호출하므로 실제로는 여기로 리턴되는 경우는 없다.
            elseif ret__ == 'show' then
                -- 광고 재생 시작
                -- @주의 - 실제 콜백 호출은 광고 재생 시작 시 발생하나 Android의 경우 광고 재생이 끝나고 광고 화면을 닫을 때 루아 콜백이 온다. (루아 콜백이 스케줄러로 관리되므로)
                -- 탭조이 광고는 별도의 Completed 콜백이 없으므로 여기서 그냥 광고 보상 처리를 한다. (광고를 스킵불가로 설정할 것)

            elseif ret__ == 'dismiss' then
                -- 어떤 경우 이런 콜백이 오는 지 알 수 없음
                -- error로 처리하면 되지 않을까...
            else
                -- error
            end
        end)
    elseif ret_ == 'success' then
        -- do nothing
    else
        -- fail, error
    end
end)
--]]

-- AdColony 광고 보기 샘플 코드
--[[
PerpleSDK:adColonyReqeust(self.adcolonyZoneId, function(ret_, info_)
    cclog('AdColony request callback - ret:' .. ret_ .. ', info:' .. info_)
    if ret_ == 'ready' then
        PerpleSDK:adColonyShow(adcolonyZoneId)
    elseif ret_ == 'reward' then
        -- AdColony 콘솔에서 ZoneType을 Value Exchange/V4VC로 설정할 경우,
        -- 광고 보기를 완료하면 이 콜백이 온다. (Client Side Only로 설정할 것)
        -- ZoneType을 Preroll/Interstitial로 설정할 경우에는 오지 않음.
    else
        -- error
    end
end)
--]]
