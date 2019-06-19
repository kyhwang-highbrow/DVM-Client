-------------------------------------
-- table UnityAdsManager
-- @brief UnityAds 전반 관리
-------------------------------------
UnityAdsManager = {
        m_sdkListener = nil,
        m_showResultCallback = nil,
    }

-------------------------------------
-- function initAdSdk
-- @brief
-------------------------------------
function UnityAdsManager:initAdSdk()
    -- UnityAds 초기화
    cclog('##UnityAds## unityads_init')
    local debug_str = 'debug' -- 'debug' or ''
    SDKManager:sendEvent('unityads_initialize', debug_str)
end

-------------------------------------
-- function initRewardedVideoAd
-- @brief 보상형 광고 초기화
-------------------------------------
function UnityAdsManager:initRewardedVideoAd()
    local unityads_listener = function(ret, info) self:unityAdsListener(ret, info) end

    -- UnityAds start
    cclog('##UnityAds## unityads_start')
    local mode = 'test' -- 'test' or ''
    local meta_data = ''
    PerpleSDK:unityAdsStart(mode, meta_data, unityads_listener)
end

-------------------------------------
-- function unityAdsListener
-- @brief 이벤트 리스너
-------------------------------------
function UnityAdsManager:unityAdsListener(ret, info)
    cclog('##UnityAds## unityads_listener') 
    cclog('##UnityAds## ret : ' .. tostring(ret))
    cclog('##UnityAds## info : ' .. tostring(info))

    if (ret == 'ready') then

    elseif (ret == 'start') then

    elseif (ret == 'finish') then

    elseif (ret == 'error') then

        -- SDK 자체가 초기화되기 전에 start를 호출한 경우
        -- info : {"code":"-1800","subcode":"0","msg":"UnityAds is not initialized."}
        local t_error = dkjson.decode(info)
        if (t_error) then
            if (t_error['code'] == '-1800') then
                self:initRewardedVideoAd()
            end
        end


        if (info == 'NOT_READY') then

        elseif (ret == 'NOT_INITIALIZED') then

        end
    end

    -- 광고 보기 호출 시 콜백
    if (self.m_showResultCallback) then
        local reset_cb = false
        local _ret = ret
        local _info = info

        if (ret == 'finish') then
            -- info : {"placementId":"lobbyGiftBox","result":"COMPLETED"}
            reset_cb = true

        elseif (ret == 'error') then
            if (info == 'NOT_READY') then
                reset_cb = true

            elseif (info == 'NOT_INITIALIZED') then
                reset_cb = true
            end

            if (reset_cb == true) then
                self:showErrorPopup(error_info)
            end
        end

        if (reset_cb == true) then
            self.m_showResultCallback(_ret, _info)
            self.m_showResultCallback = nil
        end
    end
end

-------------------------------------
-- function adPreload
-- @breif 광고 프리로드 요청
-------------------------------------
function UnityAdsManager:adPreload(ad_type)
    -- UnityAds는 SDK자체에서 프리로드를 실행하기때문에 별도로 할 필요가 없음
end

-------------------------------------
-- function showByAdType
-- @param ad_type
-- @param result_cb function(ret, info)
--                      -- 광고 시청 완료 -> 보상 처리
--                      if (ret == 'finish') then
--
--                      -- 광고 시청 취소
--                      elseif (ret == 'cancel') then
--
--                      -- 광고 에러
--                      elseif (ret == 'error') then
--
--                      end
--                  end
-------------------------------------
function UnityAdsManager:showByAdType(ad_type, result_cb)
    self.m_showResultCallback = result_cb

    -- @metaData : json format string,  '{"serverId":"@serverId", "ordinalId":"@ordinalId"}'
    local placement_id = 'lobbyGiftBox'
    local meda_data = ''
    cclog('##UnityAds## unityAdsShow ' .. placement_id) 
    PerpleSDK:unityAdsShow(placement_id, meda_data)
end

-------------------------------------
-- function showDailyAd
-- @breif 횟수 제한형 광고
-------------------------------------
function UnityAdsManager:showDailyAd(ad_type, finish_cb)

    local function result_cb(ret, info)
        if (ret == 'finish') then
            g_advertisingData:request_dailyAdShow(ad_type, function()
                if (finish_cb) then
                    finish_cb()
                end
            end)
        end
    end

    self:showByAdType(ad_type, result_cb)
end

-------------------------------------
-- function showErrorPopup
-- @brief 오류코드 출력하는 공통 에러 팝업 사용하지 않음
-------------------------------------
function UnityAdsManager:showErrorPopup(error_info)
    local msg = ''
    
    -- NOT_INITIALIZED UnityAds 초기화 중
    if (error_info == 'NOT_INITIALIZED') then
        --msg = Str('광고 초기화가 되지 않았습니다.')
        msg = Str('광고 시청 할 수 없습니다. 잠시 후에 다시 시도해주세요.') -- 더 적절한 메세지로 생각됨

    -- NOT_READY 광고 로드 중
    elseif (code == 'NOT_READY') then
		msg = Str('광고를 불러오는 중입니다. 잠시 후에 다시 시도해주세요.')

    else
        msg = Str('광고 시청 할 수 없습니다. 잠시 후에 다시 시도해주세요.')

    end

    MakeSimplePopup(POPUP_TYPE.OK, msg)
end