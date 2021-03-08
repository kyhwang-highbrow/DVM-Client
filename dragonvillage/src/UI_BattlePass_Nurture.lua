local PARENT = UI_Package

--------------------------------------------------------------------------
-- @classmod UI_BattlePass_Nurture
-- @brief 
--------------------------------------------------------------------------
UI_BattlePass_Nurture = class(PARENT, {
    m_pass_id = 'number',
    m_normal_key = '',
    m_premium_key = '',


    m_tableView = 'UIC_TableView',      -- 스크롤뷰 (횡스크롤)




    -- Nodes in ui file
    m_listNode = 'cc.Node',
    m_itemNode = 'cc.Node',

    m_timeLabel = '',

    m_levelExpBar = 'cc.Node',          -- 레벨당 경험치바 (게이지)
    m_originTotalExpScale = 'number',
    m_totalExpBar = 'cc.Node',          -- 패스 전체 경험치바 (게이지)

    m_questBtn = '',
    m_infoBtn = '',
    m_buyBtn = '',
    m_normalRewardBtn = '',
    m_passRewardBtn = '',

    m_originNextPointStr = '',
    m_nextPointLabel = '',
    
    m_originLevelStr = '',
    m_levelLabel = '',

    m_originNextLevelStr = '',
    m_nextLevelLabel = '',
})

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// pure virtual functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------
-- @function init 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:init(struct_product, is_popup)
end

--------------------------------------------------------------------------
-- @function initUI 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:initUI()
    self:initMember(self.m_structProduct)
    self:initTableView()
end

--------------------------------------------------------------------------
-- @function initButton 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:initButton()
    local vars = self.vars
    -- 
    self.m_questBtn:registerScriptTapHandler(function() self:click_questBtn() end)
    self.m_infoBtn:registerScriptTapHandler(function() self:click_infoBtn() end)
    self.m_buyBtn:registerScriptTapHandler(function() self:click_buyBtn() end)
    self.m_normalRewardBtn:registerScriptTapHandler(function() self:click_normalRewardBtn() end)
    self.m_passRewardBtn:registerScriptTapHandler(function() self:click_passRewardBtn() end)


    local isPurchased = g_battlePassData:isPurchased(self.m_pass_id)
    self.m_buyBtn:setVisible(not isPurchased)
    self.m_buyBtn:setEnabled(not isPurchased)
end

--------------------------------------------------------------------------
-- @function refresh 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:refresh()
    self:updateProgressBar()
    self:updateTextLabel()
end



--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Init Helper Functions (local)
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function initMember 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:initMember(struct_product)
    local vars = self.vars

    self.m_pass_id = struct_product['product_id']
    self.m_normal_key = 'normal'
    self.m_premium_key = 'premium'

    

    self.m_listNode = vars['listNode']
    self.m_itemNode = vars['itemNode']
    self.m_levelExpBar = vars['nextLevelGauge']
    self.m_totalExpBar = vars['passGauge']

    self.m_originTotalExpScale = self.m_totalExpBar:getScaleX()

    self.m_questBtn = vars['questBtn']
    self.m_infoBtn = vars['infoBtn']
    self.m_buyBtn = vars['buyBtn']
    self.m_normalRewardBtn = vars['normalRewardBtn']
    self.m_passRewardBtn = vars['passRewardBtn']

    self.m_timeLabel = vars['timeLabel']
    self.m_nextPointLabel = vars['nextPointLabel']
    self.m_nextLevelLabel = vars['nextLevelLabel']
    self.m_levelLabel = vars['levelLabel']

    self.m_originNextPointStr = self.m_nextPointLabel:getString()
    
    self.m_originLevelStr = self.m_nextLevelLabel:getString()
    self.m_originNextLevelStr = self.m_levelLabel:getString()
end

--------------------------------------------------------------------------
-- @function initTableView 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:initTableView()
    local vars = self.vars

    -- 생성 콜백
    local function create_cb_func(ui, data)
        
    end

    local table_view = UIC_TableView(self.m_listNode)
    table_view.m_defaultCellSize = cc.size(self.m_itemNode:getNormalSize())
    --table_view.m_defaultCellSize = cc.size(120, 385)
    table_view:setCellUIClass(UI_BattlePass_NurtureCell, create_cb_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    table_view:CreateCellUIClass(self.m_pass_id, g_battlePassData:getLevelNum(self.m_pass_id))
    
    self.m_totalExpBar:retain()
    self.m_totalExpBar:removeFromParent()
    self.m_totalExpBar:setLocalZOrder(self.m_totalExpBar:getLocalZOrder() - 1)
    table_view.m_scrollView:addChild(self.m_totalExpBar)

    self.m_tableView = table_view
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// refresh Helper Functions (local)
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
function UI_BattlePass_Nurture:updateProgressBar()
    local vars = self.vars

    local percent = (g_battlePassData:getUserExpPerLevel(self.m_pass_id) / g_battlePassData:getRequiredExpPerLevel(self.m_pass_id)) * 100
    self.m_levelExpBar:setPercentage(percent)

    local scale = self.m_originTotalExpScale * g_battlePassData:getLevelNum(self.m_pass_id)
    self.m_totalExpBar:setScaleX(scale)

    local user_exp = g_battlePassData:getUserExp(self.m_pass_id)
    if(g_battlePassData:getMinLevel(self.m_pass_id) == 0) then
        user_exp = user_exp + g_battlePassData:getRequiredExpPerLevel(self.m_pass_id)
    end

    percent = user_exp / g_battlePassData:getMaxExp(self.m_pass_id) * 100   
    self.m_totalExpBar:setPercentage(percent)

end

function UI_BattlePass_Nurture:updateTextLabel()

    self.m_timeLabel:setString(g_battlePassData:getRemainTimeStr(self.m_pass_id))

    self.m_nextPointLabel:setString(Str(self.m_originNextPointStr, 
            g_battlePassData:getUserExpPerLevel(self.m_pass_id),
            g_battlePassData:getRequiredExpPerLevel(self.m_pass_id)))

    local userLevel = g_battlePassData:getUserLevel(self.m_pass_id)

    self.m_nextLevelLabel:setString(Str(self.m_originNextLevelStr, userLevel + 1))
    self.m_levelLabel:setString(Str(self.m_originLevelStr, userLevel))
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// 
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------
-- @function click_infoBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_infoBtn()
    UI_BattlePassInfoPopup()
end

--------------------------------------------------------------------------
-- @function click_questBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_questBtn() 
    UINavigator:goTo('quest')
    -- 퀘스트 팝업 찾고
    local is_opend, idx, popupUI = UINavigatorDefinition:findOpendUI('UI_QuestPopup')

    if (popupUI) then
        popupUI:setCloseCB(function() self:onReceiveBattlePassInfo() end)
    end
end

--------------------------------------------------------------------------
-- @function onReceiveBattlePassInfo 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:onReceiveBattlePassInfo()

    local function finish_cb(ret)
        self:refresh()

        for i, v in ipairs(self.m_tableView.m_itemList) do
            local ui = v['ui'] or v['generated_ui']
            if ui then
                local targetLevel = g_battlePassData:getLevelFromIndex(self.m_pass_id, i)
                local userLevel = g_battlePassData:getUserLevel(self.m_pass_id)
                ui:updatePassLock()

                if(targetLevel <= userLevel) then 
                    ui:updatePremiumRewardStatus()
                end
            end
        end
    end

    -- ui 가 있으면 팝업 클로즈 콜백에
    -- info request response 후
    -- ui 업뎃하는 로직을 집어넣는다.
    g_battlePassData:request_battlePassInfo(finish_cb)

end



--------------------------------------------------------------------------
-- @function click_buyBtn 
-- @param 
-- @brief
-- @todo replace refreshCellStatus to refresh after test
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_buyBtn()
    local targetProduct = g_shopDataNew:getTargetProduct(self.m_pass_id)
    
    local function cb_func(ret)
        local function cb_finish(ret)
            for i, v in ipairs(self.m_tableView.m_itemList) do
                local ui = v['ui'] or v['generated_ui']
                if ui then
                    local targetLevel = g_battlePassData:getLevelFromIndex(self.m_pass_id, i)
                    local userLevel = g_battlePassData:getUserLevel(self.m_pass_id)
                    ui:updatePassLock()

                    if(targetLevel <= userLevel) then 
                        ui:updatePremiumRewardStatus()
                    end
                end
            end
            
            local isPurchased = g_battlePassData:isPurchased(self.m_pass_id)
            self.m_buyBtn:setVisible(not isPurchased)
            self.m_buyBtn:setEnabled(not isPurchased)
        end

        ItemObtainResult_Shop(ret, true) -- param : ret, show_all
        g_battlePassData:request_battlePassInfo(cb_finish)
	end

    targetProduct:buy(cb_func)
end

--------------------------------------------------------------------------
-- @function click_normalRewardBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_normalRewardBtn()
   
    local function finish_cb(ret)
        if(ret['added_items']) then
            g_serverData:receiveReward(ret)
        end

        for i, v in ipairs(self.m_tableView.m_itemList) do
            local ui = v['ui'] or v['generated_ui']
            if ui then
                local targetLevel = g_battlePassData:getLevelFromIndex(self.m_pass_id, i)
                local userLevel = g_battlePassData:getUserLevel(self.m_pass_id)
                if(targetLevel <= userLevel) then 
                    ui:updateNormalRewardStatus()
                end
            end
        end
    end

    -- level:0, type:all 로 요청 시 모든 보상 수령 요청
    g_battlePassData:request_allRewards(self.m_pass_id, self.m_normal_key, finish_cb)
end

--------------------------------------------------------------------------
-- @function click_passRewardBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_passRewardBtn()
    
    local function finish_cb(ret)
        if(ret['added_items']) then
            g_serverData:receiveReward(ret)
        end
       
        for i, v in ipairs(self.m_tableView.m_itemList) do
            local ui = v['ui'] or v['generated_ui']
            if ui then
                local targetLevel = g_battlePassData:getLevelFromIndex(self.m_pass_id, i)
                local userLevel = g_battlePassData:getUserLevel(self.m_pass_id)
                if(targetLevel <= userLevel) then 
                    ui:updatePremiumRewardStatus()
                end
            end
        end
    end
   
    -- level:0, type:all 로 요청 시 모든 보상 수령 요청
    g_battlePassData:request_allRewards(self.m_pass_id, self.m_premium_key, finish_cb)
end

