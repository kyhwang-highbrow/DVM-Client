-------------------------------------
-- class ClassScriptCache
-------------------------------------
ClassScriptCache = class({
    m_tScript = 'table'
})

-------------------------------------
-- function init
-------------------------------------
function ClassScriptCache:init()
	self:clear()
end

-------------------------------------
-- function get
-------------------------------------
function ClassScriptCache:get(name, extention, remove_comment)
    if (isWin32() or self.m_tScript[name] == nil) then
		--cclog('########## loading ', name)
		local json_table = TABLE:loadJsonTable(name, extention, remove_comment)
		if (json_table) then
		    self.m_tScript[name] = json_table
        end
        --cclog('########## load success ', name)
    end

    return self.m_tScript[name]
end

-------------------------------------
-- function clear
-------------------------------------
function ClassScriptCache:clear()
    self.m_tScript = {}
end

ScriptCache = ClassScriptCache()