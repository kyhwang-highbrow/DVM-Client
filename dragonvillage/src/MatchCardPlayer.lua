-------------------------------------
-- class MatchCardPlayer
-------------------------------------
MatchCardPlayer = class({	
        m_state = 'MATCH_CARD_PLAY_STATE', -- 플레이 상태
        m_playCount = 'number', -- 플레이 회수
        m_successCount = 'number', -- 성공 회수
        m_successGrades = 'table',
        
        m_totalCards = 'table', -- 전체 카드 정보
        m_pickCards = 'table', -- 현재 턴에 선택된 카드 정보
        m_pickBtns = 'table',



        m_randomDids = 'table', 
        m_mapRandomDragons = 'table', -- 카드에 표시되는 랜덤 드래곤 정보
     })

local BOARD_CNT = 20
local PLAY_CNT = 10

-- 2개의 카드를 보여주는 시간
local CARD_SHOW_DELAY = 1.0

MATCH_CARD_PLAY_STATE = {
    WAIT = 0,
    PLAY = 1,
    FINISH = 2,
}

-------------------------------------
-- function init
-------------------------------------
function MatchCardPlayer:init()
    self.m_state = MATCH_CARD_PLAY_STATE.WAIT
    self.m_playCount = PLAY_CNT
    self.m_successCount = 0
    self.m_successGrades = {}

    self.m_totalCards = {}
    self.m_pickCards = {}
    self.m_pickBtns = {}

    self.m_randomDids = {}
    self.m_mapRandomDragons = {}

    self:makeRandomDragonData()
    self:makeBoardData()
end

-------------------------------------
-- function makeBoardData
-------------------------------------
function MatchCardPlayer:makeBoardData()
    local board_info = g_eventMatchCardData.m_boardInfo
    for i = 1, BOARD_CNT do
        local data = board_info[tostring(i)]
        local struct_card = StructEventMatchCard(data)

        local pair = data['pair']
        local random_did = self:getRandomDragonID(pair)
        struct_card:setCardDid(random_did)

        table.insert(self.m_totalCards, struct_card)
    end
end

-------------------------------------
-- function makeRandomDragonData
-------------------------------------
function MatchCardPlayer:makeRandomDragonData()
    local t_dragon = TableDragon().m_orgTable
    for _, v in pairs(t_dragon) do
        local is_undering = (v['underling'] == 1) 
        local is_limit = (v['pick_weight'] == 0) 

        -- 자코 x, 한정 드래곤 x
        if (not is_undering) and (not is_limit) and (v['did']) then
            table.insert(self.m_randomDids, v['did'])
        end
    end
end

-------------------------------------
-- function getRandomDragonID
-- @brief pair가 같으면 같은 드래곤 카드
-------------------------------------
function MatchCardPlayer:getRandomDragonID(pair)
    if (self.m_mapRandomDragons[pair]) then
        return self.m_mapRandomDragons[pair]
    end

    local target_did

    while true do
        local is_exist = false
        target_did = self.m_randomDids[math_random(1, #self.m_randomDids)]
        for _, did in pairs(self.m_mapRandomDragons) do
            -- 이미 선택된 드래곤 제외
            if (did == target_did) then
                is_exist = true
            end
        end

        if (not is_exist) then
            self.m_mapRandomDragons[pair] = target_did
            break
        end
    end

    return target_did
end

-------------------------------------
-- function onClick
-------------------------------------
function MatchCardPlayer:onClick(card_btn, struct_card)
    local play_state = self.m_state

    -- 플레이 종료
    if (play_state == MATCH_CARD_PLAY_STATE.FINISH) then
        return
    end

    if (play_state == MATCH_CARD_PLAY_STATE.WAIT) then
        self.m_state = MATCH_CARD_PLAY_STATE.PLAY
    end

    -- 선택한 카드 상태
    local card_state = struct_card:getState()
    if (card_state == MATCH_CARD_STATE.CLOSE) then
        struct_card:changeState(MATCH_CARD_STATE.OPEN)
        table.insert(self.m_pickCards, struct_card)        
        table.insert(self.m_pickBtns, card_btn)

    elseif (card_state == MATCH_CARD_STATE.OPEN) then
        
    end

    -- 짝 맞았는지 체크
    if (#self.m_pickCards == 2) then
        local ui = UI_BlockPopup()
        local finish_cb = function()
            self:checkMatchingCard()
            ui:close()
        end
        cca.reserveFunc(struct_card.m_node, CARD_SHOW_DELAY, finish_cb)
    end
end

-------------------------------------
-- function checkMatchingCard
-------------------------------------
function MatchCardPlayer:checkMatchingCard()
    local card_1 = self.m_pickCards[1]
    local card_2 = self.m_pickCards[2]

    -- 짝 맞추기 성공
    if (card_1:getPair() == card_2:getPair()) then
        local btn_1 = self.m_pickBtns[1]
        local btn_2 = self.m_pickBtns[2]
        btn_1:setEnabled(false)
        btn_2:setEnabled(false)

        self.m_successCount = math_min(self.m_successCount + 1, PLAY_CNT)
        table.insert(self.m_successGrades, card_1:getGrade())

    -- 짝 맞추기 실패
    else 
        card_1:changeState(MATCH_CARD_STATE.CLOSE)
        card_2:changeState(MATCH_CARD_STATE.CLOSE)
    end

    self.m_state = MATCH_CARD_PLAY_STATE.WAIT
    self.m_pickCards = {}
    self.m_pickBtns = {}
    self.m_playCount = math_max(self.m_playCount - 1, 0)

    -- 남은 플레이 회수 없을 경우, 모두 다 맞춘 경우 종료
    if (self.m_playCount == 0 or self.m_successCount == PLAY_CNT) then
        self.m_state = MATCH_CARD_PLAY_STATE.FINISH
        self:showResult()
    end
end

-------------------------------------
-- function showResult
-------------------------------------
function MatchCardPlayer:showResult()
    local finish_func = function(ret)
        UI_EventMatchCardResult(ret) 
    end



    g_eventMatchCardData:request_playFinish(self.m_successGrades, finish_func)
end