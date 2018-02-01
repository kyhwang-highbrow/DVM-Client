Analytics = {
    enable = true,
}
Adbrix = {}
FiveRocks = {}
Adjust = {}

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
    FiveRocks:userInfo(uid)
end

-------------------------------------
-- function setAppDataVersion
-------------------------------------
function Analytics:setAppDataVersion()
    if (not IS_ENABLE_ANALYTICS()) then return end

    FiveRocks:setAppDataVersion()
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
-- function purchase
-------------------------------------
function Analytics:trackEvent(category, event, value, param1)
    if (not IS_ENABLE_ANALYTICS()) then return end

    FiveRocks:trackEvent(category, event, value, param1)
end

-------------------------------------
-- function purchase
-------------------------------------
function Analytics:purchase(productId, productName, price, token)
    if (not IS_ENABLE_ANALYTICS()) then return end
    
    -- price는 KRW 가격으로만 받음 
    local currencyCode = 'KRW'

    Adbrix:buy(productId, price)
    FiveRocks:trackPurchase(productName, currencyCode, price)
    if token then
        Adjust:adjustTrackPayment(token, currencyCode, price )
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
    if (not IS_ENABLE_ANALYTICS()) then return end

    local arg1 = tostring(uid)

    cclog('Adbrix:userInfo : ' .. arg1)

    PerpleSDK:adbrixEvent('userId', arg1, '')
end

-------------------------------------
-- function buy
-------------------------------------
function Adbrix:buy(productId, price)
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
    local arg1 = 'COHORT_'..tostring(cohortNo)
    local arg2 = tostring(cohortDesc)

    cclog('Adbrix:customCohort : ' .. arg1 .. ',' .. arg2)

    PerpleSDK:adbrixEvent('customCohort', arg1, arg2)
end

-------------------------------------
-- function retention
-------------------------------------
function Adbrix:retention(arg1, arg2)
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
    local arg1 = tostring(arg1)
    local arg2 = arg2 or ''

    cclog('Adbrix:firstTimeExperience : ' .. arg1)

    PerpleSDK:adbrixEvent('firstTimeExperience', arg1, arg2)
end





-------------------------------------
-- function userInfo
-------------------------------------
function FiveRocks:userInfo(userId)
    local arg1 = tostring(userId)
    local arg2 = tostring((g_userData:get('lv') or 0))

    cclog('FiveRocks:userInfo : ' .. arg1)

    PerpleSDK:tapjoyEvent('userID', arg1, '', function(ret)
    end)

    PerpleSDK:tapjoyEvent('userLevel', arg2, '', function(ret)
    end)
end

-------------------------------------
-- function trackPurchase
-------------------------------------
function FiveRocks:trackPurchase(productName, currencyCode, price)
    local arg1 = tostring(productName)
    arg1 = arg1 .. ';' .. tostring(currencyCode)
    arg1 = arg1 .. ';' .. tostring(price)

    cclog('FiveRocks:trackPurchase : ' .. arg1)

    PerpleSDK:tapjoyEvent('trackPurchase', arg1, '', function(ret)
    end)
end

-------------------------------------
-- function customCohort
-------------------------------------
function FiveRocks:customCohort(cohortNo, cohortDesc)
    local arg1 = tostring(cohortNo)
    local arg2 = cohortDesc

    cclog('FiveRocks:customCohort : ' .. arg1 .. ',' .. arg2)

    PerpleSDK:tapjoyEvent('userCohortVariable', arg1, arg2, function(ret)
    end)
end

-------------------------------------
-- function setAppDataVersion
-------------------------------------
function FiveRocks:setAppDataVersion()
    local arg1 = getAppVer()

    cclog('FiveRocks:setAppDataVersion : ' .. arg1)

    PerpleSDK:tapjoyEvent('appDataVersion', arg1, '', function(ret)
    end)
end

-------------------------------------
-- function trackEvent
-------------------------------------
function FiveRocks:trackEvent(category, event, value, param1)
    -- @format : category;event;event_name;param1;param2;value;
     
    local category = tostring(category)
    local value = tostring(value)
    local event_name = event[1]
    local value_name = event[2]
    local param1 = tostring(param1)
    local param2 = string.format('User Lv : %d', (g_userData:get('lv') or 0))
    
    local arg1 = category..';'..event_name..';'..param1..';'..param2..';'..value_name..';'..value 

    cclog('FiveRocks:trackEvent : ' .. arg1)

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
    --cclog('Adjust:trackEvent : ' .. eventKey)

    PerpleSDK:adjustTrackEvent(eventKey)
end

-------------------------------------
-- function adjustTrackPayment
-- eventkey : dash보드에서 만든 이벤트의 토큰
-------------------------------------
function Adjust:adjustTrackPayment(eventKey, currency, price )
    --cclog('Adjust:adjustTrackPayment : ' .. eventKey)
    --cclog('Adjust:adjustTrackPayment : ' .. currency)
    --cclog('Adjust:adjustTrackPayment : ' .. price)

    currency = currency or "KRW"

    PerpleSDK:adjustTrackPayment(eventKey, tostring(price), currency)
end

