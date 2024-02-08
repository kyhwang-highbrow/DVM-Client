local PARENT = UIC_ExtendedUI
-------------------------------------
-- class UIC_ExtenedUI_Shop
-------------------------------------
UIC_ExtenedUI_Shop = class(PARENT, {
    })

local THIS = UIC_ExtenedUI_Shop


-------------------------------------
-- function create
-------------------------------------
function UIC_ExtenedUI_Shop:create(ui_res)
    -- UI파일을 읽어옴
    local ui = UI()
    local vars = ui:load(ui_res)

    -- UIC_ExtenedUI_Shop instance를 생성
    local extended_ui = UIC_ExtenedUI_Shop(ui.root)    
    extended_ui.vars = vars

    do -- 숨겨져있던 버튼들의 숨겨진 첫 위치를 지정
        local base_node = vars['baseNode']
        if base_node then
            local x, y = base_node:getPosition()
            extended_ui.m_basePosX = x
            extended_ui.m_basePosY = y
        end
    end

    do -- luaname으로 버튼들의 정보를 생성 'Btn'으로 종료되는 node
        extended_ui.m_lBtnInfo = {}
        for luaname,node in pairs(vars) do
            if pl.stringx.endswith(luaname, 'Btn') then
                -- 버튼 정보 생성 후 리스트에 저장
                local t_btn_info = {}
                t_btn_info['btn'] = node

                local x, y = node:getPosition()
                t_btn_info['x'] = x
                t_btn_info['y'] = y
                table.insert(extended_ui.m_lBtnInfo, t_btn_info)
            end
        end
    end

    -- 배경 이미지 지정
    extended_ui.m_bgNode = vars['bg'] or extended_ui.m_node

    -- 첫 위치를 잡아줌
    extended_ui:initFirst()

    return extended_ui
end


-------------------------------------
-- function initFirst
-------------------------------------
function UIC_ExtenedUI_Shop:initFirst()

    PARENT.initFirst(self)
    self.m_node:scheduleUpdateWithPriorityLua(function()
        self:update()
    end, 1)

    self:initUI()
end

-------------------------------------
--- @function initUI
-------------------------------------
function UIC_ExtenedUI_Shop:initUI()
    local vars = self.vars
    self:refreshShopHottimeNoti()

    -- 상점 UI  
    vars['capsuleBoxBtn']:registerScriptTapHandler(function() self:click_capsuleBoxBtn() end) -- 캡슐 뽑기 버튼
    vars['randomShopBtn']:registerScriptTapHandler(function() self:click_randomShopBtn() end) -- 랜덤 상점
    vars['shopBtn']:registerScriptTapHandler(function() self:click_shopBtn() end) -- 상점
end

-------------------------------------
--- @function udpate
-------------------------------------
function UIC_ExtenedUI_Shop:update(delta)
    local vars = self.vars
    -- 캡슐뽑기 노티 (1개 이상 보유시)
    do
        local visible = (g_userData:get('capsule_coin') > 0)
        vars['capsuleBoxNotiSprite']:setVisible(visible)
    end

    -- 랜덤 상점 노티 (상품 갱신시)
    do
        local is_highlight = g_randomShopData:isHightlightShop()
        vars['randomShopNotiSprite']:setVisible(is_highlight)
        vars['randomShopLabel']:setVisible(not is_highlight)
        vars['randomShopLabel']:setString(g_randomShopData:getRefreshRemainTimeText())
    end

	-- 캡슐 신전 버튼
	if (not g_contentLockData:isContentLock('capsule')) then
		vars['capsuleBoxBtn']:setVisible(true)
        -- lobby ui 에서 capsule refill 정보 표시 여부
        local is_refill, is_refill_completed = g_capsuleBoxData:isRefillAndCompleted(--[[is_lobby: ]]false)
        vars['refillMenu']:setVisible(is_refill)
        if (is_refill) then
            vars['refillReservedMenu']:setVisible(not is_refill_completed)
            vars['refillCompletedMenu']:setVisible(is_refill_completed)
        end
	else
		vars['capsuleBoxBtn']:setVisible(false)
	end
end

-------------------------------------
-- function show
-------------------------------------
function UIC_ExtenedUI_Shop:show()
    PARENT.show(self)
    self:refreshShopHottimeNoti()
end

-------------------------------------
-- function show
-------------------------------------
function UIC_ExtenedUI_Shop:hide()
    PARENT.hide(self)
    self:refreshShopHottimeNoti()
end

-------------------------------------
-- function refreshShopHottimeNoti
-------------------------------------
function UIC_ExtenedUI_Shop:refreshShopHottimeNoti()
    local vars = self.vars
    vars['shopEventNoti']:setVisible(false)

    if self.m_bShow == false then
        return
    end

    -- 다이아 
    if (g_shopDataNew:checkDiaSale()) then
        self:setShopSpecialNoti('noti_dia')

    -- 인기 소환
    elseif (g_hotTimeData:isActiveEvent('event_popularity')) then
        self:setShopSpecialNoti('noti_event_popularity')

    -- 복주머니 1
    elseif g_hotTimeData:isActiveEvent('noti_lucky_bag') then
        if (g_eventLFBagData:canPlay() or g_eventLFBagData:canReward()) then
            self:setShopSpecialNoti('noti_lucky_bag')
        end

    -- 복주머니 2
    elseif g_hotTimeData:isActiveEvent('noti_lucky_marble') then
        if (g_eventLFBagData:canPlay() or g_eventLFBagData:canReward()) then
            self:setShopSpecialNoti('noti_lucky_marble')
        end

    -- 룰렛
    elseif g_hotTimeData:isActiveEvent('event_roulette') then
        self:setShopSpecialNoti('noti_roulette_ticket')

    -- 룬 페스티발, 할로윈
    elseif g_hotTimeData:isActiveEvent('event_rune_festival') then
        local version_key = g_eventRuneFestival:getEventVersionKey()

        if string.find(version_key, 'halloween') ~= nil then
            self:setShopSpecialNoti('noti_holoween')
        elseif string.find(version_key, 'summer') ~= nil then
            self:setShopSpecialNoti('noti_summer')
        elseif string.find(version_key, 'whiteday') ~= nil then
            self:setShopSpecialNoti('noti_summer')
        end
    end
end

-------------------------------------
-- function setShopSpecialNoti
-------------------------------------
function UIC_ExtenedUI_Shop:setShopSpecialNoti(event_name)
    local vars = self.vars
    local visual_list = vars['shopEventNoti']:getVisualList()
    for _, visual_id in ipairs (visual_list) do
        if (visual_id == event_name) then
            vars['shopEventNoti']:changeAni(visual_id, true)
            vars['shopEventNoti']:setVisible(true)
            break
        end
        vars['shopEventNoti']:setVisible(false)
    end
end

-------------------------------------
-- function click_shopBtn
-- @brief 상점 버튼
-------------------------------------
function UI_Lobby:click_shopBtn()
    g_shopDataNew:openShopPopup()    
end

-------------------------------------
-- function click_capsuleBoxBtn
-------------------------------------
function UI_Lobby:click_capsuleBoxBtn()
	g_capsuleBoxData:openCapsuleBoxUI()
end

-------------------------------------
-- function click_randomShopBtn
-------------------------------------
function UI_Lobby:click_randomShopBtn()
    UINavigator:goTo('shop_random')
end