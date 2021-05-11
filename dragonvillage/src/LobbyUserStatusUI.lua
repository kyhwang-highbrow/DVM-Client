local PARENT = class(UI, IEventDispatcher:getCloneTable(), IEventListener:getCloneTable())

-------------------------------------
-- class LobbyUserStatusUI
-- @brief 로비 테이머 머리 위 닉네임 UI (클랜, 칭호)
-------------------------------------
LobbyUserStatusUI = class(PARENT, {
        m_rootNode = 'cc.Node',
        m_structUserInfo = 'StructUserInfo',
     })

-------------------------------------
-- function init
-------------------------------------
function LobbyUserStatusUI:init(struct_user_info)
    self:load('lobby_user_info_01.ui')

    -- rootNode 생성
    self.m_rootNode = cc.Node:create()
    self.m_rootNode:addChild(self.root)
    self.root:setPositionY(280)

    self.m_structUserInfo = struct_user_info

    self.vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    self:init_statusUI()
    self:setActive(false)
end

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyUserStatusUI:onEvent(event_name, t_event, ...)
    if (event_name == 'lobby_character_move') then
        local arg = {...}
        local lobby_tamer = arg[1]
        local x = arg[2]
        local y = arg[3]

        self.m_rootNode:setPosition(x, y)

        self:dispatch('lobby_user_status_ui_move', {}, self, x, y)
    end
end

-------------------------------------
-- function init_statusUI
-------------------------------------
function LobbyUserStatusUI:init_statusUI()
    local struct_user_info = self.m_structUserInfo

    local vars = self.vars

    local btn_width, btn_height = vars['infoBtn']:getNormalSize()

    -- 티어...
    local tier_icon = struct_user_info:makeTierIcon()

    do -- 칭호, 닉네임
        local tamer_title_str = struct_user_info:getTamerTitleStr()
        if (vars['titleLabel']) then vars['titleLabel']:setString(tamer_title_str) end

        local nickname = struct_user_info:getNickname()

        -- 칭호와 닉네임을 붙여서 처리
        --[[if tamer_title_str and (tamer_title_str ~= '') then
            nickname = string.format('{@user_title}%s {@white}%s', tamer_title_str, nickname)
        end]]

        vars['nameLabel']:setString(nickname)

        -- 여백을 위해 10픽셀을 더해줌
        local str_width = vars['nameLabel']:getStringWidth() + 10
        if (btn_width < str_width) then
            vars['nameLabel']:setScale(btn_width / str_width)
        else
            vars['nameLabel']:setScale(1)
        end
    end

    -- 클랜이 존재하지 않을 경우 정렬
    local struct_clan = struct_user_info:getStructClan()
    if (struct_clan) then
        vars['nameLabel']:setPositionY(3)
        vars['tierNode']:setPositionY(3)
        vars['clanNode']:setVisible(true)
    else
        --vars['nameLabel']:setPositionY(11)
        vars['nameLabel']:setPositionY(0)
        vars['tierNode']:setPositionY(0)
        vars['titleLabel']:setPositionY(11)
        vars['clanNode']:setVisible(false)
    end


    if struct_clan then
        -- 클랜 마크
        local icon = struct_clan:makeClanMarkIcon()
        vars['markNode']:removeAllChildren()
        vars['markNode']:addChild(icon)

        -- 클랜명
        local clan_name = struct_clan:getClanName()
        vars['clanLabel']:setString(clan_name)

        -- 중앙 정렬
	    UIHelper:makePriceNodeVariable(nil,  vars['markNode'], vars['clanLabel'])
    end

    -- 티어
    if (vars['tierNode']) then
        vars['tierNode']:removeAllChildren()

        local info_btn_width, info_btn_height = vars['infoBtn']:getNormalSize()                             -- 버튼 배경 이미지
        local name_width = math_floor(vars['nameLabel']:getStringWidth() * vars['nameLabel']:getScaleX())   -- 텍스트 너비
        local icon_width = 0
        local icon_height = 0

        if (tier_icon) then
            vars['tierNode']:addChild(tier_icon)
            icon_width, icon_height = tier_icon:getNormalSize() 
            tier_icon:setPosition(ZERO_POINT)
        else
            vars['nameLabel']:setDockPoint(CENTER_POINT)
            vars['nameLabel']:setAnchorPoint(CENTER_POINT)
            vars['nameLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        end

        icon_width = math_floor(icon_width * vars['tierNode']:getScaleX())

        local content_center = math_floor((icon_width + name_width) / 2 + icon_width / 2)
        local move_gap = tier_icon and math_floor(0 - content_center / 2) or 0

        vars['tierNode']:setPosition(0, vars['tierNode']:getPositionY())
        vars['nameLabel']:setPosition(math_floor(icon_width / 2), vars['nameLabel']:getPositionY())
        vars['tamerNode']:setPosition(move_gap, vars['tamerNode']:getPositionY())
    end
end

-------------------------------------
-- function refreshUI
-------------------------------------
function LobbyUserStatusUI:refreshUI(struct_user_info)
    if (struct_user_info) then
        self.m_structUserInfo = struct_user_info
    end
    self:init_statusUI()
end

-------------------------------------
-- function setActive
-------------------------------------
function LobbyUserStatusUI:setActive(active)
    self.vars['infoBtn']:setVisible(active)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function LobbyUserStatusUI:click_infoBtn()
	local is_visit = true
	UI_UserInfoDetailPopup:open(self.m_structUserInfo, is_visit, nil)
end

-------------------------------------
-- function release
-------------------------------------
function LobbyUserStatusUI:release()
    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
        self.m_rootNode = nil
    end

    PARENT.release_EventDispatcher(self)
    PARENT.release_EventListener(self)
end