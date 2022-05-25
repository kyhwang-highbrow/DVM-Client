-------------------------------------
-- class UI_GetDragonPackage_LobbyButton
-------------------------------------
UI_GetDragonPackage_LobbyButton = class(UI_ManagedButton, {
    m_dragonPackage = 'StructDragonPkgData',
    m_mainProduct = 'StructProduct'
})

-------------------------------------
-- function init
-------------------------------------
function UI_GetDragonPackage_LobbyButton:init()
    self:load('button_first_myth.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GetDragonPackage_LobbyButton:initUI()
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:timeUpdate(dt) end, 0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GetDragonPackage_LobbyButton:initButton()
    local vars = self.vars

    local closeCB = function() 
        self:refresh()
    end

    local goTo_PackageShop = function()
        local dragonPackage = self.m_dragonPackage or nil
        if (dragonPackage == nil) then
            return
        end
        vars['notiSprite']:setVisible(false)
        UINavigatorDefinition:goTo('package_shop', dragonPackage:getDragonID(), closeCB)
    end  
    vars['btn']:registerScriptTapHandler(function() goTo_PackageShop() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GetDragonPackage_LobbyButton:refresh()
    self.m_dragonPackage = g_getDragonPackage:getShortTimePackage()   
    if (self.m_dragonPackage == nil) then
        return  --구매 가능 상품 없음
    end
    local vars = self.vars
    local dragonPackage = self.m_dragonPackage
    self.m_mainProduct = dragonPackage:getPossibleProduct()

    --드래곤 icon
    local did = dragonPackage:getDragonID()
    local icon = IconHelper:getDragonIconFromDid(did, 3)
    vars['dragonNode']:removeAllChildren()
    vars['dragonNode']:addChild(icon)
end

-------------------------------------
-- function timeUpdate
-------------------------------------
function UI_GetDragonPackage_LobbyButton:timeUpdate(dt)
    local vars = self.vars
    local dragonPackage = self.m_dragonPackage

    --더이상 구매할 수 있는 패키지가 없다.
    if (dragonPackage == nil) then
        self.m_bMarkDelete = true
        self:callDirtyStatusCB()
        return
    end

    --남은 시간 체크 후 시간이 지났다면 UI 갱신
    local remainTime = dragonPackage:getRemainTime()
    if ( remainTime <= 0 ) then
        self:refresh()
        return
    end

    local strTime = ServerTime:getInstance():makeTimeDescToSec(remainTime, true)
    vars['timeLabel']:setString(strTime)
end