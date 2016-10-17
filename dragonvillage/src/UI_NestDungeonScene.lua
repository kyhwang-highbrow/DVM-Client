local PARENT = UI

-------------------------------------
-- class UI_NestDungeonScene
-------------------------------------
UI_NestDungeonScene = class(PARENT, ITopUserInfo_EventListener:getCloneTable(), {
})

-------------------------------------
-- function init
-------------------------------------
function UI_NestDungeonScene:init()
    local vars = self:load('nest_dungeon_scene.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_NestDungeonScene')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_NestDungeonScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_NestDungeonScene'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('네스트 던전')
end

-------------------------------------
-- function close
-------------------------------------
function UI_NestDungeonScene:close()
    if not self.enable then return end
    SoundMgr:playEffect('EFFECT', 'ui_button')

    local function finish_cb()
        UI.close(self)
    end

    -- @ui_actions
    self:doActionReverse(finish_cb, 0.5, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_NestDungeonScene:initUI()
    local vars = self.vars

    do -- infoLabel
        vars['infoLabel']:setString(Str('시련에 따라 다른 속성의 진화석을 얻을 수 있습니다.'))
    end

    do -- listTableNode
        local list_table_node = vars['listTableNode']

        -- # 용 던전 개발에 필요함 사항
        -- 1. 현재 요일을 얻어오는 함수가 필요함
        -- 2. 던전 오픈 정보가 필요함
        -- 3. 요일 정보 sunday, monday, tuesday, wednesday, thursday, friday, saturday
        -- 4. 속성 정보 fire, water, wind, earth, light, dark
        -- 5. 정렬 정보 (1순위 : 오픈 여부, 2순위 : 정렬 순서)

        local function makeDungeonInfo(sort_idx, attr, open_days, desc, stage_id)
            local t_dragon_dungeon_info = {}
            t_dragon_dungeon_info['sort_idx'] = sort_idx
            t_dragon_dungeon_info['attr'] = attr
            t_dragon_dungeon_info['open_days'] = open_days
            t_dragon_dungeon_info['desc'] = desc
            t_dragon_dungeon_info['stage_id'] = stage_id
            t_dragon_dungeon_info['open'] = false

            local l_days = {sun=1, mon=2, tue=3, wed=4, thu=5, fri=6, sat=7}
            local day_of_week = os.date("*t").wday

            for i,v in ipairs(open_days) do
                if (day_of_week == l_days[v]) then
                    t_dragon_dungeon_info['open'] = true
                    break
                end
            end

            return t_dragon_dungeon_info
        end

        local l_dragon_dungeon_info = {}
        l_dragon_dungeon_info[1] = makeDungeonInfo(1, 'fire', {'tue', 'wed', 'sat'}, Str('화/수/토 오픈'), 11011)
        l_dragon_dungeon_info[2] = makeDungeonInfo(2, 'water', {'wed', 'thu', 'sun'}, Str('수/목/일 오픈'), 11011)
        l_dragon_dungeon_info[3] = makeDungeonInfo(3, 'earth', {'mon', 'tue', 'sat'}, Str('월/화/토 오픈'), 11011)
        l_dragon_dungeon_info[4] = makeDungeonInfo(4, 'wind', {'thu', 'fri', 'sun'}, Str('목/금/일 오픈'), 11011)
        l_dragon_dungeon_info[5] = makeDungeonInfo(5, 'light', {'sun'}, Str('일요일 오픈'), 11011)
        l_dragon_dungeon_info[6] = makeDungeonInfo(6, 'dark', {'sat'}, Str('토요일 오픈'), 11011)

        local function click_dragon_item(item)
            self:click_dragonDungeonBtn(item)
        end

        -- 테이블뷰 초기화
        local table_view_ext = TableViewExtension(list_table_node)
        table_view_ext:setCellInfo(230, 438)
        table_view_ext:setItemUIClass(UI_NestDragonDungeonListItem, click_dragon_item) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
        table_view_ext:setItemInfo(l_dragon_dungeon_info)
        --table_view_ext:update()

        -- 정렬
        local function default_sort_func(a, b)
            local a = a['data']
            local b = b['data']

            -- 1. 오픈된게 우선
            if (a['open'] ~= b['open']) then
                return a['open']
            end

            -- 2. sort_idx가 낮은게 우선
            return a['sort_idx'] < b['sort_idx']
        end
        table_view_ext:insertSortInfo('default', default_sort_func)
        table_view_ext:sortTableView('default')
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NestDungeonScene:initButton()
    local vars = self.vars
    vars['dragonBtn']:setEnabled(false)
    vars['giantBtn']:registerScriptTapHandler(function() SoundMgr:playEffect('EFFECT', 'ui_button') UIManager:toastNotificationRed('"거목 던전" 미구현') end)
    vars['secretBtn']:registerScriptTapHandler(function() SoundMgr:playEffect('EFFECT', 'ui_button') UIManager:toastNotificationRed('"비밀 던전" 미구현') end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NestDungeonScene:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_NestDungeonScene:click_exitBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    local scene = SceneLobby()
    scene:runScene()
end

-------------------------------------
-- function click_dragonDungeonBtn
-------------------------------------
function UI_NestDungeonScene:click_dragonDungeonBtn(item)
    SoundMgr:playEffect('EFFECT', 'ui_button')

    local t_data = item['data']

    if (t_data['open'] == false) then
        UIManager:toastNotificationRed(t_data['desc'])
        return
    end

    UI_NestDungeonStageSelectPopup()
end


--@CHECK
UI:checkCompileError(UI_NestDungeonScene)
