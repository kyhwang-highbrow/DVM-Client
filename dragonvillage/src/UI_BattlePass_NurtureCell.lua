local PARENT = class(UI, ITableViewCell:getCloneTable())

--------------------------------------------------------------------------
-- @classmod UI_BattlePass_NurtureCell
-- @brief battle_pass_nurture_item.ui 와 관련된 item cell의 기능 동작 관리
--------------------------------------------------------------------------
UI_BattlePass_NurtureCell = class(PARENT, {
    m_pass_id = 'number',
    m_cell_id = 'number',

    m_normal_key = '',  -- 'normal'
    m_premium_key = '', -- 'premium'


    -- Nodes in ui file
    m_swallowTouchMenu = '',    -- 해당 노드가 ui에 존재시 button의 swallowTouch를 false로.

    m_levelSprite = '',         -- 레벨 스프라이트 노드
    m_levelLabel = '',          -- 레벨 텍스트 노드

    m_normalRewardBtn = '',     -- 일반 보상 버튼 노드
    m_normalClearSprite = '',   -- 일반 보상 수령 완료 표시 스프라이트 노드
    m_normalLockSprite = '',    -- 일반 보상 비활성화 표시 스프라이트 노드
    m_normalItemNode = '',      -- 일반 보상 이미지용 노드
    m_normalItemLabel = '',     -- 일반 보상 텍스트 노드

    m_premiumRewardBtn = '',       -- 패스 보상 버튼 노드
    m_premiumClearSprite = '',     -- 패스 보상 수령완료 표시 스프라이트 노드
    m_premiumLockSprite = '',      -- 패스 보상 비활성화 표시 스프라이트 노드
    m_premiumItemNode = '',        -- 패스 보상 이미지용 노드
    m_premiumItemLabel = '',       -- 패스 보상 텍스트 노드

    m_premiumPurchaseSprite = '',  -- 패스 구매여부 (자물쇠) 스프라이트 노드
})
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// pure virtual functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function init 
-- @param 데이터 테이블   {['id']=21; ['parent_key']=121701;}
-- @brief 모든 init 함수를 실행
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:init(data)
    self.m_pass_id = data['parent_key']
    self.m_cell_id = data['id']

    local pass_list = g_shopDataNew:getProductList('pass')
    local ui_strs = plSplit(pass_list[self.m_pass_id]['package_res'], '.')
    local ui_file_name = Str(ui_strs[1] .. '_item.' .. ui_strs[2])
    
    local vars = self:load(ui_file_name)

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0.2, 0.3)
    self:doActionReset()
    self:doAction(nil, false)

    self:initMember(data)
    self:initUI()
    self:initButton()
    self:refresh()
end


--------------------------------------------------------------------------
-- @function initUI 
-- @brief UI와 관련된 변수 및 기능 초기화
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:initUI()    
    self:InitNormalItemNode()
    self:InitPremiumItemNode()

    local targetLevel = g_battlePassData:getLevelFromIndex(self.m_pass_id, self.m_cell_id)
    self.m_levelLabel:setString(Str(self.m_levelLabel:getString(), targetLevel))
end


--------------------------------------------------------------------------
-- @function initButton 
-- @brief button과 관련된 변수 및 기능 초기화
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:initButton()
    self.m_normalRewardBtn:registerScriptTapHandler(function() self:click_normalRewardBtn() end)
    self.m_premiumRewardBtn:registerScriptTapHandler(function() self:click_passRewardBtn() end)
    
    if(self.m_swallowTouchMenu ~= nil) then
        -- 버튼 드래그시 scroll view 이동이 되도록 함.
        self.m_normalRewardBtn:getParent():setSwallowTouch(false)
        self.m_premiumRewardBtn:getParent():setSwallowTouch(false)
    end
end



--------------------------------------------------------------------------
-- @function refresh 
-- @brief 
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:refresh()
    self:updatePassLock()
    self:updateLevelSprites()

    self:updateNormalRewardStatus()
    self:updatePremiumRewardStatus()
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Init Helper Functions (Local)
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function initMember 
-- @param 데이터 테이블   {['id']=21; ['parent_key']=121701;}
-- @brief init function 내부에서 멤버 변수 정의
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:initMember(data)
    local vars = self.vars
    self.m_normal_key = 'normal'
    self.m_premium_key = 'premium'

    -- Node
    self.m_swallowTouchMenu = vars['swallowTouchMenu']

    self.m_levelSprite = vars['levelSprite']
    self.m_levelLabel = vars['levelLabel']

    self.m_normalRewardBtn = vars['normalRewardBtn']
    self.m_normalClearSprite = vars['normalClearSprite']
    self.m_normalLockSprite = vars['normalLockSprite']
    self.m_normalItemNode = vars['normalItemNode']
    self.m_normalItemLabel = vars['normalItemLabel']

    self.m_premiumRewardBtn = vars['passRewardBtn']
    self.m_premiumClearSprite = vars['passClearSprite']
    self.m_premiumLockSprite = vars['passLockSprite']
    self.m_premiumItemNode = vars['passItemNode']
    self.m_premiumItemLabel = vars['passItemLabel']

    self.m_premiumPurchaseSprite = vars['passPurchaseSprite']
end

function  UI_BattlePass_NurtureCell:InitNormalItemNode()
    local item_id, item_num = g_battlePassData:getNormalItemInfo(self.m_pass_id, self.m_cell_id)
    
    local itemCard = UI_ItemCard(item_id)
    itemCard:setEnabledClickBtn(true)
    itemCard:SetBackgroundVisible(false)
    itemCard:setSwallowTouch()
    self.m_normalItemNode:addChild(itemCard.root)

    self.m_normalItemLabel:setString(Str('x{1}', comma_value(item_num)))
end

function  UI_BattlePass_NurtureCell:InitPremiumItemNode()
    local item_id, item_num = g_battlePassData:getPremiumItemInfo(self.m_pass_id, self.m_cell_id)
    
    local itemCard = UI_ItemCard(item_id)
    itemCard:setEnabledClickBtn(true)
    itemCard:SetBackgroundVisible(false)

    self.m_premiumItemNode:addChild(itemCard.root)

    self.m_premiumItemLabel:setString(Str('x{1}', comma_value(item_num)))
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Update Helper Functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------
-- @function updatePassLock
-- @brief 패스 구매 여부에 따라 잠금 표시 및 버튼 활성화
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:updatePassLock()
    local isPurchased = g_battlePassData:isPurchased(self.m_pass_id)

    self.m_premiumPurchaseSprite:setVisible(not isPurchased)
    self.m_premiumRewardBtn:setEnabled(isPurchased)
end

function UI_BattlePass_NurtureCell:updateLevelSprites()
    local userLevel = g_battlePassData:getUserLevel(self.m_pass_id)
    local targetLevel = g_battlePassData:getLevelFromIndex(self.m_pass_id, self.m_cell_id)
    
    local isAvailableLevel = (userLevel >= targetLevel)
    
    -- 레벨이 되면 밝게, 레벨이 되면 어둡게 설정
    self.m_normalLockSprite:setVisible(not isAvailableLevel)
    self.m_premiumLockSprite:setVisible(not isAvailableLevel)
    self.m_levelSprite:setVisible(isAvailableLevel)

    -- 버튼 스프라이트 활성화 표시 
    self.m_normalRewardBtn:setVisible(isAvailableLevel)
    self.m_premiumRewardBtn:setVisible(isAvailableLevel)
end

function UI_BattlePass_NurtureCell:updateNormalRewardStatus()
    local normalStatus = g_battlePassData:GetRewardStatus(self.m_pass_id, self.m_normal_key, self.m_cell_id)

    if (normalStatus == REWARD_STATUS.RECEIVED) then     
        self.m_normalClearSprite:setVisible(true)  -- 체크표시 보여주기
        self.m_normalRewardBtn:setVisible(false)   -- 버튼 어둡게 하기
        self.m_normalRewardBtn:setEnabled(false)   -- 버튼 비활성화
    elseif (normalStatus == REWARD_STATUS.POSSIBLE) then
        self.m_normalClearSprite:setVisible(false)  -- 체크표시 보여주기
        self.m_normalRewardBtn:setVisible(true)   -- 버튼 어둡게 하기
        self.m_normalRewardBtn:setEnabled(true)   -- 버튼 비활성화
    else -- normalStatus == REWARD_STATUS.NOT_AVAILABLE

    end
end

function UI_BattlePass_NurtureCell:updatePremiumRewardStatus()
    local premiumStatus = g_battlePassData:GetRewardStatus(self.m_pass_id, self.m_premium_key, self.m_cell_id)
        
    if (premiumStatus == REWARD_STATUS.RECEIVED) then
        self.m_premiumClearSprite:setVisible(true)  -- 체크표시 보여주기
        self.m_premiumRewardBtn:setVisible(false)   -- 버튼 어둡게 하기
        self.m_premiumRewardBtn:setEnabled(false)   -- 버튼 비활성화
    elseif (premiumStatus == REWARD_STATUS.POSSIBLE) then
        self.m_premiumClearSprite:setVisible(false)  -- 체크표시 보여주기
        self.m_premiumRewardBtn:setVisible(true)   -- 버튼 어둡게 하기
        self.m_premiumRewardBtn:setEnabled(true)   -- 버튼 비활성화
    else -- premiumStatus == REWARD_STATUS.NOT_AVAILABLE
        
    end
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Click Button Actions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////


--------------------------------------------------------------------------
-- @function click_normalRewardBtn 
-- @brief 일반 보상 버튼 액션
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:click_normalRewardBtn()

    local function finish_cb(ret)
        self:updateNormalRewardStatus()
        if(ret['added_items']) then
            g_serverData:receiveReward(ret)
        end
    end

    g_battlePassData:request_reward(self.m_pass_id, self.m_normal_key, 
            g_battlePassData:getLevelFromIndex(self.m_pass_id, self.m_cell_id),
        finish_cb)
    
end

--------------------------------------------------------------------------
-- @function click_passRewardBtn 
-- @brief 패스 보상 버튼 액션
--------------------------------------------------------------------------
function UI_BattlePass_NurtureCell:click_passRewardBtn()
   
    local function finish_cb(ret)
        self:updatePremiumRewardStatus()
        if(ret['added_items']) then
            g_serverData:receiveReward(ret)
        end
    end

    g_battlePassData:request_reward(self.m_pass_id, self.m_premium_key, 
            g_battlePassData:getLevelFromIndex(self.m_pass_id, self.m_cell_id),
            finish_cb)
end


--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// Local Functions
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

