--@inherit UI
local PARENT = UI_DragonManage_Base

-------------------------------------
---@class UI_DragonRecall
-------------------------------------
UI_DragonRecall = class(PARENT, {
    m_index = 'number',
    m_structRecallList = 'table', -- List<StructRecall>
    
    m_tableView = 'UIC_TableView',
    m_elapsedTime = 'number',
})

-------------------------------------
-- function initParentVariable
-------------------------------------
function UI_DragonRecall:initParentVariable()
end

-------------------------------------
-- function init
---@param struct_dragon_object StructDragonObject
-------------------------------------
function UI_DragonRecall:init(struct_dragon_object)
    self.m_uiName = 'UI_DragonRecall'
    self.m_resName = 'dragon_recall.ui'
    self.m_titleStr = Str('리콜')
    self.m_bVisible = true
    self.m_bUseExitBtn = true

    self.m_structRecallList = g_dragonsData:getRecallList()
    self.m_index = 1

    self.m_selectDragonOID = struct_dragon_object:getObjectId()
    self.m_selectDragonData = struct_dragon_object    
    self.m_elapsedTime = 1
end

-------------------------------------
-- function init_after
---@param struct_dragon_object StructDragonObject
-------------------------------------
function UI_DragonRecall:init_after(struct_dragon_object)
    if table.isEmpty(self.m_structRecallList) then
        UIManager:toastNotificationGreen(Str('대상이 없습니다.'))
        return
    end

    local vars = self:load(self.m_resName)
    UIManager:open(self, UIManager.SCENE)

    PARENT.init_after(self)

    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, self.m_uiName)

    -- self:doActionReset()
    -- self:doAction(nil, false)
    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    if vars['timeLabel'] then
        self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRecall:initUI()
    local vars = self.vars

    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRecall:initButton()
    local vars = self.vars

    vars['recallBtn']:registerScriptTapHandler(function() self:click_recallBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRecall:refresh()
    local vars = self.vars
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject

    if (not dragon_obj) then
        return
    end

    self:refresh_recallTarget()
    self:refresh_recallResult()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonRecall:click_closeBtn()
    self:close()
end

-------------------------------------
-- function getDragonList
---@return table
-------------------------------------
function UI_DragonRecall:getDragonList()
    local item_list = {}

    for idx, struct_recall in ipairs(self.m_structRecallList) do
        local dragon_list = struct_recall:getTargetDragonList()
        item_list = table.merge(item_list, dragon_list)
    end

    for idx, struct_dragon_object in ipairs(item_list) do
        
    end

    return item_list
end

-------------------------------------
-- function getTargetStructRecall
---@return StructRecall
-------------------------------------
function UI_DragonRecall:getTargetStructRecall()
    return self.m_structRecallList[self.m_index]
end

-------------------------------------
-- function refresh_recallTarget
-------------------------------------
function UI_DragonRecall:refresh_recallTarget()
    local vars = self.vars
    ---@type StructDragonObject
    local struct_dragon_object = self:getSelectDragonObj() -- StructDragonObject

    if (not struct_dragon_object) then
        return
    end

    local temp = Str('같은 종류의 드래곤은 기간 내 1회 리콜을 진행할 수 있습니다.')

    do
        local did = struct_dragon_object:getDid()
        for idx, struct_recall in ipairs(self.m_structRecallList) do
            if (struct_recall:getTargetDid() == did) then
                self.m_index = idx
                break
            end
        end
    end


    do -- 드래곤 이름
        local dragon_name = struct_dragon_object:getDragonNameWithEclv()
        vars['dragonNameLabel']:setString(dragon_name)
    end

    do -- 드래곤 속성
        local attr = struct_dragon_object:getAttr()
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        local role_type = struct_dragon_object:getRole()
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    end

    do -- 드래곤 아이콘
        vars['dragonIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(struct_dragon_object)
        vars['dragonIconNode']:addChild(dragon_card.root)
    end

    -- 배경
    if vars['bgNode'] then    
        local attr = struct_dragon_object:getAttr()
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function refresh_recallResult
-------------------------------------
function UI_DragonRecall:refresh_recallResult()
    local vars = self.vars

    local list_node = vars['listNode']
    list_node:removeAllChildren()
    self.m_tableView = nil

    local function make_func(data)
        local ui = UI_ItemCard(data['item_id'], data['count'])

        return ui
    end

    local function create_func(ui, data)
        ui.root:setScale(0.58)
    end

    local table_view = UIC_TableViewTD(list_node)
    table_view.m_cellSize = cc.size(90, 90)
    table_view.m_nItemPerCell = 6
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(make_func, create_func)

    local item_list = self:getTempList()
    table_view:setItemList(item_list)

    self.m_tableView = table_view
end

-------------------------------------
-- function getTempList
---@return table
-------------------------------------
function UI_DragonRecall:getTempList()
    local item_list = {}
    local gold = 0

    ---@type StructDragonObject
    local struct_dragon_object = self:getSelectDragonObj() -- StructDragonObject
    local did = struct_dragon_object:getDid()
    local grade = struct_dragon_object:getGrade()
    local evolution = struct_dragon_object:getEvolution()
    local curr_lv = struct_dragon_object:getLv()
    local is_myth_dragon = (struct_dragon_object:getRarity() == 'myth')

    -- 레벨업 필요 골드, 경험치 계산
    local exp = struct_dragon_object['exp']
    if (curr_lv > 1) then
        local table_dragon_exp = TableDragonExp()
        

        local required_gold, required_exp = table_dragon_exp:getGoldAndDragonEXPForDragonLevelUp(grade, 1, curr_lv, is_myth_dragon)
        exp = exp + required_exp
        gold = gold + required_gold
    end
    if (exp > 0) then
        table.insert(item_list, {item_id = 700017, count = exp})
    end


    -- 진화 필요 재료 및 골드
    if (evolution > 1) then
        local temp = {}
        local table_dragon_evolution = TABLE:get('dragon_evolution')
        local t_dragon_evolution = table_dragon_evolution[did]

        for idx = evolution, 2, -1 do
            local evolution_str = ''
            if (idx == 2) then
                evolution_str = 'hatchling'
            elseif (idx == 3) then
                evolution_str = 'adult'
            else
                break
            end
            -- 진화 재료 3종류
            for i = 1, 3 do
                local item_id = t_dragon_evolution[evolution_str .. '_item' .. i]
                local item_value = t_dragon_evolution[evolution_str .. '_value' .. i]
                
                if (temp[item_id] == nil) then temp[item_id] = 0 end
                temp[item_id] = temp[item_id] + item_value
            end

            -- 골드
            gold = gold + (t_dragon_evolution[evolution_str .. '_gold'] or 0)
        end 

        for item_id, count in pairs(temp) do
            table.insert(item_list, {item_id = item_id, count = count})
        end
    end

    -- 친밀도
    local struct_friendship_object = struct_dragon_object:getFriendshipObject()
    local curr_flv = struct_friendship_object:getFlv()
    local fexp = struct_friendship_object:getFexp()

    fexp = fexp + TableFriendship:getFriendshipReqExpBtwLevels(0, curr_flv - 1, is_myth_dragon)
    if (fexp > 0) then
        local attr = struct_dragon_object:getAttr()
        local fruit_list = TableItem:getFruitsListByAttr(attr)
        -- 특급 속성 열매로 지급
        local rare_fruit = table.getLast(fruit_list) 
        local rare_fid = rare_fruit['item']
        local cumulative_exp = TableFruit:getFruitFeel(rare_fid)
        
        local item_num = math_floor(fexp / cumulative_exp)

        if (fexp % cumulative_exp >= 0) then
            item_num = item_num + 1
        end

        table.insert(item_list, {item_id = rare_fid, count = item_num})
    end

    -- 외형 변환
    if struct_dragon_object:isAppearanceChanged() then
        local map_material = TableDragonTransform():getMaterialInfoByDragon(struct_dragon_object)

        for i = 1, 4 do
            local key = 'material_' .. tostring(i)
            local data = map_material[key]
            table.insert(item_list, {item_id = data['item_id'], count = data['cnt']})
        end

        
        gold = gold + (map_material['gold'] or 0)
    end

    local result = {}

    -- 신화 드래곤 선택권 1개
    table.insert(result, {item_id = 700319, count = 1})

    -- 스킬 레벨업 수만큼의 스킬 레벨업 티켓
    local skill_point = struct_dragon_object:getDragonSkillLevelUpNum()
    if (skill_point > 0) then
        table.insert(result, {item_id = 779275, count = skill_point})
        gold = gold + TableDragon:getBirthGrade(did) * 10000 * skill_point
    end

    if (gold > 0) then
        table.insert(item_list, {item_id = 700002, count = gold})
    end

    table.sort(item_list, function(a, b)
        return a['item_id'] < b['item_id']
    end)


    for i, data in ipairs(item_list) do
        table.insert(result, data)
    end

    local rune_obj_list = struct_dragon_object:getRuneObjectList()

    for index, struct_rune_object in pairs(rune_obj_list) do
        
        table.insert(result, {item_id = struct_rune_object['item_id'], count = 1, struct_rune_object})
    end


    return result
end

-------------------------------------
-- function update
---@param dt number
-------------------------------------
function UI_DragonRecall:update(dt)
    self.m_elapsedTime = self.m_elapsedTime + dt

    if (self.m_elapsedTime < 1) then
        return
    end

    local vars = self.vars
    self.m_elapsedTime = 0

    if vars['timeLabel'] then
        local struct_recall = self:getTargetStructRecall()
        local time_str = struct_recall:getRemainingTimeStr()
        vars['timeLabel']:setString(time_str)
    end
end

-------------------------------------
-- function click_recallBtn
-------------------------------------
function UI_DragonRecall:click_recallBtn()
    require('UI_DragonRecallConfirm')

    ---@type StructDragonObject
    local struct_dragon_object = self:getSelectDragonObj() -- StructDragonObject
    local doid = struct_dragon_object:getObjectId()
    	-- 작별 가능한지 체크
	local possible, msg = g_dragonsData:possibleMaterialDragon(doid)
	if (not possible) then
		UIManager:toastNotificationRed(msg)
        return
	end

    local function close_cb(is_recalled)
        if is_recalled then
            self:click_closeBtn()
        end
    end

    local ui = UI_DragonRecallConfirm(struct_dragon_object)
    ui:setCloseCB(close_cb)
end