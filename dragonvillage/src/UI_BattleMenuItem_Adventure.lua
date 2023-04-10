local PARENT = UI_BattleMenuItem

-------------------------------------
-- class UI_BattleMenuItem_Adventure
-------------------------------------
UI_BattleMenuItem_Adventure = class(PARENT, {})

local THIS = UI_BattleMenuItem_Adventure

-------------------------------------
-- function init
-------------------------------------
function UI_BattleMenuItem_Adventure:init(content_type, list_cnt, not_same)
    local vars = self:load('battle_menu_adventure_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()

    if (content_type == 'adventure') then
        self:initUI_advent()
    elseif (content_type == 'story_dungeon' and not_same ~= true) then
        self:initUI_storyDungeon()
    end
end

-------------------------------------
-- function initUI_advent
-------------------------------------
function UI_BattleMenuItem_Adventure:initUI_advent()
    if (g_hotTimeData:isActiveEvent('event_advent')) then
        local vars = self.vars
        vars['storyEventNode']:setVisible(true)

        -- 깜짝 출현 남은 시간
        vars['timeSprite']:setVisible(true)
        vars['timeLabel']:setString('')

        -- 깜짝 출현 타이틀
        local title = g_eventAdventData:getAdventTitle()
        
        local frame_guard = 1
        local function update(dt)
            frame_guard = frame_guard + dt
            if (frame_guard < 1) then
                return
            end
            frame_guard = frame_guard - 1
            
            local remain_time = g_hotTimeData:getEventRemainTime('event_advent')
            if remain_time > 0 then
                local time_str = ServerTime:getInstance():makeTimeDescToSec(remain_time, true)
                vars['timeLabel']:setString(title .. '\n' .. Str('{1} 남음', time_str))
            end
        end
        vars['timeSprite']:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
    end
end

-------------------------------------
-- function initUI_storyDungeon
-------------------------------------
function UI_BattleMenuItem_Adventure:initUI_storyDungeon()
    if (g_contentLockData:isContentLock('story_dungeon') == false) then
        local vars = self.vars
        vars['storyEventNode']:setVisible(true)
        vars['timeSprite']:setVisible(true)

        local season_id = g_eventDragonStoryDungeon:getStoryDungeonSeasonId()
        local did =  TableStoryDungeonEvent:getStoryDungeonEventDid(season_id)
        local table_dragon = TableDragon()
    
        -- 이름
        local dragon_name = table_dragon:getDragonName(did)
        vars['storyEventLabel']:setStringArg(Str(dragon_name))
    
        do -- 드래곤 카드
            local dragon_card = MakeSimpleDragonCard(did, {})
            dragon_card.root:setScale(100/150)
            vars['dragonIconNode']:removeAllChildren()
            vars['dragonIconNode']:addChild(dragon_card.root)
            -- 이벤트 소환 바로 가기
            dragon_card.vars['clickBtn']:setEnabled(false)
        end
        
        vars['timeLabel']:setString('')   
        local function update(dt)
            local timestamp = TableStoryDungeonEvent:getStoryDungeonEventEndTimeStamp(season_id)
            timestamp = timestamp/1000
            local remain_time = timestamp - ServerTime:getInstance():getCurrentTimestampSeconds()
            if remain_time > 0 then
                local time_str = ServerTime:getInstance():makeTimeDescToSec(remain_time, true)
                vars['timeLabel']:setString(Str('{1} 남음', time_str))
            end

            -- 스토리 던전은 노티를 여기에서 처리
            local has_noti = g_highlightData:isHighlightStoryDungeonQuest()
            if vars['notiSprite'] ~= nil then
                vars['notiSprite']:setVisible(has_noti)
            end
        end

        vars['timeSprite']:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
    end
end