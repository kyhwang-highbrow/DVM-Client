-------------------------------------
-- class ServerData_EventPopularityGacha
-------------------------------------
ServerData_EventPopularityGacha = class({
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventPopularityGacha:init(server_data)
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_EventPopularityGacha:getStatusText()
    local time = g_hotTimeData:getEventRemainTime('event_popularity')
    return Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
end

-------------------------------------
-- function isAvailableEventGacha
-------------------------------------
function ServerData_EventPopularityGacha:isAvailableEventGacha()
    if g_hotTimeData:isActiveEvent('event_popularity') == true then
        local ticket_count = g_userData:get('event_popularity_ticket')
        return ticket_count > 0
    end

    return false
end


-------------------------------------
-- function makeAddedDragonTable
-- @breif
-------------------------------------
function ServerData_EventPopularityGacha:makeAddedDragonTable(org_list, is_bundle)
    return org_list
end

-------------------------------------
-- function request_popularity_gacha_info
-- @brief 이벤트 정보
-------------------------------------
function ServerData_EventPopularityGacha:request_popularity_gacha_info(cb_func, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if cb_func ~= nil then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/shop/event_popularity/info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_popularity_gacha
-- @brief 드래곤 소환하기
-------------------------------------
function ServerData_EventPopularityGacha:request_popularity_gacha(draw_cnt, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        -- cash(캐시) / summon_dragon_ticket(드래곤 소환권) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 노티
        g_highlightData:setDirty(true)
        
        -- 드래곤들 추가
        local add_dragon_list = self:makeAddedDragonTable(ret['added_dragons'], false)
        g_dragonsData:applyDragonData_list(add_dragon_list)

        -- 신규 드래곤 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

        --드래곤 획득 패키지 정보 갱신
        g_getDragonPackage:applyPackageList(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end
    
    -- 성공 시 콜백
    local function status_cb(ret)       
        if ret['status'] == -2128 then
            MakeSimplePopup(POPUP_TYPE.OK, Str('이벤트가 종료되었습니다.'), function () 
                UINavigator:goTo('lobby')
            end)
            return true
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/shop/event_popularity/summon')
    ui_network:setParam('uid', uid)
    ui_network:setParam('sals', false)
    ui_network:setParam('draw_cnt', draw_cnt)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
    return ui_network
end
