-------------------------------------
-- table AdMobManager
-- @brief AdMob 전반 관리
-------------------------------------
AdMobManager = {}

local AdMobRewardedVideoAd = {
    mIsInit = false,
    mCallback = nil,
    mIsRequested = false, -- 광고 로드를 요청했는지 여부
    mIsLoaded = false, -- 광고가 불러졌는지 확인
}

-- 광고 키
local ADMOB_AD_UNIT_ID_TABLE
local ADMOB_APP_AD_UNIT_ID -- app launching 시 사용

-- admob 광고 단위 key 주석에서 검색 안되도록 삭제 2023-03-27 kyhwang
if (CppFunctions:isAndroid()) then
    ADMOB_APP_AD_UNIT_ID = ''
    ADMOB_AD_UNIT_ID_TABLE = {
        [AD_TYPE.AUTO_ITEM_PICK] = '',
        [AD_TYPE.RANDOM_BOX_LOBBY] = '',
        [AD_TYPE.FOREST] = '',
        [AD_TYPE.EXPLORE] = '',
        [AD_TYPE.FRIENDSHIP_SUMMON] = '',
        [AD_TYPE.TEST] = '',
    }
elseif (CppFunctions:isIos()) then
	ADMOB_APP_AD_UNIT_ID = ''
    ADMOB_AD_UNIT_ID_TABLE = {
        [AD_TYPE.AUTO_ITEM_PICK] = '',
        [AD_TYPE.RANDOM_BOX_LOBBY] = '',
        [AD_TYPE.FOREST] = '',
        [AD_TYPE.EXPLORE] = '',
        [AD_TYPE.FRIENDSHIP_SUMMON] = '',
        [AD_TYPE.TEST] = '',
    }
else
    ADMOB_AD_UNIT_ID_TABLE = {}
end


--------------------------------------------------------------------------
-- table AdMobManager
--------------------------------------------------------------------------

-------------------------------------
-- function initRewardedVideoAd
-- @brief 보상형 광고 초기화
-------------------------------------
function AdMobManager:initRewardedVideoAd()
    -- @ AdManager
    PerpleSDK:adMobInitRewardedVideoAd()
    AdMobRewardedVideoAd.mIsInit = true
   
    local rewarded_video_ad = self:getRewardedVideoAd()
    if (rewarded_video_ad) then
        local function ad_result_cb(ret, info)

            -- 광고 load 완료
            if (ret == 'receive') then
                rewarded_video_ad.mIsLoaded = true
            end

            self:result(ret, info)
            if (rewarded_video_ad.mCallback) then
                rewarded_video_ad.mCallback(ret, info)
            end
        end
        rewarded_video_ad:setResultCallback(ad_result_cb)

        -- sgkim 20190429 AdMob의 광고 로드가 비정상 종료에 영향을 준다고 판단하여 프리로드 하지 않도록 변경
        -- @sgkim 2019.10.08 문제가 발생되는 aos 7.0이상에서는 광고를 재생하고 있지 않기 때문에 다시 프리로드를 하도록 변경
        -- @sgkim 2019.10.14 광고 프리로드를 하니 aos 7.0 미만에서도 크래시가 나는 것 같아 다시 비활성화
        --rewarded_video_ad:loadRequest(ADMOB_APP_AD_UNIT_ID)
    end
end

-------------------------------------
-- function initInterstitialAd
-- @brief 전면 광고 초기화
-------------------------------------
function AdMobManager:initInterstitialAd()
    
    --local interstitial_ad = self:getInterstitialAd()
    --interstitial_ad:initInterstitialAd()
end

-------------------------------------
-- function getRewardedVideoAd
-------------------------------------
function AdMobManager:getRewardedVideoAd()
    return AdMobRewardedVideoAd
end

-------------------------------------
-- function getInterstitialAd
-------------------------------------
function AdMobManager:getInterstitialAd()
    -- 전면광고를 보낼 때가 있다?
    local msg = 'AdMobManager:getInterstitialAd :: Trying to load InterstitialAd'
    g_errorTracker:sendErrorLog(msg, nil) -- param : msg, success_cb

    --return AdMobInterstitialAd
end

-------------------------------------
-- function result
-- @brief 공용 callback 처리
-------------------------------------
function AdMobManager:result(ret, info)
    cclog('AdMob Callback - ret:' .. ret .. ', info:' .. info)

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
-- function showErrorPopup
-- @brief 오류코드 출력하는 공통 에러 팝업 사용하지 않음
-------------------------------------
function AdMobManager:showErrorPopup(error_info)
    local msg = ''
    
    local t_error = dkjson.decode(error_info)
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

--------------------------------------------------------------------------
-- table AdMobRewardedVideoAd
--------------------------------------------------------------------------

-------------------------------------
-- function loadRequest
-------------------------------------
function AdMobRewardedVideoAd:loadRequest(ad_unit_id)
    if (not self.mIsInit) then
        return
    end

    --ccdisplay('광고 프리 로드 요청 : ' .. tostring(ad_unit_id))

    self.mIsRequested = true

    -- @ AdManager
    PerpleSDK:rvAdLoadRequestWithId(ad_unit_id)
end

-------------------------------------
-- function setResultCallback
-------------------------------------
function AdMobRewardedVideoAd:setResultCallback(cb_func)
    if (not self.mIsInit) then
        return
    end

    -- @ AdManager
    PerpleSDK:rvAdSetResultCallback(cb_func)
end

-------------------------------------
-- function show
-------------------------------------
function AdMobRewardedVideoAd:show(ad_unit_id, result_cb)
    if (not self.mIsInit) then
        return
    end

    if (self.mIsRequested == false) then
        self:loadRequest(ad_unit_id)
    end

    local function showFunc()
        -- 로드된 광고 소모가 됨으로 false로 설정
        self.mIsLoaded = false
        self.mIsRequested = false

        self.mCallback = function(ret, info)
            if (result_cb) then
                result_cb(ret, info)
            end
        end

        -- @ AdManager
        PerpleSDK:rvAdShow(ad_unit_id)
    end

    if (self.mIsLoaded == true) then
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
                --loading:setLoadingMsg(Str('광고를 불러오는 중...') .. tostring(math_floor(timer)))
                if (self.mIsLoaded == true) then    
                    --loading:close()
                    
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
        loading.root:scheduleUpdateWithPriorityLua(update, 0)

        -- 일정 시간 후 닫기 (혹시 모를 무한 대기 상태를 대비)
        local node = loading.root
        local duration = 60
        local function func()
            local msg = Str('광고 시청 할 수 없습니다. 잠시 후에 다시 시도해주세요.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            if loading then
                loading:close()
                loading = nil
            end
        end
        cca.reserveFunc(node, duration, func)
    end
end

-------------------------------------
-- function showByAdType
-------------------------------------
function AdMobRewardedVideoAd:showByAdType(ad_type, result_cb)
    local ad_unit_id = self:getAdUnitIdByAdType(ad_type)
    self:show(ad_unit_id, result_cb)
end

-------------------------------------
-- function showDailyAd
-- @breif 횟수 제한형 광고
-------------------------------------
function AdMobRewardedVideoAd:showDailyAd(ad_type, finish_cb)
    local ad_unit_id = self:getAdUnitIdByAdType(ad_type)
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

    self:show(ad_unit_id, result_cb)
end


-------------------------------------
-- function adPreload
-- @breif 광고 프리로드 요청
-- @usage AdMobManager:getRewardedVideoAd():adPreload(AD_TYPE['FOREST'])
-------------------------------------
function AdMobRewardedVideoAd:adPreload(ad_type)
    local ad_unit_id = self:getAdUnitIdByAdType(ad_type)
    self:loadRequest(ad_unit_id)
end


-------------------------------------
-- function getAdUnitIdByAdType
-------------------------------------
function AdMobRewardedVideoAd:getAdUnitIdByAdType(ad_type)
    local ad_unit_id = ADMOB_AD_UNIT_ID_TABLE[ad_type]

    -- @sgkim 2019.10.18 Admob의 모든 광고는 하나의 광고 단위로 재생한다.
    --                   preload의 문제와 광고 크래시 안정화를 위해서이다.
    ad_unit_id = ADMOB_APP_AD_UNIT_ID

    return ad_unit_id
end