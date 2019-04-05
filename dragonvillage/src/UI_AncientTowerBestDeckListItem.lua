local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerBestDeckListItem
-------------------------------------
UI_AncientTowerBestDeckListItem = class(PARENT, {
        m_tData = 'table',
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
                "deck":["5ba1bcbce891935dfd799479","5ba1bcbfe891935dfd7994c7","5ba1bcbee891935dfd7994ac", nil, nil],
                "formation":"attack",
                "stage_id":1401006,
                "leader":1
                },
    --]]

    -- 층 정보
    local floor = tonumber(data['stage_id'])%100
    vars['stageLabel']:setString(floor)

    -- 점수
    local best_score = data['best_score']
    vars['meBestScoreLabel']:setString(descBlank(best_score))
    vars['meTopScoreLabel2']:setString(descBlank(0))
    vars['userTopScoreLabel']:setString(descBlank(0))

    -- 진형 정보
    if (data['formation']) then
        local formation_icon = IconHelper:getFormationIcon(data['formation'], true)   
        if (formation_icon) then
            vars['formationNode']:addChild(formation_icon)
        end
    end

    -- 테이머 정보
    if (data['tamer']) then
        local tamer_icon = IconHelper:getTamerSDIcon(data['tamer'])
        if (tamer_icon) then
            vars['tamerNode']:addChild(tamer_icon)
        end
    end
    
    -- 덱 정보(드래곤 카드UI)
    local l_deck = data['deck']
    if (not l_deck) then
        return
    end
    
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

-------------------------------------
-- function setScore
-------------------------------------
function UI_AncientTowerBestDeckListItem:setScore(t_score)
    local vars = self.vars

    if (not t_score) then
        return
    end

    vars['meTopScoreLabel2']:setString(descBlank(t_score['hiscore']))
    vars['userTopScoreLabel']:setString(descBlank(t_score['topuser_score']))
end

-------------------------------------
-- function setHighlight
-------------------------------------
function UI_AncientTowerBestDeckListItem:setHighlight(is_highlight)
    local vars = self.vars
    vars['meSprite']:setVisible(is_highlight)
end


