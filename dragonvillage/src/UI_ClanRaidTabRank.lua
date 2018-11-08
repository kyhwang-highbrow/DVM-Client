local PARENT = UI

-------------------------------------
-- class UI_ClanRaidTabRank
-------------------------------------
UI_ClanRaidTabRank = class(PARENT,{
        m_owner_ui = '',
        m_rank_data = 'table',
        m_offset = 'number',
    })
    
local CLAN_OFFSET_GAP = 20
-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidTabRank:init(owner_ui)
    self.m_owner_ui = owner_ui
    self.m_offset = 1

    self:request_clanRank()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidTabRank:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidTabRank:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidTabRank:refresh()
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_ClanRaidTabRank:initTableView()
    local rank_type = CLAN_RANK['RAID']
    self.m_rank_data = g_clanRankData:getRankData(rank_type)

    local vars = self.m_owner_ui.vars
	local node = vars['clanRankTabNode']
	local l_rank_list = self.m_rank_data

    -- 이전 보기 추가
    if (1 < self.m_offset) then
        l_rank_list['prev'] = 'prev'
    end

    -- 다음 보기 추가.. 
    if (#l_rank_list > 0) then
        l_rank_list['next'] = 'next'
    end
        
    -- 이전 랭킹 보기
    local function click_prevBtn()
        self.m_offset = math_max(self.m_offset - CLAN_OFFSET_GAP, 1)
        self:request_clanRank()
    end

    -- 다음 랭킹 보기
    local function click_nextBtn()
        if (table.count(l_rank_list) < CLAN_OFFSET_GAP) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('다음 랭킹이 존재하지 않습니다.'))
            return
        end
        self.m_offset = self.m_offset + CLAN_OFFSET_GAP
        self:request_clanRank()
    end

    -- 생성 콜백
    local function create_func(ui, data)
        if (data == 'prev') then
            ui.vars['prevBtn']:setVisible(true)
            ui.vars['itemMenu']:setVisible(false)
            ui.vars['prevBtn']:registerScriptTapHandler(click_prevBtn)
        elseif (data == 'next') then
            ui.vars['nextBtn']:setVisible(true)
            ui.vars['itemMenu']:setVisible(false)
            ui.vars['nextBtn']:registerScriptTapHandler(click_nextBtn)
        end
    end

	do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(510, 50 + 5)
        table_view:setCellUIClass(self.makeRankCell, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_rank_list)

        do-- 테이블 뷰 정렬
            local function sort_func(a, b)
                local a_data = a['data']
                local b_data = b['data']

                -- 이전, 다음 버튼 정렬
                if (a_data == 'prev') then
                    return true
                elseif (b_data == 'prev') then
                    return false
                elseif (a_data == 'next') then
                    return false
                elseif (b_data == 'next') then
                    return true
                end

                -- 랭킹으로 선별
                local a_rank = a_data:getRank()
                local b_rank = b_data:getRank()
                return a_rank < b_rank
            end

            table.sort(table_view.m_itemList, sort_func)
        end

        -- 정산 문구 분기
        local empty_str
        if (g_clanRankData:isSettlingDown()) then
            empty_str = Str('현재 클랜 순위를 정산 중입니다. 잠시만 기다려주세요.')
        else
            empty_str = Str('랭킹 정보가 없습니다.')
        end
        table_view:makeDefaultEmptyDescLabel(empty_str)
    end
end

-------------------------------------
-- function makeMyRank
-------------------------------------
function UI_ClanRaidTabRank:makeMyRank()
    local node = self.m_owner_ui.vars['myClanRankNode']
    node:removeAllChildren()

    local rank_type = CLAN_RANK['RAID']
    local my_rank = g_clanRankData:getMyRankData(rank_type)
    local ui = self.makeRankCell(my_rank)
    node:addChild(ui.root)
end

-------------------------------------
-- function makeRankCell
-------------------------------------
function UI_ClanRaidTabRank.makeRankCell(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('clan_raid_scene_item_03.ui')
    if (not t_data) then
        return ui
    end
    if (t_data == 'next') then
        return ui
    end
    if (t_data == 'prev') then
        return ui
    end

    local struct_clan_rank = t_data

    -- 클랜 마크
    local icon = struct_clan_rank:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan_rank:getClanLvWithName()
    vars['clanLabel']:setString(clan_name)

    -- 점수
    local clan_score = struct_clan_rank:getClanScore()
    vars['scoreLabel']:setString(clan_score)
    
    -- 등수 
    local clan_rank = struct_clan_rank:getRank()
    local rank = clan_rank < 0 and '-' or string.format('%d', clan_rank)
    vars['rankLabel']:setString(rank)
    
    -- 내클랜
    if (struct_clan_rank:isMyClan()) then
        vars['mySprite']:setVisible(true)
        vars['infoBtn']:setVisible(false)
    end

    -- 진행중 단계
    local lv = struct_clan_rank['cdlv'] or 1
    vars['bossLabel']:setString(string.format('Lv.%d', lv))

    -- 정보 보기 버튼
    vars['infoBtn']:registerScriptTapHandler(function()
        local clan_object_id = struct_clan_rank:getClanObjectID()
        g_clanData:requestClanInfoDetailPopup(clan_object_id)
    end)

	return ui
end

-------------------------------------
-- function request_clanRank
-------------------------------------
function UI_ClanRaidTabRank:request_clanRank(first)
    local rank_type = CLAN_RANK['RAID']
    local offset = self.m_offset
    local cb_func = function()
        self:makeMyRank()
        self:initTableView()
    end
    g_clanRankData:request_getRank(rank_type, offset, cb_func)
end

--@CHECK
UI:checkCompileError(UI_ClanRaidTabRank)