local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_NestDungeonStageListItem
-------------------------------------
UI_NestDungeonStageListItem = class(PARENT, {
        m_stageTable = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NestDungeonStageListItem:init(t_data)
    local vars = self:load('nest_dungeon_stage_list_item.ui')

    self.m_stageTable = t_data

    self:initUI(t_data)
    self:initButton()
    self:refresh()

    --self.root:setDockPoint(cc.p(0, 0))
    --self.root:setAnchorPoint(cc.p(0, 0))
end
-------------------------------------
-- function initUI
-------------------------------------
function UI_NestDungeonStageListItem:initUI(t_data)
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NestDungeonStageListItem:initButton()
    local vars = self.vars
    vars['enterButton']:registerScriptTapHandler(function() self:enterButton() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NestDungeonStageListItem:refresh()
    local vars = self.vars

    do -- 스테이지 이름
        local name = Str(self.m_stageTable['t_name'])
        vars['dungeonNameLabel']:setString(name)
    end
    

    do -- 드랍 아이템 표시
        local stage_id = self.m_stageTable['stage']

        local drop_helper = DropHelper(stage_id)
        local l_item_list = drop_helper:getDisplayItemList()

        for i=1, 4 do
            local item_id = l_item_list[i]
            if item_id then
                local ui = UI_ItemCard(item_id)
                vars['rewardNode' .. i]:addChild(ui.root)
                ui.root:setSwallowTouch(false)
                ui.root:setScale(0.55)
            end
        end
    end

    do -- 티어 표시
        local stage_id = self.m_stageTable['stage']
        local t_dungeon_id_info = g_nestDungeonData:parseNestDungeonID(stage_id)
        local tier = t_dungeon_id_info['tier']
        vars['dungeonLevelLabel']:setString(Str('{1}단계', tier))
    end

    do -- 스태미나 갯수 표시
        local cost_value = self.m_stageTable['cost_value']
        vars['actingPowerLabel']:setString(comma_value(cost_value))
    end

    do -- 오픈 여부
        local stage_id = self.m_stageTable['stage']
        local is_open = g_stageData:isOpenStage(stage_id)

        vars['lockNode']:setVisible(not is_open)
        vars['enterButton']:setVisible(is_open)
    end
end

-------------------------------------
-- function enterButton
-------------------------------------
function UI_NestDungeonStageListItem:enterButton()
    local stage_id = self.m_stageTable['stage']
    UI_AdventureStageInfo(stage_id)
end