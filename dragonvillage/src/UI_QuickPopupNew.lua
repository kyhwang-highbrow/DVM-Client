local PARENT = UI

-------------------------------------
-- class UI_QuickPopupNew
-------------------------------------
UI_QuickPopupNew = class(PARENT, {
        m_loadingUI = 'UI_TitleSceneLoading',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_QuickPopupNew:init()
    local vars = self:load('quick_popup_new.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_QuickPopupNew'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_QuickPopupNew')

    self:initUI()
    self:initButton()
    self:refresh()

    -- @UI_ACTION (포지션 바꾼후 액션)
    self:doActionReset()
    self:doAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_QuickPopupNew:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_QuickPopupNew:initButton()
    local vars = self.vars
    self:init_adventureBtn()
    self:init_dungeonBtn()
    self:init_competitionBtn()
    self:init_underBtn()

    vars['homeBtn']:registerScriptTapHandler(function() UINavigator:goTo('lobby') end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function init_adventureBtn
-------------------------------------
function UI_QuickPopupNew:init_adventureBtn()
    local vars = self.vars
    local l_content = {}
    table.insert(l_content, 'home') -- 로비 버튼은 여기 추가
    table.insert(l_content, 'adventure')
   
    if (not g_contentLockData:isContentLock('exploration')) then
        table.insert(l_content, 'exploration') 
    end

    self:checkLockContent(l_content)
    self:adjustPosX(l_content)
end

-------------------------------------
-- function init_dungeonBtn
-------------------------------------
function UI_QuickPopupNew:init_dungeonBtn()
    local vars = self.vars
    local l_content = {}

    local l_dungeon = {'ancient_ruin','nest_tree', 'nest_evo_stone', 'nest_nightmare'}
    for i, dungeon_name in ipairs(l_dungeon) do
        if (not g_contentLockData:isContentLock(dungeon_name)) then
            table.insert(l_content, dungeon_name) 
        end
    end

    table.insert(l_content, 'secret_relation')
    self:checkLockContent(l_content)
    self:adjustPosX(l_content)
end

-------------------------------------
-- function init_competitionBtn
-------------------------------------
function UI_QuickPopupNew:init_competitionBtn()
    local vars = self.vars
    local l_content = {}

    local l_competition = {'ancient', 'attr_tower', 'colosseum', 'clan_raid', 'rune_guardian', 'challenge_mode'}
    for i, competition_name in ipairs(l_competition) do
        if (not g_contentLockData:isContentLock(competition_name)) then
            table.insert(l_content, competition_name) 
        end
    end

    self:checkLockContent(l_content)
    self:adjustPosX(l_content)
end

-------------------------------------
-- function init_underBtn
-------------------------------------
function UI_QuickPopupNew:init_underBtn()
    local vars = self.vars

     -- 하단 메뉴 잠금 처리 - 아예 안나옴 처리
    local l_under = {'dragonManage', 'tamer', 'forest', 'quest', 'draw', 'shop', 'clan', 'inventory', 'book', 'setting'}
    local l_content = {}
    for i, under_name in ipairs(l_under) do
        if (not g_contentLockData:isContentLock(under_name)) then
            table.insert(l_content, vars[under_name .. 'Btn'])
            vars[under_name .. 'Btn']:setVisible(true)
        else
            vars[under_name .. 'Btn']:setVisible(false)
        end
    end

    -- 드래곤 관리
    vars['dragonManageBtn']:registerScriptTapHandler(function() self:click_dragonManageBtn() end) 
    vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn() end) -- 테이머
    vars['forestBtn']:registerScriptTapHandler(function() self:click_forestBtn() end) -- 드래곤의숲
    vars['questBtn']:registerScriptTapHandler(function() self:click_questBtn() end) -- 퀘스트
    vars['shopBtn']:registerScriptTapHandler(function() self:click_shopBtn() end) -- 상점
    vars['drawBtn']:registerScriptTapHandler(function() self:click_drawBtn() end) -- 부화소
    vars['clanBtn']:registerScriptTapHandler(function() self:click_clanBtn() end) -- 클랜 버튼
    vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)-- 가방
    vars['bookBtn']:registerScriptTapHandler(function() self:click_bookBtn() end) -- 도감 버튼
    vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end) -- 설정

    -- 전체 몇 컨텐츠 중에 - 현재 활성화 된 컨텐츠
    -- 기준 x위치에서 그 차이만큼 옆으로 이동한 다음 정렬시켜줌 
    local max_cnt = 10
    local cnt = #l_content
    local start_pos_x = -495
    local interval = 110
    local dis_cnt = max_cnt - cnt
    local pos_x = start_pos_x + dis_cnt * interval/2

    -- 버튼들의 위치 지정
    for i,v in ipairs(l_content) do
        local _pos_x = pos_x + ((i-1) * interval)
        v:setPositionX(_pos_x)
    end
end

-------------------------------------
-- function checkLockContent
-------------------------------------
function UI_QuickPopupNew:checkLockContent(l_content)
    local vars = self.vars
    for i, content in ipairs(l_content) do
        local is_content_lock, req_user_lv = g_contentLockData:isContentLock(content)
        if (is_content_lock) then
            vars[content .. 'Btn']:setVisible(true)
            if (vars[content .. 'LockSprite']) then
                vars[content .. 'LockSprite']:setVisible(true)
            end
            
            if (vars[content .. 'LockLabel']) then
                vars[content .. 'LockLabel']:setString(Str('레벨 {1}', req_user_lv))
            end

            cca.reserveFunc(vars[content .. 'Btn'], 0.5, function()
                vars[content .. 'Btn']:setEnabled(false)
            end)
        else
            vars[content .. 'Btn']:setVisible(true)
            vars[content .. 'Btn']:registerScriptTapHandler(function() 
                self:goTo(content) 
            end)
        end

        -- 베타 버튼 표시
        local beta_label = vars[content .. 'BetaLabel']
        if beta_label then
            if g_contentLockData:isContentBeta(content) then
                beta_label:setVisible(true) 
            else
                beta_label:setVisible(false)
            end
        end

        -- 룬 수호자 던전 (악몽 10단계 클리어 못했을 경우)
        if (content == 'rune_guardian') then
            if (not g_nestDungeonData:isClearNightmare()) then
                vars['rune_guardianBtn']:setEnabled(false)
                vars['rune_guardianLockSprite']:setVisible(true)
            end
        end
    end
end

-------------------------------------
-- function adjustPosX
-------------------------------------
function UI_QuickPopupNew:adjustPosX(l_content)
    local vars = self.vars
    local padding_x = 184
    local total_cnt = #l_content
    local start_x = -(total_cnt/2 * padding_x - padding_x/2)

    for i, content in ipairs(l_content) do
        local pos_x = start_x + (i - 1) * padding_x 
        vars[content .. 'Btn']:setPositionX(pos_x)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_QuickPopupNew:refresh()
end

-------------------------------------
-- function goTo
-------------------------------------
function UI_QuickPopupNew:goTo(content)
    self:close()
    self:closeDragonManageInfo()

    UINavigator:goTo(content)
end

-------------------------------------
-- function closeDragonManageInfo
-- @brief 드래곤 관리 UI가 열려있다면 닫아줌 - 갱신 문제
------------------------------------- 
function UI_QuickPopupNew:closeDragonManageInfo()
    local is_opend, idx, ui = UINavigatorDefinition:findOpendUI('UI_DragonManageInfo')
    if (is_opend == true) and (ui) then
        UINavigatorDefinition:closeUIList(idx, true)
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_QuickPopupNew:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_settingBtn
-------------------------------------
function UI_QuickPopupNew:click_settingBtn()
    UI_Setting()
end

-------------------------------------
-- function click_dragonManageBtn
-- @brief 드래곤 관리 버튼
-------------------------------------
function UI_QuickPopupNew:click_dragonManageBtn()
    self:goTo('dragon')
end

-------------------------------------
-- function click_tamerBtn
-- @brief 테이머 관리 버튼
-------------------------------------
function UI_QuickPopupNew:click_tamerBtn()
    self:goTo('tamer')
end

-------------------------------------
-- function click_questBtn
-- @brief 퀘스트 버튼
-------------------------------------
function UI_QuickPopupNew:click_questBtn()
    self:goTo('quest')
end

-------------------------------------
-- function click_shopBtn
-- @brief 상점 버튼
-------------------------------------
function UI_QuickPopupNew:click_shopBtn()
    self:goTo('shop')
end

-------------------------------------
-- function click_drawBtn
-- @brief 드래곤 소환 (가챠)
-------------------------------------
function UI_QuickPopupNew:click_drawBtn()
    self:goTo('hatchery')
end

-------------------------------------
-- function click_bookBtn
-- @brief 도감 버튼
-------------------------------------
function UI_QuickPopupNew:click_bookBtn()
    self:goTo('book')
end

-------------------------------------
-- function click_inventoryBtn
-- @brief 가방 버튼
-------------------------------------
function UI_QuickPopupNew:click_inventoryBtn()
    self:goTo('inventory')
end

-------------------------------------
-- function click_forestBtn
-- @brief 드래곤 숲
-------------------------------------
function UI_QuickPopupNew:click_forestBtn()
    self:goTo('forest')
end

-------------------------------------
-- function click_clanBtn
-- @brief 클랜 버튼
-------------------------------------
function UI_QuickPopupNew:click_clanBtn()
    self:goTo('clan')
end