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

    -- 포함된 수식들을 위한 함수 생성
    self:addFunctionsForEquation()
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

-------------------------------------
-- function addFunctionsForEquation
-------------------------------------
function TableDragonSkill:addFunctionsForEquation()
    if (not self.m_orgTable) then return end

    for sid, v in pairs(self.m_orgTable) do 
        local power_source = SkillHelper:getValid(v['power_source'], 'atk')
                
        -- power_source가 수식일 경우 함수를 추가
        local operator = string.match(power_source, '[*+/-]')
        if (operator) then
            local key = v['sid']
            local ret = pl.utils.load(
                'EQUATION_FUNC[' .. key .. '] = function(owner)' ..
                ' local atk = owner:getStat(\'atk\')' ..
                ' local def = owner:getStat(\'def\')' ..
                ' local hp = owner:getStat(\'hp\')' ..
                ' local aspd = owner:getStat(\'aspd\')' ..
                ' local cri_chance = owner:getStat(\'cri_chance\')' ..
                ' local cri_dmg = owner:getStat(\'cri_dmg\')' ..
                ' local cri_avoid = owner:getStat(\'cri_avoid\')' ..
                ' local hit_rate = owner:getStat(\'hit_rate\')' ..
                ' local avoid = owner:getStat(\'avoid\')' ..

                ' local ret = ' .. power_source .. 
                ' return ret' ..
                ' end'
            )
        end
    end
end