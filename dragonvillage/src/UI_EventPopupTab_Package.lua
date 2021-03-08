local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Package
-------------------------------------
UI_EventPopupTab_Package = class(PARENT,{
        m_package_name = 'string',
        m_product_id = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Package:init(package_name, product_id)
    local vars = self:load('event_shop.ui')
    self.m_package_name = package_name
    if product_id then 
        self.m_product_id = product_id
    else 
        self.m_product_id = -1
    end

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_Package:initUI()
    local vars = self.vars
	local package_name = self.m_package_name

    local is_popup = false
    local ui = nil
    if self.m_product_id > 0 then 
        ui = PackageManager:getTargetUI(package_name, is_popup, self.m_product_id)
    else 
        ui = PackageManager:getTargetUI(package_name, is_popup)
    end
    
    self:setAfter(ui)

    if (ui) then
        local node = vars['shopNode']
        node:addChild(ui.root)
    end
end

-------------------------------------
-- function setAfter
-- @brief 패키지UI는 PackageMnager에서 공동으로 관리
-- @brief 상점 패키지에만 따로 설정을 해주고 싶을 경우 여기에서 세팅 ex) 모험돌파 패키지 풀팝업에는 정보 팝업x 패키지에는 팝업o
-------------------------------------
function UI_EventPopupTab_Package:setAfter(ui)
    local package_name = self.m_package_name
    if (package_name == 'package_adventure_clear') then
        ui:setInfoPopup(true)
    end

    if (package_name == 'package_absolute') then
        -- @kwkang 20-12-14 새해맞이로 패키지 재판매하여 하단 주석처리        
        -- self:changeTitleSprite(ui.vars)
    end
end

-------------------------------------
-- function changeTitleSprite
-- @brief 구글 피쳐드 선정 기념. 구글 apk -> '구글 피처드 선정 기념 ~', 아니면 '피처드 선정 기념 ~'
-- @brief UI_GoogleFeaturedContentChange를 상속받아 함수의 중복을 없앤다. (쓸모 없는 코드지만 이미 작업을 완료 하였으니 피처드 끝난 이후 커밋하여 코드를 깔끔하게 한다.)
-------------------------------------
function UI_EventPopupTab_Package:changeTitleSprite(ui)
    if (ui['otherMarketSprite'] and ui['otherMarketSprite']) then
        local market, os = GetMarketAndOS()
        ui['googleSprite']:setVisible(false)
        ui['otherMarketSprite']:setVisible(false)
        if (market == 'google' or market == 'windows') then
            ui['googleSprite']:setVisible(true)
        else
            ui['otherMarketSprite']:setVisible(true)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_Package:initButton()
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Package:onEnterTab()
end
