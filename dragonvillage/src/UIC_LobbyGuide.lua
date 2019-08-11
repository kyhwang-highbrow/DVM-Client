-------------------------------------
-- class UIC_LobbyGuide
-------------------------------------
UIC_LobbyGuide = class({
		m_root = '',
		m_titleLabel = 'UIC_Label',
		m_descLabel = 'UIC_Label',
		m_notiIcon = 'cc.Sprite',

        m_lobbyGuidePointer = 'LobbyGuideAbstract',
        m_refreshDelegateFunc = 'function',
     })

-------------------------------------
-- function init
-- @comment 당초 예상보다 필요한게 많아서... 나중에 필요하면 UI로 만들자
-------------------------------------
function UIC_LobbyGuide:init(root, title_label, desc_label, noti_icon, refresh_delegate_func)
	self.m_root = root
	self.m_titleLabel = title_label
	self.m_descLabel = desc_label
	self.m_notiIcon = noti_icon
    self.m_refreshDelegateFunc = refresh_delegate_func

    if (not self.m_refreshDelegateFunc) then
        self.m_refreshDelegateFunc = function()
            self:refresh()
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UIC_LobbyGuide:refresh()
    self.m_lobbyGuidePointer = nil
	
    -- 마스터의 길
    if g_masterRoadData:isClearAllRoad() then
        self.m_root:setVisible(false)
    else
        self.m_root:setVisible(true)
        
        local rid = g_masterRoadData:getFocusRoad()
        local t_road = TableMasterRoad():get(rid)

        -- 마스터의 길 제목, 내용 텍스트 표시
		local title = TableMasterRoad:getTitleStr(t_road)
        local desc = TableMasterRoad:getDescStr(t_road)
        self.m_titleLabel:setString(title)
        self.m_descLabel:setString(desc)

        -- 획득 가능한 보상이 있으면 아이콘 표시
		local has_reward, _ = g_masterRoadData:hasRewardRoad()
		self:setVisibleNotiIcon(has_reward)
        if has_reward then
            return
        end
    end

    -- 로비 가이드
    local t_table_lobby_guide = TABLE:get('table_lobby_guide')
    local l_lobby_guide = {}
    for i,v in pairs(t_table_lobby_guide) do
        table.insert(l_lobby_guide, v)
    end
    local function sort_func(a, b)
        return a['priority'] < b['priority']
    end
    table.sort(l_lobby_guide, sort_func)

    for i,v in ipairs(l_lobby_guide) do
        -- 해당 클래스가 load되어 있는지 확인
        local lua_class = v['lua_class']
        if package.loaded[lua_class] then

            -- 해당 클래스 require통해서 얻어옴
            local lobby_guide_class = require(lua_class)
            if lobby_guide_class then

                -- 인스턴스 생성
                local pointer = lobby_guide_class(v)

                -- 조건 확인
                pointer:checkCondition()

                -- 안내가 유효할 경우
                if (pointer:isActiveGuide() == true) then
                    self.m_root:setVisible(true)
                    self:setVisibleNotiIcon(true)

                    -- 텍스트 입력	
	                self.m_titleLabel:setString(Str(pointer:getGuideTitleStr()))
                    self.m_descLabel:setString(Str(pointer:getGuideSubTitleStr()))
                    self.m_lobbyGuidePointer = pointer
                    pointer = nil
                    return
                end
                pointer = nil
            end
        end
    end
end

-------------------------------------
-- function onClick
-------------------------------------
function UIC_LobbyGuide:onClick()
    -- 도움말
    if self.m_lobbyGuidePointer then
        self.m_lobbyGuidePointer:startGuide()
        self.m_refreshDelegateFunc()
        return
    end

    -- 마스터의 길
    local ui = UI_MasterRoadPopup(false)
    local function close_cb()
        self.m_refreshDelegateFunc()
    end
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function setVisibleNotiIcon
-------------------------------------
function UIC_LobbyGuide:setVisibleNotiIcon(b)
	self.m_notiIcon:setVisible(b)
end

--@CHECK
UI:checkCompileError(UIC_LobbyGuide)
