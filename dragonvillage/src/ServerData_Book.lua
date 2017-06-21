MAX_DRAGON_RESEARCH_LV = 10

-------------------------------------
-- class ServerData_Book
-------------------------------------
ServerData_Book = class({
        m_serverData = 'ServerData',

        -- 드래곤 콜렉션 데이터(실제 도감 정보)
        m_mBookData = 'map',

        -- 드래곤 원종별 도감
        m_mDragonTypeBookData = 'map',
        -- {
        --   'pinkbell':true,
        --   'jaryong':true,
        --   'powerdragon':true
        -- }

        m_lastChangeTimeStamp = 'timestamp',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Book:init(server_data)
    self.m_serverData = server_data
    self.m_mBookData = {}
    self.m_mDragonTypeBookData = {}
end

-------------------------------------
-- function getBookList
-------------------------------------
function ServerData_Book:getBookList(role_type, attr_type)
    local role_type = (role_type or 'all')
    local attr_type = (attr_type or 'all')

    local table_dragon = TableDragon()

    local l_ret = {}

    for i,v in pairs(table_dragon.m_orgTable) do
        --if (v['test'] ~= 1) then
        if false then

        elseif (role_type ~= 'all') and (role_type ~= v['role']) then

        elseif (attr_type ~= 'all') and (attr_type ~= v['attr']) then

        -- 위 조건들에 해당하지 않은 경우만 추가
        else
            local did = v['did']
            l_ret[did] = v
        end
    end

    return l_ret
end

-------------------------------------
-- function request_BookInfo
-------------------------------------
function ServerData_Book:request_bookInfo(finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        self:response_bookInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/book/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_bookInfo
-------------------------------------
function ServerData_Book:response_bookInfo(ret)
    do -- 드래곤 도감
        for i,v in pairs(ret['book']) do
            local did = tonumber(i)
            local struct_book_data = StructBookData(v)
            struct_book_data:setDragonID(did)

            self.m_mBookData[did] = struct_book_data
        end
    end

    do -- 드래곤 원종별 도감
        self.m_mDragonTypeBookData = ret['dragon_type']
    end

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function openBookPopup
-------------------------------------
function ServerData_Book:openBookPopup(close_cb)
    local function cb()
        local ui = UI_Book()
        ui:setCloseCB(close_cb)
    end

    self:request_bookInfo(cb)
end

-------------------------------------
-- function getBookData
-- @brief
-------------------------------------
function ServerData_Book:getBookData(did)
    -- 정보가 없는 경우 생성
    if (not self.m_mBookData[did]) then
        local struct_book_data = StructBookData()
        struct_book_data:setDragonID(did)
        self.m_mBookData[did] = struct_book_data
    end

    return self.m_mBookData[did]
end

-------------------------------------
-- function isExist
-- @brief 도감에 표시 여부
-------------------------------------
function ServerData_Book:isExist(did)
    local struct_book_data = self:getBookData(did)
    return struct_book_data:isExist()
end

-------------------------------------
-- function isExistDragonType
-- @brief 도감에 표시 여부
-------------------------------------
function ServerData_Book:isExistDragonType(dragon_type)
    if self.m_mDragonTypeBookData[dragon_type] then
        return true
    else
        return false
    end
end

-------------------------------------
-- function setDragonBook
-- @brief 도감에 드래곤 등록
-------------------------------------
function ServerData_Book:setDragonBook(did)
    local struct_book_data = self:getBookData(did)
    struct_book_data:setExist()

    do -- 드래곤 원종의 도감 정보
        local dragon_type = TableDragon():getValue(tonumber(did), 'type')
        if (not self.m_mDragonTypeBookData[dragon_type]) then
            self.m_mDragonTypeBookData[dragon_type] = 0
        end
    end

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
end






-------------------------------------
-- function getRelationPoint
-- @brief 인연포인트
-------------------------------------
function ServerData_Book:getRelationPoint(did)
    local struct_book_data = self:getBookData(did)
    return struct_book_data:getRelation()
end

-------------------------------------
-- function applyRelationPoints
-- @brief 인연포인트
-------------------------------------
function ServerData_Book:applyRelationPoints(relation_point_map)
    for i,v in pairs(relation_point_map) do
        local did = tonumber(i)
        local relation = v

        local struct_book_data = self:getBookData(did)
        struct_book_data:setRelation(relation)
    end

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function request_useRelationPoint
-------------------------------------
function ServerData_Book:request_useRelationPoint(did, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 마지막으로 데이터가 변경된 시간 갱신
        self:setLastChangeTimeStamp()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/relation')
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', did)
    ui_network:setParam('cnt', 1)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end








-------------------------------------
-- function setLastChangeTimeStamp
-- @breif 마지막으로 데이터가 변경된 시간 갱신
-------------------------------------
function ServerData_Book:setLastChangeTimeStamp()
    self.m_lastChangeTimeStamp = Timer:getServerTime()
end

-------------------------------------
-- function getLastChangeTimeStamp
-------------------------------------
function ServerData_Book:getLastChangeTimeStamp()
    return self.m_lastChangeTimeStamp
end

-------------------------------------
-- function checkChange
-------------------------------------
function ServerData_Book:checkChange(timestamp)
    if (self.m_lastChangeTimeStamp ~= timestamp) then
        return true
    end

    return false
end
