local PARENT = Structure

-------------------------------------
-- class StructEventBingoInfo
-- @brief 이벤트 팝업에 등록된 탭
-------------------------------------
StructEventBingoInfo = class(PARENT, {
        table_event_product = 'table',
        
        event = 'number',
        event_get = 'number',
        event_use = 'number',
        event_max = 'number',

        bingo_count_info = 'table',
        bingo_number = 'list',
        bingo_line = 'list',
        bingo_pick_count = 'number',
    })

local THIS = StructEventBingoInfo

--[[
    "table_event_product":[
                          {"event_version":"201901bingo",
                          "price_type":"",
                          "step":5,
                          "mail_content_1":"703003;1",
                          "price_1":1,
                          "buy_count_1":"",
                          "mail_content_2":"703019;1",
                          "price_2":3,
                          "buy_count_2":"",
                           ...
    "event":0,
    "event_get":0,
    "event_max":1500,
    "event_use":0,
    "bingo_count_info":{
       "bingo_count":0,
       "bingo_count_reward":{
           "1":"703003;1",
           "3":"703019;1",
           "6":"703010;1",
           "9":"703011;1",
           "12":"703004;1"}
           },
    "bingo_number":{},
    "bingo_line":{},
    "bingo_pick_count":0,

--]]

-------------------------------------
-- function getClassName
-------------------------------------
function StructEventBingoInfo:getClassName()
    return 'StructEventBingoInfo'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructEventBingoInfo:getThis()
    return THIS
end

