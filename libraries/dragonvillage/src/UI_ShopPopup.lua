local PARENT = UI

-------------------------------------
-- class UI_ShopPopup
-------------------------------------
UI_ShopPopup = class(PARENT, ITopUserInfo_EventListener:getCloneTable(), {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopPopup:init()
    local vars = self:load('shop_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    --------------------------------------------------------------------
    -- 추후에 지울 코드(하드코딩)
    vars['addCardBtn']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')

        for i,v in pairs(g_dragonListData.m_lDragonList) do
            v['cnt'] = v['cnt'] + 5
        end
        g_userData:setDirtyLocalSaveData()
        UIManager:toastNotificationGreen('모든 카드가 5장씩 증가하였습니다.')
    end)

    vars['addStoneBtn']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')

        for _,l_rarity in pairs(g_evolutionStoneData.m_tData) do
            for i,cnt in pairs(l_rarity) do
                l_rarity[i] = cnt + 5
            end
        end
        g_userData:setDirtyLocalSaveData()
        UIManager:toastNotificationGreen('모든 진화석이 5개씩 증가하였습니다.')
    end)

    vars['evolutionUp']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')

        for i,v in pairs(g_dragonListData.m_lDragonList) do
            local dragon_id = tonumber(v['did'])
            local force = true
            local ret = g_dragonListData:evolutionDragon(dragon_id, force)
        end

        UIManager:toastNotificationGreen('모든 드래곤 진화')
    end)

    vars['gradeUp']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')

        for i,v in pairs(g_dragonListData.m_lDragonList) do
            local dragon_id = tonumber(v['did'])
            local force = true
            local ret = g_dragonListData:upgradeDragon(dragon_id, force)
        end

        UIManager:toastNotificationGreen('모든 드래곤 승급')
    end)

	
	vars['evolutionDown']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')

        for i,v in pairs(g_dragonListData.m_lDragonList) do
            local dragon_id = tonumber(v['did'])
            local force = true
            local ret = g_dragonListData:unEvolutionDragon(dragon_id, force)
        end
        g_userData:setDirtyLocalSaveData(true)
        UIManager:toastNotificationGreen('모든 드래곤 퇴화')
    end)

	vars['gradeDown']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')

        for i,v in pairs(g_dragonListData.m_lDragonList) do
            local dragon_id = tonumber(v['did'])
            local force = true
            local ret = g_dragonListData:downgradeDragon(dragon_id, force)
        end
        g_userData:setDirtyLocalSaveData(true)
        UIManager:toastNotificationGreen('모든 드래곤 강등')
    end)

	vars['init']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')

        for i,v in pairs(g_dragonListData.m_lDragonList) do
            local dragon_id = tonumber(v['did'])
            local force = true
            local ret = g_dragonListData:initializeDragon(dragon_id, force)
        end
		g_userData:initTamer()
        g_userData:setDirtyLocalSaveData(true)
        
        UIManager:toastNotificationGreen('모든 드래곤 초기화')
		UIManager:toastNotificationGreen('테이머 초기화')
    end)

	vars['stageOpen']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')

        for i,v in pairs(g_dragonListData.m_lDragonList) do
            local dragon_id = tonumber(v['did'])
            local force = true
            local ret = g_adventureData:allStageClear()
        end

        UIManager:toastNotificationGreen('모든 스테이지 오픈!')
    end)
    
    vars['dragonLevelUp']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')

        for i,v in pairs(g_dragonListData.m_lDragonList) do
            local dragon_id = tonumber(v['did'])
            local ret = g_dragonListData:levelUpDragon(dragon_id)
        end
        g_userData:setDirtyLocalSaveData(true)
        UIManager:toastNotificationGreen('모든 드래곤 레벨 업')
    end)
    
    vars['tamerLevelUp']:registerScriptTapHandler(function()
        SoundMgr:playEffect('EFFECT', 'ui_button')
        g_userData:levelUpTamer()
        UIManager:toastNotificationGreen('테이머 레벨 업')
    end)
    
    --------------------------------------------------------------------

    self:initProductList()

    self:refreshData()

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ShopPopup')
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_ShopPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ShopPopup'
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initProductList
-- @brief
-------------------------------------
function UI_ShopPopup:initProductList()
    local table_shop = TABLE:get('shop')

    local l_pos = getSortPosList(260, #table_shop)

    for i,v in ipairs(table_shop) do
        local product_button = UI_ProductButton(self, i)
        self.root:addChild(product_button.root)

        local pos_x = l_pos[i]
        product_button.root:setPositionX(pos_x)
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ShopPopup:click_exitBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:close()
end

-------------------------------------
-- function refreshData
-- @brief 누적 구매 로그 출력
-------------------------------------
function UI_ShopPopup:refreshData()
    local vars = self.vars

    vars['gachaLogLabel']:setString('Gacha : ' .. comma_value(g_userData:getCumulativePurchasesLog('gacha')))
    vars['staminaLogLabel']:setString('Stamina : ' .. comma_value( g_userData:getCumulativePurchasesLog('stamina')))
    vars['goldLogLabel']:setString('Gold : ' .. comma_value(g_userData:getCumulativePurchasesLog('gold')))
    vars['cashLogLabel']:setString('Cash : ' .. comma_value(g_userData:getCumulativePurchasesLog('cash')))
end

-------------------------------------
-- function openShopPopup
-- @brief
-------------------------------------
function openShopPopup()
    UI_ShopPopup()
end