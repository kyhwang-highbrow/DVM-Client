AD_TYPE = {
    NONE = 0,               -- 광고 없음(에러코드 처리) : 보상은 존재
    AUTO_ITEM_PICK = 1,     -- 광고 보기 보상 : 자동획득
    RANDOM_BOX_LOBBY = 2,   -- 광고 보기 보상 : 랜덤박스 (로비 진입)
    FOREST = 3,
    EXPLORE = 4,
    FSUMMON = 5,
}

-------------------------------------
-- table AdManager
-- @brief 광고 SDK 매니져
-------------------------------------
AdManager = {
    callback,
}

local ADMOB_AD_UNIT_ID_TABLE
local ADMOB_APP_AD_UNIT_ID -- app launching 시 사용
if (CppFunctions:isAndroid()) then
    ADMOB_APP_AD_UNIT_ID = 'ca-app-pub-9497777061019569/6433744394'
    ADMOB_AD_UNIT_ID_TABLE = {
        [AD_TYPE.AUTO_ITEM_PICK] = 'ca-app-pub-9497777061019569/8284077763',
        [AD_TYPE.RANDOM_BOX_LOBBY] = 'ca-app-pub-9497777061019569/1372989407',
        [AD_TYPE.FOREST] = 'ca-app-pub-9497777061019569/7721594075',
        [AD_TYPE.EXPLORE] = 'ca-app-pub-9497777061019569/7058963688',
        [AD_TYPE.FSUMMON] = 'ca-app-pub-9497777061019569/7338450690',
    }
elseif (CppFunctions:isIos()) then
    ADMOB_AD_UNIT_ID_TABLE = {
        [AD_TYPE.AUTO_ITEM_PICK] = 'ca-app-pub-9497777061019569/5295237757',
        [AD_TYPE.RANDOM_BOX_LOBBY] = 'ca-app-pub-9497777061019569/4566955961',
        [AD_TYPE.FOREST] = 'ca-app-pub-9497777061019569/1816066243',
        [AD_TYPE.EXPLORE] = 'ca-app-pub-9497777061019569/1432922866',
        [AD_TYPE.FSUMMON] = 'ca-app-pub-9497777061019569/4989024494',
    }
else
    ADMOB_AD_UNIT_ID_TABLE = {}
end

-------------------------------------
-- function result
-------------------------------------
function AdManager:result(ret, info)
    cclog('AdMob Callback - ret:' .. ret .. ', info:' .. info)

    -- 광고 load 완료
    if (ret == 'receive') then

    -- 광고 load 실패
    elseif (ret == 'fail') then

    -- 광고 show 완료
    elseif (ret == 'finish') then
        SoundMgr:playPrevBGM()
        PerpleSDK:adMobLoadRequest()

    -- 광고 show 중단
    elseif (ret == 'cancel') then
        SoundMgr:playPrevBGM()
        PerpleSDK:adMobLoadRequest()
        local msg = Str('광고 시청 도중 취소하셨습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)

    -- 에러
    elseif (ret == 'error') then
        SoundMgr:playPrevBGM()
        self:showErrorPopup(info)
    end

    -- 광고 요청 시 따로 정의한 콜백 실행
    if (self.callback ~= nil) then
        self.callback(ret, info)
    end
end

-------------------------------------
-- function start
-------------------------------------
function AdManager:start(result_cb)
    if (CppFunctions:isWin32()) then 
        return
    end
	-- 광고 비활성화 시
	if (AdManager:isAdInactive()) then
		return
	end

    self.callback = result_cb

    local function _result_cb(ret, info)
        self:result(ret, info)
    end

    -- 광고 단위 ID 등록 리스트
    local l_ad_unit_id = listToString(ADMOB_AD_UNIT_ID_TABLE, ';')
    if (CppFunctions:isAndroid()) then
        l_ad_unit_id = ADMOB_APP_AD_UNIT_ID .. ';' .. l_ad_unit_id
    end

    -- @adMob
    PerpleSDK:adMobSetResultCallBack(_result_cb)
    PerpleSDK:adMobStart(l_ad_unit_id)
    PerpleSDK:adMobLoadRequest()
end

-------------------------------------
-- function show
-------------------------------------
function AdManager:show(ad_unit_id, result_cb)
    if (CppFunctions:isWin32()) then 
        return
    end

    SoundMgr:stopBGM()
    self.callback = result_cb
    PerpleSDK:adMobShow(ad_unit_id)
end

-------------------------------------
-- function showByAdType
-------------------------------------
function AdManager:showByAdType(ad_type, result_cb)
    local ad_unit_id = ADMOB_AD_UNIT_ID_TABLE[ad_type]
    self:show(ad_unit_id, result_cb)
end

-------------------------------------
-- function showDailyAd
-- @breif 횟수 제한형 광고
-------------------------------------
function AdManager:showDailyAd(ad_type, finish_cb)
    local ad_unit_id = ADMOB_AD_UNIT_ID_TABLE[ad_type]
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
-- function showErrorPopup
-- @brief 오류코드 출력하는 공통 에러 팝업 사용하지 않음
-------------------------------------
function AdManager:showErrorPopup(error_info)
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

    -- invalid ad unit id : show 요청 받았으나 ad unit id가 비정상
    elseif (code == "-2104") then
        msg = Str('비정상적인 광고 요청입니다.')

    else
        msg = Str('광고 시청 할 수 없습니다. 잠시 후에 다시 시도해주세요.')

    end

    MakeSimplePopup(POPUP_TYPE.OK, msg)
end

-------------------------------------
-- function isAdInactive
-------------------------------------
function AdManager:isAdInactive()
	return g_localData:isAdInactive()
end

-------------------------------------
-- function makePopupAdInactive
-------------------------------------
function AdManager:makePopupAdInactive()
	local msg, sub_msg
	local lang = Translate:getGameLang()
	
	if (lang == 'ko') then
		msg = '동영상 광고 일시 중지 안내'
		sub_msg = '동영상 광고 송출에 장애가 있어 문제를 처리 중입니다.\n여러분의 양해를 부탁드립니다.'

	elseif (lang == 'zh') then
		msg = '影片廣告暫時終止公告'
		sub_msg = '正在處理影片廣告輸出時所發生的問題。如造成不便，敬請見諒。'

	elseif (lang == 'ja') then
		msg = '動画広告の一時中止のお知らせ'
		sub_msg = 'ただいま動画広告に関する不具合を処理中です。\n皆様のご了承をお願い致します。'

	else
		msg = 'Ad Viewing Temporarily Unavailable'
		sub_msg = 'Ad viewing is currently not available due to technical problems.\nThank you for your understanding.'

	end

	MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
end
