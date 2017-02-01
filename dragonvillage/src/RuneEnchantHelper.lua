-------------------------------------
-- class RuneEnchantHelper
-- @breif 보유하
-------------------------------------
RuneEnchantHelper = class({
        m_tRuneData = 'table',
        m_mMaterialRuneData = 'map[roid]',

        m_materialCnt = 'number',       -- 재료 갯수
        m_enchantReqGold = 'number',    -- 강화에 필요한 골드
        m_exp = 'number',               -- 경험치

        -- private
        m_tableRuneGrade = 'TableRuneGrade',
    })

-------------------------------------
-- function init
-------------------------------------
function RuneEnchantHelper:init(t_rune_data)
    self.m_tRuneData = t_rune_data
    self.m_mMaterialRuneData = {}

    self.m_materialCnt = 0
    self.m_enchantReqGold = 0
    self.m_exp = 0

    -- private
    self.m_tableRuneGrade = TableRuneGrade()
end

-------------------------------------
-- function addRuneEnchantMaterial
-------------------------------------
function RuneEnchantHelper:addRuneEnchantMaterial(t_rune_data)
    local roid = t_rune_data['id']

    if (self.m_mMaterialRuneData[roid]) then
        return
    end

    self.m_mMaterialRuneData[roid] = t_rune_data
    self.m_materialCnt = (self.m_materialCnt + 1)

    do -- 강화에 필요한 골드 가격 합산
        local grade = t_rune_data['grade']
        local req_gold = self.m_tableRuneGrade:getValue(grade, 'req_gold')
        self.m_enchantReqGold = (self.m_enchantReqGold + req_gold)
    end

    do -- 경험치
        local rid = t_rune_data['rid']
        local exp = TableRune:getMaterialExp(rid)
        self.m_exp = (self.m_exp + exp)
    end

    self:print()
end

-------------------------------------
-- function removeRuneEnchantMaterial
-------------------------------------
function RuneEnchantHelper:removeRuneEnchantMaterial(roid)
    local t_rune_data = self.m_mMaterialRuneData[roid]

    if (self.m_mMaterialRuneData[roid]) then
        self.m_mMaterialRuneData[roid] = nil
        self.m_materialCnt = (self.m_materialCnt - 1)
    end    

    do -- 강화에 필요한 골드 가격 합산
        local grade = t_rune_data['grade']
        local req_gold = self.m_tableRuneGrade:getValue(grade, 'req_gold')
        self.m_enchantReqGold = (self.m_enchantReqGold - req_gold)
    end

    do -- 경험치
        local rid = t_rune_data['rid']
        local exp = TableRune:getMaterialExp(rid)
        self.m_exp = (self.m_exp - exp)
    end

    self:print()
end

-------------------------------------
-- function getRuneEnchantRequestParams
-- @brief 서버에 강화요청을 할 때 필요한 parameter 리턴
-------------------------------------
function RuneEnchantHelper:getRuneEnchantRequestParams()

    -- 강화를 할 룬의 object id
    local roid = self.m_tRuneData['id']

    -- 재료로 사용될 룬의 object id(,로 분리)
    local src_roids = ''
    for i,v in pairs(self.m_mMaterialRuneData) do
        if (src_roids ~= '') then
            src_roids = src_roids .. ','
        end

        src_roids = src_roids .. i
    end

    return roid, src_roids
end

-------------------------------------
-- function print
-------------------------------------
function RuneEnchantHelper:print()
    if true then
        return
    end
    cclog('gold : ' .. self.m_enchantReqGold)
    cclog('cnt : ' .. self.m_materialCnt)
end