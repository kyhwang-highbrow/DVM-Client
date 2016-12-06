local PARENT = UI

-------------------------------------
-- class UI_DragonTrainSlot_ListItem
-------------------------------------
UI_DragonTrainSlot_ListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param t_data {doid=dragon_object_id, grade=1~6}
-------------------------------------
function UI_DragonTrainSlot_ListItem:init(t_data)
    local vars = self:load('dragon_train_list2.ui')

    self:refresh()
end

-------------------------------------
-- function refresh
-- @param
-------------------------------------
function UI_DragonTrainSlot_ListItem:refresh()

end