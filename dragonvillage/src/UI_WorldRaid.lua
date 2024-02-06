local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_WorldRaid
-------------------------------------
UI_WorldRaid = class(PARENT, {    
    m_worldRaidId = 'number',
    m_rewardTableView = 'TableView',
    m_rankingTableView = 'TableView',
    m_isMonosterCardDropDown = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_WorldRaid:initParentVariable()    
    self.m_uiName = 'UI_WorldRaid'
    self.m_isMonosterCardDropDown = false

    do -- 파티 타입
        self.m_worldRaidId = g_worldRaidData:getWorldRaidId()
        local str = TableWorldRaidInfo:getInstance():getWorldRaidPartyTypeStr(world_raid_id)      
        self.m_titleStr = Str('월드 레이드') .. ' - ' .. str
    end
    
	--self.m_staminaType = 'cldg'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    --self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaid:init()
    self.m_worldRaidId = g_worldRaidData:getWorldRaidId()
    local vars = self:load('world_raid_scene.ui')
    UIManager:open(self, UIManager.SCENE)
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_WorldRaid')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
    self:makeRankingTableView()
    self:update()
    self:refreshRanking()

    self.root:scheduleUpdateWithPriorityLua(function () self:update() end, 1)

    -- 보상 안내 팝업
    local function finich_cb()
        self:checkEnterEvent()
        self:initDevPanel()
    end

    self:sceneFadeInAction(nil, finich_cb)
end

-------------------------------------
-- function checkEnterEvent
-------------------------------------
function UI_WorldRaid:checkEnterEvent()
end

-------------------------------------
-- function refreshRanking
-------------------------------------
function UI_WorldRaid:refreshRanking()
    if g_worldRaidData:isExpiredRankingUpdate() == true then
        local success_cb = function(ret)                        
            self:makeRankingTableView()
        end

        g_worldRaidData:request_WorldRaidRanking(self.m_worldRaidId, 'world', 1, 20, success_cb)
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_WorldRaid:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaid:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function () self:click_helpBtn() end)
    vars['readyBtn']:registerScriptTapHandler(function () self:click_readyBtn() end)
    vars['synastryInfoBtn']:registerScriptTapHandler(function () self:click_attrInfoBtn() end)
    vars['rankBtn']:registerScriptTapHandler(function () self:click_rankingBtn() end)
    vars['infiniteBtn']:registerScriptTapHandler(function () self:click_infinitegBtn() end)
    vars['dropDownBtn']:registerScriptTapHandler(function() self:click_dropDownBtn() end)
    vars['synastryInfoBtn']:setVisible(false)

    -- vars['normalTestBtn']:registerScriptTapHandler(function () self:click_battleTestBtn(1) end)
    -- vars['cooperationTestBtn']:registerScriptTapHandler(function () self:click_battleTestBtn(2) end)
    -- vars['lingerTestBtn']:registerScriptTapHandler(function () self:click_battleTestBtn(3) end)
    -- vars['resetScoreBtn']:registerScriptTapHandler(function () self:click_resetBtn('score') end)

    -- vars['normalTestBtn']:setVisible(IS_TEST_MODE())
    -- vars['cooperationTestBtn']:setVisible(IS_TEST_MODE())
    -- vars['lingerTestBtn']:setVisible(IS_TEST_MODE())
    -- vars['resetScoreBtn']:setVisible(IS_TEST_MODE())
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaid:initUI()
    local vars = self.vars

    local world_raid_id = g_worldRaidData:getWorldRaidId()
    local stage_id = g_worldRaidData:getWorldRaidStageId()
    local monster_id_list = g_stageData:getMonsterIDList(stage_id)
    local boss_id = monster_id_list[#monster_id_list]
    local attr = TableWorldRaidInfo:getInstance():getWorldRaidAttr(world_raid_id)--TableStageData:getStageAttr(stage_id)
    
    do -- 보스 이름
        local boss_name = TableMonster():getMonsterName(boss_id)
        vars['bossNameLabel']:setString(boss_name)
    end

    do -- 보스 레벨
        local level = TableStageData:getStageLevel(stage_id) - 1
        vars['levelLabel']:setString(string.format('Lv.%d', level))
    end

    do -- 속성
        local icon = IconHelper:getAttributeIconButton(attr)
        vars['attrNode']:removeAllChildren()
        vars['attrNode']:addChild(icon)
    end


    do -- 보너스 속성
        local buff_key = TableWorldRaidInfo:getInstance():getBuffKey(world_raid_id)
        local bonus_str, map_attr = TableContentAttr:getInstance():getBonusInfo(buff_key, true)
        for k, v in pairs(map_attr) do
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIconButton(k)
            local target_node = vars['bonusTipsNode']
            target_node:removeAllChildren()
            target_node:addChild(icon)
        end

        -- 보너스 속성        
        vars['bonusTipsDscLabel']:setString(bonus_str)
    end

    do -- 패널티 속성  
        local debuff_key = TableWorldRaidInfo:getInstance():getDebuffKey(world_raid_id)
        local penalty_str, map_attr = TableContentAttr:getInstance():getBonusInfo(debuff_key , false)
        local cnt = table.count(map_attr)
        local idx = 0

        vars['panaltyTipsNode']:removeAllChildren()
        for i=1,4 do
            vars['panaltyTipsNode'..i]:removeAllChildren()
        end
        for k, v in pairs(map_attr) do
            idx = idx + 1
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIconButton(k)
            local target_node = (cnt == 1) and 
                                vars['panaltyTipsNode'] or 
                                vars['panaltyTipsNode'..idx]
            target_node:addChild(icon)
        end

        -- 패널티 속성
        vars['panaltyTipsDscLabel']:setString(penalty_str)
    end

    do  -- 몬스터 스파인
        local res, attr, evolution = TableMonster:getMonsterRes(boss_id)
        local scale = TableMonster:getMonsterScale(boss_id)
        local animator = AnimatorHelper:makeMonsterAnimator(res, attr, evolution)
        if (animator) then

            if 142004 == boss_id then
                animator:setScale(scale * 0.5)
            else
                animator:setScale(scale * 0.7)
            end

            vars['bossNode']:removeAllChildren()
            vars['bossNode']:addChild(animator.m_node)
            animator:changeAni('idle', true)
            
            local action = cc.EaseExponentialOut:create(cc.MoveTo:create(1.0, cc.p(0, 0)))
            animator:stopAllActions()
            animator:runAction(action)
        end
    end


    do -- 등장 몬스터 카드
        monster_id_list = table.reverse(monster_id_list)

        for idx = 1, 4 do
            local monster_id = monster_id_list[idx]
            local node_str = string.format('bossCard%dNode', idx)
            vars[node_str]:removeAllChildren()

            if monster_id ~= nil then
                local icon = UI_MonsterCard(monster_id)
                icon:setStageID(stage_id)
                vars[node_str]:addChild(icon.root)
                vars[node_str]:setVisible(self.m_isMonosterCardDropDown)
            end
        end
    end


    do
        local l_ui_list = {vars['dropDownBtn'], vars['monsterListTitleLabel']}
        AlignUIPos(l_ui_list, 'HORIZONTAL', 'HEAD', 20) -- ui list, direction, align, offset
    end
end

-------------------------------------
-- function makeRankingTableView
-------------------------------------
function UI_WorldRaid:makeRankingTableView()
    local vars = self.vars
    require('UI_WorldRaidRankingListItem')

    local rank_node = vars['userRankNode']
    local uid = g_userData:get('uid')
    local create_cb = function(ui, data)
        if (data['uid'] == uid) then
            ui.vars['meSprite']:setVisible(true)
        end
    end

    local make_my_rank_cb = function()
        local my_data = g_worldRaidData:getCurrentMyRanking()
        local me_rank = UI_WorldRaidRankingListItem(my_data)
        vars['myRankNode']:addChild(me_rank.root)
        me_rank.vars['meSprite']:setVisible(true)
    end

    local l_rank_list = g_worldRaidData:getCurrentRankingList()
    local rank_list = UIC_RankingList()
    rank_list:setRankUIClass(UI_WorldRaidRankingListItem, create_cb)    
    rank_list:setRankList(l_rank_list)
    rank_list:setEmptyStr(Str('랭킹 정보가 없습니다'))
    rank_list:setMyRank(make_my_rank_cb)
    rank_list:setOffset(1)
    --rank_list:makeRankMoveBtn(func_prev_cb, func_next_cb, RANK_OFFSET_GAP)
    local table_view = rank_list:makeRankList(rank_node, cc.size(550, (55 + 5)))
    table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['ui_action'])
end

-------------------------------------
--- @function refresh
-------------------------------------
function UI_WorldRaid:refresh()
end

-------------------------------------
--- @function click_helpBtn
-------------------------------------
function UI_WorldRaid:click_helpBtn()
    local vars = self.vars
    UI_Help('vs')
end

-------------------------------------
--- @function click_applyBtn
-------------------------------------
function UI_WorldRaid:click_readyBtn()
    -- 스테이지 시간 세팅
    -- UI_ReadySceneNew UI가 열려있을 경우, 닫고 다시 연다
    local t_sub_info = {world_raid_id = self.m_worldRaidId}
    local stage_id = g_worldRaidData:getWorldRaidStageId()
    local is_opend, idx, ui = UINavigatorDefinition:findOpendUI('UI_ReadySceneNew')
    if (is_opend == true) then
        ui:close()
        self:openReadyScene(stage_id, t_sub_info)
        self:close()
    else
        self:openReadyScene(stage_id, t_sub_info)
    end
end

-------------------------------------
--- @function openReadyScene
-------------------------------------
function UI_WorldRaid:openReadyScene(stage_id, t_sub_info)
    local party_type = g_worldRaidData:getWorldRaidPartyType()
    
    if party_type == WORLD_RAID_NORMAL then
        UI_ReadySceneWorldRaidNormal(stage_id, t_sub_info)
    elseif party_type == WORLD_RAID_COOPERATION then
        UI_ReadySceneWorldRaidCooperation(stage_id, t_sub_info)
    elseif party_type == WORLD_RAID_LINGER then
        UI_ReadySceneWorldRaidLinger(stage_id, t_sub_info)
    end
end

-------------------------------------
--- @function click_attrInfoBtn
-------------------------------------
function UI_WorldRaid:click_attrInfoBtn()
    require('UI_WorldRaidAttrPopup')
    UI_WorldRaidAttrPopup()
end

-------------------------------------
--- @function click_rankingBtn
-------------------------------------
function UI_WorldRaid:click_rankingBtn()
    local ui = UI_WorldRaidRanking.open(self.m_worldRaidId)
    ui:setCloseCB(function() 
        self:makeRankingTableView()
    end)
end

-------------------------------------
--- @function click_infinitegBtn
-------------------------------------
function UI_WorldRaid:click_infinitegBtn()
    local vars = self.vars
    local str = Str('보스 몬스터의 체력이 무한입니다.')
    local tool_tip = UI_Tooltip_Skill(0, 0, str)
    -- 자동 위치 지정
    tool_tip:autoPositioning(self.vars['infiniteBtn'])
end

-------------------------------------
-- function click_dropDownBtn
-------------------------------------
function UI_WorldRaid:click_dropDownBtn()
    local vars = self.vars
    self.m_isMonosterCardDropDown = not self.m_isMonosterCardDropDown

    for idx = 1, 4 do
        local node_str = string.format('bossCard%dNode', idx)
        --

        if self.m_isMonosterCardDropDown == true then
            local ori_x, ori_y = vars[node_str]:getPositionX(), -24
            vars[node_str]:setPositionY(ori_y + 20)
            local move_to = cc.EaseExponentialOut:create(cc.MoveTo:create(0.15, cc.p(ori_x, ori_y))) --cc.EaseExponentialOut:create(cc.MoveTo:create(0.2 + (0.1 * idx), cc.p(ori_x, ori_y)))
            local fade_in = cc.FadeIn:create(0.1)

            doAllChildren(vars[node_str], function(child) child:setCascadeOpacityEnabled(true) end)

            vars[node_str]:setOpacity(0)

            vars[node_str]:setVisible(true)
            
            vars[node_str]:stopAllActions()
            
            vars[node_str]:runAction(cc.Spawn:create(move_to, fade_in))

            vars['dropDownSprite']:stopAllActions()
            vars['dropDownSprite']:runAction(cc.RotateTo:create(0.05, 180))
        else
            local ori_x, ori_y = vars[node_str]:getPositionX(), -4
            vars[node_str]:setPositionY(ori_y - 20)
            local move_to = cc.EaseExponentialOut:create(cc.MoveTo:create(0.15, cc.p(ori_x, ori_y))) --cc.EaseExponentialOut:create(cc.MoveTo:create(0.2 + (0.1 * idx), cc.p(ori_x, ori_y)))
            local fade_in = cc.FadeOut:create(0.1)

            doAllChildren(vars[node_str], function(child) child:setCascadeOpacityEnabled(true) end)

            vars[node_str]:setOpacity(100)

            vars[node_str]:setVisible(true)
            
            vars[node_str]:stopAllActions()
            
            vars[node_str]:runAction(cc.Sequence:create(cc.Spawn:create(move_to, fade_in), cc.CallFunc:create(function() vars[node_str]:setVisible(false) end)))

            vars['dropDownSprite']:stopAllActions()
            vars['dropDownSprite']:runAction(cc.RotateTo:create(0.05, 0))
        end
    end

    --vars['dropDownSprite']:setRotation(self.m_isMonosterCardDropDown and 180 or 0)
end

-------------------------------------
--- @function click_battleTestBtn
-------------------------------------
function UI_WorldRaid:click_battleTestBtn(world_raid_party_type)
    if IS_TEST_MODE() == false then
        return
    end

    local vars = self.vars
    local table_data = TableWorldRaidInfo:getInstance()

    for k, v  in pairs(table_data.m_orgTable) do
        if self.m_worldRaidId  == k then
            local stage_id = table_data:getStageIdByPartyType(world_raid_party_type)            
            local boss_attr = table_data:getBossAttrByPartyType(world_raid_party_type)            

            local buff = table_data:getValueByPartyType(world_raid_party_type, 'buff_key')            
            local debuff = table_data:getValueByPartyType(world_raid_party_type, 'debuff_key')            

            v['party_type'] = world_raid_party_type
            v['stage'] = stage_id
            v['boss_attr'] = boss_attr
            v['buff_key'] = buff
            v['debuff_key'] = debuff
        end
    end

    self:initUI()
end

-------------------------------------
--- @function click_resetBtn
-------------------------------------
function UI_WorldRaid:click_resetBtn(type)
    if IS_TEST_MODE() == false then
        return
    end
    g_worldRaidData.m_rankingUpdateAt = ExperationTime()

    local vars = self.vars
    local finish_cb = function(ret)
        self:refreshRanking()
        UIManager:toastNotificationRed('점수 달성 정보 초기화 완료')
    end
  
    g_worldRaidData:request_WorldRaidReset(self.m_worldRaidId, type, finish_cb)
end

-------------------------------------
--- @function refresh
-------------------------------------
function UI_WorldRaid:update()
    local vars = self.vars
    local str = g_worldRaidData:getRemainTimeString()
    vars['timeLabel']:setString(str)
end

-------------------------------------
-- function initDevPanel
-- @brief 개발용 코드
-------------------------------------
function UI_WorldRaid:initDevPanel()
    local vars = self.vars
    
    if (IS_TEST_MODE()) then
        local dev_panel = UI_DevPanel()
        self.root:addChild(dev_panel.root)
        --dev_panel.root:setGlobalZOrder(1000)

        do -- 정예전
            local t_component = StructDevPanelComponent:create('normal')
            local function func()
                self:click_battleTestBtn(1)
            end
        
            t_component['cb1'] = func
            t_component['str'] = '정예전'
            dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
        end

        do -- 협동전
            local t_component = StructDevPanelComponent:create('coop')
            local function func()
                self:click_battleTestBtn(2)
            end

            t_component['cb1'] = func
            t_component['str'] = '협동전'
            dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
        end

        do -- 지구전
            local t_component = StructDevPanelComponent:create('linger')
            local function func()
                self:click_battleTestBtn(3)
            end
        
            t_component['cb1'] = func
            t_component['str'] = '지구전'
            dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
        end

        do -- 점수 달성 초기화
            local t_component = StructDevPanelComponent:create('init_score')
            local function func()
                self:click_resetBtn('score')
            end
        
            t_component['cb1'] = func
            t_component['str'] = '점수 달성 초기화'
            dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
        end

        do -- 점수 달성 초기화
            local t_component = StructDevPanelComponent:create('fix_score')
            local function func(val)

                if tonumber(val) ~= nil then
                    g_worldRaidData.m_testScoreFix = tonumber(val)
                    UIManager:toastNotificationRed('점수 고정 설정 완료')

                end
                --self:click_resetBtn('score')
            end
        
            t_component['edit_cb'] = func
            t_component['str'] = '점수 고정 설정'
            dev_panel:addDevComponent(t_component) -- params: struct_dev_panel_component(StructDevPanelComponent)
        end


    end
end

--@CHECK
UI:checkCompileError(UI_WorldRaid)