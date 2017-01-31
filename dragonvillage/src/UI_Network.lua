local PARENT = UI

-------------------------------------
-- class UI_Network
-------------------------------------
UI_Network = class(PARENT,{
        m_bRevocable = 'boolean',   -- 취소 가능 여부
        m_bReuse = 'boolean', -- 재사용 가능 여부

        m_url = 'string',
        m_method = 'string', -- 'GET' or 'POST'
        m_bHmac = 'boolean', -- false or true
        m_tData = 'table', -- request 파라미터

        m_successCB = 'function',
        m_failCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Network:init()
    local vars = self:load('network_loading.ui')
    UIManager:open(self, UIManager.LOADING)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_Network')

    self:init_MemberVariable()

    self:setLoadingMsg(Str('네트워크 통신 중...'))
end

-------------------------------------
-- function init_MemberVariable
-------------------------------------
function UI_Network:init_MemberVariable()
    self.m_bRevocable = false
    self.m_bReuse = false

    self.m_url = nil
    self.m_method = 'POST' or 'GET'
    self.m_bHmac = true or false
    self.m_tData = {}

    self.m_successCB = nil
    self.m_failCB = nil
end

-------------------------------------
-- function softReset
-------------------------------------
function UI_Network:softReset()
    self.m_tData = {}
end

-------------------------------------
-- function setRevocable
-------------------------------------
function UI_Network:setRevocable(revocable)
    self.m_bRevocable = revocable
end

-------------------------------------
-- function setReuse
-------------------------------------
function UI_Network:setReuse(reuse)
    self.m_bReuse = reuse
end

-------------------------------------
-- function setUrl
-------------------------------------
function UI_Network:setUrl(url)
    self.m_url = url
end

-------------------------------------
-- function setMethod
-------------------------------------
function UI_Network:setMethod(method)
    if not isExistValue(method, 'POST', 'GET') then
        error('method : ' .. method)
    end

    self.m_method = method
end

-------------------------------------
-- function setHmac
-------------------------------------
function UI_Network:setHmac(hmac)
    self.m_bHmac = hmac
end

-------------------------------------
-- function setSuccessCB
-------------------------------------
function UI_Network:setSuccessCB(success_cb)
    self.m_successCB = success_cb
end

-------------------------------------
-- function setFailCB
-------------------------------------
function UI_Network:setFailCB(fail_cb)
    self.m_failCB = fail_cb
end

-------------------------------------
-- function setParam
-------------------------------------
function UI_Network:setParam(key, value)
    self.m_tData[key] = value
end

-------------------------------------
-- function setLoadingMsg
-------------------------------------
function UI_Network:setLoadingMsg(msg)
    self.vars['loadingLabel']:setString(msg)
end

-------------------------------------
-- function success
-------------------------------------
function UI_Network.success(self, ret)
    
    if self:statusHandler(ret) then
        return
    end

    --if ret['status'] and ret['status']

    if self.m_successCB then
        self.m_successCB(ret)
    end

    if (self.m_bReuse == false) then
        self:close()
    end
end

-------------------------------------
-- function fail
-------------------------------------
function UI_Network.fail(self, ret)
    if self.m_failCB then
        if (self.m_failCB(ret) == true) then
            return
        end
    end

    self:makeFailPopup(nil, ret)
end

-------------------------------------
-- function statusHandler
-------------------------------------
function UI_Network:statusHandler(ret)
    local status = ret['status']
    local message = ret['message']

    if (not status) then
        return
    end

    if (status == 0) then
        return
    end

    -- not enough fruit
    if (status == -2104) then
        self:makeCommonPopup(Str('열매가 부족합니다.'))
        return true
    end

    -- not enough cash (자수정이 부족할 때)
    if (status == -2100) then
        self:makeShopPopup(Str('자수정이 부족합니다.\n상점으로 이동하시겠습니까?'), ret)
        return true
    end

    -- not enough gold (골드가 부족할 때)
    if (status == -2101) then
        self:makeShopPopup(Str('골드가 부족합니다.\n상점으로 이동하시겠습니까?'), ret)
        return true
    end

    -- not enough evolution stones (드래곤 진화 재료가 부족할 때)
    if (status == -2104) then
        self:makeCommonPopup(Str('진화재료가 부족합니다.'))
        return true
    end

    -- not enough stamina (날개가 부족할 때)
    if (status == -2103) then
        self:makeShopPopup(Str('날개가 부족합니다.\n상점으로 이동하시겠습니까?'), ret)
        return true
    end

    self:makeFailPopup(nil, ret)
    return true
end

-------------------------------------
-- function makeFailPopup
-- @brief
-------------------------------------
function UI_Network:makeFailPopup(msg, ret)
    local function ok_btn_cb()
        self:request()
    end

    local function cancel_btn_cb()
        self:close()
    end

    local msg = msg or '{@BLACK}네트워크 연결에 실패하였습니다. 다시 시도하시겠습니까?'

    if ret then
        local add_msg = '(status : ' .. tostring(ret['status']) .. ', message : ' .. tostring(ret['message']) .. ')'
        msg =  msg .. '\n\n' .. add_msg
    end

    local popup_type

    if (self.m_bRevocable == true) then
        popup_type = POPUP_TYPE.YES_NO
    else
        popup_type = POPUP_TYPE.OK
    end

    MakeSimplePopup(popup_type, msg, ok_btn_cb, cancel_btn_cb)
end

-------------------------------------
-- function makeShopPopup
-- @brief
-------------------------------------
function UI_Network:makeShopPopup(msg, ret)
    self:close()
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, openShopPopup)
end

-------------------------------------
-- function makeCommonPopup
-- @brief
-------------------------------------
function UI_Network:makeCommonPopup(msg)
    self:close()
    MakeSimplePopup(POPUP_TYPE.OK, Str(msg))
end


-------------------------------------
-- function request
-------------------------------------
function UI_Network:request()
    local t_request = {}

    t_request['url'] = self.m_url
    t_request['method'] = self.m_method
    t_request['data'] = self.m_tData

    t_request['success'] = function(ret) UI_Network.success(self, ret) end
    t_request['fail'] = function(ret) UI_Network.fail(self, ret) end

    if (self.m_bHmac == true) then
        -- 우선 둘 다 simpleRequest를 사용
        Network:SimpleRequest(t_request)
    else
        Network:SimpleRequest(t_request)
    end
end




-- 네트워크 통신 테스트
function UI_NetworkTest()
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)

    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/login')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false) -- 통신 실패 시 취소 가능 여부
    ui_network:setReuse(false) -- 재사용 여부
    ui_network:request()
end