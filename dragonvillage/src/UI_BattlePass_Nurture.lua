local PARENT = UI_Package

--------------------------------------------------------------------------
-- @classmod UI_BattlePass_Nurture
-- @brief 
--------------------------------------------------------------------------
UI_BattlePass_Nurture = class(PARENT, {
    m_bIsUserOwnedBattlePass = 'bool',  -- 배틀패스 구매여부
    m_rewardList = '',                  -- 보상 서버 리스트
    m_userRewardedList = '',            -- 유저 습득 보상 리스트 (일반, 패스 나눌지?)

    m_currUserTotalExp = 'number',      -- 유저 현재 경험치
    m_passMaxExp = 'number',            -- 패스 맥스 경험치

    m_passMaxLevel = 'number',          -- 패스 맥스 레벨

    m_currUserLevel = 'number',         -- 현재 유저 레벨
    m_requiredExpForLevelUp = 'number', -- 레벨업당 필요 경험치
    m_currUserExpForLevelUp = 'number', -- 1레벨 기준 현재 유저 경험치

    m_tableView = 'UIC_TableView',      -- 스크롤뷰 (횡스크롤)

    -- Nodes in ui file
    m_listNode = 'cc.Node',
    m_itemNode = 'cc.Node',

    m_levelExpBar = 'cc.Node',          -- 레벨당 경험치바 (게이지)
    m_totalExpBar = 'cc.Node',          -- 패스 전체 경험치바 (게이지)

    m_questBtn = '',
    m_infoBtn = '',
    m_buyBtn = '',
    m_normalRewardBtn = '',
    m_passRewardBtn = '',
})
--[[
    function clickPurchasePassBtn() end
    function clickReceiveNormalItemsAtOnceBtn() end
    function clickReceivePassItemsAtOnceBtn() end -- 나눌 필요가 있을까? 리스트를 param으로 받으면?
    function clickQuestBtn() end

    function refreshCurrExpBar() 
        vars['']:runAction(cc.ProgressTo:create())
    end
    function refreshTotalExpBar() end
    
    -- m_bIsUserOwnedBattlePass 에 따라 언락
    function unlockPassItems() end
]]--

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
    self.m_isPopup = is_popup or false

    local vars = self:load('battle_pass_nurture.ui')
    if(self.m_isPopup) then
        UIManager:open(self, UIManager.POPUP)
        g_currScene.pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_BattlePass_Nurture')
    end

    

    self:doActionReset()
    self:doAction(nil, false)

    self:initMember()
    self:initUI()
    self:initButton()
    self:refresh()
end

--------------------------------------------------------------------------
-- @function initUI 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:initUI()
    self:initProgressBar()
    self:initTableView()
    self:initTextLabel()
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

end

--------------------------------------------------------------------------
-- @function refresh 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:refresh()
    --PARENT:refresh(self)
    self:refreshCellStatus()
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
function UI_BattlePass_Nurture:initMember()
    local vars = self.vars

    self.m_bIsUserOwnedBattlePass = false -- TODO (YOUNGJIN) : 서버 데이터로 확인
    self.m_rewardList  = g_battlePassData:getRewardList()--{}    -- TODO (YOUNGJIN) : 서버 데이터로 확인
    
    self.m_userRewardedList  = {}    -- TODO (YOUNGJIN) : 서버 데이터로 확인

    -- TODO (YOUNGJIN) : normalRewardList, passRewardList 길이 비교
    self.m_passMaxLevel = #self.m_rewardList

    self.m_currUserTotalExp = 522     -- TODO (YOUNGJIN) : 서버 데이터로 확인
    self.m_passMaxExp = 1000           -- TODO (YOUNGJIN) : 서버 데이터로 확인

    self.m_listNode = vars['listNode']
    self.m_itemNode = vars['itemNode']
    self.m_levelExpBar = vars['nextLevelGauge']
    self.m_totalExpBar = vars['passGauge']

    self.m_questBtn = vars['questBtn']
    self.m_infoBtn = vars['infoBtn']
    self.m_buyBtn = vars['buyBtn']
    self.m_normalRewardBtn = vars['normalRewardBtn']
    self.m_passRewardBtn = vars['passRewardBtn']


    self:refreshMember()
end

--------------------------------------------------------------------------
-- @function initTextLabel 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:initTextLabel()
    local vars = self.vars
    -- TODO (YOUNGJIN) : 하드코딩식. 바꾸어야함.
    local label = vars['nextPointLabel']
    label:setString(Str(label:getString(), self.m_currUserExpForLevelUp, self.m_requiredExpForLevelUp))

    label = vars['nextLevelLabel']
    label:setString(Str(label:getString(), self.m_currUserLevel + 1))

    label = vars['levelLabel']
    label:setString(Str(label:getString(), self.m_currUserLevel))
end

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
    table_view:setItemList3(self.m_rewardList)
    
    self.m_totalExpBar:retain()
    self.m_totalExpBar:removeFromParent()
    self.m_totalExpBar:setLocalZOrder(self.m_totalExpBar:getLocalZOrder() - 1)
    table_view.m_scrollView:addChild(self.m_totalExpBar)

    self.m_tableView = table_view
end

--------------------------------------------------------------------------
-- @function initMember 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:initProgressBar()
    local vars = self.vars

    -- TODO (YOUNGJIN) : member으로서 필요한지 확인. 
    --local listNodeWidth, listNodeHeight = self.m_listNode:getNormalSize()
    --local itemNodeWidth, itemNodeHeight = self.m_itemNode:getNormalSize()

    --local progressBarRatio = itemNodeWidth / listNodeWidth

    -- 
    self.m_levelExpBar:setPercentage((self.m_currUserExpForLevelUp / self.m_requiredExpForLevelUp) * 100)
    self.m_totalExpBar:setScaleX(self.m_totalExpBar:getScaleX() * self.m_passMaxLevel)
    self.m_totalExpBar:setPercentage((self.m_currUserTotalExp / self.m_passMaxExp) * 100)

end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// refresh Helper Functions (local)
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------
-- @function refreshMember 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:refreshMember()
    -- 현재 유저 레벨
    self.m_currUserLevel = math.floor((self.m_currUserTotalExp / self.m_passMaxExp) * self.m_passMaxLevel)
    -- 레벨업당 필요 경험치
    self.m_requiredExpForLevelUp = (self.m_passMaxExp / self.m_passMaxLevel)
    -- 1레벨 기준 현재 유저 경험치
    self.m_currUserExpForLevelUp = (self.m_currUserTotalExp % self.m_requiredExpForLevelUp)
end

--------------------------------------------------------------------------
-- @function refreshProgressBar 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:refreshProgressBar()

end
--------------------------------------------------------------------------
-- @function click_infoBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:refreshCellStatus()
    for i, v in ipairs(self.m_tableView.m_itemList) do
        local ui = v['ui'] or v['generated_ui']
        if ui then
            ui:SetLevelSpritesVisible(self.m_currUserLevel >= i)
            ui:SetPassLock(not self.m_bIsUserOwnedBattlePass)
        end
    end
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Getter & Setter
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function SetLockBattlePass 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:SetLockBattlePass(bool_value)

end


--------------------------------------------------------------------------
-- @function click_infoBtn 
-- @param 
-- @brief
-- @todo 
--------------------------------------------------------------------------
-- function UI_BattlePass_Nurture:TempSetBattlePassLock(bool_value)
--     for i, v in ipairs(self.m_tableView.m_itemList) do
--         local ui = v['ui'] or v['generated_ui']
--         if ui then

--         end
--     end
-- end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Click Button Actions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function click_infoBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_infoBtn()

end

--------------------------------------------------------------------------
-- @function click_questBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_questBtn() 
    UINavigator:goTo('quest')
end

--------------------------------------------------------------------------
-- @function click_buyBtn 
-- @param 
-- @brief
-- @todo replace refreshCellStatus to refresh after test
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_buyBtn()
    if(self.m_bIsUserOwnedBattlePass) then 
        -- ERROR CASE. It shouldn't be hapened\
        return
    end

    self.m_bIsUserOwnedBattlePass = true
    self.m_buyBtn:setVisible(false)
    self.m_buyBtn:setEnabled(false)
    self:refreshCellStatus()
end

--------------------------------------------------------------------------
-- @function click_normalRewardBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_normalRewardBtn()
    for i, v in ipairs(self.m_tableView.m_itemList) do
        local ui = v['ui'] or v['generated_ui']
        if ui then
            ui:click_normalRewardBtn()
        end
    end
end

--------------------------------------------------------------------------
-- @function click_passRewardBtn 
-- @param 
-- @brief
--------------------------------------------------------------------------
function UI_BattlePass_Nurture:click_passRewardBtn()
    for i, v in ipairs(self.m_tableView.m_itemList) do
        local ui = v['ui'] or v['generated_ui']
        if ui then
            ui:click_passRewardBtn()
        end
    end
end

