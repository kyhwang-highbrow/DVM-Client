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
-- function func
-------------------------------------
function PackageAutoDisplayHelper:checkPackage(package_type, ...)
    local args = {...}

    -- 레벨업 패키지
    -- 5레벨마다 게임 종료 화면에서 출력한다.
    if (package_type == PACK_LV_UP) then
        local lv = args[1]
        if (lv % 5 == 0) then
            table.insert(l_display_package_list, package_type)
        end

    -- 모험돌파 패키지
    -- 매 챕터 마지막 스테이지 첫클리어 시 출력
    elseif (package_type == PACK_ADVENTURE) then
        local stage_clear_info = args[1]
        local stage_id = args[2]
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        if (stage == MAX_ADVENTURE_STAGE) and (stage_clear_info['cl_cnt'] == 1) then
            table.insert(l_display_package_list, package_type)
        end
    end
end

-------------------------------------
-- function func
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