local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcheryIncubateTab
-------------------------------------
UI_HatcheryIncubateTab = class(PARENT,{
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

        local l_agg_res = {}
        table.insert(l_agg_res, 'dark_egg')
        table.insert(l_agg_res, 'earth_egg')
        table.insert(l_agg_res, 'fire_egg')
        table.insert(l_agg_res, 'friendship_egg')
        table.insert(l_agg_res, 'illusion_egg')
        table.insert(l_agg_res, 'legend_egg')
        table.insert(l_agg_res, 'light_egg')
        table.insert(l_agg_res, 'miracle_egg')
        table.insert(l_agg_res, 'mystery_egg')
        table.insert(l_agg_res, 'mysteryup_egg')
        table.insert(l_agg_res, 'unknown_egg')
        table.insert(l_agg_res, 'water_egg')
        

        -- 200개의 아이템 임시 추가
        for i=1, 200 do
            local rand_idx = math_random(1, #l_agg_res)
            local _res = l_agg_res[rand_idx]
            local res = 'res/item/egg/' .. _res .. '.png'
            egg_picker:addEgg(res)
        end

        -- 10번째 아이템을 포커스
        --egg_picker:setFocus(10)
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcheryIncubateTab:onExitTab()
    cclog('## UI_HatcheryIncubateTab:onExitTab()')
end