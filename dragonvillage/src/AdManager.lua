AD_TYPE = {
    AUTO_ITEM_PICK = 1,     -- 광고 보기 보상 : 자동획득
    RANDOM_BOX_LOBBY = 2,   -- 광고 보기 보상 : 랜덤박스 (로비 진입)
    RANDOM_BOX_SHOP = 3,    -- 광고 보기 보상 : 랜덤박스 (상점 진입)
    NONE = 4,               -- 광고 없음(에러코드 처리) : 보상은 존재
}

-------------------------------------
-- table AdManager
-- @brief 광고 SDK 매니져
-------------------------------------
AdManager = {
    callback,
    adcolonyZoneId,
    tapjoyAdPlacementId,
}

local ADMOB_AD_UNIT_ID_TABLE
if (CppFunctions:isAndroid()) then
    ADMOB_AD_UNIT_ID_TABLE = {
        [AD_TYPE.AUTO_ITEM_PICK] = 'ca-app-pub-9497777061019569/2042688805',
        [AD_TYPE.RANDOM_BOX_SHOP] = 'ca-app-pub-9497777061019569/2042688805',
        [AD_TYPE.RANDOM_BOX_LOBBY] = 'ca-app-pub-9497777061019569/4566955961',
        [AD_TYPE.NONE] = 'error',
    }
elseif (CppFunctions:isIos()) then
    ADMOB_AD_UNIT_ID_TABLE = {
        [AD_TYPE.AUTO_ITEM_PICK] = 'ca-app-pub-9497777061019569/2042688805',
        [AD_TYPE.RANDOM_BOX_SHOP] = 'ca-app-pub-9497777061019569/2042688805',
        [AD_TYPE.RANDOM_BOX_LOBBY] = 'ca-app-pub-9497777061019569/4566955961',
        [AD_TYPE.NONE] = 'error',
    }
else
    ADMOB_AD_UNIT_ID_TABLE = {}
end

-------------------------------------
-- function result
-------------------------------------
function AdManager:result(ret, info)
    cclog('Ad Callback - ret:' .. ret .. ', info:' .. info)

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

    self.callback = result_cb

    local function _result_cb(ret, info)
        self:result(ret, info)
    end

    -- 광고 단위 ID 등록 리스트
    local l_ad_unit_id = tableToString(ADMOB_AD_UNIT_ID_TABLE, ';')
    
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
-- function showErrorPopup
-------------------------------------
function AdManager:showErrorPopup(error_info)
    local msg = ''
    
    local t_error = dkjson.decode(error_info)
    local code = t_error['code']
    if (code == "-2100") then
        msg = Str('not init')
    elseif (code == "-2101") then
        msg = Str('start')
    elseif (code == "-2102") then
        msg = Str('no ad unit id')
    elseif (code == "-2103") then
        msg = Str('not loaded ad')
    elseif (code == "-2104") then
        msg = Str('invalid ad unit id')
    else
        cclog('admob error 구멍')
    end

    MakeSimplePopup(POPUP_TYPE.OK, msg)
end