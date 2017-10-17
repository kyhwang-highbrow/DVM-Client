--[[

Character 클래스의 상태를 대리로 수행하는 클래스
owner character는 'delegate'상태로 변경시킨 후
IStateDelegate가 owner character를 관리하는 시스템
스킬에 붙어 동작하며 스킬에 있는 함수를 덮어씌우면서 자동으로 동작한다.

]]

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
-- function onDelay
-- @breif Skill class에 붙을 경우 st_delay 에서 자동으로 동작
-------------------------------------
function IStateDelegate:onDelay(char)
	-- 등록
	char:setStateDelegate(self)                                   
end

-------------------------------------
-- function onDying
-- @breif Skill class에 붙을 경우 st_dying 에서 자동으로 동작
-------------------------------------
function IStateDelegate:onDying()
	-- 해제
	if (self.m_character) then
		self.m_character:setStateDelegate(nil)
	end
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