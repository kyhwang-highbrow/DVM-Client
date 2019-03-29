local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerBestDeckListItem
-------------------------------------
UI_AncientTowerBestDeckListItem = class(PARENT, {
        m_tData = 'table'
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
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerBestDeckListItem:initUI()
    local vars = self.vars
    local data = self.m_tData
    --[[
      ['tamer']=110001;
        ['deck']={
                '5ba1bcbce891935dfd799479';
                '5ba1bcbfe891935dfd7994c7';
                '5ba1bcbee891935dfd7994ac';
        };
        ['formation']='attack';
        ['deckname']='ancient';
        ['leader']=1;
    --]]


    local l_deck = data['deck']

    if (l_deck) then
        for ind, doj in ipairs(l_deck) do
            local t_dragon_data = g_dragonsData:getDragonDataFromUid(doj)
            local ui_dragon_card = UI_DragonCard(t_dragon_data)
            vars['dragonNode'..ind]:addChild(ui_dragon_card.root)
        end
        
        local info = g_ancientTowerData.m_challengingInfo
        
        local my_score = info.m_myScore
        local my_high_score = info.m_myHighScore
        local season_high_score = info.m_seasonHighScore

        vars['meBestScoreLabel']:setString(comma_value(my_high_score))
        vars['meTopScoreLabel2']:setString(comma_value(my_score))
        vars['meTopScoreLabel1']:setString(comma_value(season_high_score))
    end

    --[[

    local ui_dragon_card = UI_DragonCard()
    vars['fomationNode']
    vars['dragonNode5']
    vars['meBestScoreLabel']
    vars['meTopScoreLabel2']
    vars['meTopScoreLabel1']
    vars['userTopScoreLabel']
    vars['stageLabel']
    vars['meSprite']
    --]]
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerBestDeckListItem:initButton()
    local vars = self.vars
    --[[
    vars['delBtn']
    vars['loadBtn']
    --]]
end

