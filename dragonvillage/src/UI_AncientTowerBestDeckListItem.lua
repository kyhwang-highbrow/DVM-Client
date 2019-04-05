local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerBestDeckListItem
-------------------------------------
UI_AncientTowerBestDeckListItem = class(PARENT, {
        m_tData = 'table',
        --[[
            -- 로컬 데이터
            {                             -- 탑 층수
                    "tamer":110001,                 -- 테이머 정보
                    "tamerInfo":{
                      "skill_lv4":1,
                      "skill_lv3":1,
                      "costume":730100,
                      "skill_lv2":1,
                      "tid":110001,
                      "skill_lv1":1
                    },
                    "deck":{                        -- 덱 정보
                      "1":"5bdb9ff4e891935dfd7a0418",
                      "2":"5bdb9ff4e891935dfd7a0418"
                      "3":"5bdb9ff4e891935dfd7a0418"
                    },
                    "formation":"attack",           -- 덱 형식 정보
                    "deckname":"ancient",           -- 덱 이름
                    "leader":1                      -- 리더
                    "top_score":0                   -- 최고 점수
            },
        --]]
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientTowerBestDeckListItem:init(data)
    local vars = self:load('tower_best_popup_item.ui')
    self.m_tData = data
    self:initUI()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerBestDeckListItem:initUI()
    local vars = self.vars
    local data = self.m_tData
    --[[
      "1401006":{
                "deckname":"ancient",
                "tamer":110001,
                "best_score":3584,
                "deck":["5ba1bcbce891935dfd799479","5ba1bcbfe891935dfd7994c7","5ba1bcbee891935dfd7994ac"],
                "formation":"attack",
                "stage_id":1401006,
                "leader":1
                },
    --]]


    -- 덱 정보(드래곤 카드UI)
    local l_deck = data['deck']
    if (l_deck) then
        for ind = 1, 5 do
            if (l_deck[ind]) then
                local t_dragon_data = g_dragonsData:getDragonDataFromUid(l_deck[ind])
                if (t_dragon_data) then
                    local ui_dragon_card = UI_DragonCard(t_dragon_data)
                    ui_dragon_card.root:setScale(0.66)
                    ui_dragon_card.root:setSwallowTouch(false)
                    vars['dragonNode'..ind]:addChild(ui_dragon_card.root)
                end
            end
        end
    end

    local floor = tonumber(data['stage_id'])%100
    vars['stageLabel']:setString(floor)
    local best_score = data['best_score']
    if (not best_score or best_score == 0) then
        best_score = '-'
    end
    vars['meBestScoreLabel']:setString(best_score)
    vars['meTopScoreLabel2']:setString('')
    vars['userTopScoreLabel']:setString('')
end

-------------------------------------
-- function setScore
-------------------------------------
function UI_AncientTowerBestDeckListItem:setScore(t_score)
    local vars = self.vars

    if (not t_score) then
        return
    end

    vars['meTopScoreLabel2']:setString(comma_value(t_score['hiscore']))
    vars['userTopScoreLabel']:setString(comma_value(t_score['topuser_score']))
end

-------------------------------------
-- function setHighlight
-------------------------------------
function UI_AncientTowerBestDeckListItem:setHighlight(is_highlight)
    local vars = self.vars
    vars['meSprite']:setVisible(is_highlight)
end

