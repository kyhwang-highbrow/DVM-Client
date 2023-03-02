-------------------------------------
-- class ServerData_DragonSkin
-------------------------------------
ServerData_DragonSkin = class({
    m_serverData = 'ServerData',
    m_shopInfo = 'map',
    m_saleInfo = 'map',
    m_bDirtyCostumeInfo = 'bool', -- 코스튬 구매로 인해 갱신이 필요한지 여부
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonSkin:init(server_data)
    self.m_serverData = server_data
    self.m_shopInfo = {}
    self.m_saleInfo = {}
    self.m_bDirtyCostumeInfo = false
end

-------------------------------------
-- function getSkinID
-- @brief 코스튬 ID 반환
-------------------------------------
function ServerData_DragonSkin:getSkinID(did)
	local tamer_id = did or g_tamerData:getCurrTamerID()
    local costume_id
    if (g_tamerData.m_mTamerMap[tamer_id]) then
        costume_id = g_tamerData.m_mTamerMap[tamer_id]['costume']
    end

    if (not costume_id) then
        costume_id = TableTamerCostume:getDefaultCostumeID(tamer_id)
    end
    
    return costume_id
end

-------------------------------------
-- function getCostumeDataWithTamerID
-- @brief 코스튬 정보 반환
-------------------------------------
function ServerData_DragonSkin:getCostumeDataWithTamerID(tamer_id)
    local costume_id = self:getCostumeID(tamer_id)
    
    local table_tamer = TableTamerCostume()
    local t_costume = table_tamer:get(costume_id)

    return StructTamerCostume(t_costume)
end

-------------------------------------
-- function getCostumeDataWithCostumeID
-- @brief 코스튬 정보 반환
-------------------------------------
function ServerData_DragonSkin:getCostumeDataWithCostumeID(costume_id)
    local table_tamer = TableTamerCostume()
    local t_costume = table_tamer:get(costume_id)

    return StructTamerCostume(t_costume)
end

-------------------------------------
-- function isDragonSkinExist
-- @brief 스킨이 존재하는 드래곤인지 확인
-------------------------------------
function ServerData_DragonSkin:isDragonSkinExist(doid)

    --@dhkim temp 23.02.17 - 스킨 있는 드래곤 우선 임시 확인용
    if doid == 121854 or doid == 121842 or doid == 121752 or doid == 121861 then
        return true
    end

    return false
end

-------------------------------------
-- function makeStructSkinList
-- @breif 해당 드래곤의 모든 스킨 정보 리스트로 반환
-------------------------------------
function ServerData_DragonSkin:makeStructSkinList(did)
    local skin_list = TableDragonSkin():filterList('did', did) 
    table.sort(skin_list, function(a,b)
        local a_priority = a['ui_priority'] or 0
        local b_priority = b['ui_priority'] or 0
        return a_priority > b_priority
    end)

    local l_struct_skin = {}
    for k, v in ipairs(skin_list) do
        table.insert(l_struct_skin, StructDragonSkin(v))
    end

    return l_struct_skin
end

-------------------------------------
-- function getShopInfo
-- @breif 해당 코스튬 샵정보 반환
-------------------------------------
function ServerData_DragonSkin:getShopInfo(costume_id)
    if (self.m_shopInfo[costume_id]) then
        return self.m_shopInfo[costume_id]
    end

    return nil
end

-------------------------------------
-- function request_costumeSelect
-------------------------------------
function ServerData_DragonSkin:request_costumeSelect(cid, tid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
    local cid = (cid % 100 == 0) and 0 or cid
    -- 0 으로 처리해도 안됨..

    -- 콜백 함수
    local function success_cb(ret)
        
        -- 테이머 정보 갱신
		g_tamerData:applyTamerInfo(ret['tamer'])
		g_tamerData:reMappingTamerInfo()

        -- 채팅 서버에 변경사항 적용
        if g_chatClientSocket then
            local tamer_id = tonumber(tid)
            if (tamer_id == g_tamerData:getCurrTamerID()) then
                g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
            end
        end

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/set/costume')
    ui_network:setParam('uid', uid)
    ui_network:setParam('tid', tid)
    ui_network:setParam('costume', cid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end