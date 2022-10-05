-------------------------------------
-- Class ServerData_HighbrowVip
-- @brief 하이브로 VIP
-------------------------------------
ServerData_HighbrowVip = class({
    m_serverData = 'ServerData',

    m_vipGrade = '',
    m_vipSurveyStatus = '',

})

local instance = nil


TABLE_HIGHBROW_VIP = {
    ['silver'] = {
        ['res_num'] = 1,
        ['name'] = '실버'
    },
    ['gold'] = {
        ['res_num'] = 2,
        ['name'] = '골드',
        ['item'] = '700001;51000',
        ['item_icon_res'] = 'ui/icons/item/shop_cash_05.png',
    },
    ['vip'] = {
        ['res_num'] = 3,
        ['name'] = 'VIP',
        ['item'] = '700001;378000',
        ['item_icon_res'] = 'ui/icons/item/shop_cash_07.png',
    },
    ['svip'] = {
        ['res_num'] = 4,
        ['name'] = 'SVIP',
        ['item'] = '700001;378000',
        ['item_icon_res'] = 'ui/icons/item/shop_cash_07.png',
    }
}

-------------------------------------
-- function init
-------------------------------------
function ServerData_HighbrowVip:init(server_data)
    assert(instance == nil, 'Can not initalize twice')

    self.m_serverData = server_data
end

-------------------------------------
-- function getInstance
-------------------------------------
function ServerData_HighbrowVip:getInstance(server_data)
    if (instance == nil) then
        instance = ServerData_HighbrowVip(server_data)
    end

    return instance
end

-------------------------------------
-- function request_reward
-------------------------------------
function ServerData_HighbrowVip:request_reward(name, phone_number, email, success_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function response_callback(ret)
        self:response_info(ret)

        if (success_cb) then 
            success_cb(ret) 
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/hvip_update')
    ui_network:setParam('uid', uid)
    ui_network:setParam('name', name)
    ui_network:setParam('hp', phone_number)
    ui_network:setParam('email', email)
    ui_network:setSuccessCB(response_callback)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_info
-------------------------------------
function ServerData_HighbrowVip:response_info(ret)
    -- 현재 등급
    if (ret['hvip_grade'] ~= nil) then
        self.m_vipGrade = ret['hvip_grade']
    end

    -- 유저가 마지막으로 관련 정보를 등록했던 등급
    if (ret['hvip_survey_state'] ~= nil) then
        self.m_vipSurveyStatus = ret['hvip_survey_state']
    end
end

-------------------------------------
-- function getVipName
-------------------------------------
function ServerData_HighbrowVip:getVipName()
    local vip_data = TABLE_HIGHBROW_VIP[self.m_vipGrade]
    return vip_data['name']
end

-------------------------------------
-- function checkItemExist
-------------------------------------
function ServerData_HighbrowVip:checkItemExist()
    local vip_data = TABLE_HIGHBROW_VIP[self.m_vipGrade]

    return (vip_data['item'] ~= nil)
end

-------------------------------------
-- function getItemStr
-------------------------------------
function ServerData_HighbrowVip:getItemStr()
    local vip_data = TABLE_HIGHBROW_VIP[self.m_vipGrade]
    local item_list = g_itemData:parsePackageItemStr(vip_data['item'])

    local str = ''
    for index, item in ipairs(item_list) do
        
        str = Str('{1} {2}개', TableItem():getItemName(item['item_id']), comma_value(item['count']))
    end

    return str
end

-------------------------------------
-- function getItemNum
-------------------------------------
function ServerData_HighbrowVip:getItemNum()
    local vip_data = TABLE_HIGHBROW_VIP[self.m_vipGrade]
    local item_str = vip_data['item']

    if (item_str == nil) then
        return 0
    end

    local item_list = g_itemData:parsePackageItemStr(item_str)

    return table.count(item_list)
end


-------------------------------------
-- function getItemIconRes
-------------------------------------
function ServerData_HighbrowVip:getItemIconRes()
    local vip_data = TABLE_HIGHBROW_VIP[self.m_vipGrade]
    return vip_data['item_icon_res']
end

-------------------------------------
-- function getVipBtnRes
-------------------------------------
function ServerData_HighbrowVip:getVipBtnRes()
    
    local vip_data = TABLE_HIGHBROW_VIP[self.m_vipGrade]
    local res_num = vip_data['res_num']
    local res = string.format('ui/icons/side_menu_vip_%02d.png', res_num)
    return res
end

-------------------------------------
-- function getVipIconRes
-------------------------------------
function ServerData_HighbrowVip:getVipIconRes()
    local vip_data = TABLE_HIGHBROW_VIP[self.m_vipGrade]
    local res_num = vip_data['res_num']
    local res = string.format('ui/icons/vip_grade_%02d.png', res_num)
    return res
end

-------------------------------------
-- function getBottomFrameRes
-------------------------------------
function ServerData_HighbrowVip:getBottomFrameRes()
    local vip_data = TABLE_HIGHBROW_VIP[self.m_vipGrade]
    local res_num = vip_data['res_num']
    local res = string.format('ui/frames/vip_letter_%02d.png', res_num)
    return res
end

-------------------------------------
-- function getItemBoxRes
-------------------------------------
function ServerData_HighbrowVip:getItemBoxRes()
    local vip_data = TABLE_HIGHBROW_VIP[self.m_vipGrade]
    local res_num = vip_data['res_num']
    local res = string.format('ui/frames/vip_itembox_%02d.png', res_num)
    return res
end

-------------------------------------
-- function getAvailableItemName
-------------------------------------
function ServerData_HighbrowVip:getAvailableItemName()
    return ''
end

-------------------------------------
-- function checkVipStatus
-------------------------------------
function ServerData_HighbrowVip:checkVipStatus()
    return (self.m_vipGrade ~= nil) and (self.m_vipGrade ~= self.m_vipSurveyStatus)
end

-------------------------------------
-- function getVipButton
-------------------------------------
function ServerData_HighbrowVip:getVipButton()
    require('UI_HighbrowVipPopup')
    return UI_ButtonHighbrowVIP
end

-------------------------------------
-- function openPopup
-------------------------------------
function ServerData_HighbrowVip:openPopup(close_cb)
    if (self.m_vipGrade == nil) or (self.m_vipGrade == self.m_vipSurveyStatus) then
        if close_cb then
            close_cb()
        end

        return
    end

    require('UI_HighbrowVipPopup')
    local is_popup = true
    local ui = UI_HighbrowVipPopup(is_popup)
    ui:setCloseCB(close_cb)
end


-------------------------------------
-- function isEventActive
---@return boolean
-------------------------------------
function ServerData_HighbrowVip:isEventActive()
    local t_data = g_eventData:getEventInByEventType('highbrow_vip')
    local visible = (t_data ~= nil)

    if (visible) then
        local event_id = t_data['event_id']
        local event_type = t_data['event_type'] 
        local priority = t_data['ui_priority']
        local feature = t_data['feature']
        local user_lv = t_data['user_lv']
        local start_date = t_data['start_date']
        local end_date = t_data['end_date']
        local target_server = t_data['target_server'] or ''
        local target_language = t_data['target_language'] or ''

        -- 유저 레벨 조건 (걸려있는 레벨 이상인 유저에게만 노출)
        if (visible) and (user_lv ~= '') then
            local curr_lv = g_userData:get('lv')
            visible = (curr_lv >= user_lv)
        end

        -- 서버 조건
        if (visible) and (target_server ~= '') then
            visible = g_eventData:checkTargetServer(target_server)
        end
        
        -- 언어 조건
        if (visible) and (target_language ~= '') then
            target_language = string.gsub(target_language, ' ', '')
            local t_language = pl.stringx.split(target_language, ',')
            local game_lang = Translate:getGameLang()
            
            visible = (table.find(t_language, game_lang) ~= nil)
        end


        -- 날짜 조건
        if (visible) and ((start_date ~= '') or (end_date ~= '')) then
            visible = g_eventData:checkEventTime(start_date, end_date, t_data)
        end

        if (visible) and (string.find(feature, 'only_aos')) then
            visible = CppFunctions:isAndroid()

            if IS_TEST_MODE() then
                visible =  visible or CppFunctions:isMac() or CppFunctions:isWin32()
            end
        elseif (visible) and (string.find(feature, 'only_ios')) then
            visible = CppFunctions:isIos()

            if IS_TEST_MODE() then
                visible = visible or CppFunctions:isMac() or CppFunctions:isWin32()
            end
        end
    end

    return visible
end

























