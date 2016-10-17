local POPUP_CONTENT_WIDTH = 410
local POPUP_CONTENT_HEIGHT = 360

POPUP_TYPE = {
    OK = 1,            -- 확인
    YES_NO = 2,        -- 예, 아니오
}

-------------------------------------
-- class UI_Popup
-------------------------------------
UI_Popup = class(UI, ITopUserInfo_EventListener:getCloneTable(), {
        m_rootNode = 'cc.Node',
        m_frameNode = 'cc.Node',
        m_frameTop = '',
        m_frameMiddle = '',
        m_frameBottom = '',

        m_rootMenu = '',

        --
        m_popupType = 'POPUP_TYPE',
        m_msg = 'string',
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',

        --
        m_selectCbFunc = 'function',
    })

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_Popup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Popup'
    self.m_bUseExitBtn = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_Popup:init(popup_type, msg, ok_btn_cb, cancel_btn_cb)
    self.m_popupType = popup_type
    self.m_msg = msg
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = cancel_btn_cb

    self.root = cc.Node:create()
    self.root:setDockPoint(cc.p(0.5, 0.5))
    self.root:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_rootNode = cc.Node:create()
    self.m_rootNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_rootNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_rootNode:setPositionY(15)
    self.root:addChild(self.m_rootNode)

    self.m_frameNode = cc.Node:create()
    self.m_frameNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_frameNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_rootNode:addChild(self.m_frameNode)

    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/popup/popup.plist')
    --self.m_frameMiddle = cc.Sprite:createWithSpriteFrameName('popup_white.png')
    self.m_frameMiddle = cc.Scale9Sprite:createWithSpriteFrameName('popup_white.png')
    self.m_frameMiddle:setDockPoint(cc.p(0.5, 0.5))
    self.m_frameMiddle:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_frameMiddle:setContentSize(POPUP_CONTENT_WIDTH, POPUP_CONTENT_HEIGHT + 20)
    self.m_frameMiddle:setScaleY(0)
    --self.m_frameMiddle:setColor(cc.c3b(0,0,0))
    --self.m_frameMiddle:setOpacity(216)
    self.m_frameNode:addChild(self.m_frameMiddle)

    self.m_frameTop = MakeAnimator('res/ui/a2d/popup/popup.vrp')
    --self.m_frameTop:changeAni('top_appear', true)
    self.m_frameNode:addChild(self.m_frameTop.m_node)

    self.m_frameBottom = MakeAnimator('res/ui/a2d/popup/popup.vrp')
    --self.m_frameBottom:changeAni('bottom_appear', true)
    self.m_frameNode:addChild(self.m_frameBottom.m_node)
    
    self.m_rootMenu = cc.Menu:create()
    --self.m_rootMenu:setDockPoint(cc.p(0.5, 0.5))
    --self.m_rootMenu:setAnchorPoint(cc.p(0.5, 0.5))
    --self.m_rootMenu:setPosition(-200, -500)
    self.m_rootMenu:setPosition(0, 0)
    self.m_rootNode:addChild(self.m_rootMenu)

    self.vars = {}

    self:initUIComponent()

    UIManager:open(self, UIManager.POPUP)
    self:openPopup()

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() if (not self.enable) then return end self:closePopup() end, 'UI_Popup')

    -- 팝업이 완전히 종료된 후 콜백 실행
    self.root:registerScriptHandler(function(event)
        if (event == 'cleanup') then
            if self.m_selectCbFunc then
                self.m_selectCbFunc()
            end
        end
    end)
end

-------------------------------------
-- function openPopup
-------------------------------------
function UI_Popup:openPopup()
    self.m_frameTop:changeAni('top_appear', false)
    self.m_frameBottom:changeAni('bottom_appear', false)

    self.m_rootMenu:setVisible(false)

    self.m_frameTop:addAniHandler(function()
        self.m_frameTop:changeAni('top_idle', false)
        self.m_frameBottom:changeAni('bottom_idle', false)

        self.m_frameTop.m_node:stopAllActions()
        self.m_frameBottom.m_node:stopAllActions()

        self.m_frameTop.m_node:runAction(cc.MoveTo:create(0.1, cc.p(0, POPUP_CONTENT_HEIGHT/2)))
        self.m_frameBottom.m_node:runAction(cc.MoveTo:create(0.1, cc.p(0, -POPUP_CONTENT_HEIGHT/2)))

        self.m_frameMiddle:stopAllActions()
        self.m_frameMiddle:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1), cc.CallFunc:create(function()
            self.m_rootMenu:setVisible(true)
            self.enable = true
        end)))

        
    end)
end

-------------------------------------
-- function closePopup
-------------------------------------
function UI_Popup:closePopup(cb_function)

    self.m_selectCbFunc = cb_function

    self.m_rootMenu:setVisible(false)

    self.m_frameTop:addAniHandler(function()
        self.m_frameTop:changeAni('top_idle', false)
        self.m_frameBottom:changeAni('bottom_idle', false)

        self.m_frameTop.m_node:stopAllActions()
        self.m_frameBottom.m_node:stopAllActions()

        self.m_frameTop.m_node:runAction(cc.MoveTo:create(0.1, cc.p(0, 0)))
        self.m_frameBottom.m_node:runAction(cc.MoveTo:create(0.1, cc.p(0, 0)))

        self.m_frameMiddle:stopAllActions()
        self.m_frameMiddle:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1, 0), cc.CallFunc:create(function()
            self:hidePopup()
        end)))

        
    end)

    self:doActionReverse()

    --[[
    self.m_frameTop:changeAni('top_positive', false)
    self.m_frameBottom:changeAni('bottom_positive', false)
    
    local duration = self.m_frameTop:getDuration() + 0.7
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function() 
        self:close()
    end)))

    self.enable = false

    UIManager:toastNotificationGreen('강화가 되었습니다.')
    --]]
end

-------------------------------------
-- function hidePopup
-------------------------------------
function UI_Popup:hidePopup()
    local sequence = cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.01), cc.CallFunc:create(function() self:close() end))
    self.m_rootNode:runAction(sequence)
end

-------------------------------------
-- function nagativeAction
-------------------------------------
function UI_Popup:nagativeAction()

    local start_action = cc.MoveTo:create(0.05, cc.p(-20, 0))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(0, 0)), 0.2)
    self.m_frameNode:stopAllActions()
    self.m_frameNode:runAction(cc.Sequence:create(start_action, end_action))

    UIManager:toastNotificationRed('금액이 부족합니다.')
end

-------------------------------------
-- function initUIComponent
-------------------------------------
function UI_Popup:initUIComponent()
    if (self.m_popupType == POPUP_TYPE.OK) then
        self:initUIComponent_OK()

    elseif (self.m_popupType == POPUP_TYPE.YES_NO) then
        self:initUIComponent_YES_NO()

    end

    -- msg
    self:makeMessageLabel()
end

-------------------------------------
-- function initUIComponent_OK
-------------------------------------
function UI_Popup:initUIComponent_OK()
    -- ok 버튼
    local o_button = self:makeOButton()
    o_button:setPositionX(0)
end

-------------------------------------
-- function initUIComponent_YES_NO
-------------------------------------
function UI_Popup:initUIComponent_YES_NO()
    -- yes 버튼
    local o_button = self:makeOButton()

    -- no 버튼
    local x_button = self:makeXButton()
end

-------------------------------------
-- function makeOButton
-- @brief
-------------------------------------
function UI_Popup:makeOButton()
    local node = cc.MenuItemImage:create()
    node:setNormalSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame('popup_btn01.png'))
    node:setSelectedSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame('popup_btn03.png'))

    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setPosition(85, -281)
    self.m_rootMenu:addChild(node)
    node:registerScriptTapHandler(function()
        if (not self.enable) then
            return
        end


        self:closePopup(self.m_cbOKBtn)
    end)

    return node
end

-------------------------------------
-- function makeXButton
-- @brief
-------------------------------------
function UI_Popup:makeXButton()
    local node = cc.MenuItemImage:create()
    node:setNormalSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame('popup_btn02.png'))
    node:setSelectedSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame('popup_btn04.png'))

    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setPosition(-85, -281)
    self.m_rootMenu:addChild(node)
    node:registerScriptTapHandler(function()
        if (not self.enable) then
            return
        end
            
        self:closePopup(self.m_cbCancelBtn)
    end)

    return node
end


-------------------------------------
-- function makeMessageLabel
-- @brief
-------------------------------------
function UI_Popup:makeMessageLabel()
    local width = (POPUP_CONTENT_WIDTH - 30)
    local height = (POPUP_CONTENT_HEIGHT - 30)
    local label = RichLabel(self.m_msg, 22, width, height, TEXT_V_ALIGN_CENTER, TEXT_H_ALIGN_CENTER, cc.p(0.5, 0.5), false)
    self.m_rootMenu:addChild(label.m_root)
end










-------------------------------------
-- function MakeSimplePopup
-------------------------------------
function MakeSimplePopup(type, msg, ok_btn_cb, cancel_btn_cb)
    local popup = UI_Popup(type, msg, ok_btn_cb, cancel_btn_cb)
    --popup.m_cbOKBtn = ok_btn_cb
    --popup.m_cbCancelBtn = cancel_btn_cb
    --popup:setMessage(msg)
    return popup
end