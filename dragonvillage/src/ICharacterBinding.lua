-------------------------------------
-- interface ICharacterBinding
-------------------------------------
ICharacterBinding = {
    m_classDef      = '',

    m_parentChar    = 'Character',
    m_lChildChar    = 'table',
}

-------------------------------------
-- function init
-------------------------------------
function ICharacterBinding:init()
    self.m_parentChar = nil
    self.m_lChildChar = {}

    self.m_bUseBinding = true

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
-- function removeAllChildCharacter
-------------------------------------
function ICharacterBinding:removeAllChildCharacter()
    for _, child in ipairs(self.m_lChildChar) do
        child:setParentCharacter(nil)
    end

    self.m_lChildChar = {}
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