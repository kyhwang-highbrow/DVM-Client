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
    vars['chatLabel']:setLineBreakWithoutSpace(true)
    local label_width = vars['chatLabel']:getStringWidth()
    local label_height = vars['chatLabel']:getTotalHeight()


    -- 메세지 넓이만큼 UI 레이아웃 설정
    local sprite_size = cc.size(vars['chatSprite']:getNormalSize())

    -- 메세지 높이가 배경 이미지보다 작을 경우 가운데 정렬
    if (label_height <= sprite_size['height']) then
        vars['chatLabel']:setDimensions(label_width, sprite_size['height'])
        vars['chatLabel']:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    end

    -- 말풍선 이미지 크기 적용
    local size = cc.size(0, 0)
    size['width'] = math_max(label_width + 20, sprite_size['width'])
    size['height'] = math_max(label_height, sprite_size['height'])
    vars['chatSprite']:setNormalSize(size)

    -- 길어진 상하 길이만큼 키워줌
    if (sprite_size['height'] < size['height']) then
        local gap = size['height'] - sprite_size['height']
        local w, h = self.root:getNormalSize()
        self.root:setNormalSize(cc.size(w, h + gap))
    end

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
        local evolution = chat_content.transform and chat_content.transform or chat_content.m_dragonEvolution
        local dragon_skin = chat_content.m_dragonSkinID
        local grade = 0
        local eclv = 0
        -- @dhkim todo 상대 채팅의 아이콘에 스킨을 낀 드래곤이 나와야 됨
        local icon = IconHelper:getDragonIconFromDidWithSkin(dragon_id, evolution, grade, eclv, dragon_skin)
        -- local icon = IconHelper:getDragonIconFromDid(dragon_id, evolution, grade, eclv)
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['profileNode']:addChild(icon)

        local profile_frame_animator = chat_content:makeProfileFrameAnimator()
        if profile_frame_animator ~= nil then
            vars['profileNode']:addChild(profile_frame_animator.m_node)
        end
    end

    self:initButton()
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
    vars['clickBtn']:registerScriptTapHandler(function() self.m_chatContent:openUserInfoMini() end)
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