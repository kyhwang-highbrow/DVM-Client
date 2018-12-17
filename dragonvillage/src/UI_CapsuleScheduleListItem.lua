local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_CapsuleScheduleListItem
-------------------------------------
UI_CapsuleScheduleListItem = class(PARENT, {
        m_scheduleData = 'Data'
        --[[
               "second_3":770203,
               "badge_first_3":"",
               "badge_first":"",
               "badge_second":"",
               "badge_first_2":"",
               "chance_up_1":121053,
               "second_2":770212,
               "first_3":770784,
               "chance_up_2":"",
               "t_first_name":"",
               "badge_second_1":"",
               "second_1":770112,
               "t_second_name":"",
               "badge_first_1":"",
               "day":20181125,
               "badge_second_2":"",
               "badge_second_3":"",
               "first_2":770433,
               "first_1":770725
        --]]
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleScheduleListItem:init(data)
    local vars = self:load('capsule_box_schedule_list_item.ui')
    self.m_scheduleData = data

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleScheduleListItem:initUI()
   local vars = self.vars

   -- item_key_list 항목 뜻 
   -- ex)  first_1 : 전설 캡슐 첫 번째 아이템, second_2 : 영웅 캡슐  두 번째 아이템
   local item_key_list = {'first_1', 'first_2', 'first_3','second_1', 'second_2', 'second_3'}

   for i, reward_name in ipairs(item_key_list) do
          
       local node_name
       if (string.match(reward_name,'first')) then
           node_name = 'legendDragonNode'
       elseif(string.find(reward_name, 'second')) then
           node_name = 'heroDragonNode'
       end
       
       if (node_name) then
          -- first_1의 숫자를 추출
          local node_number = string.match(reward_name, '%d')
          -- ex) legendDragonNode + 1
          node_name = node_name ..  node_number

          if (vars[node_name]) then
             local reward_card = UI_ItemCard(self.m_scheduleData[reward_name], 1).root
             reward_card:setScale(0.66)
             vars[node_name]:addChild(reward_card)
          end
       end
   end
   --[[
   -- 리스트 아이템 만들기 전에 또 검사
   local date = pl.Date()
   local res = date['tab']['month']*100 + date['tab']['year']*10000 + date['tab']['day']

   if (res < tonumber(self.m_scheduleData['day'])) 
   -- 판매중 or 판매 예정

   self.vars['titleHeroLabel'] 
   self.vars['titleLegendLabel']
   
   self.vars['leftTimeLabel']
   self.vars['purchaseStateLabel']
   --]]
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleScheduleListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleScheduleListItem:refresh()
end
