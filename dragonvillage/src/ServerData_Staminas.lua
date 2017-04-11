-------------------------------------
-- class ServerData_Staminas
-------------------------------------
ServerData_Staminas = class({
        m_serverData = 'ServerData',
        m_scheduleHandlerID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Staminas:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getRef
-------------------------------------
function ServerData_Staminas:getRef(key)
    return self.m_serverData:getRef('user', 'staminas', key)
end

-------------------------------------
-- function getStaminaCount
-- @brief 보유한 스태미나 갯수 리턴
-------------------------------------
function ServerData_Staminas:getStaminaCount(stamina_type)
    if (not self:isActive()) then
        self:updateStaminaInfo(stamina_type)
    end

    local t_stamina_info = self:getRef(stamina_type)

    if (not t_stamina_info) then
        return 0
    end

    local cnt = t_stamina_info['cnt']
    return cnt
end

-------------------------------------
-- function getChargeRemainText
-- @brief 다음 충전까지 남은 시간 텍스트 리턴
-------------------------------------
function ServerData_Staminas:getChargeRemainText(stamina_type)
    if (not self:isActive()) then
        self:updateStaminaInfo(stamina_type)
    end

    local t_stamina_info = self:getRef(stamina_type)

    if (not t_stamina_info) then
        return ''
    end

    local cnt = t_stamina_info['cnt']
    local max_cnt = t_stamina_info['max_cnt']
    if (cnt >= max_cnt) then
        return 'MAX'
    else
        local remain_charge_time = t_stamina_info['remain_charge_time'] or 0
        local timer = math_ceil(remain_charge_time)
        return datetime.makeTimeDesc(timer, true, false)
    end
end

-------------------------------------
-- function hasStaminaCount
-- @brief 특정 갯수를 보유했는지 확인
-------------------------------------
function ServerData_Staminas:hasStaminaCount(stamina_type, req_count)
    local cnt = self:getStaminaCount(stamina_type)
    local ret = (req_count <= cnt)
    return ret, (req_count - cnt)
end

-------------------------------------
-- function updateStaminaInfo
-- @brief 스태미나 정보를 갱신
--        (클라이언트에서 시간에 따른 충전치를 계산)
-------------------------------------
function ServerData_Staminas:updateStaminaInfo(stamina_type)
    local t_stamina_info = self:getRef(stamina_type)

    if (not t_stamina_info) then
        return
    end
    
    local cnt = t_stamina_info['cnt']
    local max_cnt = t_stamina_info['max_cnt']
    local used_at = t_stamina_info['used_at'] or 0
    local charging_time = TableStaminaInfo:getChargingTime(stamina_type)



    -- 사용 시간이 없을 경우(혹은 max일 경우 자동으로 0으로 설정???)
    if (used_at == 0) then
        --cclog('## used_at = 0')
        t_stamina_info['remain_charge_time'] = 0
        return
    end

    -- 최대치일 경우
    if (cnt >= max_cnt) then
        --cclog('## max_cnt = 0' .. cnt)
        t_stamina_info['remain_charge_time'] = 0
        return
    end

    -- 서버상의 시간을 얻어옴
    local server_time = Timer:getServerTime()

    -- 1000분의 1초 -> 1초로 단위 변경
    used_at = math.floor(used_at / 1000)

    -- @alert 드래곤히어로즈의 StaminaMgr:isDailyLimit(type)을 추후에 고려해야함

    -- error가 있는 상황임. ServerTime의 동기화를 기다리자
    if (server_time - used_at < 0) then
        t_stamina_info['remain_charge_time'] = 0
        --cclog('# error가 있는 상황임. ServerTime의 동기화를 기다리자')
        --cclog('server_time ' .. server_time)
        --cclog('used_at ' .. used_at)
		return
	end

    -- 추가된 갯수 체크
    local added = 0
    
    if (0 < charging_time) then
        added = math_floor((server_time - used_at) / charging_time)
    end

    -- 다음 충전까지 남은 시간 계산
    local next_charge_time = server_time - (used_at + (added * charging_time))
    t_stamina_info['remain_charge_time'] = math_max((charging_time - next_charge_time), 0)

    -- 추가된 양이 있으면
    if (added > 0) then
        -- 갯수 변경
        t_stamina_info['cnt'] = (t_stamina_info['cnt'] + added)

        -- 충전 시간 변경
        if (cnt < max_cnt) then
            t_stamina_info['used_at'] = t_stamina_info['used_at'] + ((charging_time * added * 1000))
        else
            t_stamina_info['used_at'] = 0
            t_stamina_info['remain_charge_time'] = 0
        end
    end
end

-------------------------------------
-- function update
-- @brief 스태미나 정보를 갱신
-------------------------------------
function ServerData_Staminas:update(dt)
    local t_staminas = self.m_serverData:getRef('user', 'staminas')
    if (not t_staminas) then
        return
    end

    for stamina_type,t_stamina_info in pairs(t_staminas) do
        self:updateStaminaInfo(stamina_type)
    end
end

-------------------------------------
-- function updateOn
-------------------------------------
function ServerData_Staminas:updateOn()
    self:update()

    if (self.m_scheduleHandlerID) then
        return
    end

    local function update(dt)
        self:update(dt)
    end
    
    self.m_scheduleHandlerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) return update(dt) end, 0, false)
end

-------------------------------------
-- function updateOff
-------------------------------------
function ServerData_Staminas:updateOff()
    if self.m_scheduleHandlerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_scheduleHandlerID)
        self.m_scheduleHandlerID = nil
    end
end

-------------------------------------
-- function isActive
-- @brief 스태미나 정보를 실시간으로 갱신중인지 여부
-------------------------------------
function ServerData_Staminas:isActive()
    -- 스케쥴 핸들러 ID가 있다는 소리는 update를 돌리고 있다는 뜻
    if self.m_scheduleHandlerID then
        return true
    else
        return false
    end
end

-------------------------------------
-- function checkStageStamina
-------------------------------------
function ServerData_Staminas:checkStageStamina(stage_id)
    local stamina_type, req_count = TableDrop:getStageStaminaType(stage_id)
    
    local is_enough, insufficient_num = self:hasStaminaCount(stamina_type, req_count)

    if is_enough then
        return true
    end

    return false

    --[[
    if self:canDailyCharge(stamina_type) then

    end
    --]]
end

-------------------------------------
-- function canDailyCharge
-- @breif 일일 충전이 가능한지 체크
-------------------------------------
function ServerData_Staminas:canDailyCharge(stamina_type)
    local charge_limit = TableStaminaInfo:getDailyChargeLimit(stamina_type)

    if (not charge_limit) then
        return false
    end

    local t_stamina_info = self:getRef(stamina_type)
    local charge_cnt = (t_stamina_info['charge_cnt'] or 0)

    if (charge_cnt >= charge_limit) then
        return false
    end

    return true
end


-------------------------------------
-- function staminaCharge
-------------------------------------
function ServerData_Staminas:staminaCharge(stage_id)
    local stamina_type, req_count = TableDrop:getStageStaminaType(stage_id)


    if (stamina_type == 'st') then
        MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('날개가 부족합니다.\n상점으로 이동하시겠습니까?'), openShopPopup_stamina)
    else
        local charge_limit = TableStaminaInfo:getDailyChargeLimit(stamina_type)

        if self:canDailyCharge(stamina_type) then
            local t_stamina_info = self:getRef(stamina_type)
            local charge_cnt = (t_stamina_info['charge_cnt'] or 0)
            local price, cnt = TableStaminaInfo:getDailyChargeInfo(stamina_type, charge_cnt)
            local msg = Str('입장권이 부족합니다.\n{@possible}입장권 {1}개{@default}를 충전하시겠습니까?\n{@impossible}(1일 {2}회 구매 가능. 현재 {3}회 구매)', cnt, charge_limit, charge_cnt)
            
            local function ok_btn_cb()
                local cash = g_userData:get('cash')
                if (cash < price) then
                    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('다이아몬드가 부족합니다.\n상점으로 이동하시겠습니까?'), openShopPopup_cash)
                    return true
                end
                
                self:request_staminaCharge(stamina_type)
            end

            UI_ConfirmPopup('cash', price, msg, ok_btn_cb)
        else
            local msg = Str('입장권을 모두 소모하였습니다.\n오늘은 더 이상 구매할 수 없습니다.\n{@impossible}(1일 {1}회 구매 가능)', charge_limit)
            MakeSimplePopup(POPUP_TYPE.OK, msg)
        end
    end
end

-------------------------------------
-- function request_staminaCharge
-------------------------------------
function ServerData_Staminas:request_staminaCharge(stamina_type, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/st_charge')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', stamina_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end