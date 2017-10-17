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
function IEventListener:onEvent(event_name, t_event, ...)
end

-------------------------------------
-- function release_EventListener
-------------------------------------
function IEventListener:release_EventListener()
    for event_name, v in pairs(self.m_lEventDispatcher) do
        for k, dispatcher in pairs(v) do
            dispatcher:removeListener(event_name, self)
        end
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