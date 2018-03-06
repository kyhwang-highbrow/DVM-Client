local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanRaidBossInfo
-------------------------------------
UI_ClanRaidBossInfo = class(PARENT,{
        m_sel_mid = 'number',
        m_sel_ui = 'UI_MonsterCard',
        m_map_animator = '',

        m_initial_tab = 'string'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidBossInfo:init(tab)
    local vars = self:load('clan_raid_boss_info.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_ClanRaidBossInfo'
    self.m_map_animator = {}
    self.m_initial_tab = tab or 'info'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ClanRaidBossInfo')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidBossInfo:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidBossInfo:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanRaidBossInfo:initTab()
    local vars = self.vars

    -- 보스 정보
    self:addTabWithLabel('info', vars['bossTabBtn'], vars['rankRewardTabLabel'], vars['bossMenu'])
    -- 상성 정보
    self:addTabWithLabel('synastry', vars['synastryTabBtn'], vars['matchRewardTabLabel'], vars['synastryMenu'])
    -- 파이널 블로우 정보
    self:addTabWithLabel('finalblow', vars['fbTabBtn'], vars['clanRewardTabLabel'], vars['fbMenu'])

    self:setTab(self.m_initial_tab)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanRaidBossInfo:onChangeTab(tab, first)
    if (first) then
        local vars = self.vars
        local target_node 
        if (tab == 'info') then
            target_node = vars['bossNode']
            self:initUI_info()

        elseif (tab == 'synastry') then
            target_node = vars['bossNode2']
            self:initUI_synastry()

        elseif (tab == 'finalblow') then
            target_node = vars['bossNode3']
            self:initUI_finalblow()
        end

        if (target_node) then
            self:initBossVrp(target_node)
        end
    else
        -- 탭할때마다 액션 
        self:doActionReset()
        self:doAction(nil, false)
    end
end

-------------------------------------
-- function initUI_info
-------------------------------------
function UI_ClanRaidBossInfo:initUI_info()
    local vars = self.vars
    self:initMonsterList()

    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local stage_id = struct_raid:getStageID()

    -- 배경
    local attr = struct_raid:getAttr()
    local animator = ResHelper:getUIDragonBG(attr, 'idle')
    vars['bgNode']:addChild(animator.m_node)

    -- 속성 아이콘
    local icon = IconHelper:getAttributeIcon(attr)
    vars['attrNode']:addChild(icon)

    -- 최초 보스 선택으로 
    local _, boss_mid = g_stageData:isBossStage(stage_id)
    self:click_partInfo(self.m_sel_ui, boss_mid)
end

-------------------------------------
-- function initUI_synastry
-------------------------------------
function UI_ClanRaidBossInfo:initUI_synastry()
    local vars = self.vars

    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local stage_id = struct_raid:getStageID()

    -- 보스 이름
    local origin_name = struct_raid:getBossName()
    vars['bossNameLabel']:setString(origin_name)
    
    -- 보스 레벨
    local lv = struct_raid:getLv()
    vars['bossLevelNode']:setString(string.format('Lv.%s', lv))

    -- 보스 속성
    local attr = struct_raid:getAttr()
    local icon = IconHelper:getAttributeIcon(attr)
    vars['bossAttrNode']:addChild(icon)

    local attr_name = dragonAttributeName(attr) 
    vars['bossAttrLabel']:setString(attr_name)
    vars['bossAttrLabel']:setColor(COLOR[attr])

    -- 보너스 속성
    do
        local str, map_attr = struct_raid:getBonusSynastryInfo()
        vars['bonusAttrDscLabel']:setString(str)

        for k, v in pairs(map_attr) do
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIcon(k)
            local target_node = vars['bonusAttrNode']
            target_node:addChild(icon)

            -- 속성 이름
            local name = dragonAttributeName(k)
            local target_label = vars['bonusAttrLabel']
            target_label:setString(name)
            target_label:setColor(COLOR[k])
        end
    end

    -- 페널티 속성
    do
        local str, map_attr = struct_raid:getPenaltySynastryInfo()
        vars['panaltyAttrDscLabel']:setString(str)

        local cnt = table.count(map_attr)
        local idx = 0

        for k, v in pairs(map_attr) do
            idx = idx + 1
            -- 속성 아이콘
            local icon = IconHelper:getAttributeIcon(k)
            local target_node = (cnt == 1) and 
                                vars['panaltyAttrNode'] or 
                                vars['panaltyAttrNode'..idx]
            target_node:addChild(icon)

            -- 속성 이름
            local name = dragonAttributeName(k)
            local target_label = (cnt == 1) and 
                                 vars['panaltyAttrLabel'] or 
                                 vars['panaltyAttrLabel'..idx]

            target_label:setString(name)
            target_label:setColor(COLOR[k])
        end
    end
end

-------------------------------------
-- function initUI_finalblow
-------------------------------------
function UI_ClanRaidBossInfo:initUI_finalblow()
    local vars = self.vars

end

-------------------------------------
-- function initMonsterList
-------------------------------------
function UI_ClanRaidBossInfo:initMonsterList()
    local vars = self.vars
    local node = vars['monsterListNode']
    node:removeAllChildren()

    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local stage_id = struct_raid:getStageID()
    local _, boss_mid = g_stageData:isBossStage(stage_id)
    local l_monster = g_stageData:getMonsterIDList(stage_id)

    -- 생성
    local function make_func(data)
        local mid = data
        local is_boss = (boss_mid == mid)
        local ui = UI_MonsterCustomCard(data)
        if (not is_boss) then
            ui:makeFrame('character_card_frame.png')
        end

        return ui
    end

    -- 생성 콜백
    local function create_func(ui, data)
        local mid = data
        local click_btn = ui.vars['clickBtn']
        click_btn:registerScriptTapHandler(function() self:click_partInfo(ui, mid) end)

        if (mid == boss_mid) then
            self.m_sel_ui = ui
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(152, 150)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_monster, true)
    table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬

    local function sort_func(a, b) 
        return a['data'] < b['data']
    end
    table.sort(table_view.m_itemList, sort_func)
    table_view:makeAllItemUI()
end

-------------------------------------
-- function initBossVrp
-------------------------------------
function UI_ClanRaidBossInfo:initBossVrp(target_node)
    local vars = self.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local stage_id = struct_raid:getStageID()
    local _, boss_mid = g_stageData:isBossStage(stage_id)

    -- 보스 animator
    local boss_node = target_node
    boss_node:removeAllChildren()

    local l_monster = g_stageData:getMonsterIDList(stage_id)
    for _, mid in ipairs(l_monster) do
        local res, attr, evolution = TableMonster:getMonsterRes(mid)
        animator = AnimatorHelper:makeMonsterAnimator(res, attr, evolution)

        if (animator) then
            local zOrder = WORLD_Z_ORDER.BOSS
            local idx = getDigit(mid, 10, 1)
            if (idx == 1) and (mid == boss_mid) then
                zOrder = WORLD_Z_ORDER.BOSS     
            elseif (idx == 1) then
                zOrder = WORLD_Z_ORDER.BOSS + 1
            elseif (idx == 7) then
                zOrder = WORLD_Z_ORDER.BOSS
            else
                zOrder = WORLD_Z_ORDER.BOSS + 1 + 7 - idx
            end
            boss_node:addChild(animator.m_node, zOrder)
            animator:setFlip(true)
            animator:changeAni('idle', true)
        end

        self.m_map_animator[mid] = animator
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidBossInfo:refresh()
    self:refresh_BossInfo()
    self:refresh_SkillInfo()
end

-------------------------------------
-- function refresh_BossInfo
-------------------------------------
function UI_ClanRaidBossInfo:refresh_BossInfo()
    local vars = self.vars
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local origin_name = struct_raid:getBossNameWithLv(true)
    vars['nameLabel']:setString(origin_name)

    local name = TableMonster:getMonsterName(self.m_sel_mid)
    vars['nameLabel']:setString(name)

    for mid, animator in pairs(self.m_map_animator) do
        -- 선택하지 않은 경우 회색 처리
        if (mid == self.m_sel_mid) then
            animator.m_node:setColor(COLOR['white'])
        else
            animator.m_node:setColor(cc.c3b(70, 70, 70))
        end
    end
end

-------------------------------------
-- function refresh_SkillInfo
-------------------------------------
function UI_ClanRaidBossInfo:refresh_SkillInfo()
    local vars = self.vars
    local t_monster = TableMonster():get(self.m_sel_mid)
    local t_skill = TableMonsterSkill()

    -- 기본 공격 표시
    local skill_node = vars['skillNode1']
    skill_node:removeAllChildren()

    local skill_id = t_monster['skill_basic']
    if (skill_id) and (skill_id ~= '') then
        local t_skill = t_skill:get(skill_id)
        local icon = UI_MonsterSkillCard('monster', skill_id)
        skill_node:addChild(icon.root)
    end

    -- 스킬 표시
    for i = 1, 5 do
        local skill_node = vars['skillNode' .. i+1]
        skill_node:removeAllChildren()

        local skill_id = t_monster['skill_'..i]
        if (skill_id) and (skill_id ~= '') then
            local t_skill = t_skill:get(skill_id)
            local icon = UI_MonsterSkillCard('monster', skill_id)
            skill_node:addChild(icon.root)
        end
    end
end

-------------------------------------
-- function click_partInfo
-------------------------------------
function UI_ClanRaidBossInfo:click_partInfo(ui, data)
    local mid = data

    -- 선택된 mid 갱신
    if (self.m_sel_mid == mid) then
        return
    end
    self.m_sel_mid = mid

    -- 선택된 UI 갱신
    if (self.m_sel_ui) then
        self.m_sel_ui:setHighlightSpriteVisible(false)
    end
    self.m_sel_ui = ui
    self.m_sel_ui:setHighlightSpriteVisible(true)

    self:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ClanRaidBossInfo:click_closeBtn()
    self:close()
end