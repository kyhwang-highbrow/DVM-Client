local PARENT = UI

-------------------------------------
-- class UI_DragonGachaResult
-------------------------------------
UI_DragonGachaResult = class(PARENT, ITopUserInfo_EventListener:getCloneTable(),{
        m_cb = 'function',

        m_lNumberLabel = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGachaResult:init(dragon_id, cb)
    self.m_cb = cb

    local vars = self:load('gacha_result.ui')
    UIManager:open(self, UIManager.POPUP)

    SoundMgr:playEffect('EFFECT', 'get_gacha')

    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['cardVisual']:setLocalZOrder(1)

    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    local dragon_card = DragonCard(t_dragon, t_dragon_data)
    vars['cardNode']:addChild(dragon_card.m_uiRoot)
    vars['cardNode']:setVisible(false)

    do -- 최초 label 수치 지정
        self.m_lNumberLabel = {}
        self.m_lNumberLabel['lukLabel'] = NumberLabel(vars['lukLabel'], 0, 1)
        self.m_lNumberLabel['dexLabel'] = NumberLabel(vars['dexLabel'], 0, 1)
        self.m_lNumberLabel['agiLabel'] = NumberLabel(vars['agiLabel'], 0, 1)
        self.m_lNumberLabel['vitLabel'] = NumberLabel(vars['vitLabel'], 0, 1)
        self.m_lNumberLabel['intLabel'] = NumberLabel(vars['intLabel'], 0, 1)
        self.m_lNumberLabel['strLabel'] = NumberLabel(vars['strLabel'], 0, 1)

        vars['cardGg']:setPercentage(0)
        vars['cardLabel']:setString('')
    end
    vars['cardVisual']:setRepeat(false)
    vars['cardVisual']:setVisual('group', 'card')
    vars['cardVisual']:registerScriptLoopHandler(function()
        self:startAction(t_dragon, t_dragon_data)
        vars['cardVisual']:setVisual('group', 'card_star_light_' .. t_dragon_data['grade'])
        vars['cardVisual']:registerScriptLoopHandler(function()
            vars['cardVisual']:setVisible(false)
        end)
    end)

    -- 에니메이션 시간이 맞지 않아서 강제로 처리
    local duration = vars['cardVisual']:getDuration()
    vars['cardVisual']:runAction(cc.Sequence:create(cc.DelayTime:create(duration - 0.3), cc.CallFunc:create(function()
            vars['cardNode']:setVisible(true)
        end)))
    
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_DragonGachaResult')
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_DragonGachaResult:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonGachaResult'
    self.m_bUseExitBtn = false
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonGachaResult:click_exitBtn()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    self:close()
    if self.m_cb then
        self.m_cb()
    end
end

-------------------------------------
-- function startAction
-- @brief
-------------------------------------
function UI_DragonGachaResult:startAction(t_dragon, t_dragon_data)
    local vars = self.vars

    local dragon_id = t_dragon['id']
    local status_calc1 = MakeOwnDragonStatusCalculator(dragon_id)

    vars['cardNode']:setVisible(true)

    self.m_lNumberLabel['lukLabel']:setNumber(status_calc1:getDPBaseStatus('LUK'))
    self.m_lNumberLabel['dexLabel']:setNumber(status_calc1:getDPBaseStatus('DEX'))
    self.m_lNumberLabel['agiLabel']:setNumber(status_calc1:getDPBaseStatus('AGI'))
    self.m_lNumberLabel['vitLabel']:setNumber(status_calc1:getDPBaseStatus('VIT'))
    self.m_lNumberLabel['intLabel']:setNumber(status_calc1:getDPBaseStatus('INT'))
    self.m_lNumberLabel['strLabel']:setNumber(status_calc1:getDPBaseStatus('STR'))

    do -- 카드 보유 갯수
        local rarity = dragonRarityStrToNum(t_dragon['rarity'])
        local table_upgrade = TABLE:get('upgrade')
        local t_upgrade = table_upgrade[rarity]

        local key = 'cost_card_0' .. t_dragon_data['grade']
        local max_count = t_upgrade[key]
        local count = t_dragon_data['cnt']

        if (max_count == 0) then
            vars['cardGg']:runAction(cc.ProgressTo:create(2, 100))
            local function tween_cb(value, node)
                node:setString(Str('{1}/{2}', math_floor(value), 'MAX'))
            end
            vars['cardLabel']:runAction(cc.ActionTweenForLua:create(1, 0, count, tween_cb))
        else
            local percentage = math_floor((count / max_count) * 100)
            local function tween_cb(value, node)
                node:setString(Str('{1}/{2}', math_floor(value), max_count))
            end
            vars['cardGg']:runAction(cc.ProgressTo:create(1, percentage))
            vars['cardLabel']:runAction(cc.ActionTweenForLua:create(1, 0, count, tween_cb))
        end
    end
end