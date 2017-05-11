-------------------------------------
-- class ChatIgnoreList
-------------------------------------
ChatIgnoreList = class({
        m_rootTable = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ChatIgnoreList:init()
    self.m_rootTable = nil
end

-------------------------------------
-- function getInstance
-------------------------------------
function ChatIgnoreList:getInstance()
    if g_chatIgnoreList then
        return g_chatIgnoreList
    end
    
    g_chatIgnoreList = ChatIgnoreList()
    g_chatIgnoreList:loadChatIgnoreListFile()

    return g_chatIgnoreList
end

-------------------------------------
-- function getChatIgnoreListSaveFileName
-------------------------------------
function ChatIgnoreList:getChatIgnoreListSaveFileName()
    local file = 'chat_ignore_list.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadChatIgnoreListFile
-------------------------------------
function ChatIgnoreList:loadChatIgnoreListFile()
    local f = io.open(self:getChatIgnoreListSaveFileName(), 'r')

    if f then
        local content = f:read('*all')

        if #content > 0 then
            self.m_rootTable = json_decode(content)
        end
        f:close()
    else
        self.m_rootTable = self:makeDefaultChatIgnoreList()
        self:saveChatIgnoreListFile()
    end
end

-------------------------------------
-- function makeDefaultChatIgnoreList
-------------------------------------
function ChatIgnoreList:makeDefaultChatIgnoreList()
    local root_table = {}
    return root_table
end

-------------------------------------
-- function saveChatIgnoreListFile
-------------------------------------
function ChatIgnoreList:saveChatIgnoreListFile()
    local f = io.open(self:getChatIgnoreListSaveFileName(),'w')
    if (not f) then
        return false
    end

    -- cclog(luadump(self.m_rootTable))
    local content = dkjson.encode(self.m_rootTable, {indent=true})
    f:write(content)
    f:close()

    return true
end

-------------------------------------
-- function clearChatIgnoreListFile
-------------------------------------
function ChatIgnoreList:clearChatIgnoreListFile()
    os.remove(self:getChatIgnoreListSaveFileName())
end


-------------------------------------
-- function addIgnore
-------------------------------------
function ChatIgnoreList:addIgnore(uid, nickname)
    self.m_rootTable[uid] = nickname
    self:saveChatIgnoreListFile()

    UIManager:toastNotificationRed(Str('{1}���� ä���� �����Ͽ����ϴ�.', nickname))
end

-------------------------------------
-- function removeIgnore
-------------------------------------
function ChatIgnoreList:removeIgnore(uid, nickname)
    self.m_rootTable[uid] = nil
    self:saveChatIgnoreListFile()

    UIManager:toastNotificationRed(Str('{1}���� ���������Ͽ����ϴ�.', nickname))
end

-------------------------------------
-- function getIgnoreCount
-------------------------------------
function ChatIgnoreList:getIgnoreCount()
    return table.count(self.m_rootTable)
end

-------------------------------------
-- function getIgnoreList
-------------------------------------
function ChatIgnoreList:getIgnoreList()
    local t_ret = {}

    for uid,nickname in pairs(self.m_rootTable) do
        t_ret[uid] = {['uid']=uid, ['nickname']=nickname}
    end

    return t_ret
end

-------------------------------------
-- function isIgnore
-------------------------------------
function ChatIgnoreList:isIgnore(uid)
    if self.m_rootTable[uid] then
        return true
    else
        return false
    end
end