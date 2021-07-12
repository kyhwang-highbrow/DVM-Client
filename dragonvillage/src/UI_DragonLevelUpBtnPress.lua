-- button에서 registerScriptPressHandler함수로 콜백 함수 등록
-- n초 이상 터치를 유지하면 최초 1회 호출됨
-- 이때 스케쥴러(update)함수를 등록해서 매 프레임 호출

-- 종료 타입
-- UP
-- 최대 레벨
-- 골드가 부족
-- 드래곤 경험치가 부족

-------------------------------------
-- class UI_DragonLevelUpBtnPress
-------------------------------------
UI_DragonLevelUpBtnPress = class({
        m_dragonLevelUpUI = 'UI_DragonManagementFriendship',
        m_updateNode = 'cc.Node',
        m_levelUpBtn = 'UIC_BUtton',

        m_blockUI = 'UI_BlockPopup',

        m_timer = 'number',

        ----------
        m_grade = 'number',
        m_beforeLv = 'number',
        m_beforeGold = 'number',
        m_beforeDragonExp = 'number',
        m_beforeDragonInitialExp = 'number',

        m_afterLv = 'number',
        m_afterGold = 'number',
        m_afterDragonExp = 'number',


        m_lInterval = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLevelUpBtnPress:init(dragon_levelup_ui)
    self.m_dragonLevelUpUI = dragon_levelup_ui

    -- update함수를 위한 노드 추가
    self.m_updateNode = cc.Node:create()
    dragon_levelup_ui.root:addChild(self.m_updateNode)

    self:resetDragonLevelUpBtnPress()
end

-------------------------------------
-- function resetDragonLevelUpBtnPress
-------------------------------------
function UI_DragonLevelUpBtnPress:resetDragonLevelUpBtnPress()
    self.m_levelUpBtn = nil
    self.m_timer = 0

    self.m_updateNode:unscheduleUpdate()
    
    if (self.m_blockUI) then
        self.m_blockUI:close()
    end
end


-------------------------------------
-- function dragonLevelUpBtnPressHandler
-- @brief 드래곤 레벨업 버튼이 press입력을 받기 시작할 때 호출
-------------------------------------
function UI_DragonLevelUpBtnPress:dragonLevelUpBtnPressHandler(btn)
    self:log('PRESS START!!!!!!!')

    if (self.m_levelUpBtn) then
        return
    end

    local dragon_levelup_ui = self.m_dragonLevelUpUI

    do -- 현재 레벨업 가능한 드래곤인지 검증    
        local doid = dragon_levelup_ui.m_selectDragonOID
        local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)
        if (not possible) then
            UIManager:toastNotificationRed(msg)
            return
        end
    end

    do -- 레벨업 시작값 지정
        local t_dragon_data = dragon_levelup_ui.m_selectDragonData
        self.m_grade = t_dragon_data['grade']
        self.m_beforeLv = t_dragon_data['lv']
        self.m_beforeGold = g_userData:get('gold')
        self.m_beforeDragonExp = g_userData:get('dragon_exp')
        self.m_beforeDragonInitialExp = t_dragon_data['exp']

        self.m_afterLv = self.m_beforeLv
        self.m_afterGold = self.m_beforeGold
        self.m_afterDragonExp = self.m_beforeDragonExp
    end

    self.m_blockUI = UI_BlockPopup() -- 이 UI가 살아있는 동안에는 backkey를 막아준다.
    self.m_levelUpBtn = btn
    self.m_updateNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UI_DragonLevelUpBtnPress:update(dt)
    if (not self.m_levelUpBtn:isSelected()) then
        self:finishPressDragonLevelUpBtn('press_up')
        return
    end

    self.m_timer = (self.m_timer - dt)
    if (self.m_timer <= 0) then

        -- 드래곤 정보
        local dragon_levelup_ui = self.m_dragonLevelUpUI
        local t_dragon_data = dragon_levelup_ui.m_selectDragonData
        local grade = t_dragon_data['grade']
        local lv = self.m_afterLv

        -- 드래곤 최대 레벨(해당 등급의 최대 레벨)
        local max_lv = TableGradeInfo:getMaxLv(grade)
        if (max_lv <= lv) then
            self:finishPressDragonLevelUpBtn('max_lv') -- 드래곤 최대 레벨
            return
        end

        -- 필요 골드, 드래곤 경험치 계산
        local table_dragon_exp = TableDragonExp()
        local target_lv = lv + 1
        local is_myth_dragon = t_dragon_data:getRarity() == 'myth'
        local total_gold, total_dragon_exp = table_dragon_exp:getGoldAndDragonEXPForDragonLevelUp(grade, lv, target_lv, is_myth_dragon)

        -- 골드가 충분히 있는지 확인
        local need_gold = total_gold
        if (self.m_afterGold < need_gold) then
            self:finishPressDragonLevelUpBtn('lack_of_gold') -- 골드가 부족
            return
        end

        -- 경험치가 충분히 있는지 확인
        local exp = 0
        if (self.m_beforeLv == self.m_afterLv) then -- 처음 레벨은 경험치가 0이 아닐 수 있다. 중간레 드래곤 레벨업 시스템을 개편하면서 생긴 이슈.
            exp = self.m_beforeDragonInitialExp
        end
        local need_dragon_exp = (total_dragon_exp - exp)
        local dragon_exp = self.m_afterDragonExp
	    if (dragon_exp < need_dragon_exp) then
		    self:finishPressDragonLevelUpBtn('lack_of_dragon_exp') -- 드래곤 경험치가 부족
		    return
	    end


        do -- 레벨업
            self.m_afterLv = (self.m_afterLv + 1)
            self.m_afterGold = (self.m_afterGold - need_gold)
            self.m_afterDragonExp = (self.m_afterDragonExp - need_dragon_exp)

            -- 이펙트 재생
			dragon_levelup_ui:playLevelUpEffect(self.m_afterLv) -- params : dragon_level

            -- UI_DragonLevelUpNew 갱신
            dragon_levelup_ui:refresh_dragonStat(self.m_afterLv) -- params : dragon_level
            dragon_levelup_ui:refresh_levelUpBtnState(self.m_afterLv, 0, self.m_afterDragonExp) -- params : curr_lv, curr_exp, dragon_exp
            g_topUserInfo:setGoodsNumber('gold', self.m_afterGold) -- params : goods_type, num
            
        end
        self:log('lv:' .. self.m_afterLv .. ', gold:' .. self.m_afterGold .. ', dragon_exp: ' .. self.m_afterDragonExp)
        
        self.m_timer = (self.m_timer + 0.15)
    end
end

-------------------------------------
-- function finishPressDragonLevelUpBtn
-- @msg string 'press_up', 'max_lv', 'lack_of_gold', 'lack_of_dragon_exp'
-------------------------------------
function UI_DragonLevelUpBtnPress:finishPressDragonLevelUpBtn(msg)
    self:log('DONE!!!!!!! ' .. msg)

    local function finish_cb()
        if (msg == 'lack_of_gold') then
            ConfirmPrice('gold', g_userData:get('gold') + 1) -- 골드가 부족한 상태로 호출(깜짝 할인 상품 or 상점 이동 유도)

        elseif (msg == 'lack_of_dragon_exp') then
            UIManager:toastNotificationRed(Str('드래곤 경험치가 부족합니다'))

        elseif (msg == 'max_lv') then
            UIManager:toastNotificationGreen(Str('{1}등급 최대레벨 {2}에 달성하였습니다.', self.m_grade, self.m_afterLv))
        end
    end

    -- 서버와 통신
    if (self.m_beforeLv < self.m_afterLv) then
        local dragon_levelup_ui = self.m_dragonLevelUpUI
        local target_lv = self.m_afterLv
        local need_gold = (self.m_beforeGold - self.m_afterGold)
        local need_dragon_exp = (self.m_beforeDragonExp - self.m_afterDragonExp)
        dragon_levelup_ui:request_levelUp(target_lv, need_gold, need_dragon_exp, finish_cb)
    else
        finish_cb()
    end

    -- 초기화
    self:resetDragonLevelUpBtnPress()
end

-------------------------------------
-- function log
-------------------------------------
function UI_DragonLevelUpBtnPress:log(msg)
    local active = false
    if (not active) then
        return
    end

    cclog('##UI_DragonLevelUpBtnPress log## : ' .. tostring(msg))
end