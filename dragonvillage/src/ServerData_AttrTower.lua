ATTR_TOWER_OPEN_FLOOR = 40

-------------------------------------
-- class ServerData_AttrTower
-------------------------------------
ServerData_AttrTower = class({
        m_serverData = 'ServerData',

        m_selectAttr = 'string', -- 선택한 속성

        m_challengingInfo = 'StructAttrTowerFloorData',
        m_challengingStageID = 'number', -- 현재 진행중인 층의 스테이지 아이디
        m_clearStageID = 'number', -- 최종 클리어한 층의 스테이지 아이디

        m_challengingFloor = 'number', -- 현재 진행중인 층    
        m_clearFloor = 'number', -- 최종 클리어한 층

        m_lStage = 'table',
        m_nStage = 'number',

        m_nGlobalOffset = 'number',
        m_lGlobalRank = 'list', -- 전체 랭킹 정보

        m_playerUserInfo = 'StructUserInfoAncientTower', -- 내 랭킹 정보

        m_subMenuInfo = 'table', -- 서브 메뉴 정보
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AttrTower:init(server_data)
    self.m_serverData = server_data
    self.m_nStage = 0
end

-------------------------------------
-- function setSelAttr
-------------------------------------
function ServerData_AttrTower:setSelAttr(attr)
    self.m_selectAttr = attr
end

-------------------------------------
-- function getSelAttr
-------------------------------------
function ServerData_AttrTower:getSelAttr()
    return self.m_selectAttr
end

-------------------------------------
-- function getSelAttrName
-------------------------------------
function ServerData_AttrTower:getSelAttrName()
    return dragonAttributeName(self.m_selectAttr)
end

-------------------------------------
-- function getAttrTopName
-------------------------------------
function ServerData_AttrTower:getAttrTopName()
    local attr = self.m_selectAttr
    local top_name = Str('{1}의 탑', dragonAttributeName(attr))

    return top_name
end

-------------------------------------
-- function getAttrTopName_Color
-------------------------------------
function ServerData_AttrTower:getAttrTopName_Color(attr)
    local attr = attr or self.m_selectAttr
    local tower_name = Str('의 탑')
    local top_name = string.format('{@%s}%s{@white}%s', attr, dragonAttributeName(attr), tower_name)

    return top_name
end

-------------------------------------
-- function isContentOpen
-------------------------------------
function ServerData_AttrTower:isContentOpen()
    local is_open = g_userData:get('attr_tower_open') or false
    return is_open
end

-------------------------------------
-- function getNextStageID
-- @brief
-------------------------------------
function ServerData_AttrTower:getNextStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id + 1)

    if t_drop then
        return stage_id + 1
    else
        return stage_id
    end
end

-------------------------------------
-- function getSimplePrevStageID
-- @brief
-------------------------------------
function ServerData_AttrTower:getSimplePrevStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id - 1)

    if t_drop then
        return stage_id - 1
    else
        return stage_id
    end
end

-------------------------------------
-- function getStageName
-------------------------------------
function ServerData_AttrTower:getStageName(stage_id)
    local attr = self.m_selectAttr
    local floor = self:getFloorFromStageID(stage_id)
    local name = Str('{1}의 탑 {2}층', dragonAttributeName(attr), floor)

    return name
end

-------------------------------------
-- function isAttrTowerStage
-------------------------------------
function ServerData_AttrTower:isAttrTowerStage(stage_id)
    if (stage_id > ANCIENT_TOWER_STAGE_ID_START) and (stage_id <= ANCIENT_TOWER_STAGE_ID_FINISH) then
        return true
    end
    return false
end

-------------------------------------
-- function goToAttrTowerScene
-------------------------------------
function ServerData_AttrTower:goToAttrTowerScene(use_scene, attr, stage_id)
    local function finish_cb()
        if use_scene then
            local function close_cb()
                SceneLobby():runScene()
            end
            local scene = SceneCommon(UI_AttrTower, close_cb)
            scene:runScene()
        else
            local ui = UI_AttrTower()
        end        
    end
        
    self:request_attrTowerInfo(attr, stage_id, finish_cb, fail_cb)
end

-------------------------------------
-- function request_attrTowerInfo
-------------------------------------
function ServerData_AttrTower:request_attrTowerInfo(attr, stage, finish_cb, fail_cb)
    self:setSelAttr(attr)

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        
        -- 시험의 탑 서브 메뉴 정보
        local menu_info = ret['stage_info']
        if (menu_info) then
            self.m_subMenuInfo = menu_info
        end

        -- 시험의 탑 층 정보
        local tower_info = ret['tower_stage']
        if (tower_info) then
            -- 도전 스테이지 정보 
            local t_challenging_info = tower_info
            self.m_challengingInfo = StructAttrTowerFloorData(t_challenging_info)
            self.m_challengingStageID = t_challenging_info['stage']
            self.m_challengingFloor = (self.m_challengingStageID % ANCIENT_TOWER_STAGE_ID_START)

            -- 최종 클리어한 스테이지 
            self.m_clearStageID = ret['clear_stage']
            self.m_clearFloor = (ret['clear_stage'] % ANCIENT_TOWER_STAGE_ID_START)

            -- 스테이지는 고대의 탑 스테이지 그대로 사용함!!
            if (not self.m_lStage) then
                self.m_lStage = g_ancientTowerData:makeAcientTower_stageList()
                self.m_nStage = table.count(self.m_lStage)
            end
        end

        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/attr_tower/info')
    ui_network:setParam('uid', uid)

    -- 속성 선택 안하면 메인 메뉴 정보 
    if (attr) then
        ui_network:setParam('attr', attr)
    end
    
    -- 선택한 스테이지
    if (stage) then
        ui_network:setParam('stage', stage)
    end

    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_attrTowerRank
-------------------------------------
function ServerData_AttrTower:request_attrTowerRank(offset, finish_cb)
    local attr = self.m_selectAttr

    -- 파라미터
    local uid = g_userData:get('uid')
    local offset = offset or 0

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        self.m_playerUserInfo = StructUserInfoAncientTower:create_forRanking(ret['my_info'])

        self.m_nGlobalOffset = ret['offset']
        self.m_lGlobalRank = {}
        for i,v in pairs(ret['list']) do
            local user_info = StructUserInfoAncientTower:create_forRanking(v)
            table.insert(self.m_lGlobalRank, user_info)
        end
        
        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/attr_tower/rank')
    ui_network:setParam('uid', uid)
    ui_network:setParam('attr', attr)
    ui_network:setParam('offset', offset)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function makeAttrTower_stageList
-------------------------------------
function ServerData_AttrTower:makeAttrTower_stageList()
    local table_drop = TableDrop()

    local function condition_func(t_table)
        local stage_id = t_table['stage']
        local game_mode = g_stageData:getGameMode(stage_id)
        return (game_mode == GAME_MODE_ANCIENT_TOWER)
    end

    -- 테이블에서 조건에 맞는 테이블만 리턴
    local l_stage_list = table_drop:filterTable_condition(condition_func)

    -- stage(stage_id) 순서로 정렬
    local function sort_func(a, b)
        return a['stage'] < b['stage']
    end
    table.sort(l_stage_list, sort_func)

    return l_stage_list
end

-------------------------------------
-- function getAttrTower_stageList
-------------------------------------
function ServerData_AttrTower:getAttrTower_stageList()
    return self.m_lStage
end

-------------------------------------
-- function getAttrTower_stageCount
-------------------------------------
function ServerData_AttrTower:getAttrTower_stageCount()
    return self.m_nStage
end

-------------------------------------
-- function getChallengingStageID
-- @brief 현재 도전중인 스테이지 아이디를 얻음
-------------------------------------
function ServerData_AttrTower:getChallengingStageID()
    return self.m_challengingStageID
end

-------------------------------------
-- function getTopStageID
-------------------------------------
function ServerData_AttrTower:getTopStageID()
    return (self.m_nStage + ANCIENT_TOWER_STAGE_ID_START)
end

-------------------------------------
-- function getChallengingFloor
-- @brief 현재 도전중인 층을 얻음
-------------------------------------
function ServerData_AttrTower:getChallengingFloor()
    return self.m_challengingFloor
end

-------------------------------------
-- function isOpenStage
-- @brief stage_id에 해당하는 스테이지가 입장 가능한지를 리턴
-------------------------------------
function ServerData_AttrTower:isOpenStage(stage_id)
    local clear_stage = self.m_clearStageID 
    clear_stage = (clear_stage == 0) and ANCIENT_TOWER_STAGE_ID_START or clear_stage
    local is_open = (stage_id <= clear_stage + 1)
    return is_open
end

-------------------------------------
-- function getFloorFromStageID
-- @brief stage_id로부터 해당 층 수를 얻음
-------------------------------------
function ServerData_AttrTower:getFloorFromStageID(stage_id)
    return (stage_id % 1000)
end

-------------------------------------
-- function getStageIDFromFloor
-- @brief 층수로부터 stage_id를 얻음
-------------------------------------
function ServerData_AttrTower:getStageIDFromFloor(floor)
    return (ANCIENT_TOWER_STAGE_ID_START + floor)
end

-------------------------------------
-- function getChallengingFloorWithAttr
-- @brief 속성 탑 도전층 정보 반환
-------------------------------------
function ServerData_AttrTower:getChallengingFloorWithAttr(attr)
    if (not self.m_subMenuInfo) then
        return 0
    end

    local floor = self.m_subMenuInfo[attr] % ANCIENT_TOWER_STAGE_ID_START
    floor = (floor >= 50) and 'clear' or floor + 1
    return floor
end

-------------------------------------
-- function getDeckName
-- @brief 시험의 탑 덱 네임 반환
-- @brief attr_tower_fire, attr_tower_water, attr_tower_earth ..
-------------------------------------
function ServerData_AttrTower:getDeckName(curr_mode)
    local deck_name = curr_mode
    if (self.m_selectAttr) then
        deck_name = 'attr_tower_' .. self.m_selectAttr
    end

    return deck_name
end

-------------------------------------
-- function changeBgRes
-- @brief 시험의 탑 맵 데이터 반환
-- @brief map_attr_tower_fire, map_attr_tower_water, map_attr_tower_earth ..
-------------------------------------
function ServerData_AttrTower:changeBgRes(bg_res)
    local bg_res = bg_res
    if (self.m_selectAttr) then
        bg_res = 'map_attr_tower_' .. self.m_selectAttr
    end

    return bg_res
end

-------------------------------------
-- function checkDragonAttr
-- @brief 드래곤 속성 체크
-------------------------------------
function ServerData_AttrTower:checkDragonAttr(l_deck)
    if (not self.m_selectAttr) then
        return true
    end

    for _, doid in pairs(l_deck) do
        local dragon = g_dragonsData:getDragonDataFromUid(doid)
        local did = dragon['did']
        local attr = TableDragon:getDragonAttr(did)

        if (attr ~= self.m_selectAttr) then
            local msg = Str('{1}속성 드래곤만 전투에 참여할 수 있습니다.', dragonAttributeName(self.m_selectAttr))
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return false
        end
    end

    return true
end
