local PARENT = UI

-------------------------------------
-- class UI_Forest_StuffLevelupPopup
-------------------------------------
UI_Forest_StuffLevelupPopup = class(PARENT,{
        m_forestStuffType = 'string',
        m_stuffObject = 'ForestStuff',
        m_tableStuff = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_StuffLevelupPopup:init(stuff_type, stuff_object)
    local vars = self:load('dragon_forest_levelup_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Forest_StuffLevelupPopup')

    self.m_forestStuffType = stuff_type or stuff_object.m_tStuffInfo['stuff_type']
    self.m_stuffObject = stuff_object
    self.m_tableStuff = TableForestStuffLevelInfo:getStuffTable(self.m_forestStuffType)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest_StuffLevelupPopup:initUI()
    local vars = self.vars
    local t_stuff_info = ServerData_Forest:getInstance():getStuffInfo_Indivisual(self.m_forestStuffType)

    -- 이름
    local name = t_stuff_info['stuff_name']
    vars['titleLabel']:setString(name)

    -- 애니변경
    local stuff_type = t_stuff_info['stuff_type']
    vars['objectVisual']:changeAni('stuff_normal_' .. stuff_type, false)

    local lv = t_stuff_info['stuff_lv'] or 0
    local t_next_level_info = self.m_tableStuff[lv + 1]

    if (not t_next_level_info) then
        return
    end

    -- 가격 아이콘
    local price_type = t_next_level_info['price_type']
    local price_icon = IconHelper:getPriceIcon(price_type)
    vars['priceNode']:removeAllChildren()
    vars['priceNode']:addChild(price_icon)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest_StuffLevelupPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest_StuffLevelupPopup:refresh()
    local vars = self.vars
    local t_stuff_info = ServerData_Forest:getInstance():getStuffInfo_Indivisual(self.m_forestStuffType)
    local stuff_type = t_stuff_info['stuff_type']
    
    -- 현재 레벨 정보
    local lv = t_stuff_info['stuff_lv'] or 0
    vars['levelLabel1']:setString(string.format('Lv.%d', lv))
    local desc = TableForestStuffLevelInfo:getStuffOptionDesc(stuff_type, lv)
    vars['dscLabel1']:setString(desc)

    -- 다음 레벨 정보
    lv = lv + 1
    vars['levelLabel2']:setString(string.format('Lv.%d', lv))
    desc = TableForestStuffLevelInfo:getStuffOptionDesc(stuff_type, lv)
    vars['dscLabel2']:setString(desc)

    -- 다음 레벨의 정보
    local t_stuff_level_info = self.m_tableStuff[lv]

    -- 레벨업 후 만렙을 달성하였을 경우를 상정
    if (not t_stuff_level_info) then
        UIManager:toastNotificationGreen(Str('최대 레벨을 달성하였습니다.'))
        self:close()
        return
    end

    -- 가격
    local price = t_stuff_level_info['price_value']
    vars['priceLabel']:setString(price)

    -- 레벨업 불가 시 잠금 처리
    local forest_lv = ServerData_Forest:getInstance():getExtensionLV()
    local open_lv = t_stuff_level_info['extension_lv']
    if (open_lv > forest_lv) then
        vars['levelupBtn']:setVisible(false)
        vars['lockSprite']:setVisible(true)
        
        local desc
        if (lv == 0) then
            desc = Str('숲 레벨 {1} 달성 시 오픈됩니다.', open_lv) 
        else
            desc = Str('숲 레벨 {1} 달성 시 레벨업 할 수 있어요.', open_lv)
        end
        vars['infoLabel']:setString(desc)
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Forest_StuffLevelupPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_levelupBtn
-------------------------------------
function UI_Forest_StuffLevelupPopup:click_levelupBtn()
    local vars = self.vars
    local stuff_type = self.m_forestStuffType
    
    vars['levelupBtn']:setEnabled(false)

    do -- 재화가 충분히 있는지 체크
        local t_stuff_info = ServerData_Forest:getInstance():getStuffInfo_Indivisual(stuff_type)
        local lv = t_stuff_info['stuff_lv']

        local table_stuff = TableForestStuffLevelInfo:getStuffTable(stuff_type)
        local t_next = table_stuff[lv + 1]
        if (not t_next) then
            return
        end

        local price_type = t_next['price_type']
        local price = t_next['price_value']

        if (not UIHelper:checkPrice(price_type, price)) then
            return
        end
    end

    local function finish_cb(t_stuff)
        vars['objectVisual']:changeAni('stuff_lvup_' .. stuff_type, false)
        vars['objectVisual']:addAniHandler(function()
            vars['levelupBtn']:setEnabled(true)
        end)
        self:refresh()
        if self.m_stuffObject then
            -- 레벨 갱신
            self.m_stuffObject.m_tStuffInfo['stuff_lv'] = t_stuff['stuff_lv']
            self.m_stuffObject.m_ui:refresh()
        end
    end
    ServerData_Forest:getInstance():request_stuffLevelup(stuff_type, finish_cb)
end
