local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_Package_LevelUpListItem
-------------------------------------
UI_Package_LevelUpListItem = class(PARENT, {
        m_data = '',
        m_productId = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_LevelUpListItem:init(ui_res, data, product_id)
    self.m_data = data
    self.m_productId = product_id
    local vars = self:load(ui_res)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_LevelUpListItem:initUI()
    local vars = self.vars
    local t_data = self.m_data

    -- 레벨 표시
    vars['levelLabel']:setString('Lv.' .. t_data['level'])

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
function UI_Package_LevelUpListItem:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_LevelUpListItem:refresh()
    local vars = self.vars
    local data = self.m_data

    if g_levelUpPackageDataOld:isActive(self.m_productId) then
        local level = data['level']
        if g_levelUpPackageDataOld:isReceived(self.m_productId, level) then
            vars['receiveSprite']:setVisible(true)
            vars['rewardBtn']:setVisible(false)
        else
            vars['receiveSprite']:setVisible(false)
            vars['rewardBtn']:setVisible(true)

            -- 2020.08.24 3번째 패키지 추가하며 1,2번째 패키지는 모두 수령가능 상태로 처리함
            if (self.m_productId == LEVELUP_PACKAGE_PRODUCT_ID or self.m_productId == LEVELUP_PACKAGE_2_PRODUCT_ID) then
                vars['rewardBtn']:setEnabled(true)
            else
                local user_lv = g_userData:get('lv')
                if (user_lv < level) then
                    vars['rewardBtn']:setEnabled(false)
                else
                    vars['rewardBtn']:setEnabled(true)
                end
            end
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
function UI_Package_LevelUpListItem:click_rewardBtn()
    local data = self.m_data
    local lv = data['level']

    local function cb_func(ret)
        self:refresh()

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
    end

    g_levelUpPackageDataOld:request_lvuppackReward(lv, cb_func, nil, self.m_productId)
end

-------------------------------------
-- function createItem
-------------------------------------
function UI_Package_LevelUpListItem.createItem(data, product_id)
    if (product_id == LEVELUP_PACKAGE_PRODUCT_ID) then
        return UI_Package_LevelUpListItem('package_levelup_item.ui', data, product_id)
    else
        return UI_Package_LevelUpListItem('package_levelup_item_02.ui', data, product_id)
    end
    
end
