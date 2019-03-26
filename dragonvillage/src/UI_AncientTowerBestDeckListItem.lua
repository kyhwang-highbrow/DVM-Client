local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerBestDeckListItem
-------------------------------------
UI_AncientTowerBestDeckListItem = class(PARENT, {
        --[[
            "1401002":{                         -- 탑 층수
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

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AncientTowerBestDeckListItem:initUI()
    local vars = self.vars
    --[[
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

