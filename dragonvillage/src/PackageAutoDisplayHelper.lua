-------------------------------------
-- table PackageAutoDisplayHelper
-------------------------------------
PackageAutoDisplayHelper = {}

-- private
local l_display_package_list = {}

-- global
-- 레벨업, 모험돌파 패키지의 경우 최신으로 유지해야함.. 리팩토링 필요
PACK_LV_UP = 'package_levelup_03'
PACK_ADVENTURE = 'package_adventure_clear_03'

-------------------------------------
-- Condition
-------------------------------------
local kUseInterval = true

-- 시작과 반복 구간 설정
local kLvStart = 10
local kLvTerm = 5

local kSidStart = 1110407
local kChapterInterval = 1

--[[
-- 하드코딩 -> 나중에 테이블로 변경?
local package_lvup_lv_list = {
    15, 20, 25, 30, 35, 40, 45, 50, -- 15 ~ 50 구간, 5레벨 마다 출력
    60, 70, 80, 90 -- 50 이후, 10레벨 마다 출력
}
local package_adventure_stage_id_list = {
    1110207, 1110407, 1110607, 1110807, 1111207, -- 난이도 보통
    1120607, 1121207,    -- 난이도 어려움
    1130607,    -- 난이도 지옥
    1140607,    -- 난이도 불지옥
}
]]

-------------------------------------
-- function getStartSid
-------------------------------------
function PackageAutoDisplayHelper:getStartSid()
    return kSidStart
end

-------------------------------------
-- function checkPackage
-------------------------------------
function PackageAutoDisplayHelper:checkPackage(package_type, ...)
    local args = {...}

    -- 레벨업 패키지
    -- 5레벨마다 게임 종료 화면에서 출력한다.
    if (package_type == PACK_LV_UP) then
        -- 이미 구매했다면 비활성화
        if (g_levelUpPackageData:isActive(LEVELUP_PACKAGE_3_PRODUCT_ID)) then
            return
        end

        -- 전달 받은 변수
        local lv = args[1]
        local b = false

        if (kUseInterval) then
            -- 지정 레벨 보다 유저 레벨이 낮다면 탈출
            if (kLvStart > lv) then
                return
            end

            for i = kLvStart, 99, kLvTerm do
                if (i == lv) then
                    b = true
                    break
                end
            end
        else
            b = isContainValue(lv, package_lvup_lv_list)
        end

        if b then
            table.insert(l_display_package_list, package_type)
        end

    -- 모험돌파 패키지
    -- 매 챕터 마지막 스테이지 첫클리어 시 출력
    elseif (package_type == PACK_ADVENTURE) then
        -- 이 구매했다면 비활성화
        if (g_adventureClearPackageData03:isActive()) then
            return
        end

        -- 전달 받은 변수
        local stage_clear_info = args[1]
        local stage_id = args[2]
        local b = false

        if (kUseInterval) then
            -- 지정 스테이지 보다 넘어온 스테이지 id가 작다면 탈출
            if (kSidStart > stage_id) then
                return
            end

            local sid = 1110007
            -- 난이도 반복
            for i = 1, 4 do
                -- 챕터 반복
                for j = 1, 12 do
                    sid = sid + 100
                    if (stage_id == sid) then
                        b = true
                        break
                    end
                end
                if (b) then
                    break
                end

                sid = sid + 10000
            end
        else
            b = isContainValue(stage_id, package_adventure_stage_id_list)
        end

        if (b) and (stage_clear_info['cl_cnt'] == 1) then
            table.insert(l_display_package_list, package_type)
        end

    end
end

-------------------------------------
-- function pushPackageUI
-------------------------------------
function PackageAutoDisplayHelper:pushPackageUI(close_cb)
    local function coroutine_function()
        local co = CoroutineHelper()

        for i, package_type in ipairs(l_display_package_list) do
            co:work()
            local ui = UI_EventFullPopup(package_type)
            if (ui) then
                ui:setCloseCB(co.NEXT)
                ui:openEventFullPopup()
            else
                co.NEXT()
            end

            if co:waitWork() then return end
        end

        l_display_package_list = {}
        
        if (close_cb) then
            close_cb()
        end

        co:close()
    end

    Coroutine(coroutine_function, 'pushPackageUI')
end