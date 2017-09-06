-------------------------------------
-- class SpineCacheManager
-------------------------------------
SpineCacheManager = class({
        m_refCntMap = 'table',
        m_totalNumber = 'number',
        m_validNumber = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SpineCacheManager:init()
    self.m_refCntMap = {}
    self.m_totalNumber = 0
    self.m_validNumber = 0
end

-------------------------------------
-- function getInstance
-------------------------------------
function SpineCacheManager:getInstance()
    if g_spineCacheManager then
        return g_spineCacheManager
    end
    
    g_spineCacheManager = SpineCacheManager()

    return g_spineCacheManager
end

-------------------------------------
-- function registerSpineAnimator
-------------------------------------
function SpineCacheManager:registerSpineAnimator(spine_animator)
    local node = spine_animator.m_node
    if (not node) then
        return
    end

    local cache_name = spine_animator.m_cacheName
    if (not cache_name) then
        return
    end

    local function node_event_handler(event)
        if (event == 'enter') then
            self:incRef(cache_name)

        elseif (event == 'exit') then
            self:decRef(cache_name)
        end
    end

    node:registerScriptHandler(node_event_handler)
end

-------------------------------------
-- function incRef
-------------------------------------
function SpineCacheManager:incRef(cache_name)
    if (not self.m_refCntMap[cache_name]) then
        self.m_refCntMap[cache_name] = 0
        self.m_totalNumber = (self.m_totalNumber + 1)
    end

    if (self.m_refCntMap[cache_name] == 0) then
        self.m_validNumber = (self.m_validNumber + 1)
    end

    self.m_refCntMap[cache_name] = (self.m_refCntMap[cache_name] + 1)
    self:onChange()
end

-------------------------------------
-- function decRef
-------------------------------------
function SpineCacheManager:decRef(cache_name)
    if (not self.m_refCntMap[cache_name]) then
        return
    end

    if (self.m_refCntMap[cache_name] == 1) then
        self.m_validNumber = (self.m_validNumber - 1)
    end

    self.m_refCntMap[cache_name] = (self.m_refCntMap[cache_name] - 1)
    self:onChange()
end

-------------------------------------
-- function onChange
-------------------------------------
function SpineCacheManager:onChange()
    if (not IS_TEST_MODE()) then
        return
    end

    cclog('###################################')
    cclog('## SpineCacheManager:onChange()  ##')
    cclog('## total : ' .. self.m_totalNumber)
    cclog('## valid : ' .. self.m_validNumber)
    cclog('###################################')
end

-------------------------------------
-- function purgeSpineCacheData
-------------------------------------
function SpineCacheManager:purgeSpineCacheData()
    local t_remove_key = {}

    for name,cnt in pairs(self.m_refCntMap) do
        if (cnt == 0) then
            sp.SkeletonAnimation:removeCache(name)
            table.insert(t_remove_key, name)
            self.m_totalNumber = (self.m_totalNumber - 1)
        end
    end

    for _,name in ipairs(t_remove_key) do
        self.m_refCntMap[name] = nil
        local _name = string.gsub(name, '.json', '.png')
        local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(_name)
        texture:release()
        --cc.Director:getInstance():getTextureCache():removeTextureForKey(_name)
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    self:onChange()
end

-------------------------------------
-- function clean
-------------------------------------
function SpineCacheManager:clean()
    self:purgeSpineCacheData()

    self.m_refCntMap = {}
    self.m_totalNumber = 0
    self.m_validNumber = 0
    sp.SkeletonAnimation:removeCacheAll()
end

-------------------------------------
-- function purgeSpineCacheData_checkNumber
-------------------------------------
function SpineCacheManager:purgeSpineCacheData_checkNumber()
    local invalid_cnt = (self.m_totalNumber - self.m_validNumber)
    if (invalid_cnt < 5) then
        return
    end

    self:purgeSpineCacheData()
end