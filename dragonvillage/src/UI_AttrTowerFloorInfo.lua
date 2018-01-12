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

    local attr_name = g_attrTowerData:getSelAttrName()
    vars['towerTabLabel']:setString(Str('{1}의 탑 {2}층', attr_name, info.m_floor))

    do -- 층 정보
        local my_score = info.m_myScore
        local top_score = info.m_myTopUserScore
        local top_user = info.m_topUserInfo
        local nick = top_user and top_user:getNickname() or ''
        local str = Str('{@DESC2}{1}점\n{@DESC}{@MUSTARD2}{2}점\n{3}', my_score, top_score, nick)
        vars['scoreLabel']:setString(str)

        local struct_clan = top_user and top_user:getStructClan() or nil
        if struct_clan then
            -- 클랜 마크
            local icon = struct_clan:makeClanMarkIcon()
            vars['markNode']:removeAllChildren()
            vars['markNode']:addChild(icon)

            -- 클랜명
            local clan_name = struct_clan:getClanName()
            vars['clanLabel']:setString(clan_name)     
        end

        vars['markNode']:setVisible(struct_clan and true or false)
        vars['clanLabel']:setVisible(struct_clan and true or false)

        local stage_id = info.m_stage
        local str_help = TableStageData():getValue(tonumber(stage_id), 't_help')
        vars['towerDscLabel']:setString(Str(str_help))
    end
    
    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local stage_id = info.m_stage
        local st_type, st_cnt = TableDrop:getStageStaminaType(stage_id)
        local icon = IconHelper:getStaminaInboxIcon(st_type)
        vars['staminaNode']:addChild(icon)
        vars['actingPowerLabel']:setString(st_cnt)
    end

    do -- 잠겨있다면 준비하기 버튼 비활성화

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