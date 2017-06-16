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


        local function onChangeCurrEgg(t_item, idx)
            self:onChangeCurrEgg(t_item, idx)
        end
        egg_picker:setChangeCurrFocusIndexCB(onChangeCurrEgg)

        self:refreshEggList()


        -- 테이머
        do
		    --local t_tamer =  g_tamerData:getCurrTamerTable()
            --local table_tamer = TableTamer()
            --local t_tamer = table_tamer:get(110002) -- 누리로 하드코딩 추후 NPC로 교체
            --local tamer_res = t_tamer['res']
            local res = 'res/character/npc/yuria/yuria.spine'
            local animator = MakeAnimator(res)
            animator.m_node:setDockPoint(cc.p(0.5, 0.5))
            animator.m_node:setDockPoint(cc.p(0.5, 0.5))
            self.vars['tamerNode']:addChild(animator.m_node)
		
		    -- 표정 적용
		    --local face_ani = TableTamer:getTamerFace(t_tamer['type'], true)
		    --animator:changeAni(face_ani, true)
            animator:changeAni('idle', true)
            --animator:setFlip(true)
        end
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcheryIncubateTab:onExitTab()
end

-------------------------------------
-- function click_eggItem
-------------------------------------
function UI_HatcheryIncubateTab:click_eggItem(t_item, idx)
    local t_data = t_item['data']

    if t_data['is_shop'] then
        UIManager:toastNotificationRed(Str('"알 상점"은 준비 중입니다.'))
        return
    end

    local egg_id = t_data['egg_id']
    local cnt = t_data['count']

    self:requestIncubate(egg_id, cnt)
end

-------------------------------------
-- function requestIncubate
-------------------------------------
function UI_HatcheryIncubateTab:requestIncubate(egg_id, cnt, old_ui)
    local function finish_cb(ret)

        -- 이어서 뽑기를 했을 때 이전 결과 UI가 통신 후에 닫히도록 처리
        if (old_ui) then
            old_ui:setCloseCB(nil)
            old_ui:close()
        end

        local l_dragon_list = ret['added_dragons']
        local ui = UI_GachaResult_Dragon(l_dragon_list)

        local function close_cb()
            self:sceneFadeInAction()
        end
        ui:setCloseCB(close_cb)

        -- 리스트 갱신
        self:refreshEggList()

        -- 
        local egg_picker = self.m_eggPicker
        if egg_picker.m_currFocusIndex then
            egg_picker:setFocus(egg_picker.m_currFocusIndex, 0.5)
        end

        do -- 이어서 뽑기 (단차 뽑기만 지원함)
            local remain_cnt = g_eggsData:getEggCount(egg_id)
            if (cnt == 1) and (cnt <= remain_cnt) then
                --ui.vars['summonBtn']:setVisible(true)
                ui.vars['summonBtn']:registerScriptTapHandler(function()
                        self:requestIncubate(egg_id, cnt, ui)
                    end)

                ui.vars['summonEggLabel']:setString(Str('X{1}', remain_cnt))
                local egg_icon = IconHelper:getEggIconByEggID(egg_id)
                ui.vars['summonEggNode']:addChild(egg_icon)

                table.insert(ui.m_hideUIList, ui.vars['summonBtn'])
            end
        end

        -- 하일라이트 노티 갱신을 위해 호출
        self.m_ownerUI:refresh_highlight()
    end

    local function fail_cb()

    end

    g_eggsData:request_incubate(egg_id, cnt, finish_cb, fail_cb)
end

-------------------------------------
-- function onChangeCurrEgg
-------------------------------------
function UI_HatcheryIncubateTab:onChangeCurrEgg(t_item, idx)
    local vars = self.vars
    local t_data = t_item['data']

    if t_data['is_shop'] then
        vars['nameLabel']:setString('상점')
        vars['descLabel']:setString('')
        return
    end

    local egg_id = tonumber(t_data['egg_id'])
    local cnt = t_data['count']

    local table_item = TableItem()
    local name = table_item:getValue(egg_id, 't_name')

    if (1 < cnt) then
        name = name .. 'X' .. cnt
    end
    vars['nameLabel']:setString(name)

    local desc = table_item:getValue(egg_id, 't_desc')
    vars['descLabel']:setString(desc)
end

-------------------------------------
-- function refreshEggList
-------------------------------------
function UI_HatcheryIncubateTab:refreshEggList()
    local egg_picker = self.m_eggPicker

    egg_picker:clearAllItems()
        
    local l_item_list = g_eggsData:getEggListForUI()
    local table_item = TableItem()
    
    -- Shop Egg 추가
    do
        local scale = 0.8
        local sprite = cc.Sprite:create('res/item/egg/egg_shop.png')
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setScale(scale)

        local data = {['is_shop']=true}

        local ui = {}
        ui.root = sprite

        egg_picker:addEgg(data, ui)
    end

    -- 알들 추가
    for i,v in ipairs(l_item_list) do
        local egg_id = tonumber(v['egg_id'])
        local _res = table_item:getValue(egg_id, 'full_type')
        if (v['cnout'] == 10) then
            _res = _res .. '_10'
        end
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

    -- 2번째 아이템을 포커스 (1번째 아이템은 "상점")
    egg_picker:setFocus(2)
end