local PARENT = UI

-------------------------------------
-- class UI_ExplorationResultPopup
-------------------------------------
UI_ExplorationResultPopup = class(PARENT,{
        m_eprID = '',
        m_data = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationResultPopup:init(epr_id, data)
    self.m_eprID = epr_id
    self.m_data = data

    local vars = self:load('exploration_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ExplorationResultPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExplorationResultPopup:initUI()
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    -- 지역 이름
    vars['locationLabel']:setString(Str(location_info['t_name']))

    -- 소요 시간
    local sec = location_info['clear_time']
    local time_str = ServerTime:getInstance():makeTimeDescToSec(sec, true)
    vars['timeLabel']:setString(Str('탐험 소요 : {1}', time_str))

    do
        -- 획득하는 아이템 리스트
        local l_item_list = self.m_data['added_items']['items_list']
        vars['rewardNode']:removeAllChildren()

        local scale = 0.53
        local l_pos = getSortPosList(150 * scale + 3, #l_item_list)

        for i,v in ipairs(l_item_list) do

            local t_sub_data = nil
            if v['oids'] then
                -- Object는 하나만 리턴한다고 가정 (dragon or rune)
                local oid = v['oids'][1]
                if oid then
                    -- 드래곤에서 정보 검색
                    for _,obj_data in ipairs(self.m_data['added_items']['dragons']) do
                        if (obj_data['id'] == oid) then
                            t_sub_data = StructDragonObject(obj_data)
                            break
                        end
                    end

                    -- 룬에서 정보 검색
                    if (not t_sub_data) then
                        for _,obj_data in ipairs(self.m_data['added_items']['runes']) do
                            if (obj_data['id'] == oid) then
                                t_sub_data = StructRuneObject(obj_data)
                                break
                            end
                        end
                    end
                end
            end

            local ui = UI_ItemCard(v['item_id'], v['count'], t_sub_data)
            vars['rewardNode']:addChild(ui.root)
            ui.root:setScale(0)
            ui.root:setPosition(l_pos[i], 0)
            ui.root:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.ScaleTo:create(0.25, scale)))
        end
    end

    do -- 드래곤 실리소스
        local l_dragon_list = self.m_data['modified_dragons']
        local l_before_dragon_list = self.m_data['before_dragons']

        for i=1, 5 do
            vars['dragonBoard' .. i]:setVisible(false)
        end

        local interval = 160
        local count = table.count(l_dragon_list)
        local l_pos_list = getSortPosList(interval, count)

        for i,v in ipairs(l_dragon_list) do
            vars['dragonBoard' .. i]:setVisible(true)
            vars['dragonBoard' .. i]:setPositionX(l_pos_list[i])

            local user_data = v
            local table_data = TableDragon():get(v['did'])
            local res_name = table_data['res']
            local evolution = user_data['evolution']
            local grade = user_data['grade']
		    local attr = table_data['attr']

            local animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
            animator.m_node:setDockPoint(cc.p(0.5, 0.5))
            animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
            --animator.m_node:setScale(0.5)
            vars['dragonNode' .. i]:addChild(animator.m_node)

            local lv_label      = vars['lvLabel' .. i]
            local exp_label     = vars['expLabel' .. i]
            local max_icon      = vars['maxSprite' .. i]
            local exp_gauge     = vars['expGauge' .. i]
            local level_up_vrp  = vars['lvUpVisual' .. i]
            local levelup_director = LevelupDirector_GameResult(lv_label, exp_label, max_icon, exp_gauge, level_up_vrp, grade)

            -- 최초 레벨업 시 포즈
            levelup_director.m_cbFirstLevelup = function()
                animator:changeAni('pose_1', false)
                animator:addAniHandler(function() animator:changeAni('idle', true) end)
            end

            local t_levelup_data = v['levelup_data']
            local src_lv        = l_before_dragon_list[i]['lv']
            local src_exp       = l_before_dragon_list[i]['exp']
            local dest_lv       = user_data['lv']
            local dest_exp      = user_data['exp']
            local type          = 'dragon'
			local rlv			= user_data['reinforce']['lv']
            local mlv           = user_data['mastery_lv']
            levelup_director:initLevelupDirector(src_lv, src_exp, dest_lv, dest_exp, type, grade, rlv, mlv)
            levelup_director:start()
            --self:addLevelUpDirector(levelup_director)

            do -- 등급
                local sprite = IconHelper:getDragonGradeIcon(user_data, 1)
                vars['starNode' .. i]:removeAllChildren()
                vars['starNode' .. i]:addChild(sprite)
            end
        end
    end

    -- 모험의 order가 모험모드의 chapter로 간주한다
    local chapter = location_info['order']

    do -- 배경 이미지 생성
        local bg_node = vars['bgNode']
        ResHelper:makeUIAdventureChapterBG(bg_node, chapter)
    end

    -- 모험의 order가 모험모드의 chapter로 간주한다
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)
    local chapter = location_info['order']

    local res = string.format('res/ui/icons/adventure_map/chapter_01%.2d.png', chapter)
    local icon = cc.Sprite:create(res)
    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))
    vars['stageNode']:addChild(icon)


    -- 대성공
    if self.m_data['great'] then
        vars['successVisual']:setVisible(true)
        local function ani_handler()
            vars['successVisual']:setVisible(false)
        end
        vars['successVisual']:addAniHandler(ani_handler)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationResultPopup:initButton()
    local vars = self.vars
    vars['quickBtn']:registerScriptTapHandler(function() self:click_quickBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationResultPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_quickBtn
-- @brief 바로 재시작 버튼
-------------------------------------
function UI_ExplorationResultPopup:click_quickBtn()
    local modified_dragons = self.m_data['modified_dragons']
    local selected_dragon_list = {}
    for i,v in pairs(modified_dragons) do
        local doid = v['id']
        table.insert(selected_dragon_list, doid)
    end

    -- 인원 체크
    if (table.count(modified_dragons) < 5) then
        UIManager:toastNotificationRed(Str('탐험에는 5마리의 드래곤이 필요합니다.'))
        return
    end

    local check_dragon_inven
    local check_item_inven
    local start_game

    -- 드래곤 가방 확인(최대 갯수 초과 시 획득 못함)
    check_dragon_inven = function()
        local function manage_func()
            UINavigator:goTo('dragon')
        end
        g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
    end

    -- 아이템 가방 확인(최대 갯수 초과 시 획득 못함)
    check_item_inven = function()
        local function manage_func()
            -- UI_Inventory() @kwkang 룬 업데이트로 룬 관리쪽으로 이동하게 변경 
            UI_RuneForge('manage')
        end
        g_inventoryData:checkMaximumItems(start_game, manage_func)
    end

    
    start_game = function()
        local function request()
            local function finish_cb(ret)
                UIManager:toastNotificationGreen(Str('드래곤 5마리가 탐험을 떠났습니다.'))
                self:close()

                -- 덱 저장
                local l_doid = g_settingData:setExplorationDec(self.m_eprID, selected_dragon_list)
            end

            -- params
            local epr_id = self.m_eprID
            local doids = listToCsv(selected_dragon_list)

            g_explorationData:request_explorationStart(epr_id, doids, finish_cb)
        end

        
        --MakeSimplePopup(POPUP_TYPE.YES_NO, Str('드래곤 5마리를 탐험을 보내시겠습니까?'), request)
        request() -- 2018-01-11 sgkim 확인 팝업이 불필요한 뎁스라고 느껴져서 제거
    end

    check_dragon_inven()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ExplorationResultPopup:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ExplorationResultPopup)
