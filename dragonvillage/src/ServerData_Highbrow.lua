-------------------------------------
-- class ServerData_Highbrow
-------------------------------------
ServerData_Highbrow = class({
        m_serverData = 'ServerData',
        m_hbItemList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Highbrow:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function applyHBItemList
-- @brief 하이브로 상점 목록 사용하기 좋게 만듬
-------------------------------------
function ServerData_Highbrow:applyHBItemList(item_list)
    local l_ret = {}

    for game_key, v in pairs(item_list) do 
        for _, t_item in pairs(v) do

            -- 게임 서버, 어카운트 서버(하이브로)를 통해서 받은 리스트에서 클라이언트 테이블에 정보가 있는지 확인
            -- 클라이언트 테이블에서 해당 항목이 없으면 리스트뷰에 추가하지 않음
            local code = t_item['code']
            local t_highbrow = TableHighbrow:find(game_key, code)

            if (t_highbrow ~= nil) then
                t_item['game_key'] = game_key
                table.insert(l_ret, StructHighbrowProduct(t_item))
            end
        end
    end
    
    -- 정렬 순서
    -- 1. 수령하지 않은 것
    -- 2. 튜토리얼 보상 먼저
    -- 3. 드빌1
    table.sort(l_ret, function(a, b)
        if (a.done == b.done) then
            if (a.type == b.type) then
                if (a.game_key == 'dv1') then
                    return true
                elseif (b.game_key == 'dv1') then
                    return false
                end
            else
                return a.type < b.type
            end
        else
            if (a.done == false) then
                return true
            elseif (b.done == false) then
                return false
            end
        end            
    end)

    self.m_hbItemList = l_ret
end

-------------------------------------
-- function getHBItemList
-- @brief 하이브로 상점 목록
-------------------------------------
function ServerData_Highbrow:getHBItemList()
    local l_item_list = {}

    for i, v in ipairs(self.m_hbItemList) do
        local b_is_active = false
        local start_date = v['start_date']
        local end_date = v['end_date']
        
        if (CheckValidDateFromTableDataValue(start_date, end_date)) then
            table.insert(l_item_list, v)
        end
    end

    return l_item_list
end

-------------------------------------
-- function getBannerUrl
-- @brief 하이브로 배너 url
-------------------------------------
function ServerData_Highbrow:getBannerUrl()
    local url
    -- 언어별 처리는 언어 정책이 정해진 후에
    if (CppFunctions:isAndroid()) then
        url = 'http://gate.game.highbrow-inc.com/_intro.php?gameType=dvm&marketType=google&la=ko'
        --'http://gate.game.highbrow-inc.com/_intro.php?gameType=dvm&marketType=google&la=en'
    elseif (CppFunctions:isIos()) then
        url = 'http://gate.game.highbrow-inc.com/_intro.php?gameType=dvm&marketType=ios&la=ko'
        --'http://gate.game.highbrow-inc.com/_intro.php?gameType=dvm&marketType=ios&la=en'
    end

    return url
end

-------------------------------------
-- function request_getHbProductList
-------------------------------------
function ServerData_Highbrow:request_getHbProductList(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:applyHBItemList(ret['hb_items'])
                
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/highbrow/item_list')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_buyHbProcduct
-------------------------------------
function ServerData_Highbrow:request_buyHbProcduct(code, game_key, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        g_highlightData:applyHighlightInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/highbrow/buy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('code', code)
    ui_network:setParam('game', game_key)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_buyHBProductTutorial
-------------------------------------
function ServerData_Highbrow:request_buyHBProductTutorial(code, game_key, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        g_highlightData:applyHighlightInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/highbrow/tutorial')
    ui_network:setParam('uid', uid)
    ui_network:setParam('code', code)
    ui_network:setParam('game', game_key)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_couponCheck
-------------------------------------
function ServerData_Highbrow:request_couponCheck(coupon, success_cb, result_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/highbrow/coupon_check')
    ui_network:setParam('uid', uid)
    ui_network:setParam('coupon', coupon)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(result_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_couponUse
-------------------------------------
function ServerData_Highbrow:request_couponUse(coupon, success_cb, result_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/highbrow/coupon_use')
    ui_network:setParam('uid', uid)
    ui_network:setParam('coupon', coupon)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(result_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_cardCouponUse
-------------------------------------
function ServerData_Highbrow:request_cardCouponUse(coupon, success_cb, result_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/collabo/coupon/use')
    ui_network:setParam('uid', uid)
    ui_network:setParam('coupon_code', coupon)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(result_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end