local PARENT = UI

-------------------------------------
-- class UI_Forest_StuffLevelupPopup
-------------------------------------
UI_Forest_StuffLevelupPopup = class(PARENT,{
        m_stuffObject = 'ForestStuff',
        m_tableStuff = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_StuffLevelupPopup:init(stuff_object)
    local vars = self:load('dragon_forest_levelup_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Forest_StuffLevelupPopup')

    self.m_stuffObject = stuff_object
    self.m_tableStuff = TableForestStuffLevelInfo:getStuffTable(stuff_object.m_tStuffInfo['stuff_type'])

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest_StuffLevelupPopup:initUI()
    local vars = self.vars
    local t_stuff_info = self.m_stuffObject.m_tStuffInfo

    -- 이름
    local name = t_stuff_info['stuff_name']
    vars['titleLabel']:setString(name)

    -- 애니변경
    local stuff_type = t_stuff_info['stuff_type']
    vars['objectVisual']:changeAni('stuff_normal_' .. stuff_type, false)

    local lv = t_stuff_info['stuff_lv']
    local t_next_level_info = self.m_tableStuff[lv + 1]

    if (not t_next_level_info) then
        return
    end

    -- 가격 아이콘
    local price_type = t_next_level_info['price_type']
    local price_icon = IconHelper:getPriceIcon(price_type)
    vars['priceNode']:removeAllChildren()
    vars['priceNode']:addChild(price_icon)

    -- 레벨업 불가 시 잠금 처리
    local tamer_lv = g_userData:get('lv')
    local open_lv = t_next_level_info['open_lv']
    if (open_lv > tamer_lv) then
        vars['levelupBtn']:setVisible(false)
        vars['lockSprite']:setVisible(true)
        vars['infoLabel']:setString(Str('테이머 레벨 {1} 달성 시 레벨업 할 수 있어요', open_lv))
    end
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
    local t_stuff_info = self.m_stuffObject.m_tStuffInfo
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
        UIManager:toastNotificationGreen(Str('레벨 최대치 입니다.'))
        self:close()
    end

    -- 가격
    local price = t_stuff_level_info['price_value']
    vars['priceLabel']:setString(price)
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
    local stuff_type = self.m_stuffObject.m_tStuffInfo['stuff_type']
    local function finish_cb(t_stuff)
        self.vars['objectVisual']:changeAni('stuff_lvup_' .. stuff_type, false)
        self.vars['objectVisual']:addAniHandler(function()
            self:refresh()
        end)
    end
    ServerData_Forest:getInstance():request_stuffLevelup(stuff_type, finish_cb)
end
