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

    local tamer_title_str
    do -- 칭호, 닉네임
        tamer_title_str = struct_user_info:getTamerTitleStr()
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
    local has_title = isNullOrEmpty(tamer_title_str) == false
    cclog(has_title)
    if (struct_clan and has_title == true) then
        vars['clanNode']:setVisible(true)
        vars['tamerNode']:setPositionY(9)
    elseif (struct_clan) then
        vars['clanNode']:setVisible(true)
        vars['tamerNode']:setPositionY(24)
        vars['clanNode']:setPositionY(0)
    elseif (has_title == true) then
        vars['clanNode']:setVisible(false)
        vars['titleLabel']:setPositionY(24)
        vars['tamerNode']:setPositionY(0)
    else
        vars['clanNode']:setVisible(false)
        vars['tamerNode']:setPositionY(9)
        --vars['nameLabel']:setPositionY(11)
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
	    --UIHelper:makePriceNodeVariable(nil,  vars['markNode'], vars['clanLabel'])
    end

    -- 티어...
    local tier_icon = struct_user_info:makeTierIcon()
    if (vars['tierNode']) then
        vars['tierNode']:removeAllChildren()

        if (tier_icon) then
            vars['tierNode']:addChild(tier_icon)
        end
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