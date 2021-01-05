-------------------------------------
-- class ServerData_RuneMemo
-- @comment 서버 데이터가 아닌 로컬 데이터를 사용함
-- g_runeMemoData
-------------------------------------
ServerData_RuneMemo = class({
        m_serverData = 'ServerData',
        ----------------------------------------------
        m_mRuneMemoMap = 'map', -- map[roid] = string
        m_bDirty = 'boolean',
        ----------------------------------------------
    })

RUNE_MEMO_MIN_LENGTH = 0
RUNE_MEMO_MAX_LENGTH = 40

-------------------------------------
-- function init
-------------------------------------
function ServerData_RuneMemo:init(server_data)
    self.m_serverData = server_data
    
    self.m_bDirty = false

    -- g_runesData에서 룬 정보 받은 뒤 룬 메모 파일 읽고, 현재 가지고 있지 않은 룬 아이디 정보 삭제
    -- self:loadRuneMemoMap()
end

-------------------------------------
-- function getRuneMemoMapFileName
-------------------------------------
function ServerData_RuneMemo:getRuneMemoMapFileName()
    local file = 'rune_memo.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadRuneMemoMap
-------------------------------------
function ServerData_RuneMemo:loadRuneMemoMap()
    self.m_mRuneMemoMap = {}

    local ret_rune_memo, success_load = LoadLocalSaveJson(self:getRuneMemoMapFileName())

    if (success_load) then
        self.m_mRuneMemoMap = ret_rune_memo
	end

	-- 변수 선언
	local runes_map = g_runesData:getRuneList()

    -- 룬 정보가 없는 경우 메모 삭제
	for roid, _ in pairs(self.m_mRuneMemoMap) do
        local t_rune_data = g_runesData:getRuneObject(roid)
		if (t_rune_data == nil) then
			self.m_mRuneMemoMap[roid] = nil
            self.m_bDirty = true
		end
	end

    self:saveRuneMemoMap()
end

-------------------------------------
-- function saveRuneMemoMap
-------------------------------------
function ServerData_RuneMemo:saveRuneMemoMap()
	if (self.m_bDirty) then
		SaveLocalSaveJson(self:getRuneMemoMapFileName(), self.m_mRuneMemoMap)
		self.m_bDirty = false
	end
end

-------------------------------------
-- function modifyMemo
-------------------------------------
function ServerData_RuneMemo:modifyMemo(roid, memo)
    if (memo == '') then 
        memo = nil
    end

    self.m_mRuneMemoMap[roid] = memo
    self.m_bDirty = true
end

-------------------------------------
-- function getMemo
-- @return 없는 경우, nil을 반환할 수 있음
-------------------------------------
function ServerData_RuneMemo:getMemo(roid)
	local memo = self.m_mRuneMemoMap[roid]

    return memo
end

-------------------------------------
-- function clearRuneMemoFile
-------------------------------------
function ServerData_RuneMemo:clearRuneMemoFile()
	-- 룬 메모 정보 삭제
	local path = self:getRuneMemoMapFileName()
	os.remove(path)
end

-------------------------------------
-- function validateMemoText
-- @brief 메모 내용이 적절한지 판단
-- @return 
-------------------------------------
function ServerData_RuneMemo:validateMemoText(context)
	local is_valid = true

    local valid_text = context

	local str_len = uc_len(valid_text)

	-- 최대 글자는 경고 후 넘치는 부분 삭제
	if (str_len > RUNE_MEMO_MAX_LENGTH) then
		UIManager:toastNotificationGreen(Str('최대 글자수(40자)를 초과했어요!'))
		valid_text = utf8_sub(valid_text, RUNE_MEMO_MAX_LENGTH)
	end

	return valid_text, is_valid
end