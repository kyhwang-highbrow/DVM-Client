-- global
-- 레벨업, 모험돌파 패키지의 경우 최신으로 유지해야함.. 리팩토링 필요
PACK_LV_UP = 'package_levelup_03'
PACK_ADVENTURE = 'package_adventure_clear_03'

PERSONALPACK = 'package_personal' 

-------------------------------------
-- class ServerData_Personalpack
-- g_personalpackData
-------------------------------------
ServerData_Personalpack = class({
        m_activePPTable = 'table<string, number>', -- 서버에서 조건 충족하여 보내준 패키지 테이블
        m_groupCoolDownTable = 'table',
        m_condCheckCount = 'number',
    })

-- private
local mPackageList = {}

-------------------------------------
-- Condition
-------------------------------------
local kUseInterval = true

-- 시작과 반복 구간 설정
local kLvStart = 10
local kLvTerm = 5

local kSidStart = 1110407
local kChapterInterval = 1

-------------------------------------
-- function init
-------------------------------------
function ServerData_Personalpack:init()
    self.m_activePPTable = {}
    self.m_groupCoolDownTable = {}
    self.m_condCheckCount = 0
end

-------------------------------------
-- function getStartSid
-------------------------------------
function ServerData_Personalpack:getStartSid()
    return kSidStart
end

-------------------------------------
-- function isEmpty
-------------------------------------
function ServerData_Personalpack:isEmpty()
    return table.count(mPackageList) == 0
end

-------------------------------------
-- function push
-------------------------------------
function ServerData_Personalpack:push(package_type, ...)
    local args = {...}

    -- 레벨업 패키지
    -- 5레벨마다 게임 종료 화면에서 출력한다.
    if (package_type == PACK_LV_UP) then
        self:checkPackage_lvup(args[1])

    -- 모험돌파 패키지
    -- 매 챕터 마지막 스테이지 첫클리어 시 출력
    elseif (package_type == PACK_ADVENTURE) then
        self:checkPackage_adv(args[1], args[2])

    -- 특별제안 패키지
    elseif (package_type == PERSONALPACK) then
        -- LIVE 10분, TEST 1분
        local check_minute = 10
        if (IS_TEST_MODE()) then
            check_minute = 1
        end

        -- PERSONALPACK은 구동한 후 매 10분 마다 한번 체크한다.
        if (g_accessTimeData:getTimeSinceStartup() < (60 * check_minute * (1 + self.m_condCheckCount))) then
            return
        end

        -- 몇십분 후에 로비 들어올 수도 있으므로
        self.m_condCheckCount = math_floor(g_accessTimeData:getTimeSinceStartup() / (60 * check_minute))

        -- 시간 조건을 충족한 모든 personalpack 검사
        local l_list = TablePersonalpack:getActivatedDateList()
        for i, t_data in ipairs(l_list) do
            local ppid = t_data['ppid']
            local b = self:checkPersonalpack(ppid)
            if b then
                self:addPersonalpack(ppid)
            end
        end

    end
end

-------------------------------------
-- function pull
-------------------------------------
function ServerData_Personalpack:pull(close_cb)    
    -- push 된 package가 없는 경우 실행
    if (table.count(mPackageList) == 0) then
        if (close_cb) then
            close_cb()
        end
        return
    end

    -- pull coroutine
    local function coroutine_function()
        local co = CoroutineHelper()

        for i, package_type in ipairs(mPackageList) do
            co:work()
            
            local ui
            -- 모험돌파, 레벨업
            if (package_type == PACK_ADVENTURE) or (package_type == PACK_LV_UP) then
                ui = UI_EventFullPopup(package_type)

                if (ui) then
                    ui:setCloseCB(co.NEXT)
                    ui:openEventFullPopup()
                else
                    co.NEXT()
                end

            -- personalpack
            else
                local ppid = tonumber(package_type)
                self:request_personalpackStart(ppid, function()
                    require('UI_Package_Personalpack')
                    ui = UI_Package_Personalpack(ppid) -- ppid
                    ui:setCloseCB(co.NEXT)
                end, co.NEXT)
            end

            if co:waitWork() then return end
        end

        mPackageList = {}
        
        if (close_cb) then
            close_cb()
        end

        co:close()
    end
    Coroutine(coroutine_function, 'pull')
end

-------------------------------------
-- function addPersonalpack
-------------------------------------
function ServerData_Personalpack:addPersonalpack(ppid)
    if (table.contain(mPackageList, ppid)) then
        return
    end
    table.insert(mPackageList, ppid)
end


-------------------------------------
-- function checkPackage_lvup
-------------------------------------
function ServerData_Personalpack:checkPackage_lvup(lv)
    -- 이미 구매했다면 비활성화
    if (g_levelUpPackageDataOld:isActive(LEVELUP_PACKAGE_3_PRODUCT_ID)) then
        return
    end

    -- 전달 받은 변수
    local b = false

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

    if b then
        self:addPersonalpack(PACK_LV_UP)
    end
end

-------------------------------------
-- function checkPackage_adv
-------------------------------------
function ServerData_Personalpack:checkPackage_adv(stage_clear_info, stage_id)
    -- 이 구매했다면 비활성화
    if (g_adventureClearPackageData03:isActive()) then
        return
    end

    -- 전달 받은 변수
    local b = false

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

    if (b) and (stage_clear_info['cl_cnt'] == 1) then
        self:addPersonalpack(PACK_ADVENTURE)
    end
end






-------------------------------------
-- function checkPersonalpack
-- @brief 개별 상품에 대한 조건 검사
-------------------------------------
function ServerData_Personalpack:checkPersonalpack(ppid)
    local table_personalpack = TablePersonalpack()
    if (not table_personalpack:exists(ppid)) then
        return false
    end

    cclog('@@@@@@@@@@@@@@@@@@@@@@@@ ServerData_Personalpack:checkPersonalpack')
    cclog(ppid)

    do-- 그룹 확인
        cclog('check group')
        local group = table_personalpack:getGroup(ppid)

        -- 그룹 내의 ppid가 이미 추가되어있는지 확인
        for i, ppid in ipairs(mPackageList) do
            if (TablePersonalpack:getGroup(ppid) == group) then
                cclog('already in')
                return false
            end
        end

        -- 그룹의 쿨다운 확인
        local cool_down = self:getGroupCooldown(group)
        local curr_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
        -- 쿨다운이 nil 인 경우는 아직 활성화 되지 않았기 때문
        if (cool_down ~= nil) and (curr_time < cool_down) then
            cclog('on cooldown')
            return false
        end
    end

    do-- 결제액 확인
        local money = UserStatusAnalyser.userStatus.sum_money
        local min, max = table_personalpack:getSumMoneyMinMax(ppid)
        cclog('check sum money', money, min, max)
        if (min > money) or (money >= max) then
            return false
        end
    end

    -- 계정 생성일 확인
    do
        local days = UserStatusAnalyser.userStatus.days_after_join
        local std_days = table_personalpack:getDaysAfterJoin(ppid)
        cclog('check days', days, std_days)
        if (days < std_days) then
            return false
        end
    end

    cclog('@@@@@@@@@@@@@@@@@ ADD : ' .. ppid)
    return true
end

-------------------------------------
-- function getGroupCooldown
-------------------------------------
function ServerData_Personalpack:getGroupCooldown(group)
    return self.m_groupCoolDownTable[group]
end

-------------------------------------
-- function getEndOfSaleTime
-------------------------------------
function ServerData_Personalpack:getEndOfSaleTime(ppid)
    return self.m_activePPTable[tostring(ppid)]
end

-------------------------------------
-- function isGroupActive
-------------------------------------
function ServerData_Personalpack:isGroupActive(group)
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    for _ppid, end_time in pairs(self.m_activePPTable) do
        local ppid = tonumber(_ppid)
        if (curr_time < end_time / 1000) then
            if (TablePersonalpack:getGroup(ppid) == group) then
                return true
            end
        end
    end
    return false
end

-------------------------------------
-- function findActivePpidByGroup
-- @brief 특정 그룹에서 활성화 되어 있는 ppid가 있는지 탐색하여 반환한다.
-------------------------------------
function ServerData_Personalpack:findActivePpidByGroup(group)
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    for _ppid, end_time in pairs(self.m_activePPTable) do
        local ppid = tonumber(_ppid)
        if (curr_time < end_time / 1000) then
            if (TablePersonalpack:getGroup(ppid) == group) then
                return ppid
            end
        end
    end
    return nil
end

-------------------------------------
-- function isBuyAll
-------------------------------------
function ServerData_Personalpack:isBuyAll(ppid)
    local l_pid = TablePersonalpack:getProductIdList(ppid)

    local count = 0
    for _, pid in ipairs(l_pid) do
        if (not g_shopDataNew:getTargetProduct(tonumber(pid)):isItBuyable()) then
            count = count + 1
        end
    end

    -- 상품의 숫자보다 count(구매 완료) 숫자가 크거나 같으면 true를 리턴
    return count >= table.count(l_pid)
end

-------------------------------------
-- function request_personalpackStart
-------------------------------------
function ServerData_Personalpack:request_personalpackStart(ppid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    local ppid = ppid

    -- 성공 콜백
    local function success_cb(ret)
		self:response_personalpackInfo(ret['personalpack_info'])
        if (finish_cb) then
            finish_cb()
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/personalpack/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('ppid', ppid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_personalpackInfo
-------------------------------------
function ServerData_Personalpack:response_personalpackInfo(t_data)
    self.m_activePPTable = t_data['active_list']
    self.m_groupCoolDownTable = t_data['cool_down_list']
end
