-------------------------------------
-- class UI_LeagueRaidRankItem
-------------------------------------
UI_LeagueRaidRankMenu = class(UI,{
    m_totalScrollView = 'cc.scrollView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidRankMenu:init(owner_ui)
    local vars = self:load('league_raid_rank.ui')

    self:initScroll()
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LeagueRaidRankMenu:initUI()
    self:updateRankItems()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LeagueRaidRankMenu:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LeagueRaidRankMenu:refresh()
end

-------------------------------------
-- function updateRankItems
-------------------------------------
function UI_LeagueRaidRankMenu:updateRankItems()
    local vars = self.vars
    local promotion_list = {}
    local remaining_list = {}
    local demoted_list = {}
    local waiting_list = {}
    local my_info = g_leagueRaidData:getMyInfo()
    local members_list = g_leagueRaidData:getMemberList()


    local up_last_rank = 1
    local stay_last_rank = 1
    local down_last_rank = 1

    if (my_info['rank_last_index']) then
        if (my_info['rank_last_index']['up_last_rank']) then up_last_rank = my_info['rank_last_index']['up_last_rank'] end
        if (my_info['rank_last_index']['stay_last_rank']) then stay_last_rank = my_info['rank_last_index']['stay_last_rank'] end
        if (my_info['rank_last_index']['down_last_rank']) then down_last_rank = my_info['rank_last_index']['down_last_rank'] end
    end

    -- 0 승급, 1 잔류, 3 강등
    for i, v in ipairs(members_list) do
        if (v and v['status'] and v['status'] == 3) or (v and v['score'] and v['score'] <= 0 ) then
            table.insert(waiting_list, v)
        elseif (v and v['status'] and v['status'] == 0) then
            table.insert(promotion_list, v)
        elseif (v and v['status'] and v['status'] == 1) then
            table.insert(remaining_list, v)

        else
            table.insert(demoted_list, v)
        end
    end

    -- 리스트 확정 후 판단훌 수 있는것들
    -- 승급 구간{@GOLD} ({1}위 - {1}위) {@default}
    -- 잔류 구간{@sky_blue} ({1}위 - {1}위) {@default}
    -- 강등 구간{@light_red} ({1}위 - {1}위) {@default}
    -- {1}위~{2}위 or {1}위
    if (#promotion_list > 0) then
        local starting_index = 1
        local format_string = Str('승급 구간') .. '{@GOLD} ('

        if (up_last_rank <= 1 and #promotion_list <= 1) then
            format_string = format_string .. Str('{1}위', starting_index) .. ') {@default}'
        else
            format_string = format_string .. Str('{1}위~{2}위', starting_index, up_last_rank) .. ') {@default}'
        end

        if (vars['promotionPannelLabel']) then vars['promotionPannelLabel']:setString(format_string) end
    end

    if (#remaining_list > 0) then
        local starting_index = #promotion_list + 1
        local format_string = Str('잔류 구간') .. '{@sky_blue} ('

        if (stay_last_rank <= 1 and #remaining_list <= 1) then
            format_string = format_string .. Str('{1}위', starting_index) .. ') {@default}'
        else
            format_string = format_string .. Str('{1}위~{2}위', starting_index, stay_last_rank) .. ') {@default}'
        end

        if (vars['remainingPannelLabel']) then vars['remainingPannelLabel']:setString(format_string) end
    end

    if (#demoted_list > 0) then
        local starting_index = #promotion_list + #remaining_list + 1
        local format_string = Str('강등 구간') .. '{@light_red} ('

        if (down_last_rank <= 1 and #remaining_list <= 1) then
            format_string = format_string .. Str('{1}위', starting_index) .. ') {@default}'
        else
            format_string = format_string .. Str('{1}위~{2}위', starting_index, down_last_rank) .. ') {@default}'
        end

        if (vars['demotedPannelLabel']) then vars['demotedPannelLabel']:setString(format_string) end
    end


    --[[
    for i = 1, 3 do
        table.insert(promotion_list, members_list[1])
    end

    
    for i = 1, 3 do
        table.insert(remaining_list, members_list[1])
    end

    
    for i = 1, 3 do
        table.insert(demoted_list, members_list[1])
    end

    
    for i = 1, 3 do
        table.insert(waiting_list, members_list[1])
    end]]

    local list_offset_y = 35
    local margin = 20
    local last_adjusted_Y = 0

    -- 승격
    if (not vars['promotionNode']) then return end

    -- 승격 아이템 수량에 따라 잔류 위치 조정
    local line_promotion = 0
    for i, v in ipairs(promotion_list) do
        if (i % 3 == 1) then line_promotion = line_promotion + 1 end
    end
    line_promotion = line_promotion == 0 and 1 or line_promotion

    if (#promotion_list > 0) then
        vars['promotionNode']:setContentSize(740, 100 * line_promotion)
        vars['promotionPannelNode']:setContentSize(740, 100 * line_promotion)

        local table_view_promotion = UIC_TableViewTD(vars['promotionNode'])
        table_view_promotion.m_cellSize = cc.size(245, 100)
        table_view_promotion.m_nItemPerCell = 3
        table_view_promotion:setCellUIClass(UI_LeagueRaidRankItem)
        table_view_promotion:setItemList(promotion_list)
        table_view_promotion.m_scrollView:setTouchEnabled(false)
        table_view_promotion.m_node:setPositionY(0 - list_offset_y - 10)
        last_adjusted_Y = 0 - list_offset_y - (100) * line_promotion - margin
        if (vars['promotionLabel']) then  
            local promotion_reward = 0
            if (my_info and my_info['up_season_reward']) then
                promotion_reward = my_info['up_season_reward']['700001']
            end

            vars['promotionLabel']:setString(comma_value(promotion_reward))
        end
    else
        vars['promotionPannelNode']:setVisible(false)
    end

    -- 잔류
    if (not vars['remainingPannelNode'] or not vars['remainingNode']) then return end

    -- 승격 아이템 수량에 따라 잔류 위치 조정
    local line_remaining = 0
    for i, v in ipairs(remaining_list) do
        if (i % 3 == 1) then line_remaining = line_remaining + 1 end
    end

    line_remaining = line_remaining == 0 and 1 or line_remaining

    if (#remaining_list > 0) then
        vars['remainingNode']:setContentSize(740, 100 * line_remaining)
        vars['remainingPannelNode']:setContentSize(740, 100 * line_remaining)

        local table_view_remaining = UIC_TableViewTD(vars['remainingNode'])
        table_view_remaining.m_cellSize = cc.size(245, 100)
        table_view_remaining.m_nItemPerCell = 3
        table_view_remaining:setCellUIClass(UI_LeagueRaidRankItem)
        table_view_remaining:setItemList(remaining_list)
        table_view_remaining.m_scrollView:setTouchEnabled(false)
        table_view_remaining.m_node:setPositionY(0 - list_offset_y - 10)

        if (vars['remainingLabel']) then  
            local remaining_reward = 0
            if (my_info and my_info['stay_season_reward']) then
                remaining_reward = my_info['stay_season_reward']['700001']
            end
            vars['remainingLabel']:setString(comma_value(remaining_reward))
        end

        vars['remainingPannelNode']:setPositionY(last_adjusted_Y)
        last_adjusted_Y = last_adjusted_Y - list_offset_y - 90 * line_remaining - margin
    else
        vars['remainingPannelNode']:setVisible(false)
    end

    -- 강등
    if (not vars['demotedPannelNode'] or not vars['demotedNode']) then return end

    -- 승격 아이템 수량에 따라 잔류 위치 조정
    local line_demoted = 0
    for i, v in ipairs(demoted_list) do
        if (i % 3 == 1) then line_demoted = line_demoted + 1 end
    end

    line_demoted = line_demoted == 0 and 1 or line_demoted

    if (#demoted_list > 0) then
        vars['demotedNode']:setContentSize(740, 100 * line_demoted)
        vars['demotedPannelNode']:setContentSize(740, 100 * line_demoted)

        local table_view_demoted = UIC_TableViewTD(vars['demotedNode'])
        table_view_demoted.m_cellSize = cc.size(245, 100)
        table_view_demoted.m_nItemPerCell = 3
        table_view_demoted:setCellUIClass(UI_LeagueRaidRankItem)
        table_view_demoted:setItemList(demoted_list)
        table_view_demoted.m_scrollView:setTouchEnabled(false)
        table_view_demoted.m_node:setPositionY(0 - list_offset_y - 10)

        if (vars['demotedLabel']) then  
            local demoted_reward = 0
            if (my_info and my_info['down_season_reward']) then
                demoted_reward = my_info['down_season_reward']['700001']
            end
            vars['demotedLabel']:setString(comma_value(demoted_reward))
        end

        vars['demotedPannelNode']:setPositionY(last_adjusted_Y)
        last_adjusted_Y = last_adjusted_Y - list_offset_y - 100 * line_demoted - margin
    else
        vars['demotedPannelNode']:setVisible(false)
    end

    -- 대기
    if (not vars['waitingPannelNode'] or not vars['waitingNode']) then return end

    -- 승격 아이템 수량에 따라 잔류 위치 조정
    local line_waiting = 0
    for i, v in ipairs(waiting_list) do
        if (i % 3 == 1) then line_waiting = line_waiting + 1 end
    end

    if (#waiting_list > 0) then
        vars['waitingNode']:setContentSize(740, 100 * line_waiting)
        vars['waitingPannelNode']:setContentSize(740, 100 * line_waiting)

        vars['waitingPannelNode']:setVisible(true)
        local table_view_waiting = UIC_TableViewTD(vars['waitingNode'])
        table_view_waiting.m_cellSize = cc.size(245, 100)
        table_view_waiting.m_nItemPerCell = 3
        table_view_waiting:setCellUIClass(UI_LeagueRaidRankItem)
        table_view_waiting:setItemList(waiting_list)
        table_view_waiting.m_scrollView:setTouchEnabled(false)
        table_view_waiting.m_node:setPositionY(0 - list_offset_y - 10)

        local line_count = table_view_waiting:getLineCount()

        vars['waitingPannelNode']:setPositionY(last_adjusted_Y)
    else
        vars['waitingPannelNode']:setVisible(false)
    end

    local total_lines = line_promotion + line_remaining + line_demoted + line_waiting
    local content_size = (95 + margin) * total_lines
    if (line_promotion > 0) then content_size = content_size + list_offset_y end
    if (line_remaining > 0) then content_size = content_size + list_offset_y end
    if (line_demoted > 0) then content_size = content_size + list_offset_y end
    if (line_waiting > 0) then content_size = content_size + list_offset_y end

    self.m_totalScrollView:setContentSize(740, content_size)
    self.m_totalScrollView:setContentOffset(self.m_totalScrollView:minContainerOffset(), false)

    if (total_lines <= 6) then 
        self.m_totalScrollView:setTouchEnabled(false)
    end

    --local min_container_offset = self.m_totalScrollView:minContainerOffset()
    --local max_container_offset = self.m_totalScrollView:maxContainerOffset()-

    --self.m_totalScrollView:scheduleUpdateWithPriorityLua(function(dt) ccdump(self.m_totalScrollView:minContainerOffset()) end, 0)
end



-------------------------------------
-- function initScroll
-------------------------------------
function UI_LeagueRaidRankMenu:initScroll()
    local vars = self.vars
    for lua_name,v in pairs(vars) do
        
        -- [UI규정] Scroll 루아 변수명 ex) clanScrollNode, clanSrollMenu (접두어 동일)
        if (pl.stringx.endswith(lua_name, 'ScrollNode')) then        
            local scroll_name = pl.stringx.rpartition(lua_name,'ScrollNode')                        -- ex) clan + ScrollNode 로 접두어 분리

            self:makeScroll(vars[scroll_name .. 'ScrollMenu'], vars[scroll_name .. 'ScrollNode'], scroll_name)   -- ex) clan + SrollMenu 가 있을 거라고 판단(규정상)
        end
    end
end

-------------------------------------
-- function makeScroll
-------------------------------------
function UI_LeagueRaidRankMenu:makeScroll(scroll_menu, scroll_node, scroll_name)
    local vars = self.vars
   
    -- ScrollNode, ScrollMenu 둘 다 있어야 동작 가능
    if (not scroll_node or not scroll_menu) then
        return
    end

    -- ScrollView 사이즈 설정 (ScrollNode 사이즈)
    local size = scroll_node:getContentSize()
    local scroll_view = cc.ScrollView:create()
    scroll_view:setNormalSize(size)
    scroll_node:setSwallowTouch(false)
    scroll_node:addChild(scroll_view)

    -- ScrollView 에 달아놓을 컨텐츠 사이즈(ScrollMenu)
    local target_size = scroll_menu:getContentSize()
    scroll_view:setContentSize(target_size)
    scroll_view:setDockPoint(TOP_CENTER)
    scroll_view:setAnchorPoint(TOP_CENTER)
    scroll_view:setPosition(ZERO_POINT)
    scroll_view:setTouchEnabled(true)

    -- ScrollMenu를 부모에서 분리하여 ScrollView에 연결
    -- 분리할 부모가 없을 때 에러 없음
    scroll_menu:removeFromParent()
    scroll_view:addChild(scroll_menu)

    -- ScrollMenu와 화면 길이 비교(가로/세로)
    local container_node = scroll_view:getContainer()
    local size_x = size.width - target_size.width
    local size_y = size.height - target_size.height

    container_node:setPositionY(size_y)
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 외부에서 스크롤뷰 제어할 수 있도록 vars에 담아둠
    vars[scroll_name .. 'ScrollView'] = scroll_view

    self.m_totalScrollView = scroll_view
end






-------------------------------------
-- class UI_LeagueRaidRankItem
-------------------------------------
UI_LeagueRaidRankItem = class(UI, ITableViewCell:getCloneTable(),{
        m_userInfo = 'table',
    })


--[[
{
                ['lv']=99;
                ['uid']='ykil';
                ['nick']='ykil';
                ['status']=0;
                ['leader']={
                        ['transform']=3;
                        ['did']=120872;
                        ['evolution']=3;
                };
                ['score']=0;
        }
]]

-----------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidRankItem:init(user_info)
    local vars = self:load('league_raid_rank_item.ui')

    self.m_userInfo = user_info

    self:initUI()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_LeagueRaidRankItem:initUI()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LeagueRaidRankItem:initButton()
    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LeagueRaidRankItem:refresh()
    local vars = self.vars

    if (not self.m_userInfo) then return end

    local number = self.m_userInfo['rank'] == nil and '-' or self.m_userInfo['rank']
    local nick_name = self.m_userInfo['nick']
    local score = self.m_userInfo['score']
    local leader_info = self.m_userInfo['leader'] == nil and {} or self.m_userInfo['leader']
    local my_uid = g_userData:get('uid')

    -- 기본정보
    if (vars['rankLabel']) then vars['rankLabel']:setString(Str('No. {1}', number)) end
    if (vars['userLabel']) then vars['userLabel']:setString(nick_name) end
    if (vars['scoreLabel']) then vars['scoreLabel']:setString(Str('{1}점', comma_value(score))) end
    if (vars['meVisual']) then
        local is_me = my_uid == self.m_userInfo['uid']
        vars['meVisual']:setVisible(is_me) 
    end


    do -- 리더 드래곤 아이콘
        local dragon_id = leader_info['did']
        local transform = leader_info['transform']
        local evolution = transform and transform or leader_info['evolution']
        local icon = IconHelper:getDragonIconFromDid(dragon_id, evolution, 0, 0)
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        icon:setFlippedX(true)
        vars['dragonNode']:addChild(icon)
    end

end
