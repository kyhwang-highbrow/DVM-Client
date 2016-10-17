

-------------------------------------
-- function addDamagedEventListener
-------------------------------------
function Character:addDamagedEventListener(listener)
    if (not self.m_damagedEventListener) then
        self.m_damagedEventListener = {}
    end

    self.m_damagedEventListener[listener] = listener
end

-------------------------------------
-- function removeDamagedEventListener
-------------------------------------
function Character:removeDamagedEventListener(listener)
    if (not self.m_damagedEventListener) then
        return
    end

    self.m_damagedEventListener[listener] = nil
end

-------------------------------------
-- function damagedEvent
-------------------------------------
function Character:damagedEvent(char, damage)
    if (not self.m_damagedEventListener) then
        return
    end

    for i,v in pairs(self.m_damagedEventListener) do
        v:damagedEventCB(char, damage)
    end
end