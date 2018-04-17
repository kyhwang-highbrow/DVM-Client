-------------------------------------
-- interface ICharacterBinding
-------------------------------------
ICharacterBinding = {
    m_parentChar    = 'Character',
    m_lChildChar    = 'table',

    m_bodyKey       = 'number', -- 부모(m_parentChar)가 존재하는 경우 대응되는 부모의 body key
}

-------------------------------------
-- function init
-------------------------------------
function ICharacterBinding:init()
    self.m_parentChar = nil
    self.m_lChildChar = {}
    self.m_bodyKey = nil

    self.m_bUseBinding = true
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