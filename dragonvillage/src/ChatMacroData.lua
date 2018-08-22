-------------------------------------
-- class ChatMacroData
-------------------------------------
ChatMacroData = class({
        m_rootTable = 'table',
        m_rootTableDefault = 'table',

        m_nLockCnt = 'number',
        m_bDirtyDataTable = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ChatMacroData:init()
    self.m_rootTable = nil
    self.m_rootTableDefault = nil
    self.m_nLockCnt = 0
    self.m_bDirtyDataTable = false
end

-------------------------------------
-- function getInstance
-------------------------------------
function ChatMacroData:getInstance()
    if g_chatMacroData then
        return g_chatMacroData
    end
    
    g_chatMacroData = ChatMacroData()
    g_chatMacroData:loadChatMacroDataFile()

    return g_chatMacroData
end

-------------------------------------
-- function getChatMacroDataSaveFileName
-------------------------------------
function ChatMacroData:getChatMacroDataSaveFileName()
    local file = 'chat_macro_data.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadChatMacroDataFile
-------------------------------------
function ChatMacroData:loadChatMacroDataFile()
    local ret_json, success_load = LoadLocalSaveJson(self:getChatMacroDataSaveFileName())

    if (success_load == true) then
        self.m_rootTable = ret_json
    else
        self.m_rootTable = self:makeDefaultData()
        self:saveChatMacroDataFile()
    end

    self.m_rootTableDefault = self:makeDefaultData()
end

-------------------------------------
-- function makeDefaultData
-------------------------------------
function ChatMacroData:makeDefaultData()
    local root_table = {
        ['chat_macro'] = {}
    }
    local lang = Translate:getGameLang()
	
	local macro_ = ''

	if (lang == 'ko') then
		macro_ = '매크로'
	elseif (lang == 'en') then
		macro_ = 'macro'
	elseif (lang == 'ja') then
		macro_ = 'マクロ'
	elseif (lang == 'zh') then
		macro_ = '巨集'

	-- 태국어, 스페인어 준비 안됨 나중에 추가하자..
	else
		macro_ = 'macro'
    end
	for i = 1, 10 do
        table.insert(root_table['chat_macro'], {['idx'] = i, ['macro'] = macro_ .. i})
    end
    return root_table
end

-------------------------------------
-- function saveChatMacroDataFile
-------------------------------------
function ChatMacroData:saveChatMacroDataFile()
    if (self.m_nLockCnt > 0) then
        self.m_bDirtyDataTable = true
        return
    end

    return SaveLocalSaveJson(self:getChatMacroDataSaveFileName(), self.m_rootTable)
end

-------------------------------------
-- function clearChatMacroDataFile
-------------------------------------
function ChatMacroData:clearChatMacroDataFile()
    os.remove(self:getChatMacroDataSaveFileName())
end


-------------------------------------
-- function applyChatMacroData
-------------------------------------
function ChatMacroData:applyChatMacroData(data, ...)
    local args = {...}
    local cnt = #args

    local dirty = false

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                container[key] = {}
                dirty = true
            end
            container = container[key]
        else
            if (container[key] ~= data) then
                if (data ~= nil) then
                    container[key] = clone(data)
                else
                    container[key] = nil
                end
                dirty = true
            end
        end
    end

    -- 변경사항이 있을 때에만 저장
    if dirty then
        self:saveChatMacroDataFile()
    end
end

-------------------------------------
-- function getFunc
-- @brief
-------------------------------------
function ChatMacroData:getFunc(target_table, ...)
    return LocalData:getFunc(target_table, ...)
end

-------------------------------------
-- function get
-- @brief
-------------------------------------
function ChatMacroData:get(...)
    local ret = self:getFunc(self.m_rootTable, ...)

    if (ret == nil) then
        return self:getFunc(self.m_rootTableDefault, ...)
    end

    return ret
end

-------------------------------------
-- function getRef
-- @brief
-------------------------------------
function ChatMacroData:getRef(...)
    local args = {...}
    local cnt = #args

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return container[key]
            end
        end
    end

    return nil
end

-------------------------------------
-- function lockSaveData
-- @breif
-------------------------------------
function ChatMacroData:lockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt + 1)
end

-------------------------------------
-- function unlockSaveData
-- @breif
-------------------------------------
function ChatMacroData:unlockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt -1)

    if (self.m_nLockCnt <= 0) then
        if self.m_bDirtyDataTable then
            self:saveChatMacroDataFile()
        end
        self.m_bDirtyDataTable = false
    end
end


-------------------------------------
-- function setMacro
-- @breif
-------------------------------------
function ChatMacroData:setMacro(idx, macro)
	self:applyChatMacroData({['idx'] = idx, ['macro'] = macro}, 'chat_macro', idx)
end

-------------------------------------
-- function getLang
-- @breif
-------------------------------------
function ChatMacroData:getMacroTable()
	return self:get('chat_macro')
end
