local PARENT = TableClass

-------------------------------------
-- class TableDragonSkill
-------------------------------------
TableDragonSkill = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableDragonSkill:init()
    self.m_tableName = 'dragon_skill'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getSkillIcon
-------------------------------------
function TableDragonSkill:getSkillIcon(key)
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
function TableDragonSkill:getSkillName(key)
	if (not key) or (key == '') then return end
    local t_skill = self:get(key)
    return t_skill['t_name']
end

-------------------------------------
-- function getSkillDesc
-------------------------------------
function TableDragonSkill:getSkillDesc(key)
	if (not key) or (key == '') then return end
    local t_skill = self:get(key)
    local desc = IDragonSkillManager:getSkillDescWithSubstituted(t_skill)
    return desc
end

-------------------------------------
-- function getSkillType
-------------------------------------
function TableDragonSkill:getSkillType(key)
	if (not key) or (key == '') then return end
    local t_skill = self:get(key)
    return t_skill['chance_type']
end