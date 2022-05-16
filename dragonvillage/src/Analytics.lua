Analytics = {
    enable = true,
}
Adbrix = {}
Tapjoy = {}

require 'CppFunctions'
require 'PerpleSdkManager'
if (PerpleSdkManager:xsollaIsAvailable()) then
	Adjust = {
		EVENT = {
			FIRST_PURCHASE = '793ad3',
			PURCHASE = 'nil',
			PURCHASE_USD = 'at7due',

			PURCHASE_1000_US = 'qobhb0',
			PURCHASE_100_US = '2x0qi0',
			PURCHASE_10_US = 'vtowtt',
			TUTORIAL_FINISH_1_2 = 't78879',
			STAGE_FINISH_1_7 = 'k7hrgn',
			RUNE_EQUIP = 'rr9kfq',
			CREATE_NICKNAME = '404adx',
			CREATE_NICKNAME_REPEAT = 'bdofei',
			TUTORIAL_FINISH_INTRO = 'fi0mg2',
			DRAGON_ENVOLVE = 'oqm19x',
			DRAGON_RANKUP = 'knulf0',
			DRAGON_MAKE_6GRADE = '4zoahx',
			TAMER_LV_4 = 'oumkg2',
			TAMER_LV_6 = 'qk0pe4',
			TAMER_LV_8 = 'ju80wk',
			TAMER_LV_10 = 'iniqva',
			TAMER_LV_12 = '7cy2lu',
			TAMER_LV_15 = 'eqqxkc',
		}
	}
-- @sgkim 2020.08.12 adjust에서 구글 플레이 / 앱스토어 / 원스토어 빌드의 지표를 하나의 adjust app으로 남기도록 변경함.
---elseif (PerpleSdkManager:onestoreIsAvailable()) then
---	Adjust = {
---		EVENT = {
---			FIRST_PURCHASE = 'wejpab',              --첫구매
---			PURCHASE = '9vhez3',                    --구매 통합
---			PURCHASE_USD = 'nxwz7u',                --구매 (달러)
---
---			CREATE_NICKNAME = '40e5qw',             --닉네임 생성
---			CREATE_NICKNAME_REPEAT = 'zewa3w',      --닉네임 생성 unique아닌거(리세마라 체크용)
---			TUTORIAL_FINISH_INTRO = 'k8qdlb',       --인트로 전투 끝
---			TUTORIAL_FINISH_1_2 = 'ifqx0i',         --1-2스테이지 끝
---			STAGE_FINISH_1_7 = '8cxrfm',            --1-7 스테이지 끝
---			TAMER_LV_4 = 'wn5h73',                  --테이머 레벨4
---			TAMER_LV_6 = 'rgldp1',                  --테이머 레벨6
---			TAMER_LV_8 = 'yd9c2u',                  --테이머 레벨8
---			TAMER_LV_10 = '7r8v3q',                 --테이머 레벨10
---			TAMER_LV_12 = '62thni',                 --테이머 레벨12
---			TAMER_LV_15 = 'mbx4qz',                 --테이머 레벨15
---			DRAGON_ENVOLVE = 'w6uyo9',              --드래곤 진화
---			DRAGON_RANKUP = 'tkoo5d',               --드래곤 승급
---			DRAGON_MAKE_6GRADE = '9qt8m6',          --6성드래곤 만듬
---			RUNE_EQUIP = '551loq',                  --6성 룬 장비
---			PURCHASE_10_US = '3rsefo',              --누적 결제금액 1만원 이상
---			PURCHASE_100_US = '547z21',             --누적 결제금액 10만원 이상
---			PURCHASE_1000_US = 'wun3fo',            --누적 결제금액 100만원 이상
---		}
---    }
else
	Adjust = {
		EVENT = {
			FIRST_PURCHASE = 'vooktq',              --첫구매
			PURCHASE = '33qpix',                    --구매 통합
			PURCHASE_USD = '2a7wxs',                --구매 (달러)

			CREATE_NICKNAME = 'kfwvim',             --닉네임 생성
			CREATE_NICKNAME_REPEAT = 'j878iw',      --닉네임 생성 unique아닌거(리세마라 체크용)
			TUTORIAL_FINISH_INTRO = '8kbl5r',       --인트로 전투 끝
			TUTORIAL_FINISH_1_2 = '8muhb5',         --1-2스테이지 끝
			STAGE_FINISH_1_7 = 'jvsd8a',            --1-7 스테이지 끝
			TAMER_LV_4 = 'jwr2ph',                  --테이머 레벨4
			TAMER_LV_6 = 'cr2mhh',                  --테이머 레벨6
			TAMER_LV_8 = 'vu1op6',                  --테이머 레벨8
			TAMER_LV_10 = 'qdp5xl',                 --테이머 레벨10
			TAMER_LV_12 = 'isdc0l',                 --테이머 레벨12
			TAMER_LV_15 = '7jdlbl',                 --테이머 레벨15
			DRAGON_ENVOLVE = 'm2n4v9',              --드래곤 진화
			DRAGON_RANKUP = 'l3gjj6',               --드래곤 승급
			DRAGON_MAKE_6GRADE = 't17tqo',          --6성드래곤 만듬
			RUNE_EQUIP = 'oe7bdp',                  --6성 룬 장비
			PURCHASE_10_US = 'y7mq3a',              --누적 결제금액 1만원 이상
			PURCHASE_100_US = '6c2snf',             --누적 결제금액 10만원 이상
			PURCHASE_1000_US = 'yu1up4',            --누적 결제금액 100만원 이상
		}
	}
end



CUS_CATEGORY = {

    FIRST   = '001.초기 안착',

    CASH    = '101.캐쉬',
    AMET    = '102.자수정',
    GOLD    = '103.골드',
    STAMINA = '104.날개',
    MILEAGE = '105.마일리지',
    TOPAZ   = '106.토파즈',
    HONOR   = '107.명예',
    ANCIENT = '108.고대주화',

    PLAY    = '201.플레이',

    GROWTH  = '301.성장/육성',
}

-- event name, value name
CUS_EVENT = {

    MASTER_ROAD = {'마스터의 길', '마스터의 길 클리어 유저수'},
    GET_CASH    = {'획득', '획득한 모든 다이아 수량'},
    USE_CASH    = {'소진', '소진한 모든 다이아 수량'},

    GET_AMET    = {'획득', '획득한 모든 자수정 수량'},
    USE_AMET    = {'소진', '소진한 모든 자수정 수량'},

    GET_GOLD    = {'획득', '획득한 모든 골드 수량'},
    USE_GOLD    = {'소진', '소진한 모든 골드 수량'},

    GET_STAMINA = {'획득', '획득한 모든 날개 수량'},
    USE_STAMINA = {'소진', '소진한 모든 날개 수량'},

    USE_MILEAGE = {'소진', '소진한 모든 마일리지 수량'},
    USE_TOPAZ   = {'소진', '소진한 모든 토파즈 수량'},
    USE_HONOR   = {'소진', '소진한 모든 명예 수량'},
    USE_ANCIENT = {'소진', '소진한 모든 고대주화 수량'},

    TRY_ADV     = {'모험', '모험모드 도전 횟수'},
    CLR_ADV     = {'모험', '모험모드 클리어 횟수'},

    TRY_EXP     = {'탐험', '탐험모드 도전 횟수'},
    CLR_EXP     = {'탐험', '탐험모드 클리어 횟수'},

    TRY_DGN     = {'던전', '던전 도전 횟수'},
    CLR_DGN     = {'던전', '던전 클리어 횟수'},

    TRY_COL     = {'콜로세움', '콜로세움 도전 횟수'},

    DRA_UP      = {'드래곤 승급', '고등급 드래곤 획득 수량'},
    DRA_EV      = {'드래곤 진화', '성룡 진화한 드래곤 개수'},
    DRA_FR_MAX  = {'드래곤 친밀도', '친밀도 고등급 상태 드래곤 개수'},

    TMR_SEL     = {'테이머', '테이머 선택'},
    TMR_GET     = {'테이머', '테이머 획득'},

    RUNE_GET    = {'룬', '고등급 룬 획득 수량'},
}

-------------------------------------
-- function setEnable
-------------------------------------
function Analytics:setEnable(enable)
    self['enable'] = enable
end

-------------------------------------
-- function getEnable
-------------------------------------
function Analytics:getEnable()
    if (self['enable'] ~= nil) then
        return self['enable']
    end

    return true
end

-------------------------------------
-- function userInfo
-------------------------------------
function Analytics:userInfo()
    if (not IS_ENABLE_ANALYTICS()) then return end

    local uid = g_userData:get('uid')
    Adbrix:userInfo(uid)
    Tapjoy:userInfo(uid)
end

-------------------------------------
-- function setAppDataVersion
-------------------------------------
function Analytics:setAppDataVersion()
    if (not IS_ENABLE_ANALYTICS()) then return end

    Tapjoy:setAppDataVersion()
end
-------------------------------------
-- function cohort
-------------------------------------
function Analytics:cohort(cohortNo, cohortDesc)
    if (not IS_ENABLE_ANALYTICS()) then return end

    Adbrix:customCohort(cohortNo, cohortDesc)
end

-------------------------------------
-- function firstTimeExperience
-------------------------------------
function Analytics:firstTimeExperience(arg1, arg2)
    if (not IS_ENABLE_ANALYTICS()) then return end

    -- 유저데이터가 있다면 
    local user = g_userData
    if (user) then
        local created_at = user:get('created_at')
        if (created_at) then
            local curr_time = Timer:getServerTime()
            local time = curr_time - math_floor(created_at/1000)

            -- 계정 생성한지 24시간 이내의 유저만 firstTimeExperience 호출
            if (time < 86400) then
                Adbrix:firstTimeExperience(arg1, arg2)
            end

        -- 계정 생성시간이 없을 경우도 계정 생성 전으로 판단 
        else
            Adbrix:firstTimeExperience(arg1, arg2)
        end

    -- 없다면 호출
    else
        Adbrix:firstTimeExperience(arg1, arg2)
    end
end

-------------------------------------
-- function trackEvent
-------------------------------------
function Analytics:trackEvent(category, event, value, param1)
    if (not IS_ENABLE_ANALYTICS()) then return end

    Tapjoy:trackEvent(category, event, value, param1)
end

-------------------------------------
-- function purchase
-------------------------------------
function Analytics:purchase(product_id, sku, price_krw, price_usd, first_buy)
    if (not IS_ENABLE_ANALYTICS()) then return end

    local currency_code = 'KRW'
    local currency_price = price_krw

    -- StructMarketProduct
    local struct_market_product = g_shopDataNew:getStructMarketProduct(sku)
    if struct_market_product then
        local _currency_code = struct_market_product:getCurrencyCode()
        local _currency_price = struct_market_product:getCurrencyPrice()
            
        -- currency_code, currency_price의 변수 타입이나 적절치 않은 값일 경우 무시
        if (type(_currency_code) ~= 'string') then
        elseif (_currency_code == '') then
        elseif (type(_currency_price) ~= 'number') then
        elseif (_currency_price <= 0) then
        else
            -- 타입과 값이 온전할 경우에만 사용
            currency_code = _currency_code
            currency_price = _currency_price
        end
    end

    -- @adbrix
    Adbrix:buy(product_id, price_krw)

    -- @tapjoy
    Tapjoy:trackPurchase(product_id, currency_code, currency_price)

    -- @adjust
    do
        -- 첫 구매는 event
        if first_buy then
            Adjust:trackEvent(Adjust.EVENT.FIRST_PURCHASE)
        end

        Adjust:adjustTrackPayment(Adjust.EVENT.PURCHASE, currency_code, currency_price)
    end
end

-------------------------------------
-- function trackGetGoodsWithRet
-- @brief 재화 증가량 체크 (type 체크함)
-------------------------------------
function Analytics:trackGetGoodsWithRet(ret, desc, from_type)
    local added_items = ret['added_items']
    local reward_items = ret['reward_info']

    if (added_items) then 
        local item_list = added_items['items_list']
        Analytics:trackGetGoodsWithItemList(item_list, desc, from_type)

    elseif (reward_items) then
        local item_list = reward_items
        Analytics:trackGetGoodsWithItemList(item_list, desc, from_type)

    -- ret에 있는 재화로 바로 검색
    else
        local l_goods = {'cash', 'gold', 'amethyst'}

        for _, value in ipairs(l_goods) do
            if (ret[value]) then
                local get_cnt = 0
                local pre_cnt = g_userData:get(value) or 0
                get_cnt = ret[value] - pre_cnt 
   
                if (get_cnt > 0) then
                    if (value == 'cash') then
                        Analytics:trackEvent(CUS_CATEGORY.CASH, CUS_EVENT.GET_CASH, get_cnt, desc)

                    elseif (value == 'gold') then
                        Analytics:trackEvent(CUS_CATEGORY.GOLD, CUS_EVENT.GET_GOLD, get_cnt, desc)

                    elseif (value == 'amethyst') then
                        Analytics:trackEvent(CUS_CATEGORY.AMET, CUS_EVENT.GET_AMET, get_cnt, desc)

                    end
                end
            end
        end
    end
end

-------------------------------------
-- function trackGetGoodsWithItemList
-- @breif 재화 증가량 체크 (item_list)
-------------------------------------
function Analytics:trackGetGoodsWithItemList(item_list, desc, from_type)
    if (not item_list) then 
        return
    end

    local from_type = from_type or nil
    for _, v in ipairs(item_list) do
        local item_id = v['item_id']
        local item_cnt = v['count']
        local from = v['from']

        -- type 지정한 경우만 type 검사 ()
        if (from == nil) or (from_type == nil) or (from_type and from == from_type) then
            if (item_id == ITEM_ID_CASH) then
                Analytics:trackEvent(CUS_CATEGORY.CASH, CUS_EVENT.GET_CASH, item_cnt, desc)

            elseif (item_id == ITEM_ID_GOLD) then
                Analytics:trackEvent(CUS_CATEGORY.GOLD, CUS_EVENT.GET_GOLD, item_cnt, desc)

            elseif (item_id == ITEM_ID_AMET) then
                Analytics:trackEvent(CUS_CATEGORY.AMET, CUS_EVENT.GET_AMET, item_cnt, desc)

            elseif (item_id == ITEM_ID_ST) then
                Analytics:trackEvent(CUS_CATEGORY.STAMINA, CUS_EVENT.GET_STAMINA, item_cnt, desc)
            end
        end
    end
end

-------------------------------------
-- function trackUseGoodsWithRet
-- @breif 재화 소모량 체크
-------------------------------------
function Analytics:trackUseGoodsWithRet(ret, desc)
    local l_goods = {'cash', 'gold', 'amethyst', 'mileage', 'topaz', 'honor', 'ancient'}

    for _, value in ipairs(l_goods) do
        if (ret[value]) then
            local use_cnt = 0
            local pre_cnt = g_userData:get(value) or 0
            use_cnt = pre_cnt - ret[value]
   
            if (use_cnt > 0) then
                if (value == 'cash') then
                    Analytics:trackEvent(CUS_CATEGORY.CASH, CUS_EVENT.USE_CASH, use_cnt, desc)

                elseif (value == 'gold') then
                    Analytics:trackEvent(CUS_CATEGORY.GOLD, CUS_EVENT.USE_GOLD, use_cnt, desc)

                elseif (value == 'amethyst') then
                    Analytics:trackEvent(CUS_CATEGORY.AMET, CUS_EVENT.USE_AMET, use_cnt, desc)

                elseif (value == 'mileage') then
                    Analytics:trackEvent(CUS_CATEGORY.MILEAGE, CUS_EVENT.USE_MILEAGE, use_cnt, desc)

                elseif (value == 'topaz') then
                    Analytics:trackEvent(CUS_CATEGORY.TOPAZ, CUS_EVENT.USE_TOPAZ, use_cnt, desc)

                elseif (value == 'honor') then
                    Analytics:trackEvent(CUS_CATEGORY.HONOR, CUS_EVENT.USE_HONOR, use_cnt, desc)
                
                elseif (value == 'ancient') then
                    Analytics:trackEvent(CUS_CATEGORY.ANCIENT, CUS_EVENT.USE_ANCIENT, use_cnt, desc)
                end
            end
        end
    end
end




-------------------------------------
-- function userInfo
-------------------------------------
function Adbrix:userInfo(uid)
    -- @sgkim 201919 adbrix정책 변경으로 사용하지 않게 됨
    if true then
        return
    end

    if (not IS_ENABLE_ANALYTICS()) then return end

    local arg1 = tostring(uid)

    cclog('Adbrix:userInfo : ' .. arg1)

    PerpleSDK:adbrixEvent('userId', arg1, '')
end

-------------------------------------
-- function buy
-------------------------------------
function Adbrix:buy(productId, price)
    -- @sgkim 201919 adbrix정책 변경으로 사용하지 않게 됨
    if true then
        return
    end

    local arg1 = tostring(productId)
    local arg2 = tostring(price)

    cclog('Adbrix:buy : ' .. arg1 .. ',' .. arg2)

    PerpleSDK:adbrixEvent('buy', arg1, arg2)
end

-------------------------------------
-- function customCohort
-------------------------------------
-- [실제 적용한 항목들]
-- 1 : 인게임에서 드랍된 다이아의 수
-- 2 : 인게임에서 드랍된 골드의 수
-- 3 : 인게임에서 자수정의 수
-------------------------------------
function Adbrix:customCohort(cohortNo, cohortDesc)
    -- @sgkim 201919 adbrix정책 변경으로 사용하지 않게 됨
    if true then
        return
    end

    local arg1 = 'COHORT_'..tostring(cohortNo)
    local arg2 = tostring(cohortDesc)

    cclog('Adbrix:customCohort : ' .. arg1 .. ',' .. arg2)

    PerpleSDK:adbrixEvent('customCohort', arg1, arg2)
end

-------------------------------------
-- function retention
-------------------------------------
function Adbrix:retention(arg1, arg2)
    -- @sgkim 201919 adbrix정책 변경으로 사용하지 않게 됨
    if true then
        return
    end

    local arg1 = tostring(arg1)
    local arg2 = arg2 or ''

    cclog('Adbrix:retention : ' .. arg1 .. ',' .. arg2)

    PerpleSDK:adbrixEvent('retention', arg1, arg2)
end

-------------------------------------
-- function firstTimeExperience
-------------------------------------
-- [실제 적용한 항목들 (50개 제한)]
-- @ 집계 순서대로 

-- 게임실행 (StartApp) 

-- 패치다운로드 시작(PatchDownload_Start) 
-- 패치다운로드 끝 (PatchDownload_Finish) 

-- 프롤로그 시작 (Prologue_Start) 
-- 프롤로그 끝 (Prologue_Finish) 

-- 로그인 닉네임 생성 (Login_CreateAccount) 

-- @ 인트로 튜토리얼은 강제종료 가능
-- 인트로 튜토리얼 시작 (Tutorial_Intro_Start) 
-- 인트로 튜토리얼 웨이브(평타 어택) 진입 (Tutorial_Intro_Wave) 
-- 인트로 튜토리얼 자동줍기 사용 (Tutorial_Intro_AutoPick) 
-- 인트로 튜토리얼 드래그스킬 사용 (Tutorial_Intro_DragSkill) 
-- 인트로 튜토리얼 종료 (Tutorial_Intro_Finish) 

-- 로비 진입 (Lobby_Enter) 

-- 1-1 시작 (Stage_1_1_Start) 
-- 1-1 종료 (Stage_1_1_Finish)
-- 마스터의 길 첫번째 보상 수령 (MasterRoad_Reward)
-- 알 부화 (DragonIncubate)  -> 강제가 아니여서 집계 제대로 안될 수 있음.
-- 1-2 시작 (Stage_1_2_Start)  
-- 1-2 종료 (Stage_1_2_Finish)
-- 1-3 시작 (Stage_1_3_Start) 
-- 1-3 종료 (Stage_1_3_Finish)
-- 1-4 시작 (Stage_1_4_Start) 
-- 1-4 종료 (Stage_1_4_Finish)
-- 1-5 종료 (Stage_1_5_Finish)
-- 1-6 종료 (Stage_1_6_Finish)
-- 1-7 종료 (Stage_1_7_Finish)
-- 2-1 종료 (Stage_2_1_Finish)
-- 2-2 종료 (Stage_2_2_Finish)
-- 2-3 종료 (Stage_2_3_Finish)
-- 2-4 종료 (Stage_2_4_Finish)
-- 2-5 종료 (Stage_2_5_Finish)
-- 2-6 종료 (Stage_2_6_Finish)
-- 2-7 종료 (Stage_2_7_Finish)

-- @ 기타
-- 도감 보상 수령 (Book_Rewrad) 
-- 종합 랭킹 확인 (TotalRanking_Confirm) 
-- 드래곤 승급 (3 → 4)(DragonUpgrade_3to4) 
-- 드래곤 승급 (4 → 5) (DragonUpgrade_4to5) 
-- 드래곤 승급 (5 → 6) (DragonUpgrade_5to6) 
-- 콜로세움 1승 (Colosseum_Win) 
-- 고대의탑 1층 클리어 (AncientTower_1_Clear) 
-- 드래곤 진화 (DragonEvolution) 
-- 친밀도 열매 먹이기(FriendshipUp) 
-- 드래곤 11회 확률업 소환 (DragonSummonEvent_11) 
-- 드래곤 11회 고급 소환 (DragonSummonCash_11) 
-- 퀘스트 클리어 (Quest_Clear) 
-- 테이머 변경 (Change_Tamer) 
-- 6성 60레벨 달성(DragonLevelUp_6_60) 

-------------------------------------
function Adbrix:firstTimeExperience(arg1, arg2)
    -- @sgkim 201919 adbrix정책 변경으로 사용하지 않게 됨
    if true then
        return
    end

    local arg1 = tostring(arg1)
    local arg2 = arg2 or ''

    cclog('Adbrix:firstTimeExperience : ' .. arg1)

    PerpleSDK:adbrixEvent('firstTimeExperience', arg1, arg2)
end





-------------------------------------
-- function userInfo
-------------------------------------
function Tapjoy:userInfo(userId)
    local arg1 = tostring(userId)
    local arg2 = tostring((g_userData:get('lv') or 0))

    cclog('Tapjoy:userInfo : ' .. arg1)

    PerpleSDK:tapjoyEvent('userID', arg1, '', function(ret)
    end)

    PerpleSDK:tapjoyEvent('userLevel', arg2, '', function(ret)
    end)
end

-------------------------------------
-- function trackPurchase
-------------------------------------
function Tapjoy:trackPurchase(productName, currencyCode, price)
    local arg1 = tostring(productName)
    arg1 = arg1 .. ';' .. tostring(currencyCode)
    arg1 = arg1 .. ';' .. tostring(price)

    cclog('Tapjoy:trackPurchase : ' .. arg1)

    PerpleSDK:tapjoyEvent('trackPurchase', arg1, '', function(ret)
    end)
end

-------------------------------------
-- function customCohort
-------------------------------------
function Tapjoy:customCohort(cohortNo, cohortDesc)
    local arg1 = tostring(cohortNo)
    local arg2 = cohortDesc

    cclog('Tapjoy:customCohort : ' .. arg1 .. ',' .. arg2)

    PerpleSDK:tapjoyEvent('userCohortVariable', arg1, arg2, function(ret)
    end)
end

-------------------------------------
-- function setAppDataVersion
-------------------------------------
function Tapjoy:setAppDataVersion()
    local arg1 = getAppVer()

    cclog('Tapjoy:setAppDataVersion : ' .. arg1)

    PerpleSDK:tapjoyEvent('appDataVersion', arg1, '', function(ret)
    end)
end

-------------------------------------
-- function trackEvent
-------------------------------------
function Tapjoy:trackEvent(category, event, value, param1)
    -- @format : category;event;event_name;param1;param2;value;
     
    local category = tostring(category)
    local value = tostring(value)
    local event_name = event[1]
    local value_name = event[2]
    local param1 = tostring(param1)
    local param2 = string.format('User Lv : %d', (g_userData:get('lv') or 0))
    
    local arg1 = category..';'..event_name..';'..param1..';'..param2..';'..value_name..';'..value 

    cclog('Tapjoy:trackEvent : ' .. arg1)

    PerpleSDK:tapjoyEvent('trackEvent', arg1, '', function(ret)
    end)
end

---------------------------------------------------------------------------------------------------------------
-- Adjust
---------------------------------------------------------------------------------------------------------------
-------------------------------------
-- function trackEvent
-------------------------------------
function Adjust:trackEvent(eventKey)
    if (eventKey == nil) then
        error('eventKey is nil')
    end

    if (not IS_ENABLE_ANALYTICS()) then return end
    --cclog('Adjust:trackEvent : ' .. eventKey)

    PerpleSDK:adjustTrackEvent(eventKey)
end

-------------------------------------
-- function adjustTrackPayment
-- eventkey : dash보드에서 만든 이벤트의 토큰
-------------------------------------
function Adjust:adjustTrackPayment(eventKey, currency, price )
    if (not IS_ENABLE_ANALYTICS()) then return end
    cclog('Adjust:adjustTrackPayment : ' .. eventKey)
    cclog('Adjust:adjustTrackPayment : ' .. currency)
    cclog('Adjust:adjustTrackPayment : ' .. price)

    currency = currency or "KRW"

    PerpleSDK:adjustTrackPayment(eventKey, tostring(price), currency)
end

-------------------------------------
-- function trackEventSumPrice
-- eventkey : 총 결제 금액에 따른 adjust
-------------------------------------
function Adjust:trackEventSumPrice(sum_money)
    --가격별
    if sum_money >= 1000000 then    --100만원이상
        Adjust:trackEvent(Adjust.EVENT.PURCHASE_1000_US )
    elseif sum_money >= 100000 then --10만원 이상
        Adjust:trackEvent(Adjust.EVENT.PURCHASE_100_US)
    elseif sum_money >= 10000 then  --1만원 이상
        Adjust:trackEvent(Adjust.EVENT.PURCHASE_10_US)
    end
end

-------------------------------------
-- function IVEKorea_ads_complete_run
-- @brief IVE Korea CPI 캠페인
-------------------------------------
function Analytics:IVEKorea_ads_complete_run(cb_func)
    local function request_cb_func(ret, advertising_id)

        if IS_DEV_SERVER() == true then
            UIManager:toastNotificationGreen('# ret : ' .. ret)
            UIManager:toastNotificationGreen('# advertising_id : ' .. advertising_id)
        end

        local adid = advertising_id
        
        -- 파라미터 셋팅
        local t_data = {}
        
        if (isAndroid() == true) then
            t_data['av'] = adid
            t_data['ai'] = '16437'

        elseif (isIos() == true) then
            t_data['ae'] = adid
            t_data['ai'] = '16438'

        else
            -- @sgkim 2021.09.09 테스트 코드
            --t_data['av'] = '9de91c7a-06da-4b6c-8f6b-ec73623d12b1'
            if cb_func then
                cb_func()
            end
            return
        end

        -- 요청 정보 설정
        local t_request = {}
        t_request['full_url'] = 'https://api.i-screen.kr/api/ads_complete_run'
        t_request['method'] = 'GET'
        t_request['data'] = t_data


        local req = Network:request(t_request['full_url'], t_request['data'], t_request['method'])
        cclog('# Analytics:IVEKorea_ads_complete_run() - t_request')
        ccdump(t_request)

        -- 성공 시 콜백 함수
        t_request['success'] = function(ret)
            cclog('## https://api.i-screen.kr/api/ads_complete_run - success')
            ccdump(ret)

            if (IS_DEV_SERVER() == true) then
                local msg = 'url : ' .. req.url .. '\n\nmessage : ' .. ret['message']

                MakeSimplePopup2(POPUP_TYPE.OK, msg, ret['status'], cb_func)
            else
                if cb_func then
                    cb_func()
                end
            end
        end

        -- 실패 시 콜백 함수
        t_request['fail'] = function(ret)
            cclog('## https://api.i-screen.kr/api/ads_complete_run - fail')
            ccdump(ret)
            
            if (IS_DEV_SERVER() == true) then
                local msg = 'url : ' .. req.url .. '\n\nmessage : ' .. ret['message']
                
                MakeSimplePopup2(POPUP_TYPE.OK, msg, ret['status'], cb_func)
            else
                if cb_func then
                    cb_func()
                end
            end
        end

        -- 네트워크 통신
        Network:SimpleRequest(t_request)
    end

    SDKManager:getAdvertisingID(request_cb_func)
end
