local PARENT = UI_AncientTowerFloorInfo

-------------------------------------
-- class UI_AttrTowerFloorInfo
-------------------------------------
UI_AttrTowerFloorInfo = class(PARENT ,{})

-------------------------------------
-- function refresh_floorData
-------------------------------------
function UI_AttrTowerFloorInfo:refresh_floorData()
    local vars = self.m_uiScene.vars
    local info = self.m_floorInfo

    vars['towerTabLabel']:setString(Str('시험의 탑 {1}층', info.m_floor))

    do -- 층 정보
        local my_score = info.m_myScore
        local top_score = info.m_myTopUserScore
        local str = Str('{@DESC2}{1}점\n{@DESC}{@MUSTARD2}{2}점', my_score, top_score)
        vars['scoreLabel']:setString(str)

        local stage_id = info.m_stage
        local str_help = TableStageData():getValue(tonumber(stage_id), 't_help')
        vars['towerDscLabel']:setString(str_help)
    end
    
    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local stage_id = info.m_stage
        local st_type, st_cnt = TableDrop:getStageStaminaType(stage_id)
        local icon = IconHelper:getStaminaInboxIcon(st_type)
        vars['staminaNode']:addChild(icon)
        vars['actingPowerLabel']:setString(st_cnt)
    end
end

-------------------------------------
-- function refresh_rewardData
-------------------------------------
function UI_AttrTowerFloorInfo:refresh_rewardData()
    local vars = self.m_uiScene.vars
    local info = self.m_floorInfo

    -- 재화일 경우 숫자만
    local node = vars['rewardNode']
    node:removeAllChildren()

    local id, cnt = info:getReward()
    local ui = UI_ItemCard(id, cnt)
    node:addChild(ui.root)
end