local PARENT = UI

-------------------------------------
-- class UI_ClanRaidRankPopup
-------------------------------------
UI_ClanRaidRankPopup = class(PARENT,{
        m_rank_data = 'table',
        m_offset = 'number',
    })

local CLAN_OFFSET_GAP = 20

-------------------------------------
-- function init
-------------------------------------
function UI_ClanRaidRankPopup:init()
    local vars = self:load('clan_raid_rank.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_ClanRaidRankPopup'

    self.m_offset = 1

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ClanRaidRankPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanRaidRankPopup:initUI()
    local vars = self.vars
    self:makeMyRank()
    self:initTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanRaidRankPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanRaidRankPopup:refresh()
    local vars = self.vars
    -- 종료 시간
    local status_text = g_clanRaidData:getClanRaidStatusText()
    vars['timeLabel']:setString(status_text)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_ClanRaidRankPopup:initTableView()
    local rank_type = CLAN_RANK['RAID']
    self.m_rank_data = g_clanRankData:getRankData(rank_type)

    local vars = self.vars
	local node = vars['listNode']
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
        table_view.m_defaultCellSize = cc.size(1000, 100 + 5)
        table_view:setCellUIClass(UI_ClanRaidRankPopup.makeRankCell, create_func)
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
function UI_ClanRaidRankPopup:makeMyRank()
    local node = self.vars['myClanNode']
    node:removeAllChildren()
    local rank_type = CLAN_RANK['RAID']
    local my_rank = g_clanRankData:getMyRankData(rank_type)
    local ui = self.makeRankCell(my_rank)
    node:addChild(ui.root)
end

-------------------------------------
-- function makeRankCell
-------------------------------------
function UI_ClanRaidRankPopup.makeRankCell(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('clan_raid_rank_item.ui')
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

    -- 클랜 마스터
    local clan_master = struct_clan_rank:getMasterNick()
    vars['masterLabel']:setString(clan_master)

    -- 점수
    local clan_score = struct_clan_rank:getClanScore()
    vars['scoreLabel']:setString(clan_score)
    
    -- 등수 
    local clan_rank = struct_clan_rank:getClanRank()
    vars['rankLabel']:setString(clan_rank)
    
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
function UI_ClanRaidRankPopup:request_clanRank(first)
    local rank_type = CLAN_RANK['RAID']
    local offset = self.m_offset
    local cb_func = function()
        self:initTableView()
    end
    g_clanRankData:request_getRank(rank_type, offset, cb_func)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ClanRaidRankPopup:click_closeBtn()
    self:close()
end