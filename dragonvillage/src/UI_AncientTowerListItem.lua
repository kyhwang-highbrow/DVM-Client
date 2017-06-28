local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_AncientTowerListItem
-------------------------------------
UI_AncientTowerListItem = class(PARENT, {
        m_stageTable = 'table',
    })

    -------------------------------------
    -- function init
    -------------------------------------
    function UI_AncientTowerListItem:init(t_data)
        local vars = self:load('tower_scene_item.ui')

        self.m_stageTable = t_data

        self:initUI(t_data)
        self:initButton()
        self:refresh()

        self.m_cellSize = cc.size(800, 150)
    end

    -------------------------------------
    -- function initUI
    -------------------------------------
    function UI_AncientTowerListItem:initUI(t_data)
        local vars = self.vars

        local stage_id = self.m_stageTable['stage']
        local floor = g_ancientTowerData:getFloorFromStageID(stage_id)
        local clear_floor = g_ancientTowerData.m_clearFloor

        -- 층 수 표시
        vars['floorLabel']:setString(Str('{1}층', floor))

        -- 클리어시 보상 표시
        local t_info = TABLE:get('anc_floor_reward')[stage_id]
        if (t_info) then
            local l_str = (floor > clear_floor) and seperate(t_info['reward_first'], ';') or seperate(t_info['reward_repeat'], ';')
            local item_type = l_str[1]
            local item_id = TableItem:getItemIDFromItemType(item_type) or tonumber(item_type)
            local item_count = tonumber(l_str[2])

            local item_card = UI_ItemCard(item_id, item_count)
            item_card.vars['clickBtn']:setEnabled(false)
            vars['rewardNode']:addChild(item_card.root)
        end
        
        --
        local is_open = g_ancientTowerData:isOpenStage(stage_id)
        local visual_id

        if (is_open) then   visual_id = 'normal'
        else                visual_id = 'lock'
        end

        vars['towerVisual']:changeAni(visual_id, true)
        vars['lockSprite']:setVisible(not is_open)
    end

    -------------------------------------
    -- function initButton
    -------------------------------------
    function UI_AncientTowerListItem:initButton()
        local vars = self.vars
    
        vars['floorBtn']:getParent():setSwallowTouch(false)
    end

    -------------------------------------
    -- function refresh
    -------------------------------------
    function UI_AncientTowerListItem:refresh()
    end

-------------------------------------
-- class UI_AncientTowerListBottomItem
-------------------------------------
UI_AncientTowerListBottomItem = class(PARENT, {})

    -------------------------------------
    -- function init
    -------------------------------------
    function UI_AncientTowerListBottomItem:init(t_data)
        local vars = self:load('tower_scene_item.ui')

        vars['floorLabel']:setVisible(false)
        vars['floorBtn']:getParent():setSwallowTouch(false)
        vars['towerVisual']:changeAni('bottom', true)
    
        self.m_cellSize = cc.size(800, 150)
    end

-------------------------------------
-- class UI_AncientTowerListTopItem
-------------------------------------
UI_AncientTowerListTopItem = class(PARENT, {})

    -------------------------------------
    -- function init
    -------------------------------------
    function UI_AncientTowerListTopItem:init(t_data)
        local vars = self:load('tower_scene_item.ui')

        vars['floorLabel']:setVisible(false)
        vars['floorBtn']:getParent():setSwallowTouch(false)
        vars['towerVisual']:changeAni('top', true)
    
        self.m_cellSize = cc.size(800, 300)
    end