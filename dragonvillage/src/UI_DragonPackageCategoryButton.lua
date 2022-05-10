

----------------------------------------------------------------------
-- class UI_DragonPackageCategoryButton
----------------------------------------------------------------------
UI_DragonPackageCategoryButton = class(UI, ITableViewCell:getCloneTable(), {
    m_data   = 'StructDragonPkgDat',
    m_parent = 'UI_ShopPackageScene',
    m_DragonPkgUI = 'UI_GetDragonPackage'
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_DragonPackageCategoryButton:init(data)
    self.m_data = data
    self.m_DragonPkgUI = nil
    self:load('shop_package_list.ui')

    self:initButton()
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_DragonPackageCategoryButton:initButton()
    local vars = self.vars
    vars['listBtn']:setVisible(false)  --일반 버튼

    local mythBtn = vars['mythListBtn']
    mythBtn:setVisible(true)
    mythBtn:registerScriptTapHandler(function() self:click_btn() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_DragonPackageCategoryButton:refresh()
    local vars = self.vars
    local packageData = self.m_data
    --제목
    local did = packageData:getDragonID()
    local dragonName = TableDragon:getDragonName(did)
    local titleName = Str('{1} 획득 축하 패키지', dragonName)
    vars['mythListLabel']:setString(titleName)

    local badeIcon = packageData:getBadgeIcon()
    if (badeIcon) then
        vars['mythBadgeNode']:removeAllChildren()
        vars['mythBadgeNode']:addChild(badeIcon)
    end
end

----------------------------------------------------------------------
-- function click_btn
----------------------------------------------------------------------
function UI_DragonPackageCategoryButton:click_btn()
    local vars = self.vars
    local packageData = self.m_data
    local parent = self.m_parent
    local mainUI = self.m_DragonPkgUI
    --UI 타겟 변경
    parent:changeTargetUI(self)

    --없다면 만든다.
    local isNew = false
    if (mainUI == nil) then
        isNew = true
        mainUI = UI_GetDragonPackage(packageData, nil, false)
    end
    parent:setDragonPackageUI(mainUI, isNew)

    --UI저장
    self.m_DragonPkgUI = mainUI

    self.vars['mythNotiSprite']:setVisible(false)
end

----------------------------------------------------------------------
-- function SetTarget
----------------------------------------------------------------------
function UI_DragonPackageCategoryButton:SetTarget(isTarget)
    self.vars['mythListBtn']:setEnabled(not isTarget)
end

----------------------------------------------------------------------
-- function isDragonPackage
----------------------------------------------------------------------
function UI_DragonPackageCategoryButton:isDragonPackage()
    return true
end