local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_GachaResult_Dragon100
-------------------------------------
UI_GachaResult_Dragon100 = class(PARENT, {
		m_type = 'string', -- 획득한 경로

        m_lGachaDragonList = 'list', -- 드래곤 데이터
		m_tDragonCardTable = 'table', -- 드래곤 카드 UI

		-- 연출 관련
        m_hideUIList = '',
        m_tUIOriginPos = 'table', -- 액션시킬 UI들의 원래 위치 저장
        m_tUIIsMoved = 'table', -- UI들이 움직였는가 체크
        m_titleEffector = 'animator',
        m_selectRuneCard = 'UI_RuneCard',
        m_selectRuneEffector = 'animator',
        m_tUIOriginPos = 'table', -- 이동이 되어야하는 UI들의 원래 위치 기억
        m_rarityEffect = 'Animator', -- 상단 텍스트 이펙트

        -- 상태 FSM 쓰려 했는데, 동시에 봐야하는 조건도 있어서 그냥 여러 개의 boolean 사용
        m_bCanOpenCard = 'boolean', -- 현재 카드 오픈 가능한지 
        m_bIsSkipping = 'boolean', -- 현재 스킵 액션이 진행중인지
        m_skipUpdateNode = 'cc.Node', -- 업데이트 노드
        m_cleanFunc = 'function', -- 드래곤 정보 창 끄기 위한 함수
        m_timer = 'number', -- 스킵 관련 타이머
        m_currDoid = 'string', -- 현재 드래곤 정보 창으로 보고 있는 드래곤 doid

        m_animatorTest = '',
     })

UI_GachaResult_Dragon100.UPDATE_CARD_SUMMON_OFFSET = 0.2 -- 카드 줄마다 처음에 소환되는 간격
UI_GachaResult_Dragon100.UPDATE_CARD_OPEN_OFFSET = 0.05 -- 스킵할 때 다음 카드 뒤집는 간격
UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH = 15 -- 드래곤 카드가 가로줄 당 몇 개씩?
UI_GachaResult_Dragon100.DRAGON_CARD_SCALE = 0.45 -- 드래곤 카드 스케일 조정
UI_GachaResult_Dragon100.DRAGON_CARD_WIDTH_OFFSET = 72 -- 드래곤 카드 가로 오프셋
UI_GachaResult_Dragon100.DRAGON_CARD_HEIGHT_OFFSET = 72 -- 드래곤 카드 세로 오프셋


-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_GachaResult_Dragon100:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_bVisible = false -- onFocus 용도로만 쓰임
end

-------------------------------------
-- function init
-- @param type : 드래곤을 얻게된 방법
-------------------------------------
function UI_GachaResult_Dragon100:init(type, l_gacha_dragon_list)
	self.m_type = type

    require('UI_DragonCard_Gacha')

    self.m_uiName = 'UI_GachaResult_Dragon100'
    local vars = self:load('dragon_summon_100_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- @UI_ACTION
    self:doActionReset()
    --self:doAction(nil, false)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_GachaResult_Dragon100')

    for index, data in pairs(l_gacha_dragon_list) do
        data['id'] = index
    end

	-- 멤버 변수
    self.m_lGachaDragonList = l_gacha_dragon_list
    self.m_tDragonCardTable = {}

    self.m_hideUIList = {}
    self.m_tUIOriginPos = {}
    self.m_tUIIsMoved = {}
    
    self.m_bIsSkipping = false
    self.m_bCanOpenCard = false
    self.m_currDoid = nil

	self:initUI()  
	self:initButton()
    self:refresh()

    SoundMgr:stopBGM()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GachaResult_Dragon100:initUI()
	local vars = self.vars
    
    self:initDragonCardList()

    Translate:a2dTranslate('ui/a2d/summon/summon_cut.plist')
	local res_name = 'res/ui/a2d/summon/summon.vrp'
    self.m_rarityEffect = MakeAnimator(res_name)
    self.m_rarityEffect:setIgnoreLowEndMode(true) -- 저사양 모드 무시
    vars['rarityNode']:addChild(self.m_rarityEffect.m_node)

    local visibleSize = cc.Director:getInstance():getVisibleSize()

    self.m_tUIOriginPos['nameSprite'] = {}
    self.m_tUIOriginPos['nameSprite']['x'], self.m_tUIOriginPos['nameSprite']['y'] = vars['nameSprite']:getPosition()
    vars['nameSprite']:setPositionY(self.m_tUIOriginPos['nameSprite']['x'] - visibleSize['height'])
    
    vars['skipBtn']:setVisible(false)

    self:refresh_inventoryLabel()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GachaResult_Dragon100:initButton()
	local vars = self.vars

	vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['skipBtn']:registerScriptTapHandler(function() self:click_skipBtn() end)
    vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GachaResult_Dragon100:refresh()
    local vars = self.vars

    local b_is_all_card_open = self:isAllCardOpen()

    if (b_is_all_card_open) then
        -- 마지막에만 보여야 하는 UI들을 관리
        for i,v in pairs(self.m_hideUIList) do
            v:setVisible(true)
        end

        self:doActionReset()
        self:doAction(nil, false)

        vars['skipBtn']:setVisible(false)
        SoundMgr:playEffect('UI', 'ui_grow_result')
    end 
end

-------------------------------------
-- function isAllCardOpen
-------------------------------------
function UI_GachaResult_Dragon100:isAllCardOpen()
    for doid, dragon_card_gacha in pairs(self.m_tDragonCardTable) do
        if (not dragon_card_gacha:isOpen())  then
            return false
        end
    end

    return true
end

-------------------------------------
-- function initDragonCardList
-------------------------------------
function UI_GachaResult_Dragon100:initDragonCardList()
	local vars = self.vars

    self.m_tDragonCardTable = {}
	local total_card_count = table.count(self.m_lGachaDragonList)	-- 총 드래곤 카드 수
    local first_width_card_count = (total_card_count % UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH)
    if (first_width_card_count == 0) then
        first_width_card_count = UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH
    end
    local vertical_count = math_floor(total_card_count / UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH) -- 세로 줄 수
    if (total_card_count % UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH ~= 0) then
        vertical_count = vertical_count + 1
    end

	local horizontal_card_interval = UI_GachaResult_Dragon100.DRAGON_CARD_WIDTH_OFFSET	-- 드래곤 카드 가로 오프셋
	local vertical_card_interval = UI_GachaResult_Dragon100.DRAGON_CARD_HEIGHT_OFFSET	-- 드래곤 카드 세로 오프셋

    local l_horizontal_pos_list = getSortPosList(horizontal_card_interval, UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH)
    local l_first_horizontal_pos_list = getSortPosList(horizontal_card_interval, first_width_card_count)
    local l_vertical_pos_list = getSortPosList(vertical_card_interval, vertical_count)
    
	for idx, t_dragon_data in ipairs(self.m_lGachaDragonList) do
		-- 드래곤 카드 생성
        local struct_dragon_object = StructDragonObject(t_dragon_data) -- raw data를 StructDragonObject 형태로 변경
        --struct_dragon_object['id'] = idx
        local doid = struct_dragon_object['id']
		
        local card = UI_DragonCard_Gacha(struct_dragon_object)
        
        card.root:setScale(UI_GachaResult_Dragon100.DRAGON_CARD_SCALE)
        
        -- 프레스 함수 세팅
        local press_card_cb = function()
            local t_dragon_data_refresh = g_dragonsData:getDragonDataFromUid(doid)
            local ui = UI_SimpleDragonInfoPopup(t_dragon_data_refresh)
            ui:setLockPossible(true, false)
            ui:setCloseCB(function()
                local t_dragon_data_refresh = g_dragonsData:getDragonDataFromUid(doid)
                local is_lock = t_dragon_data_refresh:getLock()
	            card.m_dragonCard:setLockSpriteVisible(is_lock)
            end)
        end
        card.m_dragonCard.vars['clickBtn']:registerScriptPressHandler(press_card_cb)
        
        vars['dragonMenu']:addChild(card.root)

		self.m_tDragonCardTable[doid] = card

        -- 카드 위치 정렬
        local x_idx = (idx <= first_width_card_count) and idx or (idx - first_width_card_count)
        x_idx = x_idx % UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH

        local y_idx = math_floor(idx / UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH)
        if (idx <= first_width_card_count) then
            y_idx = 0
        else
            y_idx = math_floor((idx - first_width_card_count) / UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH) + 1
        end

        if (x_idx == 0) then
            x_idx = UI_GachaResult_Dragon100.DRAGON_CARD_PER_WIDTH
        else
            y_idx = y_idx + 1
        end

        local pos_x = (y_idx > 1) and l_horizontal_pos_list[x_idx] or l_first_horizontal_pos_list[x_idx]
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

                -- 자동작별 시 노출할 경험치 UI 추가
            if (self.m_type == 'cash') or (self.m_type == 'pickup') then
                if g_hatcheryData.m_isAutomaticFarewell and (struct_dragon_object['grade'] <= 3) then
                    local dragon_exp_table = TableDragonExp()
                    local exp = dragon_exp_table:getDragonGivingExp(3, 1)	
                    local exp_card = UI_ItemCard(700017, exp)
                    local tint_action = cca.repeatFadeInOutRuneOpt(3.2)
                    card.root:addChild(exp_card.root)
                    exp_card:setEnabledClickBtn(false)
                    exp_card.root:runAction(tint_action)
                end
            end

            self:refresh()
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

        local sequence = cc.Sequence:create(cc.DelayTime:create(UI_GachaResult_Dragon100.UPDATE_CARD_SUMMON_OFFSET * (y_idx - 1)), cc.CallFunc:create(card_set_sound_play), move_action)

        card.root:setPositionY(y + move_distance)
        card.root:runAction(sequence)
	end

    local function skip_btn_visible_true()
        vars['skipBtn']:setVisible(true)
        self.m_bCanOpenCard = true
    end
    
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(UI_GachaResult_Dragon100.UPDATE_CARD_SUMMON_OFFSET * (vertical_count - 1) + 0.2), cc.CallFunc:create(skip_btn_visible_true)))
end

-------------------------------------
-- function test
-------------------------------------
function UI_GachaResult_Dragon100:test(struct_dragon_object, pos_x, pos_y)
    local animator = self.m_animatorTest
    local scale_finish_action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.5, 0), 1.7)
    local doid = struct_dragon_object.id
    local did = struct_dragon_object.did
    local rarity = TableDragon:getValue(did, 'rarity')


    
    local function card_relocate_finish_cb()
        self.m_bCanOpenCard = true

        -- 연출동안 오래 기다렸으니 바로 다음 카드 뒤집을 수 있도록 하자
        self.m_timer = 0
        self.m_animatorTest = nil
    end

    local function card_relocate_func()
        -- 0.7초간 원래 자리로 돌아가기
        local relocate_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.7, cc.p(pos_x, pos_y)), 1.7)
        local rescale_action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.7, UI_GachaResult_Dragon100.DRAGON_CARD_SCALE), 1.7)
        local spawn_action = cc.Spawn:create(relocate_action, rescale_action)
        local card_sequence = cc.Sequence:create(spawn_action, cc.CallFunc:create(card_relocate_finish_cb))
        
        local card = self.m_tDragonCardTable[doid]
        card.root:runAction(card_sequence)
    end

    local function dragon_animation_finish_cb()
        card_relocate_func()
        animator.m_node:removeFromParent()
    end

    local function sound_cb()
        -- 오픈 될 때 사운드 재생
        if (struct_dragon_object:isLimited()) or (rarity == 'myth') then
            SoundMgr:playEffect('BG', 'bgm_dungeon_victory')
        else
            SoundMgr:playEffect('UI', 'ui_star_up')
        end
    end
    
    local finish_action = cc.Sequence:create(cc.CallFunc:create(sound_cb), cc.DelayTime:create(1.7), scale_finish_action, 
    cc.CallFunc:create(function() self:closeDragonInfo() end),
    cc.CallFunc:create(dragon_animation_finish_cb))

--    cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(finish_action))
    animator.m_node:runAction(finish_action)
end

-------------------------------------
-- function directingLegend
-- @brief 5성 드래곤에 대한 연출, 드래곤 애니메이터 크게 화면에 띄우기
-------------------------------------
function UI_GachaResult_Dragon100:directingLegend(struct_dragon_object, pos_x, pos_y)
    local vars = self.vars
    
    local did = struct_dragon_object.did
    local t_dragon = TableDragon():get(did)
    local res_name = t_dragon['res']
    local evolution = 3
    local attr = t_dragon['attr']
    local grade = struct_dragon_object['grade']

    local rarity = TableDragon:getValue(did, 'rarity')

    local animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
    vars['dragonMenu']:addChild(animator.m_node)

    animator.m_node:setLocalZOrder(201)
    animator.m_node:setScale(0.2)
    animator.m_node:setPositionY(-40)
    local scale_start_action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.5, 1), 1.7)

    self.m_animatorTest = animator
    
    local function myth_cutscene()
        if (rarity == 'myth') then
            local dragon_name = TableDragon:getValue(did, 'type')
            local file_name = string.format('appear_%s', dragon_name)
            local myth_cutscene_res = string.format('res/dragon_appear/%s/%s.json', file_name, file_name)
            local myth_cutscene_animator = MakeAnimator(myth_cutscene_res)

            if self.vars['effectNode'] and myth_cutscene_animator then
                self.vars['effectNode']:addChild(myth_cutscene_animator.m_node)
                
                -- 번역
                --Translate:a2dTranslate(myth_cutscene_animator)

                -- 저사양 모드 무시
                myth_cutscene_animator:setIgnoreLowEndMode(true)

                myth_cutscene_animator.m_node:setGlobalZOrder(myth_cutscene_animator.m_node:getGlobalZOrder() + 2)

                -- 사운드 재생 
                local sound_file_name = string.format('appear_%s', dragon_name)
	             SoundMgr:playEffect('VOICE', sound_file_name)

                myth_cutscene_animator:changeAni('appear', false)
                myth_cutscene_animator:addAniHandler(function()
                    myth_cutscene_animator:changeAni('idle', false)
                end)
                myth_cutscene_animator:addAniHandler(function()
                    self:test(struct_dragon_object, pos_x, pos_y)
                end)
                
            end
        else
            self:test(struct_dragon_object, pos_x, pos_y)
        end
    end

    local function open_info_func()
        do -- 드래곤 별
            vars['starVisual']:setVisible(true)
            local ani_name = TableDragon:getStarAniName(did, 1)
            ani_name = ani_name .. grade
            vars['starVisual']:changeAni(ani_name)
        end

        do -- 드래곤 텍스트 이펙트
        vars['rarityNode']:setVisible(true)
        
            local ani_num = math_max((grade - 1), 1) -- 1 ~ 4
            local ani_appear = string.format('text_appear_%02d', ani_num)
            local ani_idle = string.format('text_idle_%02d', ani_num)
        
            self.m_rarityEffect:setVisible(true)
            self.m_rarityEffect:changeAni(ani_appear, false)
            self.m_rarityEffect:addAniHandler(function()
		        self.m_rarityEffect:changeAni(ani_idle, true)
	        end)
        end

        myth_cutscene()
        self:openDragonInfo()
    end

    local start_action = cc.Spawn:create(scale_start_action, cc.CallFunc:create(open_info_func))


    --local ani_sequence = cc.Sequence:create(start_action, cc.DelayTime:create(1), finish_action, cc.CallFunc:create(dragon_animation_finish_cb))


    animator.m_node:runAction(start_action)


    -- 이름
    local name = struct_dragon_object:getDragonNameWithEclv()
    vars['nameLabel']:setString(name)
end

-------------------------------------
-- function setDragonInfo
-- @brief 드래곤 애니메이션 가운데에 띄우고 드래곤 정보 보여주기
-------------------------------------
function UI_GachaResult_Dragon100:setDragonInfo(struct_dragon_object, pos_x, pos_y)
    -- 모든 카드가 오픈된 경우에만 진행 가능
    if (self:isAllCardOpen() == false) then
        return
    end

    if (self.m_cleanFunc) then
        self.m_cleanFunc()
        self.m_cleanFunc = nil

        if (self.m_currDoid == struct_dragon_object.id) then
            self.m_currDoid = nil
            self:closeDragonInfo()
            return
        else
            self.m_currDoid = struct_dragon_object.id
        end
    end

    local vars = self.vars

    self.m_currDoid = struct_dragon_object.id
    
    local did = struct_dragon_object.did
    local t_dragon = TableDragon():get(did)
    local res_name = t_dragon['res']
    local evolution = 3
    local attr = t_dragon['attr']
    local grade = struct_dragon_object['grade']

    local animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
    vars['dragonMenu']:addChild(animator.m_node)

    animator.m_node:setLocalZOrder(201)
    animator.m_node:setScale(0.2)
    animator.m_node:setPositionX(pos_x)
    animator.m_node:setPositionY(pos_y)

    local scale_start_action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.5, 1), 1.7)
    local move_start_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(0, -40)), 1.7)
    local start_spawn = cc.Spawn:create(scale_start_action, move_start_action)

    animator.m_node:runAction(start_spawn)

    local function clear_func()
        local scale_finish_action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.5, 0), 1.7)
        local move_finish_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(pos_x, pos_y)), 1.7)
        local finish_spawn = cc.Spawn:create(scale_finish_action, move_finish_action)
        local clean_sequence = cc.Sequence:create(finish_spawn, cc.RemoveSelf:create())
        animator.m_node:stopAllActions()
        animator.m_node:runAction(clean_sequence)
    end

    self.m_cleanFunc = clear_func

    -- 이름
    local name = struct_dragon_object:getDragonNameWithEclv()
    vars['nameLabel']:setString(name)

    do -- 드래곤 별
        vars['starVisual']:setVisible(true)
        local ani_name = TableDragon:getStarAniName(did, 1)
        ani_name = ani_name .. grade
        vars['starVisual']:changeAni(ani_name)
    end

    do -- 드래곤 텍스트 이펙트
        vars['rarityNode']:setVisible(true)
        
        local ani_num = math_max((grade - 1), 1) -- 1 ~ 4
        local ani_appear = string.format('text_appear_%02d', ani_num)
        local ani_idle = string.format('text_idle_%02d', ani_num)
        
        self.m_rarityEffect:setVisible(true)
        self.m_rarityEffect:changeAni(ani_appear, false)
        self.m_rarityEffect:addAniHandler(function()
		    self.m_rarityEffect:changeAni(ani_idle, true)
	    end)
    end

    self:openDragonInfo()
end

-------------------------------------
-- function openDragonInfo
-- @brief 드래곤 정보창을 화면 안으로 끌고 옴
-------------------------------------
function UI_GachaResult_Dragon100:openDragonInfo()
    local vars = self.vars
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local duration = 0.3

    -- 드래곤 이름창
    -- 아래 창에서 위로 나와야함
    local x, y = self.m_tUIOriginPos['nameSprite']['x'], self.m_tUIOriginPos['nameSprite']['y']
    local moveToTop = cc.MoveTo:create(duration, cc.p(x, y))
    vars['nameSprite']:stopAllActions()
    vars['nameSprite']:runAction(moveToTop)
end

-------------------------------------
-- function click_inventoryBtn
-- @brief 인벤 확장
-------------------------------------
function UI_GachaResult_Dragon100:click_inventoryBtn()
    local item_type = 'dragon'
    local function finish_cb()
        self:refresh_inventoryLabel()
    end

    g_inventoryData:extendInventory(item_type, finish_cb)
end

-------------------------------------
-- function refresh_inventoryLabel
-- @brief
-------------------------------------
function UI_GachaResult_Dragon100:refresh_inventoryLabel()
    local vars = self.vars
    local inven_type = 'dragon'
    local dragon_count = g_dragonsData:getDragonsCnt()
    local max_count = g_inventoryData:getMaxCount(inven_type)
    self.vars['inventoryLabel']:setString(string.format('%d/%d', dragon_count, max_count))
end

-------------------------------------
-- function closeDragonInfo
-- @brief 드래곤 정보창을 화면 밖으로 내보냄
-------------------------------------
function UI_GachaResult_Dragon100:closeDragonInfo()
    local vars = self.vars
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local duration = 0.3

    vars['starVisual']:setVisible(false)
    vars['rarityNode']:setVisible(false)

    -- 드래곤 이름창
    -- 아래 창으로 나가야함
    local x, y = self.m_tUIOriginPos['nameSprite']['x'], self.m_tUIOriginPos['nameSprite']['y'] - visibleSize['height']
    local moveToDown = cc.MoveTo:create(duration, cc.p(x, y))
    vars['nameSprite']:stopAllActions()
    vars['nameSprite']:runAction(moveToDown)
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UI_GachaResult_Dragon100:click_skipBtn()
    if (self.m_bIsSkipping == true) then
        return
    end
    
    if (self.vars['skipBtn']:isVisible() == false) then
        return
    end

    self.vars['skipBtn']:setVisible(false)

    self.m_bIsSkipping = true
    self.m_timer = UI_GachaResult_Dragon100.UPDATE_CARD_OPEN_OFFSET

    self.m_skipUpdateNode = cc.Node:create()
    self.root:addChild(self.m_skipUpdateNode)
    
    self.m_skipUpdateNode:scheduleUpdateWithPriorityLua(function(dt) return self:update_skip(dt) end, 0)
end

-------------------------------------
-- function update_skip
-------------------------------------
function UI_GachaResult_Dragon100:update_skip(dt)
    -- 연출 중에는 타이머 X
    if (self.m_bCanOpenCard == false) then
        return
    end
    
    self.m_timer = self.m_timer - dt
    
    if (self.m_timer <= 0) then
        for idx, t_dragon_data in ipairs(self.m_lGachaDragonList) do
            local doid = t_dragon_data['id']
            local dragon_card = self.m_tDragonCardTable[doid]

            if (dragon_card:isClose()) then
                dragon_card:openCard(true)

                local rarity = dragon_card.m_tDragonData:getRarity()

                if (rarity == 'legend') or (rarity == 'myth')  then
                    self.m_bCanOpenCard = false
                    
                    -- 연출 전 미리 애니메이터 스파인 캐시에 저장 (렉 제거)
                    local did = dragon_card.m_tDragonData['did']
                    local t_dragon = TableDragon():get(did)
                    local res_name = t_dragon['res']
                    local evolution = 3
                    local attr = t_dragon['attr']
                    local animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
                    animator:release()

                else
                    SoundMgr:playEffect('UI', 'ui_card_flip')
                end

                self.m_timer = self.m_timer + UI_GachaResult_Dragon100.UPDATE_CARD_OPEN_OFFSET
                return
            end
        end

        -- 모든 카드를 오픈한 이후
        if (self:isAllCardOpen()) then
            self.m_bIsSkipping = false
            self:refresh()
            self.m_skipUpdateNode:unscheduleUpdate()
        end
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_GachaResult_Dragon100:click_closeBtn()
    if(self:isAllCardOpen()) then
        SoundMgr:playPrevBGM()
        self:close()
    else
        self:click_skipBtn()
    end
end

-------------------------------------
-- function onFocus
-- @brief 탑바가 포커싱 되었을 때
-------------------------------------
function UI_GachaResult_Dragon100:onFocus()
end
