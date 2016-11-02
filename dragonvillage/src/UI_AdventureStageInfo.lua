local PARENT = UI

-------------------------------------
-- class UI_AdventureStageInfo
-------------------------------------
UI_AdventureStageInfo = class(PARENT,{
        m_stageID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureStageInfo:init(stage_id)
    self:init_MemberVariable(stage_id)

    local vars = self:load('adventure_stage_info.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AdventureStageInfo')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function init_MemberVariable
-------------------------------------
function UI_AdventureStageInfo:init_MemberVariable(stage_id)
    self.m_stageID = stage_id
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AdventureStageInfo:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdventureStageInfo:initButton()
    local vars = self.vars
    vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdventureStageInfo:refresh()
    local vars = self.vars
    local stage_id = self.m_stageID

    do -- 스테이지 이름
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        local chapter_name = chapterName(chapter)
        vars['titleLabel']:setString(chapter_name .. Str(' {1}-{2}', chapter, stage))
    end

    do -- 스테이지 설명
        vars['dscLabel']:setString(Str('정령의 숲에서 정령정령한 일이 일어나고 있었다.\n정령정령한 일은 과연 무엇일까?'))
    end

    do -- 모험 소비 활동력
        if (stage_id == 99999) then
            self.vars['actingPowerLabel']:setString('0')
        else
            local table_drop = TABLE:get('drop')
            local t_drop = table_drop[stage_id]
            -- 'stamina' 추후에 타입별 stamina 사용 예정
            -- local cost_type = t_drop['cost_type']
            local cost_value = t_drop['cost_value']
            self.vars['actingPowerLabel']:setString(cost_value)
        end 
    end

    -- 획득 가능 보상
    self:refresh_rewardInfo()
end

-------------------------------------
-- function refresh_rewardInfo
-- @brief 획득 가능 보상
-------------------------------------
function UI_AdventureStageInfo:refresh_rewardInfo()
    -- stage_id로 드랍정보를 얻어옴
    local stage_id = self.m_stageID
    local drop_helper = DropHelper(stage_id)
    local l_item_list = drop_helper:getDisplayItemList()

    local list_table_node = self.vars['listViewNode']

    -- 리스트 아이템 생성 콜백
    local function create_func(item)
        local ui = item['ui']
        ui.root:setDockPoint(cc.p(0, 0))
        ui.root:setAnchorPoint(cc.p(0, 0))
        ui.root:setScale(0.8)
    end

    -- 클릭 콜백 함수
    local function click_item(item)
        local ui = item['ui']
        ui:click_clickBtn()
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.HORIZONTAL)
    table_view_ext:setCellInfo(120, 120)
    table_view_ext:setItemUIClass(UI_ItemCard, click_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo(l_item_list)
    table_view_ext:update()

    --self.m_tableViewExt = table_view_ext
end

-------------------------------------
-- function click_enterBtn
-------------------------------------
function UI_AdventureStageInfo:click_enterBtn()
    local func = function()
        local stage_id = self.m_stageID

        local function close_cb()
            self:sceneFadeInAction()
        end

        local ui

        if (DEVELOPMENT_SEONG_GOO_KIM == true) then
            ui = UI_ReadyScene(stage_id)
        else
            ui = UI_ReadySceneNew(nil, stage_id)
        end
        ui:setCloseCB(close_cb)
    end

    self:sceneFadeOutAndCallFunc(func)
end


--@CHECK
UI:checkCompileError(UI_AdventureStageInfo)
