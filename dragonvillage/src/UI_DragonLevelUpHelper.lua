-------------------------------------
-- class UI_DragonLevelUpHelper
-------------------------------------
UI_DragonLevelUpHelper = class({
        m_selectedDoid = 'string',
        m_selectedDragonAttr = '',
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
    local dragon_object = g_dragonsData:getDragonObject(self.m_selectedDoid)
    self.m_selectedDragonAttr = dragon_object:getAttr()


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
    local object_type, exp, price = self:getMaterialInfo(doid)

    self.m_materialDoidMap[doid] = object_type
    self.m_materialCount = (self.m_materialCount + 1)

    self.m_addExp = self.m_addExp + exp
    self.m_price = self.m_price + price

    self:clacChangedLevelAndExp()
end

-------------------------------------
-- function deleteMaterial
-------------------------------------
function UI_DragonLevelUpHelper:deleteMaterial(doid)
    local object_type, exp, price = self:getMaterialInfo(doid)

    self.m_materialDoidMap[doid] = nil
    self.m_materialCount = (self.m_materialCount - 1)

    self.m_addExp = self.m_addExp - exp
    self.m_price = self.m_price - price

    self:clacChangedLevelAndExp()
end

-------------------------------------
-- function addExp
-------------------------------------
function UI_DragonLevelUpHelper:addExp(exp)
    self.m_addExp = self.m_addExp + exp

    self:clacChangedLevelAndExp()
end

-------------------------------------
-- function getMaterialInfo
-------------------------------------
function UI_DragonLevelUpHelper:getMaterialInfo(oid)
    local dragon_object = g_dragonsData:getDragonObject(oid)

    local object_type = dragon_object.m_objectType

    local exp
    local price

    local exp_table = nil
    if (object_type == 'dragon') then
        exp_table = TableDragonExp()

    elseif (object_type == 'slime') then
        exp_table = TableSlimeExp()

        -- 슬라임 테이블에 경험치과 가격 정보가 있으면 우선 적용
        exp, price = TableSlime:getGivingExpInfo(dragon_object['slime_id'])
    end

    if (not exp) and (not price) then
        local grade = dragon_object['grade']
        local lv = dragon_object['lv']
        exp = exp_table:getDragonGivingExp(grade, lv)
        price = exp_table:getDragonReqGoldPerMtrl(grade, lv)
    end
    
    -- 동일 속성은 50% 추가 경험치
    if (self.m_selectedDragonAttr == dragon_object:getAttr()) then
        exp = (exp * 1.5)
    end

    return object_type, exp, price
end

-------------------------------------
-- function clacChangedLevelAndExp
-------------------------------------
function UI_DragonLevelUpHelper:clacChangedLevelAndExp()
    local t_dragon_data = g_dragonsData:getDragonObject(self.m_selectedDoid)
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
    max_exp = tonumber(max_exp)

    if (not max_exp) then
        self.m_expPercentage = 100
    else
        self.m_expPercentage = (self.m_changedExp / max_exp) * 100
    end

    self.m_changedMaxExp = max_exp

    do -- 최대 레벨 체크
        if (self.m_maxLevel <= self.m_changedLevel) then
            self.m_changedExp = max_level_table[self.m_maxLevel - 1] 
            self.m_changedMaxExp = self.m_changedExp
            self.m_expPercentage = 100
        end
    end
end


-------------------------------------
-- function getMaterialCountString
-------------------------------------
function UI_DragonLevelUpHelper:getMaterialCountString()
    return Str('선택재료 {1} / {2}', self.m_materialCount, self.m_maxMaterialCount)
end

-------------------------------------
-- function isCanAdd
-------------------------------------
function UI_DragonLevelUpHelper:isCanAdd()
    -- 재료 갯수 초과
    if (self.m_materialCount >= self.m_maxMaterialCount) then
        return false, 'max_cnt'
    end

    -- 등급(구간)별 최대 레벨로 인해 추가할 수 없음
    if (self.m_changedLevel >= self.m_maxLevel) then
        return false, 'max_lv'
    end

    return true
end


-------------------------------------
-- function isSelectedDragon
-------------------------------------
function UI_DragonLevelUpHelper:isSelectedDragon(doid)
    if (self.m_materialDoidMap[doid]) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getPlusLevel
-------------------------------------
function UI_DragonLevelUpHelper:getPlusLevel()
    return (self.m_changedLevel - self.m_dragonLevel)
end

