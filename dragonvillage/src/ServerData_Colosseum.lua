-------------------------------------
-- class ServerData_Colosseum
-------------------------------------
ServerData_Colosseum = class({
        m_serverData = 'ServerData',

        -- 상대방 정보
        m_vsInfo = '',
        m_vsDeckInfo = '',
        m_vsDragons = '',
        m_vsRunes = '',

        -- 매칭된 게임의 고유 키
        m_colosseumGameKey = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Colosseum:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_colosseumStart
-------------------------------------
function ServerData_Colosseum:request_colosseumStart(cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local is_cash = 1 -- 캐시로 플레이 할 경우 (1이면 유료플레이)

    -- 콜백 함수
    local function success_cb(ret)
        self:response_colosseumStart(ret, cb)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/ladder/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_cash', is_cash)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function response_colosseumStart
-------------------------------------
function ServerData_Colosseum:response_colosseumStart(ret, cb)

    self.m_colosseumGameKey = ret['m_colosseumGameKey']
    self.m_vsInfo = ret['vs_info']
    self.m_vsDeckInfo = ret['vs_deck']
    self.m_vsRunes = ret['vs_runes']
    self.m_vsDragons = ret['vs_dragons']

    for _,t_rune_data in pairs(self.m_vsRunes) do
        t_rune_data['information'] = g_runesData:makeRuneInfomation(t_rune_data)
    end
    
    if cb then
        cb(ret)
    end
end

-------------------------------------
-- function setTestColosseumDeck
-- @breif 'data/colosseum_test_deck.txt'파일에 테스트용 상대방 덱 설정 기능
-------------------------------------
function ServerData_Colosseum:setTestColosseumDeck()
    local script = TABLE:loadJsonTable('colosseum_test_deck')
    
    local ret = script
    self.m_vsDeckInfo = ret['vs_deck']
    self.m_vsRunes = ret['vs_runes']
    self.m_vsDragons = ret['vs_dragons']

    for _,t_rune_data in pairs(self.m_vsRunes) do
        t_rune_data['information'] = g_runesData:makeRuneInfomation(t_rune_data)
    end
end

-------------------------------------
-- function getOpponentDeck
-- @brief 콜로세움 상대방의 덱 정보를 얻어옴
-------------------------------------
function ServerData_Colosseum:getOpponentDeck()
    -- 드래곤의 doid가 있는 슬롯 리스트
    local l_deck = self.m_vsDeckInfo['deck']

    -- 진형
    local formation = self.m_vsDeckInfo['formation']
    formation = ServerData_Deck:adjustFormationName(formation)

    -- 덱 이름
    local deckname = self.m_vsDeckInfo['deckname']

    return l_deck, formation, deckname
end

-------------------------------------
-- function getOpponentDragon
-- @brief 콜로세움 상대방의 드래곤 개별 정보
-------------------------------------
function ServerData_Colosseum:getOpponentDragon(doid)
    local l_dragons = self.m_vsDragons

    for _,v in pairs(l_dragons) do
        if (doid == v['id']) then
            return clone(v)
        end
    end

    return nil
end

-------------------------------------
-- function getOpponentRuneData
-- @brief 콜로세움 상대방의 룬 개별 정보
-------------------------------------
function ServerData_Colosseum:getOpponentRuneData(roid)
    local l_runes = self.m_vsRunes

    for _,v in pairs(l_runes) do
        if (roid == v['id']) then
            return clone(v)
        end
    end

    return nil
end

-------------------------------------
-- function makeOpponentDragonStatusCalculator
-- @brief 콜로세움 상대방의 능력치 계산기 생성
-------------------------------------
function ServerData_Colosseum:makeOpponentDragonStatusCalculator(doid)
    local t_dragon_data = self:getOpponentDragon(doid)

    -- 드래곤 룬 정보
    local l_runes = t_dragon_data['runes']
    local l_rune_obj_map = {}
    local l_runes_for_set = {}
    for _,roid in pairs(l_runes) do
        local t_rune_data = self:getOpponentRuneData(roid)
        l_rune_obj_map[roid] = t_rune_data
        table.insert(l_runes_for_set, t_rune_data)
    end

    -- 룬 세트 효과 지정
    t_dragon_data['rune_set'] = g_runesData:makeRuneSetData(l_runes_for_set[1], l_runes_for_set[2], l_runes_for_set[3])

    -- 룬은 친밀도, 수련과 달리 Rune Object가 별도로 존재하여
    -- 외부의 함수를 통해 룬 보너스 리스트를 얻어옴
    local l_rune_bonus = ServerData_Dragons:makeRuneBonusList(t_dragon_data, l_rune_obj_map)

    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data, l_rune_bonus)
end