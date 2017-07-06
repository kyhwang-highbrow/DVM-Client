local PARENT = UI

-------------------------------------
-- class UI_ContentLock
-------------------------------------
UI_ContentLock = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ContentLock:init()
    local vars = self:load('contents_lock.ui')
end

-------------------------------------
-- function create
-------------------------------------
function UI_ContentLock:create(req_user_lv)
    local ui = UI_ContentLock()
    ui.vars['lockLabel']:setString(Str('레벨 {1}', req_user_lv))
    return ui
end