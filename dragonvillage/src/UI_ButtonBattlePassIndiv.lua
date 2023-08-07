local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonBattlePassIndiv
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonBattlePassIndiv = class(PARENT, {
        m_bActive = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonBattlePassIndiv:init()
    self:load('button_battle_pass_indiv.ui')
    self.m_bActive = false

    local vars = self.vars
    vars['passBtn']:registerScriptTapHandler(
        function () 
            self:click_battlePassBtn()
        end)
    
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonBattlePassIndiv:isActive()
    return self.m_bActive
end

-------------------------------------
-- function update
-- @brief UI_Lobby에서 매 프레임 호출됨
-------------------------------------
function UI_ButtonBattlePassIndiv:update(dt)

end

-------------------------------------
-- function click_battlePassBtn
-------------------------------------
function UI_ButtonBattlePassIndiv:click_battlePassBtn()
    local list = g_indivPassData:getEventRepresentProductList()

    if #list == 0 then
        return
    end

    local ui = UI_IndivPassScene()

    --local ui = UI_EventPopupTab_Package(list[1])
    --UIManager:open(ui, UIManager.SCENE)
    --g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'UI_EventPopupTab_Package')
end

-------------------------------------
-- function updateButtonStatus
-------------------------------------
function UI_ButtonBattlePassIndiv:updateButtonStatus()
    local vars = self.vars

    local list = g_indivPassData:getEventRepresentProductList()

    local is_available = #list > 0

    vars['passBtn']:setVisible(is_available)

    self.m_bActive = is_available

--[[     -- 모든 특별 할인 상품 visible을 꺼준다.
    for i=1, 10 do
        local btn = vars['specialOfferBtn' .. i]
        if btn then
            btn:setVisible(false)
        end
    end

    -- 상점에서 특별 할인 상품을 받아온다.
    local struct_product, idx, bonus_num = g_shopDataNew:getSpecialOfferProductNurture()

    -- UI가 없을 경우
    local button = vars['specialOfferBtn' .. idx]
    local time_label = vars['specialOfferLabel' .. idx]
    if (not button) or (not time_label) then
        return
    end

    -- 특별 할인 상품 유무에 따라서 초기화
    if struct_product then
        button:setVisible(true)

        -- 상품 클릭 시 패키지 팝업
        button:registerScriptTapHandler(function()
            -- local pid = struct_product['product_id']
            -- local package_name = TablePackageBundle:getPackageNameWithPid(pid)   
            -- local ui = UI_Package_Bundle(package_name, true)
            
            local ui = UI_Package({struct_product}, true, 'specialOffer')


            -- 혜택률 표시
            if ui.vars['bonusLabel'] then
                ui.vars['bonusLabel']:setString(Str('{1}%', bonus_num)) -- '800% 이상의 혜택!'
            end

            ui:doAction()

            -- 팝업이 닫히면 정보 다시 갱신
            ui:setBuyCB(function()
                if (struct_product:getDependency() == nil) then
                    self.m_bMarkDelete = true
                end
                self:callDirtyStatusCB()
                ui:close()
            end)
        end)

        -- 매 프레임 남은 시간을 표기한다.
        local function update(dt)
            local time_sec = struct_product:getTimeRemainingForEndOfSale()
            local time_millisec = (time_sec * 1000)
            local str = datetime.makeTimeDesc_timer(time_millisec)
            time_label:setString(str)
        end
        update(0) -- 최초 1번 호출
        time_label.m_node:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
        self.m_bActive = true
                
    else
        button:setVisible(false)
        time_label.m_node:unscheduleUpdate()
        self.m_bActive = false
    end ]]
end