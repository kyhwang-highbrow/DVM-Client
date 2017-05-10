local PARENT = UI_ChatListItem

-------------------------------------
-- class UI_ChatListItem_msg
-------------------------------------
UI_ChatListItem_msg = class(PARENT, {
        m_chatContent = 'ChatContent',
        m_timer = 'number',
        m_timeDesc = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatListItem_msg:init(chat_content)
    self.m_chatContent = chat_content
    self.m_timer = 0
    local vars = self:load('chat_item_user.ui')

    -- 닉네임 (길드, 레벨, 닉네임)
    vars['infoLabel']:setString(chat_content:getUserInfoStr())

    -- 메세지
    vars['chatLabel']:setString(chat_content:getMessage())

    -- 메세지 넓이만큼 UI 레이아웃 설정
    local label_width = vars['chatLabel']:getStringWidth()
    local size = cc.size(vars['chatSprite']:getNormalSize())
    size['width'] = math_max(label_width + 10, 30) -- 말풍선은 최소 30픽셀
    vars['chatSprite']:setNormalSize(size)

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
        end
    end)
    -- 최초 한 번 실행하기 위해 1초를 넣음
    self:update(1)


    do -- 리더 드래곤 아이콘
        local dragon_id = chat_content.m_dragonID
        local evolution = chat_content.m_dragonEvolution
        local grade = 0
        local eclv = 0
        local icon = IconHelper:getDragonIconFromDid(dragon_id, evolution, grade, eclv)
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['profileNode']:addChild(icon)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChatListItem_msg:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChatListItem_msg:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChatListItem_msg:refresh()
end

-------------------------------------
-- function getCellSize
-------------------------------------
function UI_ChatListItem_msg:getCellSize()
    local width, height = self.root:getNormalSize()
    return cc.size(width, height)
end

-------------------------------------
-- function update
-------------------------------------
function UI_ChatListItem_msg:update(dt)
    self.m_timer = (self.m_timer + dt)

    if (self.m_timer >= 1) then
        self.m_timer = (self.m_timer - 1)

        local time_desc = self.m_chatContent:makeTimeDesc()
        if (self.m_timeDesc ~= time_desc) then
            self.vars['timeLabel']:setString(time_desc)
            self.m_timeDesc = time_desc
        end
    end
end