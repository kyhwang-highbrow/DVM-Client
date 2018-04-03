UIC_Factory = {}

-------------------------------------
-- function MakeTableViewDescLabelTTF
-- @brief 리스트뷰에서 리스트가 비었을 때 사용하는 label
-------------------------------------
function UIC_Factory:MakeTableViewDescLabelTTF(table_view_node, text, font_size, tickness)
    -- 테이블뷰에서 사이즈를 얻어옴
    local content_size = table_view_node:getContentSize()

    local font_name = Translate:getFontPath()
    local font_size = (font_size or 24)
    local stroke_tickness = (tickness or 1)
    local dimension = content_size

    local label = cc.Label:createWithTTF(text, font_name, font_size, stroke_tickness, dimension, cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    label:setTextColor(cc.c4b(240, 215, 159, 255))
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))

    label = UIC_LabelTTF(label)

    return label
end

-------------------------------------
-- function MakeTableViewEmptyMandragora
-- @brief 리스트뷰에서 리스트가 비었을 때 사용하는 만드라고라 이미지
-------------------------------------
function UIC_Factory:MakeTableViewEmptyMandragora(text)
    local ui = UI()
    ui:load('mandragora.ui')
    
    local vars = ui.vars
    local label = vars['talkLabel']
    label:setString(text)
    
    local label_size = label:getContentSize()
    local width = math_max(320, label_size.width + 100)
    local height = math_max(100, label_size.height + 60)
    
    local new_size = cc.size(width, height)

    local sprite = vars['talkSprite']
    sprite:setContentSize(new_size)

    -- 기본 visible off
    ui.root:setVisible(false)

    return ui
end