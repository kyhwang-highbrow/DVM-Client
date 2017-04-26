local PARENT = TableClass

-------------------------------------
-- class TableTamerSkill
-------------------------------------
TableTamerSkill = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableTamerSkill:init()
    self.m_tableName = 'tamer_skill'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getTamerSkill
-------------------------------------
function TableTamerSkill:getTamerSkill(skill_id)
	local t_skill = self:get(skill_id)
	
	-- 스킬 자체가 없는 경우는 nil 반환
	if not (t_skill) then 
		return nil
	end

	return t_skill

	--[[
	-- 패시브는 스킬 레벨이 1이다.
	if (t_skill['chance_type'] == 'passive') then
		return t_skill

	-- 패시브가 아닌 경우
	else
		-- 유저 레벨에 따른 스킬의 레벨 계산
		local skill_level = self:getSkillLevel()
		local adj_skill_id = skill_id + skill_level
		t_skill = self:get(adj_skill_id)
		return t_skill
	end
	]]
end

-------------------------------------
-- function getSkillIcon
-------------------------------------
function TableTamerSkill:getSkillIcon(key)
    local t_skill = self:get(key)

    local res_name = t_skill['res_icon']
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icon/skill/developing.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getSkillName
-------------------------------------
function TableTamerSkill:getSkillName(key)
	if (not key) or (key == '') then return end
    local t_skill = self:get(key)
    return t_skill['t_name']
end

-------------------------------------
-- function getSkillDesc
-------------------------------------
function TableTamerSkill:getSkillDesc(key)
	if (not key) or (key == '') then return end
    local t_skill = self:get(key)
    local desc = IDragonSkillManager:getSkillDescWithSubstituted(t_skill)
    return desc
end

-------------------------------------
-- function getSkillType
-------------------------------------
function TableTamerSkill:getSkillType(key)
	if (not key) or (key == '') then return end
    local t_skill = self:get(key)
    return t_skill['chance_type']
end