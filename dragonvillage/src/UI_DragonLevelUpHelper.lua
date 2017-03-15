-------------------------------------
-- class UI_DragonLevelUpHelper
-------------------------------------
UI_DragonLevelUpHelper = class({
        m_selectedDoid = 'string',
        m_materialDoidMap = 'map',
        m_materialCount = 'number',
        m_maxMaterialCount = 'number',


        m_dragonGrade = 'number',
        m_dragonLevel = 'number',
        m_dragonExp = 'number',
        m_maxLevel = 'number',

        

        m_addExp = 'number',
        m_price = 'number',

        m_changedLevel = 'number',
        m_changedExp = 'number',
        m_changedMaxExp = 'number',
        m_expPercentage = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLevelUpHelper:init(doid, max_material_count)
    self.m_selectedDoid = doid
    self.m_materialDoidMap = {}
    self.m_materialCount = 0
    self.m_maxMaterialCount = max_material_count

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    self.m_dragonGrade = t_dragon_data['grade']
    self.m_dragonLevel = t_dragon_data['lv']
    self.m_dragonExp = t_dragon_data['exp']
    self.m_maxLevel = TableGradeInfo():getValue(t_dragon_data['grade'], 'max_lv')

    self.m_changedLevel = t_dragon_data['lv']
    self.m_changedExp = t_dragon_data['exp']

    self.m_addExp = 0
    self.m_price = 0

    self:clacChangedLevelAndExp()
end

-------------------------------------
-- function modifyMaterial
-------------------------------------
function UI_DragonLevelUpHelper:modifyMaterial(doid)
    if self.m_materialDoidMap[doid] then
        self:deleteMaterial(doid)
    else
        self:addMaterial(doid)
    end
end

-------------------------------------
-- function addMaterial
-------------------------------------
function UI_DragonLevelUpHelper:addMaterial(doid)
    self.m_materialDoidMap[doid] = true
    self.m_materialCount = (self.m_materialCount + 1)

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    local grade = t_dragon_data['grade']
    local lv = t_dragon_data['lv']

    local table_dragon_exp = TableDragonExp()

    self.m_addExp = self.m_addExp + table_dragon_exp:getDragonGivingExp(grade, lv)
    self.m_price = self.m_price + table_dragon_exp:getDragonReqGoldPerMtrl(grade, lv)

    self:clacChangedLevelAndExp()
end

-------------------------------------
-- function deleteMaterial
-------------------------------------
function UI_DragonLevelUpHelper:deleteMaterial(doid)
    self.m_materialDoidMap[doid] = nil
    self.m_materialCount = (self.m_materialCount - 1)

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    local grade = t_dragon_data['grade']
    local lv = t_dragon_data['lv']

    local table_dragon_exp = TableDragonExp()

    self.m_addExp = self.m_addExp - table_dragon_exp:getDragonGivingExp(grade, lv)
    self.m_price = self.m_price - table_dragon_exp:getDragonReqGoldPerMtrl(grade, lv)

    self:clacChangedLevelAndExp()
end


-------------------------------------
-- function clacChangedLevelAndExp
-------------------------------------
function UI_DragonLevelUpHelper:clacChangedLevelAndExp()
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_selectedDoid)
    local grade = t_dragon_data['grade']
    

    local max_level = TableGradeInfo:getMaxLv(grade)

    local table_dragon_exp = TableDragonExp()

    local max_level_table = {}
    for i=1, max_level do
        local lv = i
        max_level_table[i] = table_dragon_exp:getDragonMaxExp(grade, lv)
    end
    
    local remain_exp = self.m_addExp
    self.m_changedLevel = self.m_dragonLevel
    self.m_changedExp = self.m_dragonExp

    while (remain_exp > 0) and (self.m_changedLevel < max_level) do
        local max_exp = max_level_table[self.m_changedLevel]

        if (remain_exp < (max_exp - self.m_changedExp)) then
            self.m_changedExp = (self.m_changedExp + remain_exp)
            remain_exp = 0
        elseif ((max_exp - self.m_changedExp) <= remain_exp) then
            remain_exp = (remain_exp - (max_exp - self.m_changedExp))
            self.m_changedLevel = self.m_changedLevel + 1
            self.m_changedExp = 0
        end
    end

    local max_exp = max_level_table[self.m_changedLevel] 

    if (not max_exp) then
        self.m_expPercentage = 100
    else
        self.m_expPercentage = (self.m_changedExp / max_exp) * 100
    end

    self.m_changedMaxExp = max_exp
end


-------------------------------------
-- function getMaterialCountString
-------------------------------------
function UI_DragonLevelUpHelper:getMaterialCountString()
    return Str('선택재료 {1} / {2}', self.m_materialCount, self.m_maxMaterialCount)
end
