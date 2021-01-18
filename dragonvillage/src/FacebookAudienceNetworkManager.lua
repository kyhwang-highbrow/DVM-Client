-------------------------------------
-- table FacebookAudienceNetworkManager
-- @brief Facebook Audience Network 전반 관리
-------------------------------------
FacebookAudienceNetworkManager = {}

local FacebookAudienceNetworkRewardedVideoAd = {
    mIsInit = false,
    mCallback = nil,
    mIsRequested = false, -- 광고 로드를 요청했는지 여부
    mIsLoaded = false, -- 광고가 불러졌는지 확인
}

-- 광고 키
local AD_PLACEMENT_ID = '1305794786440407_1311338499219369' -- app launching 시 사용

-------------------------------------
-- function initRewardedVideoAd
-- @brief 보상형 광고 초기화
-------------------------------------
function FacebookAudienceNetworkManager:initRewardedVideoAd()
    -- @ AdManager
    -- Native Call
    PerpleSDK:facebookAudienceNetworkInitRewardedVideoAd()

    FacebookAudienceNetworkRewardedVideoAd.mIsInit = true

    local rewarded_video_ad = self:getRewardedVideoAd()

    if (rewarded_video_ad) then
        local function ad_result_cb(ret, info)

            -- 광고 load 완료
            if (ret == 'receive') then
                rewarded_video_ad.mIsLoaded = true
            end

            self:onResultCallback(ret, info)

            if (rewarded_video_ad.mCallback) then
                rewarded_video_ad.mCallback(ret, info)
            end
        end

        rewarded_video_ad:setResultCallback(ad_result_cb)

        -- Optional : 광고 로드를 초기화 후 바로 할지는 알아서 판단.
        rewarded_video_ad:loadRewardedAd(AD_PLACEMENT_ID)
    end
end


-------------------------------------
-- function onResultCallback
-- @brief 공용 callback 처리
-------------------------------------
function FacebookAudienceNetworkManager:onResultCallback(ret, info)
    cclog('FacebookAudienceNetwork Callback - ret:' .. ret .. ', info:' .. info)

    -- 광고 load 완료
    if (ret == 'receive') then

    -- 광고 load 실패
    elseif (ret == 'fail') then

	-- 광고 open <-> finish
	elseif (ret == 'open') then
        SoundMgr:stopBGM()

	-- 각각 opne, finish와 큰 차이는 없음
	elseif (ret == 'start') then
	elseif (ret == 'complete') then

    -- 광고 show 완료
    elseif (ret == 'finish') then
        SoundMgr:playPrevBGM()

    -- 광고 show 중단
    elseif (ret == 'cancel') then
        SoundMgr:playPrevBGM()
        local msg = Str('광고 시청 도중 취소하셨습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)

    -- 에러
    elseif (ret == 'error') then
        SoundMgr:playPrevBGM()
        self:showErrorPopup(info)
    end
end



-------------------------------------
-- function getRewardedVideoAd
-- @brief 초기화된 보상형 객체 가져오기
-------------------------------------
function FacebookAudienceNetworkManager:getRewardedVideoAd()
    return FacebookAudienceNetworkRewardedVideoAd
end


-------------------------------------
-- function showErrorPopup
-- @brief 오류코드 출력하는 공통 에러 팝업 사용하지 않음
-------------------------------------
function FacebookAudienceNetworkManager:showErrorPopup(error_info)
    local msg = ''

    local t_error = dkjson.decode(error_info)

    if (not t_error) then return end

    local code = t_error['code']

    -- not init
    if (code == "-2100") then
        msg = Str('광고 초기화가 되지 않았습니다.')

    -- start error
    elseif (code == "-2101") then
        msg = Str('광고를 불러오는 과정에서 에러가 발생했습니다.')

    -- no ad unit id : show 요청 받았으나 ad unit id가 없음
    elseif (code == "-2102") then
        msg = Str('존재 하지 않는 광고 요청입니다.')

    -- not loaded ad : 광고가 load되지 않음
    elseif (code == "-2103") then
		msg = Str('광고를 불러오는 중입니다. 잠시 후에 다시 시도해주세요.')

    -- fail to load : 광고 불러오기 실패
    elseif (code == "-2104") then
        msg = Str('비정상적인 광고 요청입니다.')

    else
        msg = Str('광고 시청 할 수 없습니다. 잠시 후에 다시 시도해주세요.')

    end

    MakeSimplePopup(POPUP_TYPE.OK, msg)
end



-------------------------------------
-- function loadRewardedAd
-------------------------------------
function FacebookAudienceNetworkRewardedVideoAd:loadRewardedAd(ad_placement_id)
    if (not self.mIsInit) then
        return
    end

    self.mIsRequested = true

    -- @ AdManager
    PerpleSDK:rvFacebookAudienceNetworkLoadWithId(ad_placement_id)
end

-------------------------------------
-- function setResultCallback
-------------------------------------
function FacebookAudienceNetworkRewardedVideoAd:setResultCallback(cb_func)
    if (not self.mIsInit) then
        return
    end

    -- @ AdManager
    PerpleSDK:rvFacebookAudienceNetworkSetResultCallback(cb_func)
end

-------------------------------------
-- function show
-------------------------------------
function FacebookAudienceNetworkRewardedVideoAd:show(ad_placement_id, result_cb)
    if (not self.mIsInit) then
        return
    end

    -- 로드를 한적이 없으면 먼저 로드시킨다.
    if (self.mIsRequested == false) then
        self:loadRewardedAd(ad_placement_id)
    end

    -- 전부 로드 됐을 때의 콜백
    local function showFunc()
        -- 로드된 광고 소모가 됨으로 false로 설정
        self.mIsLoaded = false
        self.mIsRequested = false

        -- 결과 콜백
        -- Manager Init할 때 셋팅됨.
        self.mCallback = function(ret, info)
            if (result_cb) then
                result_cb(ret, info)
            end
        end

        -- @ AdManager
        -- Native
        PerpleSDK:rvFacebookAudienceNetworkAdShow(ad_placement_id)
    end

    if (self.mIsLoaded) then
        showFunc()
    else
        -- 광고를 로드하는 동안 로딩창으로 터치 블럭 처리
        local loading = UI_LoadingAdLoad()
        loading:showBgLayer()
        loading:setLoadingMsg(Str('광고를 불러오는 중...'))

        -- 취소
        local function click()
            if loading then
                loading:close()
                loading = nil
            end
        end

        local close_btn = loading.vars['closeBtn']
        close_btn:setVisible(false)
        close_btn:registerScriptTapHandler(click)

        -- 광고 로드가 완료될때까지 기다림
        local timer = 0
        local function update(dt)
            if loading then
                timer = (timer + dt)
                if (self.mIsLoaded == true) then
                    -- node 본인의 Update schedule에서 본인을 삭제할 경우 오류가 발생하는 것으로 유추되어 액션으로 0.1초 후 close 시도
                    local loading_ = loading
                    cca.reserveFunc(loading_.root, 0.1, function() loading_:close() end)

                    loading = nil
                    showFunc()

                -- 5초 이후부터는 취소 버튼 추가
                elseif (5 <= timer) then
                    local close_btn = loading.vars['closeBtn']
                    if (close_btn:isVisible() == false) then
                        close_btn:setVisible(true)
                    end
                end
            end
        end

        -- Update 이벤트 구독
        loading.root:scheduleUpdateWithPriorityLua(update, 0)

        -- 일정 시간 후 닫기 (혹시 모를 무한 대기 상태를 대비)
        local node = loading.root
        local duration = 60

        local function func_timeout()
            local msg = Str('광고 시청 할 수 없습니다. 잠시 후에 다시 시도해주세요.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)

            if loading then
                loading:close()
                loading = nil
            end
        end

        cca.reserveFunc(node, duration, func_timeout)
    end
end

-------------------------------------
-- function showByAdType
-- 광고 타입을 받아서 분기처리를 할것에 대비해 함수만은 살려둠
-------------------------------------
function FacebookAudienceNetworkRewardedVideoAd:showByAdType(ad_type, result_cb)
    local adPlacementID = self:getAdUnitIdByAdType(ad_type)
    self:show(adPlacementID, result_cb)
end

-------------------------------------
-- function showDailyAd
-- @breif 횟수 제한형 광고
-- 광고 타입을 받아서 분기처리를 할것에 대비해 ad_type 살려둠
-------------------------------------
function FacebookAudienceNetworkRewardedVideoAd:showDailyAd(ad_type, finish_cb)
    local adPlacementID = self:getAdUnitIdByAdType(ad_type)
    local function result_cb(ret, info)
        if (ret == 'finish') then
            g_advertisingData:request_dailyAdShow(ad_type, function()
                if (finish_cb) then
                    finish_cb()
                end
            end)
        end
    end

    if (CppFunctions:isWin32()) then
        result_cb('finish')
        return
    end

    self:show(adPlacementID, result_cb)
end


-------------------------------------
-- function adPreload
-- @breif 광고 프리로드 요청
-- @usage FacebookAudienceNetworkManager:getRewardedVideoAd():adPreload(AD_TYPE['FOREST'])
-------------------------------------
function FacebookAudienceNetworkRewardedVideoAd:adPreload(ad_type)
    local adPlacementID = self:getAdUnitIdByAdType(ad_type)
    self:loadRewardedAd(adPlacementID)
end


-------------------------------------
-- function getAdUnitIdByAdType
-------------------------------------
function FacebookAudienceNetworkRewardedVideoAd:getAdUnitIdByAdType(ad_type)
    local adPlacementID = ''

    -- 혹시 모를 상황 대비해서 로직 살려두기
    adPlacementID = AD_PLACEMENT_ID

    return adPlacementID
end