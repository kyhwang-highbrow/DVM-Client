-------------------------------------
-- table SkillHelper
-- @brief 스킬 사용에 전역적으로 필요한 함수 모음
-------------------------------------
SkillHelper = {}

-------------------------------------
-- function getAttributeRes
-- @brief 스킬에서 사용할 리소스 경로를 만들어 반환하는데 객체 생성전에 사용되므로 주의
-------------------------------------
function SkillHelper:getAttributeRes(res, owner)
	if (not res) then 
		error('비어있는 스킬 리소스 문자열')
	elseif (res == 'x') then
		return nil
	else
		return string.gsub(res, '@', owner:getAttributeForRes())
	end
end