local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcherySummonTab
-------------------------------------
UI_HatcherySummonTab = class(PARENT,{
        m_eggPicker = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcherySummonTab:init(owner_ui)
    local vars = self:load('hatchery_summon.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_HatcherySummonTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
        self:init_eggFicker()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcherySummonTab:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcherySummonTab:initUI()
    local vars = self.vars

    do -- 배너
        local animator = MakeAnimator('res/ui/event/summon_banner_01.png')
        vars['bannerNode']:addChild(animator.m_node)
    end

    -- 테이머
    do
		--local t_tamer =  g_tamerData:getCurrTamerTable()
        local table_tamer = TableTamer()
        local t_tamer = table_tamer:get(110002) -- 누리로 하드코딩 추후 NPC로 교체
        local tamer_res = t_tamer['res']
        local animator = MakeAnimator(tamer_res)
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        self.vars['tamerNode']:addChild(animator.m_node)
		
		-- 표정 적용
		--local face_ani = TableTamer:getTamerFace(t_tamer['type'], true)
		--animator:changeAni(face_ani, true)
        animator:changeAni('idle', true)
        animator:setFlip(true)
    end
end

-------------------------------------
-- function click_eventSummonBtn
-- @brief 확률업
-------------------------------------
function UI_HatcherySummonTab:click_eventSummonBtn(is_bundle)
    local function finish_cb(ret)
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local ui = UI_GachaResult_Dragon(l_dragon_list, l_slime_list)

        local function close_cb()
            self:sceneFadeInAction()
        end
        ui:setCloseCB(close_cb)

        -- 추가된 마일리지
        local added_mileage = ret['added_mileage'] or 0
        UIManager:toastNotificationGreen(Str('{1}마일리지가 적립되었습니다.', added_mileage))
    end

    local function fail_cb()
    end

    local is_sale = false
    g_hatcheryData:request_summonCashEvent(is_bundle, is_sale, finish_cb, fail_cb)
end

-------------------------------------
-- function click_cashSummonBtn
-- @brief 캐시 뽑기
-------------------------------------
function UI_HatcherySummonTab:click_cashSummonBtn(is_bundle)
    local function finish_cb(ret)
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local ui = UI_GachaResult_Dragon(l_dragon_list, l_slime_list)

        local function close_cb()
            self:sceneFadeInAction()
        end
        ui:setCloseCB(close_cb)

        -- 추가된 마일리지
        local added_mileage = ret['added_mileage'] or 0
        UIManager:toastNotificationGreen(Str('{1}마일리지가 적립되었습니다.', added_mileage))
    end

    local function fail_cb()
    end

    local is_sale = false
    g_hatcheryData:request_summonCash(is_bundle, is_sale, finish_cb, fail_cb)
end

-------------------------------------
-- function click_friendSummonBtn
-- @brief 우정포인트 뽑기
-------------------------------------
function UI_HatcherySummonTab:click_friendSummonBtn(is_bundle)
    local function finish_cb(ret)
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local ui = UI_GachaResult_Dragon(l_dragon_list, l_slime_list)

        local function close_cb()
            self:sceneFadeInAction()
        end
        ui:setCloseCB(close_cb)
    end

    local function fail_cb()
    end

    g_hatcheryData:request_summonFriendshipPoint(is_bundle, finish_cb, fail_cb)
end

-------------------------------------
-- function init_eggFicker
-------------------------------------
function UI_HatcherySummonTab:init_eggFicker()
    local vars = self.vars
    local parent_node = vars['eggFickerNode']

    -- UIC_EggPicker 생성
    local egg_picker = UIC_EggPicker:create(parent_node)

    egg_picker.m_itemWidth = 225 -- 알의 가로 크기
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
end

-------------------------------------
-- function refreshEggList
-------------------------------------
function UI_HatcherySummonTab:refreshEggList()
    local egg_picker = self.m_eggPicker

    egg_picker:clearAllItems()
        
    local l_item_list = g_hatcheryData:getSummonEggList()
    local table_item = TableItem()

    -- 알들 추가
    for i,v in ipairs(l_item_list) do
        local egg_id = tonumber(v['egg_id'])
        local _res = v['full_type']
        local res = 'res/item/egg/' .. _res .. '.png'

        local scale = 0.8 * 0.9
        local sprite = cc.Sprite:create(res)
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setScale(scale)

        local data = v

        local ui = {}
        ui.root = sprite
            
        egg_picker:addEgg(data, ui)
    end
end

-------------------------------------
-- function click_eggItem
-------------------------------------
function UI_HatcherySummonTab:click_eggItem(t_item, idx)
    local t_data = t_item['data']

    local egg_id = t_data['egg_id']
    local is_bundle = t_data['bundle']

    local function ok_btn_cb()
        if (egg_id == 700001) then
            self:click_eventSummonBtn(is_bundle)

        elseif (egg_id == 700002) then
            self:click_cashSummonBtn(is_bundle)

        elseif (egg_id == 700003) then
            self:click_friendSummonBtn(is_bundle)

        else
            error('egg_id ' .. egg_id)
        end
    end

    local cancel_btn_cb = nil

    local item_key = t_data['price_type']
    local item_value = t_data['price']
    local msg = Str('"{1}"를 진행하시겠습니까?', t_data['name'])

    MakeSimplePopup_Confirm(item_key, item_value, msg, ok_btn_cb, cancel_btn_cb)
end

-------------------------------------
-- function onChangeCurrEgg
-------------------------------------
function UI_HatcherySummonTab:onChangeCurrEgg(t_item, idx)
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
    --local name = table_item:getValue(egg_id, 't_name')
    local name = t_data['name']
    vars['nameLabel']:setString(name)

    --local desc = table_item:getValue(egg_id, 't_desc')
    local desc = t_data['desc']
    vars['descLabel']:setString(desc)

    do -- 가격
        local price = t_data['price']
        vars['priceLabel']:setString(comma_value(price))
    end

    do -- 아이콘
        local price_type = t_data['price_type']
        local price_icon
        if (price_type == 'cash') then
            price_icon = cc.Sprite:create('res/ui/icon/item/cash.png')
        elseif (price_type == 'fp') then
            price_icon = cc.Sprite:create('res/ui/icon/item/fp.png')
        else
            error('price_icon ' .. price_icon)
        end

        price_icon:setDockPoint(cc.p(0.5, 0.5))
        price_icon:setAnchorPoint(cc.p(0.5, 0.5))
        price_icon:setScale(0.5)

        vars['priceNode']:removeAllChildren()
        vars['priceNode']:addChild(price_icon)
    end
end