-------------------------------------
-- table LobbyMapFactory
-------------------------------------
LobbyMapFactory = {
    m_lobbyMap = 'LobbyMap',
}

-- 로비 낮/밤 전환용 임시 변수
USE_NIGHT = false
SKIP_CHECK_DAY_OR_NIGHT = false

local LAYER_INFO_LIST = {
    {'left', -1280},
    {'center', 0},
    {'right', 1280}
}

local DECO_TYPE = {
    ['X_MAS'] = 'christmas',
    ['BLOSSOM'] = 'blossom',
    ['HALLOWEEN'] = 'halloween',
    ['ANNIVERSARY_1ST'] = '1st_anniversary',
    ['ANNIVERSARY_1ST_GLOBAL'] = '1st_anniversary_global',
    ['ANNIVERSARY_2ST'] = '2st_anniversary',
    ['ANNIVERSARY_2ST_GLOBAL'] = '2st_anniversary_global',
    ['ANNIVERSARY_3RD'] = '3rd_anniversary',
    ['ANNIVERSARY_4TH'] = '4th_anniversary',
    ['WEIDEL_FESTIVAL'] = 'event_weidel_festival'
}

-- ## 장식 추가 스텝 ##
-- DECO_TYPE 추가
-- function getDecoType : 적절한 조건에 따라 deco_type 반환하도록 추가
-- function createLobbyWorld : deco_type에 따라 적절한 장식 생성 함수 호출
-- function makeLobbyDecoLayer, makeLobbyDeco_onLayer, makeLobbyParticle : 적절하게 장식 생성 로직 추가

-------------------------------------
-- function createLobbyWorld
-------------------------------------
function LobbyMapFactory:createLobbyWorld(parent_node, ui_lobby)
    self:chcekDayOrNight()

    local lobby_ground = self:makeLobbyLayer(1)
    local lobby_map = LobbyMap(parent_node)
    lobby_map:setContainerSize(1280 * 3, 960)

    -- 레이어 생성
    lobby_map:addLayer(self:makeLobbyLayer(4), 0.7) -- 하늘
    lobby_map:addLayer(self:makeLobbyLayer(3), 0.8) -- 마을
    lobby_map:addLayer(self:makeLobbyLayer(2), 0.9) -- 분수
    lobby_map:addLayer_lobbyGround(lobby_ground) -- 바닥
    lobby_map:addLayer(self:makeLobbyLayer(0), 1) -- 근경

    self:setDeco(lobby_map, ui_lobby)

    return lobby_map
end

-------------------------------------
-- function setDeco
-------------------------------------
function LobbyMapFactory:setDeco(lobby_map, ui_lobby)
    local lobby_ground = lobby_map.m_groudNode
    self.m_lobbyMap = lobby_map

    -- 이벤트 장식 타입
    local deco_type = self.getDecoType() or ''

    -- 할로윈
    if (deco_type == DECO_TYPE.HALLOWEEN) then
        -- 크리스마스
        self:makeLobbyDeco_onLayer(lobby_ground, deco_type) -- 바닥 장식
        lobby_map:addLayer(self:makeLobbyDecoLayer(deco_type), 1) -- 근경 레이어
    elseif (deco_type == DECO_TYPE.X_MAS) then
        -- 벚꽃
        self:makeLobbyDeco_onLayer(lobby_ground, deco_type) -- 바닥 트리
        self:makeLobbyParticle(ui_lobby, deco_type) -- 눈 파티클
    elseif (deco_type == DECO_TYPE.BLOSSOM) then
        -- 기념(케이크)
        lobby_map:addLayer(self:makeLobbyDecoLayer(deco_type), 1) -- 벚꽃 나무 레이어
        self:makeLobbyParticle(ui_lobby, deco_type) -- 벚꽃 파티클
    elseif (string.find(deco_type, 'anniversary')) then
        self:makeLobbyDeco_onLayer(lobby_ground, deco_type)
        self:makeLobbyParticleConfetti(ui_lobby) -- 종이 조각 파티클
    elseif (string.find(deco_type, DECO_TYPE.WEIDEL_FESTIVAL)) then
        self:makeLobbyDeco_onLayer(lobby_ground, deco_type)
        self:makeLobbyParticle(ui_lobby, deco_type) -- 축제용 꽃 파티클
        self:makeLayoutForWeidelFestival(lobby_map, ui_lobby)
    end

    return lobby_map
end

-------------------------------------
-- function makeLobbyLayer
-- @param idx : layer 생성의 키이자 local_z_order로 사용함
-------------------------------------
function LobbyMapFactory:makeLobbyLayer(idx)
    local node = cc.Node:create()
    node:setDockPoint(CENTER_POINT)
    node:setAnchorPoint(CENTER_POINT)

    local night = ''
    if USE_NIGHT then
        night = '_night'
    end

    -- 1. vrp를 먼저 찾고
    -- 2. 없으면 png를 찾는다
    -- 3. png도 없다면 불러오지 않는다

    local skip_error_msg = true
    local animator = nil
    local dir, pos_x, res_name, path = nil, nil, nil, nil
    for _, l_info in ipairs(LAYER_INFO_LIST) do
        dir = l_info[1]
        pos_x = l_info[2]

        res_name = string.format('lobby_layer_%.2d_%s%s', idx, dir, night)
        path = string.format('res/lobby/%s/%s.vrp', res_name, res_name)

        if (cc.FileUtils:getInstance():isFileExist(path) == false) then
            path = string.format('res/lobby/%s.png', res_name)
        end

        animator = MakeAnimator(path, skip_error_msg)
        if (animator.m_node) then
            animator:setDockPoint(CENTER_POINT)
            animator:setAnchorPoint(CENTER_POINT)
            animator:setPositionX(pos_x)
            node:addChild(animator.m_node)
        end
    end

    return node
end

-------------------------------------
-- function makeLobbyDecoLayer
-------------------------------------
function LobbyMapFactory:makeLobbyDecoLayer(deco_type)
    local node = cc.Node:create()
    node:setDockPoint(CENTER_POINT)
    node:setAnchorPoint(CENTER_POINT)

    local skip_error_msg = false
    local animator = nil

    local night = ''
    if USE_NIGHT then
        night = '_night'
    end

    -- 벚꽃 나무
    if (deco_type == DECO_TYPE.BLOSSOM) then
        -- 할로윈 0번 레이어
        local full_path = string.format('res/lobby/lobby_season_deco/lobby_blossom%s.png', night)
        animator = MakeAnimator(full_path, skip_error_msg)
        if (animator.m_node) then
            animator:setDockPoint(CENTER_POINT)
            animator:setAnchorPoint(CENTER_POINT)
            animator:setPosition(200, 0)
            node:addChild(animator.m_node)
        end
    elseif (deco_type == DECO_TYPE.HALLOWEEN) then
        local l_layer_info = {
            {'left', -1280},
            {'right', 1280}
        }

        for _, l_info in ipairs(l_layer_info) do
            local name = l_info[1]
            local pos_x = l_info[2]
            local full_path = string.format('res/lobby/lobby_season_deco/halloween/lobby_halloween_00_%s.png', name)
            animator = MakeAnimator(full_path, skip_error_msg)
            if (animator.m_node) then
                animator:setDockPoint(CENTER_POINT)
                animator:setAnchorPoint(CENTER_POINT)
                animator:setPositionX(pos_x)
                node:addChild(animator.m_node)
            end
        end
    end

    return node
end

-------------------------------------
-- function makeLobbyDeco_onLayer
-- @brief 바닥과 테이머 사이에 찍기 위해서 ground_node에 직접 붙임
-------------------------------------
function LobbyMapFactory:makeLobbyDeco_onLayer(node, deco_type)
    local night = ''
    if USE_NIGHT then
        night = '_night'
    end

    -- 전단지
    if (deco_type == 'wanted') then
        -- 크리스마스 트리
        local full_path = string.format('res/lobby/lobby_season_deco/lobby_wanted%s.png', night)
        animator = MakeAnimator(full_path, skip_error_msg)
        if (animator.m_node) then
            animator:setDockPoint(CENTER_POINT)
            animator:setAnchorPoint(CENTER_POINT)
            animator:setPosition(645, 110, 1)
            node:addChild(animator.m_node, 1)
        end
    elseif (deco_type == DECO_TYPE.X_MAS) then
        -- 1주년 기념
        animator = MakeAnimator('res/lobby/lobby_layer_01_center_tree/lobby_layer_01_center_tree.vrp')
        if (animator.m_node) then
            animator:setDockPoint(CENTER_POINT)
            animator:setAnchorPoint(CENTER_POINT)
            animator:setPosition(235, 145)
            node:addChild(animator.m_node, 1)
        end
        
        self:makeEventRoulette(self.m_lobbyMap.m_groudNode, cc.p(-240, 80))

    elseif (deco_type == DECO_TYPE.ANNIVERSARY_1ST) then
        -- 1주년 기념 케이크 (민트 초코)
        animator = MakeAnimator('res/lobby/lobby_layer_01_center_cake/lobby_layer_01_center_cake.vrp')
        if (animator.m_node) then
            animator:setPosition(0, 0)
            animator:changeAni(USE_NIGHT and 'idle_02' or 'idle_01', true)
            node:addChild(animator.m_node, 1)
        end
    elseif (deco_type == DECO_TYPE.ANNIVERSARY_1ST_GLOBAL) then
        -- 2주년 기념 케이크 (민트 초코)
        animator = MakeAnimator('res/lobby/lobby_layer_01_center_cake2/lobby_layer_01_center_cake2.vrp')
        if (animator.m_node) then
            animator:setPosition(0, 0)
            animator:changeAni(USE_NIGHT and 'idle_02' or 'idle_01', true)
            node:addChild(animator.m_node, 1)
        end
    elseif (deco_type == DECO_TYPE.ANNIVERSARY_2ST) then
        -- 2주년 글로벌 기념 케이크 (민트 초코)
        animator = MakeAnimator('res/lobby/lobby_layer_02_center_cake/lobby_layer_02_center_cake.vrp')
        if (animator.m_node) then
            animator:setPosition(0, 0)
            animator:changeAni(USE_NIGHT and 'idle_02' or 'idle_01', true)
            node:addChild(animator.m_node, 1)
        end
    elseif (deco_type == DECO_TYPE.ANNIVERSARY_2ST_GLOBAL) then
        -- 할로윈 1번 레이어
        animator = MakeAnimator('res/lobby/lobby_layer_02_center_cake2/lobby_layer_02_center_cake2.vrp')
        if (animator.m_node) then
            animator:setPosition(0, 0)
            animator:changeAni(USE_NIGHT and 'idle_02' or 'idle_01', true)
            node:addChild(animator.m_node, 1)
        end
    elseif (deco_type == DECO_TYPE.HALLOWEEN) then
        -- 3주년 기념 케이크 2020.08.27
        for _, l_info in ipairs(LAYER_INFO_LIST) do
            local name = l_info[1]
            local pos_x = l_info[2]
            local full_path = string.format('res/lobby/lobby_season_deco/halloween/lobby_halloween_01_%s.png', name)
            animator = MakeAnimator(full_path, skip_error_msg)
            if (animator.m_node) then
                animator:setDockPoint(CENTER_POINT)
                animator:setAnchorPoint(CENTER_POINT)
                animator:setPositionX(pos_x)
                node:addChild(animator.m_node, 1)
            end
        end
    elseif (deco_type == DECO_TYPE.ANNIVERSARY_3RD) then
        animator = MakeAnimator('res/lobby/lobby_layer_03_center_cake/lobby_layer_03_center_cake.vrp')
        if (animator.m_node) then
            animator:setPosition(0, 0)
            animator:changeAni(USE_NIGHT and 'idle_02' or 'idle_01', true)
            node:addChild(animator.m_node, 1)
        end
    elseif (deco_type == DECO_TYPE.ANNIVERSARY_4TH) then
        animator = MakeAnimator('res/lobby/lobby_layer_04_center_cake/lobby_layer_04_center_cake.vrp')
        if (animator.m_node) then
            animator:setPosition(0, 0)
            animator:changeAni(USE_NIGHT and 'idle_02' or 'idle_01', true)
            node:addChild(animator.m_node, 1)
        end
    elseif (deco_type == DECO_TYPE.WEIDEL_FESTIVAL) then
        for _, l_info in ipairs(LAYER_INFO_LIST) do
            local name = l_info[1]
            if USE_NIGHT then
                name = name .. '_night'
            end

            local pos_x = l_info[2]
            local full_path =
                string.format('res/lobby/lobby_season_deco/weidel_festival/lobby_weidel_festival_%s.vrp', name)
            animator = MakeAnimator(full_path, skip_error_msg)
            if (animator.m_node) then
                animator:setDockPoint(CENTER_POINT)
                animator:setAnchorPoint(CENTER_POINT)
                animator:setPositionX(pos_x)
                animator:setPositionY(0)
                node:addChild(animator.m_node, 1)
            end
        end

        --[[
        button:addTouchEventListener(function(sender,eventType)
            ccdump(sender)
            if eventType == ccui.TouchEventType.ended then
                touch_event()
            end
        end)]]
        --node:addChild(button)

        self:makeLobbyEffectByMode(node)
    end
end

-------------------------------------
-- function makeLobbyFirecracker
-- @brief ui_lobby에 폭죽이펙트를 생성한다.
-- 낮이면 꽃가루가 날리고 밤이면 폭죽이 터진다
-------------------------------------
function LobbyMapFactory:makeLobbyEffectByMode(node)
    if (USE_NIGHT == false) then
        return
    end

    local temp_pos = -150

    -- 생성
    for i = 1, 5 do
        local pos_x = 150 + temp_pos
        local pos_y = math.random(340, 380)
        local scale = math.random(8, 15) * 0.1
        local speed = math.random(5, 10) * 0.1

        if (i % 2 ~= 0) then
            scale = 0 - scale
        end

        temp_pos = pos_x

        local firecracker_instance = MakeAnimator('res/ui/a2d/result/result.vrp')
        firecracker_instance:setScale(scale)
        node:addChild(firecracker_instance.m_node)
        firecracker_instance:setPosition(pos_x, pos_y)
        firecracker_instance:setTimeScale(speed)
        firecracker_instance:setVisible(false)
        firecracker_instance:setLocalZOrder(-1)

        function loop_func(firecracker)
            -- 스케쥴링
            if (firecracker:isVisible() == false) then
                firecracker:setVisible(true)
            end

            local delay = cc.DelayTime:create(math.random(8, 24) * 0.1)
            local sequence =
                cc.Sequence:create(
                delay,
                cc.CallFunc:create(
                    function()
                        firecracker:changeAni('event_firework', true)
                    end
                )
            )

            node:runAction(sequence)
        end

        loop_func(firecracker_instance)
    end
end

-------------------------------------
-- function makeLobbyParticle
-- @brief ui_lobby에 파티클을 생성한다.
-------------------------------------
function LobbyMapFactory:makeLobbyParticle(ui_lobby, deco_type)
    if (not ui_lobby) then
        return
    end

    local particle_res

    -- 눈은 밤에만 내린다
    if (deco_type == DECO_TYPE.X_MAS) and (USE_NIGHT) then
        -- 벚꽃
        particle_res = 'dv_snow'
    elseif (deco_type == DECO_TYPE.BLOSSOM) then
        -- 바이델 축제용 (사실상)벛꽃
        particle_res = 'particle_cherry'
    elseif (deco_type == DECO_TYPE.WEIDEL_FESTIVAL) and (USE_NIGHT == false) then
        -- 정의되지 않은 타입은 파티클 생성안함
        particle_res = 'particle_weidel'
    else
        return
    end

    self:makeParticle(ui_lobby, particle_res)
end

-------------------------------------
-- function makeLobbyParticleConfetti
-- @brief lobby에 confetti 파티클을 생성한다.
-------------------------------------
function LobbyMapFactory:makeLobbyParticleConfetti(ui_lobby)
    if (not ui_lobby) then
        return
    end

    self:makeParticle(ui_lobby, 'confetti/particle_confetti_0301')
    self:makeParticle(ui_lobby, 'confetti/particle_confetti_0302')
    self:makeParticle(ui_lobby, 'confetti/particle_confetti_0303')
    self:makeParticle(ui_lobby, 'confetti/particle_confetti_0401')
    self:makeParticle(ui_lobby, 'confetti/particle_confetti_0402')
end

-------------------------------------
-- function makeParticle
-- @brief 파티클을 생성한다.
-------------------------------------
function LobbyMapFactory:makeParticle(node, name)
    local particle_res = string.format('res/ui/particle/%s.plist', name)
    local particle = cc.ParticleSystemQuad:create(particle_res)
    particle:setAnchorPoint(CENTER_POINT)
    particle:setDockPoint(CENTER_POINT)
    node.root:addChild(particle)
end

-------------------------------------
-- function getDecoType
-- @brief 현재의 deco_type 반환
-------------------------------------
function LobbyMapFactory.getDecoType()
    -- table_event_list 의 event_type 과 현재의 deco_type 형식 맞추어야함
    -- ex) event_type = 1st_annivasary_global
    local lobby_deco_event_id = g_eventData:getLobbyDeco_eventId()
    if (not lobby_deco_event_id) then
        return nil
    end

    return lobby_deco_event_id
end

-------------------------------------
-- function chcekDayOrNight
-- @brief 낮/밤을 체크한다
-------------------------------------
function LobbyMapFactory:chcekDayOrNight()
    if SKIP_CHECK_DAY_OR_NIGHT then
        return
    end

    local curr_time = os.time()
    local date = pl.Date()
    date:set(curr_time)

    local hour = date:hour()

    -- 오전 6시 ~ 오후 6시 사이는 낮
    if (hour > 6) and (hour < 18) then
        -- 밤
        USE_NIGHT = false
    else
        USE_NIGHT = true
    end
end

-------------------------------------
-- function makeLayoutForWeidelFestival
-- @brief 낮/밤을 체크한다
-------------------------------------
function LobbyMapFactory:makeLayoutForWeidelFestival(lobby_map, ui_lobby)
    local lobby_ground = lobby_map.m_groudNode

    -- 돌림판
    local roulette_name = 'weidel_roulette'
    local candy_shop_name = 'weidel_candyshop'
    local photo_board_name = 'weidel_board'

    if USE_NIGHT then
        roulette_name = roulette_name .. '_night'
        candy_shop_name = candy_shop_name .. '_night'
        photo_board_name = photo_board_name .. '_night'
    end

    -- 민초 솜사탕 가게
    local candy_shop = MakeAnimator(string.format('res/lobby/lobby_season_deco/weidel_festival/%s.vrp', candy_shop_name))
    candy_shop:changeAni('idle_01', true)
    candy_shop.m_node:setContentSize(0, 300)
    candy_shop.m_node:setPosition(-240, 80)
    local shop_z_order = lobby_map:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_DRAGON, -120)
    lobby_ground:addChild(candy_shop.m_node, shop_z_order)

    -- 사진판
    local photo_board = MakeAnimator(string.format('res/lobby/lobby_season_deco/weidel_festival/%s.vrp', photo_board_name))
    photo_board:changeAni('idle', true)
    photo_board.m_node:setContentSize(0, 300)
    photo_board.m_node:setPosition(-750, -42)
    local board_z_order = lobby_map:makeLobbyMapZorder(LobbyMap.Z_ORDER_TYPE_DRAGON, -180)
    lobby_ground:addChild(photo_board.m_node, board_z_order)
    
    self:makeEventRoulette(lobby_ground)

    ServerData_Forest:getInstance():request_myForestInfo(
        function()
            local t_dragon_object = table.sortRandom(ServerData_Forest:getInstance():getMyDragons())
            local loop_count = 0

            if (not t_dragon_object) or (#t_dragon_object <= 0) then
                return
            end

            local max_loop_count = math.min(#t_dragon_object, 3)

            for doid, struct_dragon_object in pairs(t_dragon_object) do
                if (loop_count >= max_loop_count) then
                    break
                end

                lobby_map:makeDragon(struct_dragon_object)

                loop_count = loop_count + 1
            end
        end
    )
end


function LobbyMapFactory:makeEventRoulette(lobby_ground, pos)
    if not g_hotTimeData:isActiveEvent('event_roulette') and not g_hotTimeData:isActiveEvent('event_roulette_reward') then return end

    local roulette_name = 'weidel_roulette'
    local roulette = MakeAnimator(string.format('res/lobby/lobby_season_deco/weidel_festival/%s.vrp', roulette_name))
    local position = pos == nil and cc.p(235, 180) or pos

    roulette:changeAni('idle', true)
    roulette.m_node:setContentSize(0, 350)
    roulette.m_node:setPosition(position)
    lobby_ground:addChild(roulette.m_node, 5)

    local is_requested = false
    local function touch_event(touches, event)
        if (is_requested == true) then
            return
        end
        local world_pos = convertToWorldSpace(roulette.m_node)
        local touch_pos = touches[1]:getLocation()

        -- 화면상에 보이는 Y스케일을 얻어옴
        local transform = roulette.m_node:getNodeToWorldTransform()
        local scale_y = transform[5 + 1]

        local std_distance = (180 * scale_y)

        local distance = getDistance(touch_pos['x'], touch_pos['y'], world_pos['x'], world_pos['y'])

        if (distance > std_distance) then
            return
        end

        local function show_event_roulette()
            local is_opend, idx, ui = UINavigatorDefinition:findOpendUI('UI_EventRoulette')

            if (is_opend and ui) then
                ui:close()
            end
            local is_popup = true
            UI_EventRoulette(is_popup)

            is_requested = false
        end
        
        if g_hotTimeData:isActiveEvent('event_roulette') or g_hotTimeData:isActiveEvent('event_roulette_reward') then
            g_eventRouletteData:request_rouletteInfo(false, true, show_event_roulette)
        end
        is_requested = true
    end

    if (self.m_lobbyMap) then
        self.m_lobbyMap:makeTouchLayer(roulette, touch_event)
    end

end