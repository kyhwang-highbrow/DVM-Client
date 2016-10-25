local PARENT = UI

-------------------------------------
-- class UI_DragonEvolutionWindow
-------------------------------------
UI_DragonEvolutionWindow = class(PARENT, {
        m_parentUI = 'UI_DragonManageScene',
        m_bActive = 'boolean',

        m_nextEvolutionDragonAnimator = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonEvolutionWindow:init(parent_ui)
    self.m_parentUI = parent_ui
    local vars = self:load('evolution_window.ui')
    self.m_bActive = nil

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['invenBtn']:registerScriptTapHandler(function() self:click_invenBtn() end)
end

-------------------------------------
-- function setActive
-------------------------------------
function UI_DragonEvolutionWindow:setActive(active)
    if (self.m_bActive == active) then
        return
    end

    self.m_bActive = active

    -- 보여지기
    self.root:setVisible(active)

    if active then
        local vars = self.m_parentUI['vars']
        vars['nameLabel']:setVisible(true)
        vars['starNode']:setVisible(true)
        --vars['dragonNode']:setPosition(-154, 224)
        --vars['dragonNode']:stopAllActions()
        --vars['dragonNode']:runAction(cc.MoveTo:create(0.1, cc.p(-140, 280)))
        vars['bottomLeft']:setVisible(true)

        -- 드래곤 ID
        local dragon_id = self.m_parentUI.m_selectDragonButton.m_dataDragonID
        self:refresh(dragon_id)
    else
        if self.m_nextEvolutionDragonAnimator then
            self.m_nextEvolutionDragonAnimator:release()
            self.m_nextEvolutionDragonAnimator = nil
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonEvolutionWindow:refresh(dragon_id)
    local vars = self.vars

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    local t_dragon_data = g_dragonListData:getDragon(dragon_id)
    
    -- 진화 정보 얻어옴
    local rarity = dragonRarityStrToNum(t_dragon['rarity'])
    local table_evolution = TABLE:get('evolution')
    local t_evolution = table_evolution[rarity]

    local evolution = t_dragon_data['evolution']
    local l_need_stone = {} -- 필요 진화석
    for i=1, 4 do
        -- 키의 형태 'evo1_stone_01'
        local key = 'evo' .. evolution .. '_stone_0' .. i
        local need_stone = t_evolution[key]

        if need_stone > 0 then
            table.insert(l_need_stone, {i, need_stone})
        end
    end

    -- 최대 레벨인지 체크
    local key_gold = 'evo' .. evolution .. '_gold'
    local need_gold = t_evolution[key_gold]
    local is_max_evolution = (need_gold == 0)

    -- 최대레벨 확인
    if is_max_evolution then
        vars['okBtn']:setVisible(false)
        vars['bottomLeft']:setVisible(false)
        vars['maxLabel']:setVisible(true)
        vars['evolutionEffect']:setVisible(false)

        local dragon_node = self.m_parentUI['vars']['dragonNode']
        dragon_node:stopAllActions()
        dragon_node:runAction(cc.MoveTo:create(0.1, cc.p(0, 280)))
    else
        vars['okBtn']:setVisible(true)
        vars['priceLabel']:setString(comma_value(need_gold))
        vars['bottomLeft']:setVisible(true)
        vars['maxLabel']:setVisible(false)
        vars['evolutionEffect']:setVisible(true)

        local curr_max_lv = dragonMaxLevel(evolution)
        local next_max_lv = dragonMaxLevel(evolution + 1)
        vars['presentLvLabel']:setString('Lv.' .. curr_max_lv)
        vars['changeLvLabel']:setString('Lv.' .. next_max_lv)

        local dragon_node = self.m_parentUI['vars']['dragonNode']
        dragon_node:stopAllActions()
        dragon_node:runAction(cc.MoveTo:create(0.1, cc.p(-140, 280)))
    end

    -- 진화석 아이콘 출력
    local table_item = TABLE:get('item_sort_by_type')
    for i=1, 4 do
        vars['stoneNode' .. i]:removeAllChildren()
        if (l_need_stone[i]) then
            local stone_rarity = l_need_stone[i][1]
            local stone_count = l_need_stone[i][2]

            local full_type = DataEvolutionStone:makeEvolutionStoneFullType(stone_rarity, t_dragon['attr'])
            local t_item = table_item[full_type]
            local item_id = t_item['item']

            local item = UI_ItemCard(item_id, stone_count)
            vars['stoneNode' .. i]:addChild(item.root)

            do-- 보유 개수 / 필요 개수
                local real_stone_cnt = g_evolutionStoneData:getEvolutionStoneCount(stone_rarity, t_dragon['attr'])
                local str = Str('{1}/{2}', comma_value(real_stone_cnt), comma_value(stone_count))
                item:setString(str)
            end
        end
    end


    do 
        if self.m_nextEvolutionDragonAnimator then
            self.m_nextEvolutionDragonAnimator:release()
            self.m_nextEvolutionDragonAnimator = nil
        end

        if is_max_evolution then

        else
            self.m_nextEvolutionDragonAnimator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution + 1, t_dragon['attr'])
            self.m_nextEvolutionDragonAnimator.m_node:setDockPoint(cc.p(0.5, 0.5))
            self.m_nextEvolutionDragonAnimator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
            vars['afterNode']:addChild(self.m_nextEvolutionDragonAnimator.m_node)
        end
    end
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonEvolutionWindow:click_okBtn()

    -- 드래곤 ID
    local dragon_id = self.m_parentUI.m_selectDragonButton.m_dataDragonID

    local success, l_invalid_data = g_dragonListData:evolutionDragon(dragon_id)

    if success then
        self.m_parentUI:refreshSelectDragonInfo()
        UI_DragonEvolutionResult(dragon_id)
    else
        for _,t_invalid_data in ipairs(l_invalid_data) do
            UIManager:toastNotificationRed(t_invalid_data['msg'])
        end
    end
end

-------------------------------------
-- function click_invenBtn
-------------------------------------
function UI_DragonEvolutionWindow:click_invenBtn()
    UI_InventoryEvolutionStonePopup()
end