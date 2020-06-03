
-------------------------------------
-- class StructToast
-------------------------------------
StructToast = class({
        m_toastType = 'string',
        m_toastList = 'list',
        m_toastLayer = 'cc.Layer',
        m_toastHeight = 'number',
        m_toastTime = 'number',
        m_toastPosY = 'number',

        m_empty_cb = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function StructToast:init(toast_type, ui_item, delay_time, height, empty_cb, pos_y)

    -- 토스트 종류 구분하는 타입
    self.m_toastType = toast_type or ''
    
    -- 초기화
    self.m_toastHeight = height
    self.m_toastTime = delay_time
    self.m_toastPosY = pos_y or 370

    -- 토스트 붙일 레이어
    self.m_toastLayer = cc.Node:create()
    self.m_toastLayer:setDockPoint(cc.p(0.5, 0.5))
    self.m_toastLayer:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_toastLayer:setPositionY(self.m_toastPosY)
    UIManager.m_scene:addChild(self.m_toastLayer, SCENE_ZORDER.TOAST)
    

    -- 토스트 첫번째 아이템 등록
    self.m_toastList = {}
    self:addToastItem(ui_item)

    -- 리스트 비었을 때 콜백
    self.m_empty_cb = empty_cb
end

-------------------------------------
-- function addToastItem
-- @brief 
-------------------------------------
function StructToast:addToastItem(ui_item)

    -- 리스트에 추가
    table.insert(self.m_toastList, 1, ui_item)
    self.m_toastLayer:addChild(ui_item.root)

    local function cb()
        self:removeToastNoti(ui_item)
    end

    local delay_time = self.m_toastTime
    -- 등장 액션 지정
    ui_item.root:setOpacity(0)
    ui_item.root:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 255), cc.DelayTime:create(delay_time), cc.FadeTo:create(0.5, 0), cc.CallFunc:create(cb)))

    -- 정렬
    self:sortToastNoti()

end

-------------------------------------
-- function removeToastNoti
-- @brief 재생이 완료된 메세지를 삭제
-------------------------------------
function StructToast:removeToastNoti(ui_item)
    
    -- 삭제 처리
    for i,v in ipairs(self.m_toastList) do
        if (v == ui_item) then
            ui_item.root:removeFromParent(true)
            table.remove(self.m_toastList, i)
            break
        end
    end

    if (self.m_toastList == 0) then
        if (self.m_empty_cb) then
            self.m_empty_cb(self.m_toastType)
        end
    end
   
end

-------------------------------------
-- function sortToastNoti
-- @brief 메세지들의 위치를 정렬
-------------------------------------
function StructToast:sortToastNoti()
    for i, ui_item in ipairs(self.m_toastList) do
        -- 기존에 move액션 삭제(tag 1)
        ui_item.root:stopActionByTag(1)

        local height = self.m_toastHeight
        -- 새로운 move액션 실행
        local action = cc.MoveTo:create(0.3, cc.p(0, (i-1)*height))
        action:setTag(1)
        ui_item.root:runAction(action)
    end
end