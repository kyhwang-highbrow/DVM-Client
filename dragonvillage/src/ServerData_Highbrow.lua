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
    local t_ret = {}

    for game_key, v in pairs(item_list) do 
        for _, t_item in pairs(v) do
            t_item['game_key'] = game_key
            table.insert(t_ret, StructHighbrowProduct(t_item))
        end
    end

    self.m_hbItemList = t_ret
end

-------------------------------------
-- function getHBItemList
-- @brief 하이브로 상점 목록
-------------------------------------
function ServerData_Highbrow:getHBItemList()
    return self.m_hbItemList
end

-------------------------------------
-- function request_HbProductHistory
-------------------------------------
function ServerData_Highbrow:request_HbProductHistory(code, game_key, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
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
    ui_network:hideLoading()
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
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
    ui_network:hideLoading()
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
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
    ui_network:hideLoading()
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end