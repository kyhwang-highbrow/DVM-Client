local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcheryIncubateTab
-------------------------------------
UI_HatcheryIncubateTab = class(PARENT,{
        m_eggPicker = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryIncubateTab:init(owner_ui)
    local vars = self:load('hatchery_incubate.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_HatcheryIncubateTab:onEnterTab(first)
    cclog('## UI_HatcheryIncubateTab:onEnterTab(first)')

    if first then
        local vars = self.vars
        local parent_node = vars['eggFickerNode']

        -- UIC_EggPicker 생성
        local egg_picker = UIC_EggPicker:create(parent_node)

        egg_picker.m_itemWidth = 250 -- 알의 가로 크기
        egg_picker.m_nearItemScale = 0.66
        self.m_eggPicker = egg_picker

        local function click_egg(t_item, idx)
            self:click_eggItem(t_item, idx)
        end
        egg_picker:setItemClickCB(click_egg)

        self:refreshEggList()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcheryIncubateTab:onExitTab()
    cclog('## UI_HatcheryIncubateTab:onExitTab()')
end

-------------------------------------
-- function click_eggItem
-------------------------------------
function UI_HatcheryIncubateTab:click_eggItem(t_item, idx)
    local function finish_cb(ret)
    local l_dragon_list = ret['added_dragons']
        UI_GachaResult_Dragon(l_dragon_list)

        -- 리스트 갱신
        self:refreshEggList()
    end

    local function fail_cb()

    end

    local t_data = t_item['data']
    local egg_id = t_data['egg_id']
    local cnt = t_data['count']

    g_eggsData:request_incubate(egg_id, cnt, finish_cb, fail_cb)
end

local is_first = true

-------------------------------------
-- function refreshEggList
-------------------------------------
function UI_HatcheryIncubateTab:refreshEggList()
    local egg_picker = self.m_eggPicker

    egg_picker:clearAllItems()
        
    local l_item_list = g_eggsData:getEggListForUI()
    if (is_first == false) then
        table.remove(l_item_list, 1)
    end

    local table_item = TableItem()
    

    for i,v in ipairs(l_item_list) do
        local egg_id = tonumber(v['egg_id'])
        local _res = table_item:getValue(egg_id, 'full_type')
        local res = 'res/item/egg/' .. _res .. '.png'

        local scale = 0.8
        local sprite = cc.Sprite:create(res)
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setScale(scale)

        local data = v

        local ui = {}
        ui.root = sprite
            
        egg_picker:addEgg(data, ui)
    end

    -- 2번째 아이템을 포커스
    --egg_picker:setFocus(2)


    is_first = false
end