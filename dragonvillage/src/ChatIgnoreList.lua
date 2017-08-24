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
    local ret_json, success_load = LoadLocalSaveJson(self:getChatIgnoreListSaveFileName())

    if (success_load == true) then
        self.m_rootTable = ret_json
        if (not self.m_rootTable['user_list']) then
            self.m_rootTable = self:makeDefaultChatIgnoreList()
            self:saveChatIgnoreListFile()
        end
        return
    end

    self.m_rootTable = self:makeDefaultChatIgnoreList()
    self:saveChatIgnoreListFile()
end

-------------------------------------
-- function makeDefaultChatIgnoreList
-------------------------------------
function ChatIgnoreList:makeDefaultChatIgnoreList()
    local root_table = {}
    root_table['user_list'] = {} -- 차단 유저 리스트
    root_table['global_ignore'] = false -- 채팅 전체 무시
    return root_table
end

-------------------------------------
-- function saveChatIgnoreListFile
-------------------------------------
function ChatIgnoreList:saveChatIgnoreListFile()
    return SaveLocalSaveJson(self:getChatIgnoreListSaveFileName(), self.m_rootTable)
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
    if (self:getIgnoreCount() >= 30) then
        UIManager:toastNotificationRed(Str('최대 {1}명 까지 차단이 가능합니다.', 30))
        return
    end

    self.m_rootTable['user_list'][uid] = nickname
    self:saveChatIgnoreListFile()

    UIManager:toastNotificationRed(Str('{1}님의 채팅을 차단하였습니다.', nickname))
end

-------------------------------------
-- function removeIgnore
-------------------------------------
function ChatIgnoreList:removeIgnore(uid, nickname)
    self.m_rootTable['user_list'][uid] = nil
    self:saveChatIgnoreListFile()

    UIManager:toastNotificationRed(Str('{1}님의 차단해제하였습니다.', nickname))
end

-------------------------------------
-- function getIgnoreCount
-------------------------------------
function ChatIgnoreList:getIgnoreCount()
    return table.count(self.m_rootTable['user_list'])
end

-------------------------------------
-- function getIgnoreList
-------------------------------------
function ChatIgnoreList:getIgnoreList()
    local t_ret = {}

    for uid,nickname in pairs(self.m_rootTable['user_list']) do
        t_ret[uid] = {['uid']=uid, ['nickname']=nickname}
    end

    return t_ret
end

-------------------------------------
-- function isIgnore
-------------------------------------
function ChatIgnoreList:isIgnore(uid)
    if self.m_rootTable['user_list'][uid] then
        return true
    else
        return false
    end
end

-------------------------------------
-- function setGlobalIgnore
-------------------------------------
function ChatIgnoreList:setGlobalIgnore(ignore)
    self.m_rootTable['global_ignore'] = ignore
    self:saveChatIgnoreListFile()

    if (ignore) then
        UIManager:toastNotificationRed(Str('채팅을 비활성화하였습니다.'))
    else
        UIManager:toastNotificationRed(Str('채팅을 활성화하였습니다.'))
    end
end

-------------------------------------
-- function isGlobalIgnore
-------------------------------------
function ChatIgnoreList:isGlobalIgnore()
    return self.m_rootTable['global_ignore']
end