-------------------------------------
-- class ServerData_Formation
-------------------------------------
ServerData_Formation = class({
        m_serverData = 'ServerData',
		m_formationData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Formation:init(server_data)
    self.m_serverData = server_data
	self:initFormation()
end

-------------------------------------
-- function initFormation
-- @brief 진형 정보를 초기화 한다.
-------------------------------------
function ServerData_Formation:initFormation()
	self.m_formationData = {
		attack = {formation = 'attack',  formation_lv = 1},
		balance = {formation = 'balance', formation_lv = 1},
		defence = {formation = 'defence', formation_lv = 1},
		critical = {formation = 'critical', formation_lv = 1},
	}
end

-------------------------------------
-- function getFormationInfoList
-------------------------------------
function ServerData_Formation:getFormationInfoList()
	local l_formation_lv = self.m_serverData:get('user','formation_lv')
	self:makeDataPretty(l_formation_lv)

	return self.m_formationData
end

-------------------------------------
-- function getFormationInfo
-------------------------------------
function ServerData_Formation:getFormationInfo(formation_type)
	local l_formation_lv = self.m_serverData:get('user','formation_lv')
	self:makeDataPretty(l_formation_lv)

	return self.m_formationData[formation_type]
end

-------------------------------------
-- function makeDataPretty
-- @brief 서버로부터 가져온 정보를 사용하기 좋게 가공한다.
-------------------------------------
function ServerData_Formation:makeDataPretty(l_formation_lv)
	for i, v in pairs(self.m_formationData) do
		local idx = tostring(i)
		local formation_lv = l_formation_lv[tostring(idx)]
		if (formation_lv) then
			v['formation_lv'] = formation_lv
		end
	end
end

-------------------------------------
-- function request_lvupFormation
-------------------------------------
function ServerData_Formation:request_lvupFormation(formation_type, enhance_level, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local formation_type = formation_type
	local enhance_level  = enhance_level

    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '진형 레벨업')

		-- 골드 적용
        self.m_serverData:networkCommonRespone(ret)
        -- 진형 레벨 적용
		self.m_serverData:applyServerData(ret['formation_lv'], 'user','formation_lv')

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/lvup/deck')
    ui_network:setParam('uid', uid)
	ui_network:setParam('formation', formation_type)
	ui_network:setParam('level', enhance_level)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end
