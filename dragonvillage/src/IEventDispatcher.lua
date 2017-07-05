-------------------------------------
-- interface IEventDispatcher
-------------------------------------
IEventDispatcher = {
    m_lEventListener = 'list',
}

-------------------------------------
-- function init
-------------------------------------
function IEventDispatcher:init()
    self.m_lEventListener = {}
end

-------------------------------------
-- function addListener
-------------------------------------
function IEventDispatcher:addListener(event_name, listener)
    if (not listener) then return end

    if (not self.m_lEventListener[event_name]) then
        self.m_lEventListener[event_name] = {}
    end
    self.m_lEventListener[event_name][listener] = listener

    if (not listener.m_lEventDispatcher[event_name]) then
        listener.m_lEventDispatcher[event_name] = {}
    end
    listener.m_lEventDispatcher[event_name][self] = self
end

-------------------------------------
-- function removeListener
-------------------------------------
function IEventDispatcher:removeListener(event_name, listener)
    if (not listener) then return end

    if (not self.m_lEventListener[event_name]) then
        error('removeListener no event_name : ' .. event_name)
    end
    self.m_lEventListener[event_name][listener] = nil

    if (listener.m_lEventDispatcher[event_name]) then
        listener.m_lEventDispatcher[event_name][self] = nil 
    end
end

-------------------------------------
-- function dispatch
-- @brief dispatch를 하는 클래스는 dispatch함수를 오버로딩해서
--        event_name의 항목을 검증하는 코드를 넣도록 한다.
--        event_name에 따른 매개변수를 함수로 적도록 한다.
-------------------------------------
function IEventDispatcher:dispatch(event_name, t_event, ...)
    local l_listener = self.m_lEventListener[event_name]
    if (not l_listener) then
        return
    end

    for i,v in pairs(l_listener) do
        v:onEvent(event_name, t_event, ...)
    end
end

-------------------------------------
-- function release_EventDispatcher
-------------------------------------
function IEventDispatcher:release_EventDispatcher()
    for event_name, listeners in pairs(self.m_lEventListener) do
        for i,listener in pairs(listeners) do
            self:removeListener(event_name, listener)
        end
    end
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function IEventDispatcher:getCloneTable()
	return clone(IEventDispatcher)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function IEventDispatcher:getCloneClass()
	return class(clone(IEventDispatcher))
end