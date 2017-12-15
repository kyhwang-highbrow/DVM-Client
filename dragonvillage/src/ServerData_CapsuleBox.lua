-------------------------------------
-- class ServerData_CapsuleBox
-------------------------------------
ServerData_CapsuleBox = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_CapsuleBox:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function apply
-------------------------------------
function ServerData_CapsuleBox:apply()

end

-------------------------------------
-- function request_capsuleInfo
-------------------------------------
function ServerData_CapsuleBox:request_capsuleInfo(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
		if (ret['??']) then
			self:apply(ret['??'])
		end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/capsule/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end