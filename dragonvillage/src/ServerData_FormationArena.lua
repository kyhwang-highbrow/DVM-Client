-------------------------------------
-- class ServerData_FormationArena
-------------------------------------
ServerData_FormationArena = class({
        m_serverData = 'ServerData',
		m_formationData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_FormationArena:init(server_data)
    self.m_serverData = server_data
	self:initFormation()
end

-------------------------------------
-- function initFormation
-- @brief 진형 정보를 초기화 한다.
-------------------------------------
function ServerData_FormationArena:initFormation()
	self.m_formationData = {
		attack = {formation = 'attack',  formation_lv = 1},
		balance = {formation = 'balance', formation_lv = 1},
		defence = {formation = 'defence', formation_lv = 1},
		critical = {formation = 'critical', formation_lv = 1},
        charge = {formation = 'charge', formation_lv = 1},
		guard = {formation = 'guard', formation_lv = 1},
	}
end

-------------------------------------
-- function getFormationInfoList
-------------------------------------
function ServerData_FormationArena:getFormationInfoList()
	self:makeDataPretty()

	return self.m_formationData
end

-------------------------------------
-- function makeDataPretty
-- @brief 서버로부터 가져온 정보를 사용하기 좋게 가공한다.
-------------------------------------
function ServerData_FormationArena:makeDataPretty()
	for i, v in pairs(self.m_formationData) do
        v['formation_lv'] = 1 -- 일딴 레벨 1로 고정

--		if (formation_lv) then
--			v['formation_lv'] = formation_lv
--		end
	end
end

-- 후에 아레나 덱 레벨업이나 서버 통신 필요한 경우 처리