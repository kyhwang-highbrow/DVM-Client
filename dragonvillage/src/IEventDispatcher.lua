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
    if (not self.m_lEventListener[event_name]) then
        self.m_lEventListener[event_name] = {}
    end

    self.m_lEventListener[event_name][listener] = listener

    listener.m_lEventDispatcher[event_name] = self
end

-------------------------------------
-- function removeListener
-------------------------------------
function IEventDispatcher:removeListener(event_name, listener)
    self.m_lEventListener[event_name][listener] = nil
    listener.m_lEventDispatcher[event_name] = nil
end

-------------------------------------
-- function dispatch
-- @brief dispatch를 하는 클래스는 dispatch함수를 오버로딩해서
--        event_name의 항목을 검증하는 코드를 넣도록 한다.
--        event_name에 따른 매개변수를 함수로 적도록 한다.
-------------------------------------
function IEventDispatcher:dispatch(event_name, ...)
    local l_listener = self.m_lEventListener[event_name]
    if (not l_listener) then
        return
    end

    for i,v in pairs(l_listener) do
        local bool = v:onEvent(event_name, ...)
		if bool then return bool end
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













-------------------------------------
-- interface IEventListener
-------------------------------------
IEventListener = {
    m_lEventDispatcher = 'list',
}

-------------------------------------
-- function init
-------------------------------------
function IEventListener:init()
    self.m_lEventDispatcher = {}
end

-------------------------------------
-- function onEvent
-------------------------------------
function IEventListener:onEvent(event_name, ...)
end

-------------------------------------
-- function release
-------------------------------------
function IEventListener:release_listener()
    for event_name, dispatcher in pairs(self.m_lEventDispatcher) do
        dispatcher:removeListener(event_name, self)
    end
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function IEventListener:getCloneTable()
	return clone(IEventListener)
end

-------------------------------------
-- function getCloneClass
-------------------------------------
function IEventListener:getCloneClass()
	return class(clone(IEventListener))
end