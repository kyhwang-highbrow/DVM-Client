CHARACTER_BINDING_FLAG_KEY = {
    USE_PARENT_POS = 1,
    USE_PARENT_HP = 2,
}

-------------------------------------
-- interface ICharacterBinding
-------------------------------------
ICharacterBinding = {
    m_classDef      = '',

    m_parentChar    = 'Character',
    m_lChildChar    = 'table',

    m_mBindingFlag  = 'table',
}

-------------------------------------
-- function init
-------------------------------------
function ICharacterBinding:init()
    self.m_parentChar = nil
    self.m_lChildChar = {}
    self.m_mBindingFlag = {}

    -- 기본 설정
    self:setBindingFlag(CHARACTER_BINDING_FLAG_KEY.USE_PARENT_POS)
    self:setBindingFlag(CHARACTER_BINDING_FLAG_KEY.USE_PARENT_HP)

    self:initCharacterBinding()
end

-------------------------------------
-- function initCharacterBinding
-- @brief 바인딩 관련 초기값 지정(m_classDef은 반드시 설정되어야함)
-- @override
-------------------------------------
function ICharacterBinding:initCharacterBinding()
end

-------------------------------------
-- function onUpdateParentCharacterPos
-- @brief 부모의 위치 정보가 갱신 되었을 경우 호출
-- @override
-------------------------------------
function ICharacterBinding:onUpdateParentCharacterPos()
end

-------------------------------------
-- function setParentCharacter
-------------------------------------
function ICharacterBinding:setParentCharacter(parent)
    self.m_parentChar = parent
end

-------------------------------------
-- function addChildCharacter
-------------------------------------
function ICharacterBinding:addChildCharacter(child)
    if (table.find(self.m_lChildChar, child)) then
        return
    end

    child:setParentCharacter(self)

    table.insert(self.m_lChildChar, child)
end

-------------------------------------
-- function removeChildCharacter
-------------------------------------
function ICharacterBinding:removeChildCharacter(child)
    local idx = table.find(self.m_lChildChar, child)
    if (not idx) then
        return
    end

    child:setParentCharacter(nil)

    table.remove(self.m_lChildChar, idx)
end

-------------------------------------
-- function setDamage
-------------------------------------
function ICharacterBinding:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    local bApplyDamage

    if (self.m_parentChar and self:isSettedBindingFlag(CHARACTER_BINDING_FLAG_KEY.USE_PARENT_HP)) then
        -- 부모에게 데미지를 준다
        bApplyDamage = self.m_parentChar:setDamage(attacker, self.m_parentChar, i_x, i_y, damage, t_info)

    elseif (self.m_classDef) then
        bApplyDamage = self.m_classDef.setDamage(self, attacker, defender, i_x, i_y, damage, t_info)

    end

    return bApplyDamage
end

-------------------------------------
-- function setPosition
-------------------------------------
function ICharacterBinding:setPosition(x, y)
    if (self.m_classDef) then
        self.m_classDef.setPosition(self, x, y)
    end

    for _, child in ipairs(self.m_lChildChar) do
        if (child:isSettedBindingFlag(CHARACTER_BINDING_FLAG_KEY.USE_PARENT_POS)) then
            child:onUpdateParentCharacterPos()
        end
    end
end

-------------------------------------
-- function setBindingFlag
-------------------------------------
function ICharacterBinding:setBindingFlag(key)
    self.m_mBindingFlag[key] = true
end

-------------------------------------
-- function isSettedBindingFlag
-------------------------------------
function ICharacterBinding:isSettedBindingFlag(key)
    local b = self.m_mBindingFlag[key] or false
    return b
end

-------------------------------------
-- function getCloneTable
-- @brief
-------------------------------------
function ICharacterBinding:getCloneTable()
    return clone(ICharacterBinding)
end

-------------------------------------
-- function getCloneClass
-- @brief
-------------------------------------
function ICharacterBinding:getCloneClass()
    return class(clone(ICharacterBinding))
end