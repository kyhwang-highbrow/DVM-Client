local PARENT = UI_GachaResult_Dragon100

-------------------------------------
-- class UI_GachaResult_StoryDungeonDragon10
-------------------------------------
UI_GachaResult_StoryDungeonDragon10 = class(PARENT, {
     })


UI_GachaResult_StoryDungeonDragon10.UPDATE_CARD_SUMMON_OFFSET = 0.2 -- 카드 줄마다 처음에 소환되는 간격
UI_GachaResult_StoryDungeonDragon10.UPDATE_CARD_OPEN_OFFSET = 0.05 -- 스킵할 때 다음 카드 뒤집는 간격
UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_PER_WIDTH = 10 -- 드래곤 카드가 가로줄 당 몇 개씩?
UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_SCALE = 1 -- 드래곤 카드 스케일 조정
UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_WIDTH_OFFSET = 72 -- 드래곤 카드 가로 오프셋
UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_HEIGHT_OFFSET = 72 -- 드래곤 카드 세로 오프셋

     
-------------------------------------
-- function initDragonCardList
-------------------------------------
function UI_GachaResult_StoryDungeonDragon10:initDragonCardList()
	local vars = self.vars

    self.m_tDragonCardTable = {}
	local total_card_count = table.count(self.m_lGachaDragonList)	-- 총 드래곤 카드 수
    local first_width_card_count = (total_card_count % UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_PER_WIDTH)
    if (first_width_card_count == 0) then
        first_width_card_count = UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_PER_WIDTH
    end
    local vertical_count = math_floor(total_card_count / UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_PER_WIDTH) -- 세로 줄 수
    if (total_card_count % UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_PER_WIDTH ~= 0) then
        vertical_count = vertical_count + 1
    end

	local horizontal_card_interval = UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_WIDTH_OFFSET	-- 드래곤 카드 가로 오프셋
	local vertical_card_interval = UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_HEIGHT_OFFSET	-- 드래곤 카드 세로 오프셋

    local l_horizontal_pos_list = getSortPosList(horizontal_card_interval, UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_PER_WIDTH)
    local l_first_horizontal_pos_list = getSortPosList(horizontal_card_interval, first_width_card_count)


    local l_vertical_pos_list = getSortPosList(vertical_card_interval, vertical_count)
    
	for idx, t_dragon_data in ipairs(self.m_lGachaDragonList) do
		-- 드래곤 카드 생성
        local struct_dragon_object = StructDragonObject(t_dragon_data) -- raw data를 StructDragonObject 형태로 변경
        local doid = t_dragon_data['id']
		
        local card = UI_DragonCard_Gacha(struct_dragon_object)
        card.root:setScale(UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_SCALE)

        card.vars['skipBtn']:registerScriptTapHandler(function() 
            if (not self.m_bIsSkipping) then
                card:click_skipBtn()
            end
        end)
 
        card.vars['skipBtn']:registerScriptPressHandler(function() 
            if (not self.m_bIsSkipping) then
                card:click_skipBtn()
            end
        end)

        -- 프레스 함수 세팅
        local press_card_cb = function()
            if self.m_bIsSkipping then return end
            local ui = UI_SimpleDragonInfoPopup(struct_dragon_object)

            local is_lock_visible
            if g_hatcheryData.m_isAutomaticFarewell then
                is_lock_visible = (struct_dragon_object['grade'] > 3)
            else
                is_lock_visible = (struct_dragon_object['grade'] > 2)
            end

            if is_lock_visible then
                card.m_dragonCard:setLockSpriteVisible(struct_dragon_object:getLock())
            end

            ui:setLockPossible(is_lock_visible, false)
            ui:setCloseCB(function()
                if is_lock_visible then
                    local refreshed_data = g_dragonsData:getDragonDataFromUid(doid)
                    local is_lock = refreshed_data:getLock()
                    card.m_dragonCard:setLockSpriteVisible(is_lock)
                end
            end)
        end
        card.m_dragonCard.vars['clickBtn']:registerScriptPressHandler(press_card_cb)
        
        vars['dragonMenu']:addChild(card.root)

		self.m_tDragonCardTable[doid] = card

        -- 카드 위치 정렬
        local x_idx = (idx <= first_width_card_count) and idx or (idx - first_width_card_count)
        x_idx = x_idx % UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_PER_WIDTH

        local y_idx = 1 
        
        --[[ math_floor(idx / UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_PER_WIDTH)
        if (idx <= first_width_card_count) then
            y_idx = 0
        else
            y_idx = math_floor((idx - first_width_card_count) / UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_PER_WIDTH) + 1
        end

        if (x_idx == 0) then
            x_idx = UI_GachaResult_StoryDungeonDragon10.DRAGON_CARD_PER_WIDTH
        else
            y_idx = y_idx + 1
        end

        cclog('y_idx', y_idx, #l_vertical_pos_list)
 ]]
        local pos_x = l_first_horizontal_pos_list[x_idx]
        local pos_y = l_vertical_pos_list[y_idx]

        card.root:setPositionX(pos_x)
        card.root:setPositionY(-pos_y)

        local function open_condition_func()
            return self.m_bCanOpenCard
        end

        -- 카드를 뒤집기 시작할 때 호출되는 콜백함수
        local function open_start_cb()
            local str_rarity = struct_dragon_object:getRarity()
            
            -- 5성은 카드가 1초간 가운데로 확대대며 이동
            if (str_rarity == 'legend') or (str_rarity == 'myth') then
                 self.m_bCanOpenCard = false

                -- 움직이는게 잘 보이도록 해당 카드의 z order 맨 위로
                card.root:setLocalZOrder(200)

                local move_action = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(0, -40)), 1.7)
                local scale_action = cc.EaseElasticOut:create(cc.ScaleTo:create(1, 1), 1.7)
                local spawn = cc.Spawn:create(move_action, scale_action)
                card.root:runAction(spawn)

                -- 연출 전 미리 애니메이터 스파인 캐시에 저장 (렉 제거)
                local did = t_dragon_data['did']
                local t_dragon = TableDragon():get(did)
                local res_name = t_dragon['res']
                local evolution = 3
                local attr = t_dragon['attr']
                local animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
                animator:release()            
            else
                SoundMgr:playEffect('UI', 'ui_card_flip')
            end
        end

        -- 카드를 뒤집고 난 이후 호출되는 콜백함수
        local function open_finish_cb()
            local str_rarity = struct_dragon_object:getRarity()
            -- 3성은 어둡게
            -- if (str_rarity == 'rare') then
            --     card.m_dragonCard:setShadowSpriteVisible(true)
            
            -- 5성 추가 연출
            if (str_rarity == 'legend')  or (str_rarity == 'myth') then
                self:directingLegend(struct_dragon_object, pos_x, -pos_y)
            end

            self:refresh()

            -- 자동작별 시 노출할 경험치 UI 추가
            if (self.m_type == 'cash') or (self.m_type == 'pickup') or (self.m_type == 'summon_dragon_ticket')then
            
                if g_hatcheryData.m_isAutomaticFarewell and (struct_dragon_object['grade'] <= 3) then
                    local dragon_exp_table = TableDragonExp()
                    local exp = dragon_exp_table:getDragonGivingExp(3, 1)	
                    local exp_card = UI_ItemCard(700017, exp)
                    local tint_action = cca.repeatFadeInOutRuneOpt(3.2)
                    -- 덤프를 찍어보니 exp_card 에 icon metadata가 
                    -- object로 저장된것이 아닌 주소로 저장되어 있어서
                    -- label은 fade가 먹는 대신 아이콘은 안되는것으로 추정됨
                    -- 더이상 시간 뺏기지 말고 일단은 되게끔 만듦
                    exp_card.vars['icon']:removeFromParent()
                    exp_card.vars['clickBtn'].m_node:addChild(exp_card.vars['icon'], 0)
                    exp_card.vars['numberLabel']:setLocalZOrder(1)
                    card.root:addChild(exp_card.root)
                    exp_card:setEnabledClickBtn(false)
                    exp_card.root:runAction(tint_action)
                end
            end
        end
        
        local function click_cb()
            self:setDragonInfo(struct_dragon_object, pos_x, -pos_y)
        end

        card:setOpenStartCB(open_start_cb)
        card:setOpenFinishCB(open_finish_cb)
        card:setOpenConditionFunc(open_condition_func)
        card:setClickCB(click_cb)

        -- 등장할 때 미끄러지면서 생성되기
        card.root:setOpacity(0)
        local x, y = card.root:getPosition()
        local move_distance = 20
        local duration = 0.2
        local move = cc.MoveTo:create(duration, cc.p(x, y))
        local fade_in = cc.FadeIn:create(duration)
        local move_action = cc.EaseInOut:create(cc.Spawn:create(fade_in, move), 1.3)

        local function card_set_sound_play()
            SoundMgr:playEffect('UI', 'ui_card_set')
        end

        local sequence = cc.Sequence:create(cc.DelayTime:create(UI_GachaResult_StoryDungeonDragon10.UPDATE_CARD_SUMMON_OFFSET * (y_idx - 1)), cc.CallFunc:create(card_set_sound_play), move_action)

        card.root:setPositionY(y + move_distance)
        card.root:runAction(sequence)
	end

    local function skip_btn_visible_true()
        vars['skipBtn']:setVisible(true)
        self.m_bCanOpenCard = true
    end
    
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(UI_GachaResult_StoryDungeonDragon10.UPDATE_CARD_SUMMON_OFFSET * (vertical_count - 1) + 0.2), cc.CallFunc:create(skip_btn_visible_true)))
end

