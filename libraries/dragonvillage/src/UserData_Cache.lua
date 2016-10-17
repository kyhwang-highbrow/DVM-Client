-------------------------------------
-- function setCache
-------------------------------------
function UserData:setCache(key, value)
    self.m_cache[key] = value
end

-------------------------------------
-- function getCache
-------------------------------------
function UserData:getCache(key)
    return self.m_cache[key]
end

-------------------------------------
-- function removeCache
-------------------------------------
function UserData:removeCache(key)
    self.m_cache[key] = nil
end