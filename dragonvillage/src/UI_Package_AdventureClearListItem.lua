local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_Package_AdventureClearListItem01
-------------------------------------
UI_Package_AdventureClearListItem01 = class(PARENT, {
        m_data = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AdventureClearListItem01:init(data)
    self.m_data = data
    local vars = self:load('package_adventure_clear_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AdventureClearListItem01:initUI()
    local vars = self.vars
    local t_data = self.m_data

    -- 스테이지
    local stage_id = t_data['stage']
    local stage_info = g_adventureData:getStageInfo(stage_id) -- StructAdventureStageInfo
    local str = stage_info:getStageRichName()
    vars['levelLabel']:setString(str)

    local product_info_list = {}

    local ret1 = ServerData_Item:parsePackageItemStr(t_data['product_content'])
    for i,v in ipairs(ret1) do
        table.insert(product_info_list, v)
    end

    local ret2 = ServerData_Item:parsePackageItemStr(t_data['mail_content'])
    for i,v in ipairs(ret2) do
        table.insert(product_info_list, v)
    end

    for i,v in ipairs(product_info_list) do
        local card = UI_ItemCard(v['item_id'], v['count'])
        card.root:setSwallowTouch(false)
        vars['itemNode' .. i]:addChild(card.root)        
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AdventureClearListItem01:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['linkBtn']:registerScriptTapHandler(function() self:click_linkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AdventureClearListItem01:refresh()
    local vars = self.vars
    local data = self.m_data

    if g_adventureClearPackageData01:isActive() then
        local stage_id = data['stage']
        if g_adventureClearPackageData01:isReceived(stage_id) then
            vars['receiveSprite']:setVisible(true)
            vars['rewardBtn']:setVisible(false)
            vars['linkBtn']:setVisible(false)
        
        -- 2020.08.24 3번째 패키지 추가하며 1,2번째 패키지는 모두 수령가능 상태로 처리함
        else
            vars['receiveSprite']:setVisible(false)
            vars['rewardBtn']:setVisible(true)
            vars['rewardBtn']:setEnabled(true)
            vars['linkBtn']:setVisible(false)
        end
    else
        vars['receiveSprite']:setVisible(false)
        vars['rewardBtn']:setVisible(true)
        vars['rewardBtn']:setEnabled(false)
    end

    if vars['rewardBtn']:isEnabled() then
        vars['infoLabel']:setTextColor(cc.c4b(0, 0, 0, 255))
    else
        vars['infoLabel']:setTextColor(cc.c4b(240, 215, 159, 255))
    end
    
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_Package_AdventureClearListItem01:click_rewardBtn()
    local data = self.m_data
    local stage_id = data['stage']

    local function cb_func(ret)
        self:refresh()

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
    end

    g_adventureClearPackageData01:request_adventureClearReward(stage_id, cb_func)
end

-------------------------------------
-- function click_linkBtn
-- @brief 스테이지 바로가기 버튼
-------------------------------------
function UI_Package_AdventureClearListItem01:click_linkBtn()
    local data = self.m_data
    local stage_id = data['stage']
    UINavigator:goTo('adventure', stage_id)
end