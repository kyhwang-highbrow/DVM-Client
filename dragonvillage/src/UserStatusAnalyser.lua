-------------------------------------
-- table UserStatusAnalyser
-------------------------------------
UserStatusAnalyser = {
	userStatus = 'StructUserStatus',
	dragonStatus = 'StructDragonStatus',
}

-------------------------------------
-- function init
-------------------------------------
function UserStatusAnalyser:init()
	self.userStatus = StructUserStatus()
	self.dragonStatus = StructDragonStatus()
end

-------------------------------------
-- function analyzeUserStat
-------------------------------------
function UserStatusAnalyser:analyzeUserStat(ret)
	self.userStatus:apply(ret)
end

-------------------------------------
-- function analyzeDragon
-------------------------------------
function UserStatusAnalyser:analyzeDragon()
	local l_dragon = g_dragonsData:getDragonsListRef()

	-- 각종 드래곤 지표 추출
	local limit_cnt = 0
	local legend_cnt = 0
	local max_all_cnt = 0

	for i, struct_dragon in ipairs(l_dragon) do
		
		-- 레벨, 등급, 스킬, 강화, 특성 모두 최대치
		if (struct_dragon:isMaxGradeAndLv()) then
			max_all_cnt = max_all_cnt + 1
		end

		-- 전설
		cclog(struct_dragon:getRarity())
		if (struct_dragon:getRarity() == 'legend') then
			legend_cnt = legend_cnt + 1
		end

		-- 한정
		if (struct_dragon:isLimited()) then
			limit_cnt = limit_cnt + 1
		end

	end

	-- 분석 정보
	self.dragonStatus:apply({
		['limit_cnt'] = limit_cnt,
		['legend_cnt'] = legend_cnt,
		['max_all_cnt'] = max_all_cnt,
	})
end

-------------------------------------
-- function analyzeRune
-------------------------------------
function UserStatusAnalyser:analyzeRune()

end












-------------------------------------
-- class StructUserStatus
-------------------------------------
StructUserStatus = class({
	sum_money = 'number',
	login_days = 'number',
	last_cleared_stage = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function StructUserStatus:init()
	self.sum_money = 0
	self.login_days = 0
end

-------------------------------------
-- function apply
-------------------------------------
function StructUserStatus:apply(ret)
	if (ret) then
		-- 직접 서버에서 받는 정보
		self.sum_money = ret['sum_money']
		self.login_days = ret['login_days']
	end

	-- 간접 정보
	self.last_cleared_stage = g_adventureData:getLastClearedStage()
end

-------------------------------------
-- class StructDragonStatus
-------------------------------------
StructDragonStatus = class({
	limit_cnt = 'number',
	legend_cnt = 'number',
	max_all_cnt = 'number',
})

-------------------------------------
-- function apply
-------------------------------------
function StructDragonStatus:apply(ret)
	self.limit_cnt = ret['limit_cnt']
	self.legend_cnt = ret['legend_cnt']
	self.max_all_cnt = ret['max_all_cnt']
end