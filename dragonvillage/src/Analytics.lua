Analytics = {}
Adbrix = {}
FiveRocks = {}

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

    Adbrix:firstTimeExperience(arg1, arg2)
end

-------------------------------------
-- function purchase
-------------------------------------
function Analytics:purchase(productId, productName, price)
    if (not IS_ENABLE_ANALYTICS()) then return end

    local productId = productId..';'..productName
    local arg1 = tostring(productId)
    local arg2 = tostring(price)

    Adbrix:buy(arg1, arg2)
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
    if (not IS_ENABLE_ANALYTICS()) then return end

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
    if (not IS_ENABLE_ANALYTICS()) then return end

    local arg1 = 'COHORT_'..tostring(cohortNo)
    local arg2 = tostring(cohortDesc)

    cclog('Adbrix:customCohort : ' .. arg1 .. ',' .. arg2)

    PerpleSDK:adbrixEvent('customCohort', arg1, arg2)
end

-------------------------------------
-- function retention
-------------------------------------
function Adbrix:retention(arg1, arg2)
    if (not IS_ENABLE_ANALYTICS()) then return end

    local arg1 = tostring(arg1)
    local arg2 = arg2 or ''

    cclog('Adbrix:retention : ' .. arg1 .. ',' .. arg2)

    PerpleSDK:adbrixEvent('retention', arg1, arg2)
end

-------------------------------------
-- function firstTimeExperience
-------------------------------------
-- [실제 적용한 항목들 (50개 제한)]
-- 게임실행 (StartApp) 
-- 패치다운로드 (PatchDownload) 
-- 프롤로그 (Prologue) 
-- 로그인 (Login) 
-- 인트로 튜토리얼 완료 (Tutorial_Intro) 
-- 1-1 클리어 (Stage_1_1_Clear) 
-- 1-2 클리어 (Stage_1_2_Clear)
-- 1-3 클리어 (Stage_1_3_Clear)
-- 1-4 클리어 (Stage_1_4_Clear)
-- 1-5 클리어 (Stage_1_5_Clear)
-- 1-6 클리어 (Stage_1_6_Clear)
-- 1-7 클리어 (Stage_1_7_Clear)
-- 2-1 클리어 (Stage_2_1_Clear)
-- 2-4 클리어 (Stage_2_4_Clear)
-- 2-7 클리어 (Stage_2_7_Clear)
-- 마스터의 길 첫번째 보상 수령 (MasterRoad_Reward) 
-- 도감 보상 수령 (Book_Rewrad) 
-- 종합 랭킹 확인 (TotalRanking_Confirm) 
-- 드래곤 승급 (3 → 4)(DragonUpgrade_3to4) 
-- 드래곤 승급 (4 → 5) (DragonUpgrade_4to5) 
-- 드래곤 승급 (5 → 6) (DragonUpgrade_5to6) 
-- 콜로세움 1승 (Colosseum_Win) 
-- 고대의탑 1층 클리어 (AncientTower_1_Clear) 
-- 드래곤 진화 (DragonEvolution) 
-- 친밀도 열매 먹이기(FriendshipUp) 
-- 드래곤 부화 (DragonIncubate) 
-- 드래곤 11회 확률업 소환 (DragonSummonEvent_11) 
-- 드래곤 11회 고급 소환 (DragonSummonCash_11) 
-- 퀘스트 클리어 (Quest_Clear) 
-- 테이머 변경 (Change_Tamer) 
-- 전설 드래곤 획득 (LegendDragon_Get) 
-- 6성 60레벨 달성(DragonLevelUp_6_60) 
-------------------------------------
function Adbrix:firstTimeExperience(arg1, arg2)
    if (not IS_ENABLE_ANALYTICS()) then return end

    local arg1 = tostring(arg1)
    local arg2 = arg2 or ''

    cclog('Adbrix:firstTimeExperience : ' .. arg1)

    PerpleSDK:adbrixEvent('firstTimeExperience', arg1, arg2)
end


-------------------------------------
-- function userInfo
-------------------------------------
function FiveRocks:userInfo(userId)
    if (not IS_ENABLE_ANALYTICS()) then return end

    local arg0 = tostring(userId)

    cclog('FiveRocks:userInfo : ' .. arg0)

    PerpSocial:SDKEvent('5rocks_userInfo', arg0, '', function(ret)
    end)
end

-------------------------------------
-- function trackPurchase
-------------------------------------
function FiveRocks:trackPurchase(productId, price, currencyCode, campaignId)
    if (not IS_ENABLE_ANALYTICS()) then return end

    local arg0 = tostring(productId)
    if price ~= nil then
        arg0 = arg0 .. ';' .. currencyCode .. ';' .. tostring(price)
    end
    if campaignId ~= nil then
        arg0 = arg0 .. ';' .. tostring(campaignId)
    end

    cclog('FiveRocks:trackPurchase : ' .. arg0)

    PerpSocial:SDKEvent('5rocks_trackPurchase', arg0, '', function(ret)
    end)
end

-------------------------------------
-- function customCohort
-------------------------------------
function FiveRocks:customCohort(cohortNo, cohortDesc)
    if (not IS_ENABLE_ANALYTICS()) then return end

    local arg0 = tostring(cohortNo)
    local arg1 = cohortDesc

    cclog('FiveRocks:customCohort : ' .. arg0 .. ',' .. arg1)

    PerpSocial:SDKEvent('5rocks_customCohort', arg0, arg1, function(ret)
    end)
end

-------------------------------------
-- function setAppDataVersion
-------------------------------------
function FiveRocks:setAppDataVersion()
    if (not IS_ENABLE_ANALYTICS()) then return end

    local arg0 = getAppVer()

    cclog('FiveRocks:setAppDataVersion : ' .. arg0)

    PerpSocial:SDKEvent('5rocks_appDataVersion', arg0, '', function(ret)
    end)
end

-------------------------------------
-- function setAppDataVersion
-------------------------------------
function FiveRocks:trackEvent(category, name, param1, param2, value1Name, value1, value2Name, value2, value3Name, value3)
    if (not IS_ENABLE_ANALYTICS()) then return end

    local arg0 = category .. ';' .. name .. ';' .. param1 .. ';' .. param2

    if value1Name ~= nil and value1 ~= nil then
        arg0 = arg0 .. ';' .. value1Name .. ';' .. value1
    end

    if value2Name ~= nil and value2 ~= nil then
        arg0 = arg0 .. ';' .. value2Name .. ';' .. value2
    end

    if value3Name ~= nil and value3 ~= nil then
        arg0 = arg0 .. ';' .. value3Name .. ';' .. value3
    end

    cclog('FiveRocks:trackEvent : ' .. arg0)

    PerpSocial:SDKEvent('5rocks_trackEvent', arg0, '', function(ret)
    end)
end


