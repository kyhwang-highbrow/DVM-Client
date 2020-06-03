local PARENT = UI

-------------------------------------
-- class UI_EventMatchCardResult
-------------------------------------
UI_EventMatchCardResult = class(PARENT,{
        m_successCount = 'number',
        m_rewardInfo = '',
        m_getTicket = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventMatchCardResult:init(data, success_cnt)
    local vars = self:load('event_match_card_result.ui')
    self.m_uiName = 'UI_EventMatchCardResult'
    UIManager:open(self, UIManager.POPUP)
    -- 백키 블럭 해제
    UIManager:blockBackKey(false)
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_okBtn() end, 'UI_EventMatchCardResult')

    self.m_rewardInfo = data['reward_info']
    self.m_getTicket = data['match_cnt'] or 0
    self.m_successCount = success_cnt

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
function UI_EventMatchCardResult:initUI()
    local vars = self.vars
    local title_label = vars['resultLabel']
    title_label:setString(Str('카드 짝 맞추기 {1}회 성공!', self.m_successCount))
    cca.uiReactionSlow(title_label)

    local sub_label = vars['cardLabel']
    sub_label:setString(Str('카드 {1}개 획득!', self.m_getTicket))
    cca.uiReactionSlow(sub_label)

    local reward_info =  self.m_rewardInfo
    local total_cnt = table.count(reward_info)
	for idx, t_item in ipairs(reward_info) do
		local item_id = t_item['item_id']
		local item_cnt = t_item['count']
        local from = t_item['from']

		local card = UI_ItemCard(item_id, item_cnt)
		vars['dropRewardMenu']:addChild(card.root)

        local scale = (self.m_successCount == 10) and 0.55 or 0.65
		local pos_x = UIHelper:getCardPosXWithScale(total_cnt, idx, scale + 0.1)
		card.root:setPositionX(pos_x)
        card.root:setScale(scale)

        cca.uiReactionSlow(card.root, scale, scale, scale - 0.1)

        local grade = string.find(from, 'grade_') and 
                      string.gsub(from, 'grade_', '') or 3

        self:setItemCardRarity(card, grade)
	end
end

-------------------------------------
-- function setItemCardRarity
-------------------------------------
function UI_EventMatchCardResult:setItemCardRarity(item_card, grade)
    local grade = tonumber(grade)
	if (grade > 3) then
		local rarity_effect = MakeAnimator('res/ui/a2d/card_summon/card_summon.vrp')
		if (grade == 5) then
			rarity_effect:changeAni('summon_regend', true)
		else
			rarity_effect:changeAni('summon_hero', true)
		end
		rarity_effect:setScale(1.7)
		rarity_effect:setAlpha(0)
		item_card.root:addChild(rarity_effect.m_node)
        rarity_effect.m_node:runAction(cc.FadeIn:create(0.2))
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventMatchCardResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventMatchCardResult:refresh()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_EventMatchCardResult:click_okBtn()
    UINavigator:goTo('event_match_card')
end

--@CHECK
UI:checkCompileError(UI_EventMatchCardResult)
