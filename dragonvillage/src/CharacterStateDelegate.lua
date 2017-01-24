--
-- Character 클래스의 상태를 대리로 수행하는 클래스
-- owner character는 'delegate'상태로 변경시킨 후
-- IStateDelegate가 owner character를 관리하는 시스템
--

-------------------------------------
-- class IStateDelegate
-- @brief
-------------------------------------
IStateDelegate = {
        m_character = 'Character',
     }

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function IStateDelegate:init(file_name, body, ...)    
end

-------------------------------------
-- function initState
-------------------------------------
function IStateDelegate:initState()
    self:addState('dying', IStateDelegate.st_dying, nil, nil, 10)
end

-------------------------------------
-- function st_dying
-------------------------------------
function IStateDelegate.st_dying(owner, dt)
    -- m_character의 StateDelegate를 초기화
    if owner.m_character then
        owner.m_character:restore()

		-- 해제
        if (owner.m_character.m_stateDelegate == owner) then
            owner.m_character:setStateDelegate(nil)
        end
    end
    owner:setOwnerCharacter(nil)
    return true
end

-------------------------------------
-- function setOwnerCharacter
-- @brief 
-------------------------------------
function IStateDelegate:setOwnerCharacter(char)
    local prev = self.m_character

    -- onExit 호출
    if prev and (char == nil) then
        self:onStateDelegateExit()
    end

    self.m_character = char
    
    -- onEnter 호출
    if self.m_character then
        self:onStateDelegateEnter()
    end
end

-------------------------------------
-- function onStateDelegateEnter
-- @brief 
-------------------------------------
function IStateDelegate:onStateDelegateEnter()
    --cclog('##### IStateDelegate:onStateDelegateEnter()')
end

-------------------------------------
-- function onStateDelegateExit
-- @brief 
-------------------------------------
function IStateDelegate:onStateDelegateExit()
    --cclog('##### IStateDelegate:onStateDelegateExit()')
    self.m_character:stopAllActions()
end

-------------------------------------
-- function getCloneTable
-- @brief
-------------------------------------
function IStateDelegate:getCloneTable()
    return clone(IStateDelegate)
end

-------------------------------------
-- function getCloneClass
-- @brief
-------------------------------------
function IStateDelegate:getCloneClass()
    return class(clone(IStateDelegate))
end