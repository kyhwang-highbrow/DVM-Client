-------------------------------------
-- table SkillTargetFinder
-- @brief 스킬과 인디케이터가 공통으로 사용할 스태틱한 find target 함수
-------------------------------------
SkillTargetFinder = {}

-------------------------------------
-- function findTarget_AoERound
-------------------------------------
function SkillTargetFinder:findTarget_AoERound(l_target, x, y, range)
	local l_target = l_target or {}
	local pos_x = x or 0
	local pos_y = y or 0
	local range = range or 0

	local l_ret = {}

	-- 바디사이즈를 감안한 충돌 체크
    for _, target in pairs(l_target) do
		if isCollision(pos_x, pos_y, target, range) then 
			table.insert(l_ret, target)
		end
    end
    
    return l_ret
end

-------------------------------------
-- function findTarget_AoESquare
-------------------------------------
function SkillTargetFinder:findTarget_AoESquare(owner, x, y, range)
end

-------------------------------------
-- function findTarget_AoEWedge
-------------------------------------
function SkillTargetFinder:findTarget_AoEWedge(owner, x, y, range)
end

-------------------------------------
-- function findTarget_Bar
-------------------------------------
function SkillTargetFinder:findTarget_Bar(owner, x, y, range)
end

-------------------------------------
-- function findTarget_AoERound
-------------------------------------
function SkillTargetFinder:findTarget_AoESquare(owner, x, y, range)
end