-------------------------------------
-- class ServerData_Runes
-------------------------------------
ServerData_Runes = class({
        m_serverData = 'ServerData',
        m_mRuneObjects = 'map',
        m_runeCount = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Runes:init(server_data)
    self.m_serverData = server_data
    self.m_mRuneObjects = {}
    self.m_runeCount = 0
end

-------------------------------------
-- function request_runesInfo
-- @breif
-------------------------------------
function ServerData_Runes:request_runesInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 룬 강화 테이블
        TABLE:setServerTable('table_rune_enhance', ret['table_rune_enhance'])

        -- 룬 등급 테이블
        TABLE:setServerTable('table_rune_grade', ret['table_rune_grade'])

        -- 보유 중인 룬 정보를 받아옴
        self:applyRuneData_list(ret['runes'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function applyRuneData
-- @breif 룬 오브젝트 적용 (추가, 갱신)
-------------------------------------
function ServerData_Runes:applyRuneData(t_rune_data)
    local roid = t_rune_data['id']

    -- 추가일 경우 count 증가
    if (not self.m_mRuneObjects[roid]) then
        self.m_runeCount = (self.m_runeCount + 1)
    end

    -- 룬 정보의 관리를 위해 StructRuneObject클래스로 래핑하여 사용
    self.m_mRuneObjects[roid] = StructRuneObject(t_rune_data)
end

-------------------------------------
-- function applyRuneData_list
-- @breif 룬 오브젝트 적용 (추가, 갱신)
-------------------------------------
function ServerData_Runes:applyRuneData_list(l_rune_data)
    for i,v in pairs(l_rune_data) do
        self:applyRuneData(v)
    end
end

-------------------------------------
-- function deleteRuneData
-- @breif 룬 오브젝트 삭제
-------------------------------------
function ServerData_Runes:deleteRuneData(roid)
    -- 삭제일 경우 count 감소
    if (self.m_mRuneObjects[roid]) then
        self.m_runeCount = (self.m_runeCount - 1)
        self.m_mRuneObjects[roid] = nil
    end
end

-------------------------------------
-- function deleteRuneData_list
-- @breif 룬 오브젝트 삭제
-------------------------------------
function ServerData_Runes:deleteRuneData_list(l_roid)
    for i,v in pairs(l_roid) do
        self:deleteRuneData(v)
    end
end