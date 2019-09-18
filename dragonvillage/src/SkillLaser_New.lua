local PARENT = SkillLaser_Zet

-------------------------------------
-- class SkillLaser_New
-------------------------------------
SkillLaser_New = class(PARENT, {
        m_isIntegratedRes = 'boolean', -- 스킬 리소스 형식 구분
     })

-------------------------------------
-- function initc
-- @param file_name
-- @param body
-------------------------------------
function SkillLaser_New:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLaser_New:init_skill(missile_res, hit, thickness)
    -- 스킬 사용자 보임
    self.m_owner.m_animator:setVisible(true)
end
