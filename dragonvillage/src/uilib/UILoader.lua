UILoader = {
}

local uiRoot = 'res/'

local UILoaderFileCache = {}

function checkUIFileExist(url)
    return cc.FileUtils:getInstance():isFileExist(uiRoot .. url)
end

function getUIFile(url, check_exist)
	if UILoaderFileCache[url] then
		return UILoaderFileCache[url]
	end

    if check_exist then
        if (not cc.FileUtils:getInstance():isFileExist(uiRoot .. url)) then
            return
        end
    end

	local content = cc.FileUtils:getInstance():getStringFromFile(uiRoot .. url)

	if (not content) then
		return nil
	end

	local data = loadstring('return ' .. content)()
	UILoaderFileCache[url] = data

	return data
end

local function setUIHeader(data)
	local header = {}
	if (data['type'] == 'Header') then
		header['type'] = data['type']
		header['version'] = data['version']
		data = data[1]
	else
		header['type'] = 'Header'
		header['version'] = '1.0.0'
	end

	return data, header
end

local function adjustLabelPropsForLowResolution(data)
    --Label을 낮은 해상도에 대응시킨다 (font size를 조절하여)
    --[[
    if UIManager.displayMode ~= DisplayMode_Normal then
        return
    end

    if data.type ~= 'CCStylishLabelTTF' and data.type ~= 'CCTextFieldTTF' then
        return
    end

    data.width = data.width * 0.5
    data.height = data.height * 0.5
    data.fontSize = data.fontSize * 0.5
    data.scaleX = data.scaleX * 2
    data.scaleY = data.scaleY * 2

    if data.hasStroke then
        data.strokeTickness = data.strokeTickness * 0.5
    end
    --]]
end

local function setPropsForNode(node, data)
    node:setPosition(data.x, data.y)
    if not data.relative_size_type then
        if data.is_relative_size then
            data.relative_size_type = 3
            data.width = -data.rel_width or 0 
            data.height = -data.rel_height or 0
        else
            data.relative_size_type = 0
        end
    end

	if (data['relative_size_type'] ~= 0) then
		node:setRelativeSizeAndType(cc.size(data.width, data.height), data.relative_size_type, false)
	end
	if (data['width'] ~= 0 or data['height'] ~= 0) then
    	node:setNormalSize(data.width or 0, data.height or 0)
	end
    if data.anchor_point then node:setAnchorPoint(unpack(data.anchor_point)) end
	if data.dock_point then	node:setDockPoint(cc.p(unpack(data.dock_point))) end
	if (data['scale_x'] ~= 1) then node:setScaleX(data['scale_x']) end
	if (data['scale_y'] ~= 1) then node:setScaleY(data['scale_y']) end
	if (data['skew_x'] ~= 0) then node:setSkewX(data['skew_x']) end
	if (data['skew_y'] ~= 0) then node:setSkewY(data['skew_y']) end
	if (data['rotation'] ~= 0) then node:setRotation(data['rotation']) end
	if (data['visible'] ~= true) then node:setVisible(data['visible']) end
end

-------------------------------------
-- function getStencilSize
-- @brief 부모를 계속 돌면서 realitve_size를 만듬
-- relative size로 설정되어 있으면 width와 height가 음수로 넘어온다.
-- 이때 부모에 붙여진 후 부모에 대비한 node의 size를 구하게 되는데
-- clipping node의 경우에는 stencil을 미리 만들기 때문에 인위적으로 먼저 구하기 위하여
-- clipping node의 부모를 순회하면서 합당한 relative size를 계산한다.
-------------------------------------
local function getStencilSize(width, height, node)
   if (width > 0) and (height > 0) then
       return width, height
   end

   local node_size

   if (not node) then
       node_size = cc.Director:getInstance():getVisibleSize()
   else
       node_size = node:getContentSize()
   end

   if (width < 0) then
       width = (width + node_size['width'])
   end

   if (height < 0) then
       height = (height + node_size['height'])
   end

   if (width < 0) or (height < 0) then
       return findSize(width, height, node:getParent())
   end

   return width, height
end

local function setPropsForClippingNode(node, data, parent)
	setPropsForNode(node, data)
	local stencil = node:getStencil()
	if not stencil then
        if data.stencil_type == 1 then -- CUSTOM
            stencil = cc.Node:create()
            node:setStencil(stencil)
            node:setAlphaThreshold(data.alpha_threshold)
            local stencil_sprite = cc.Sprite:create(uiRoot .. data.stencil_img)
            if stencil_sprite then
                stencil_sprite:setAnchorPoint(cc.p(0,0))
                stencil_sprite:setDockPoint(cc.p(0,0))
                stencil:addChild(stencil_sprite)
            end
        else
			if data.relative_size_type > 0 then
				data['width'], data['height'] = getStencilSize(data['width'], data['height'], parent)
			end

		    stencil = cc.DrawNode:create()
		    node:setStencil(stencil)
		    stencil:clear()
		    local rectangle = {}
		    local white = cc.c4b(1,1,1,1)
		    table.insert(rectangle, cc.p(0, 0))
		    table.insert(rectangle, cc.p(data.width or 0, 0))
		    table.insert(rectangle, cc.p(data.width or 0, data.height or 0))
		    table.insert(rectangle, cc.p(0,data.height or 0))
		    stencil:drawPolygon(
				    rectangle
				    , 4
				    , white
				    , 1
				    , white
		    )
        end
	end
    node:setInverted(data.is_invert)
end

local function setPropsForRGBAProtocol(node, data)
    if data.type == 'LabelTTF' then
        local r,g,b = unpack(data.color)
        local a = data.opacity
        node:setTextColor(cc.c4b(r,g,b,a))
    else
        node:setColor(cc.c3b(unpack(data.color)))
        node:setOpacity(data.opacity)
    end
end

local function setPropsForBlendProtocol(node, data)
    node:setBlendFunc(data.src_blend, data.dest_blend)
end

local function setPropsForLayer(node, data)
    setPropsForNode(node, data)
end

local function setPropsForLayerColor(node, data)
    setPropsForNode(node, data)
    setPropsForRGBAProtocol(node, data)
    setPropsForBlendProtocol(node, data)
end

local function setPropsForLayerGradient(node, data)
    setPropsForLayerColor(node, data)
    node:setStartColor(cc.c3b(unpack(data.start_color)))
    node:setStartOpacity(data.start_opacity)
    node:setEndColor(cc.c3b(unpack(data.end_color)))
    node:setEndOpacity(data.end_opacity)
    local radian = data.angle * 0.01745329252
    node:setVector(cc.pForAngle(radian))
end

local function setPropsForScale9Sprite(node, data)
    setPropsForNode(node, data)
    setPropsForRGBAProtocol(node, data)
end

local function setPropsForLabel(node, data)
    setPropsForNode(node, data)
    setPropsForRGBAProtocol(node, data)

    --TODO: 디폴트 텍스트 관련 작업이 필요
    if data.lua_name == '' then
        node:setString(Str(data.text))
    end
end

local function setPropsForEditBox(node, data)
    setPropsForNode(node, data)

    -- edit_box 데이터 검증
    if (data.input_flag ~= 1) then
        ccdump({['lua_name'] = data.lua_name, ['msg'] = 'edit box input flag를 확인해주세요. 기본값은 Initial_caps_all_character 입니다.'})
        data.input_flag = 1
    end
    if (data.max_length == 0) then
        --ccdump({['lua_name'] = data.lua_name, ['msg'] = 'editbox max_length가 0일 경우 ios에서는 입력이 불가합니다.(무한으로 처리X), 반면 안드로이드는 0부터 제한 없이 입력.'})
        data.max_length = -1
    end

    node:setInputMode(data.input_mode)
    node:setInputFlag(data.input_flag)
    node:setReturnType(data.return_type)
    node:setMaxLength(data.max_length)
    node:setText(Str(data.text))
    node:setFontName(data.font_name)
    node:setFontSize(data.font_size)
    node:setFontColor(cc.c3b(unpack(data.font_color)))
    node:setPlaceHolder(Str(data.placeholder))
    node:setPlaceholderFontName(data.font_name)
    -- node:setPlaceholderFontName(data.placeholder_font_name)
    node:setPlaceholderFontSize(data.placeholder_font_size)
    node:setPlaceholderFontColor(cc.c3b(unpack(data.placeholder_font_color)))
end

local function setPropsForSprite(node, data)
    node:setFlippedX(data.flip_x)
    node:setFlippedY(data.flip_y)
    setPropsForNode(node, data)
    setPropsForRGBAProtocol(node, data)
    setPropsForBlendProtocol(node, data)
end

local function setPropsForTableView(node, data)
    setPropsForNode(node, data)
    node:setBounceable(data.bounce)

    if data.scroll == 2 then
        node:setDirection(0)
    else
        node:setDirection(1)
    end

    node:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    node:setDelegate()
end

local function setPropsForButton(node, data)
    setPropsForNode(node, data)
    node:setEnabled(data.enable)
    --TODO: 이 부분에, 닫기 사운드 관련된 코드를 넣자
    --[[
    if data.selectedFilename ~= '' then
        -- for sampl
        if data.var and string.match(data.var, 'close') then
            node:setSfxForSelection(SoundMgr.sfx['btn_close']) --'sound/button_click_close.mp3')
        else
            node:setSfxForSelection(SoundMgr.sfx['btn_click']) --'sound/button_click_normal.mp3')
        end
    end
    --]]
end

local function setPropsForRotatePlate(node, data)
    setPropsForNode(node, data)
end

local function setPropsForProgressTimer(node, data)
    setPropsForNode(node, data)
    setPropsForRGBAProtocol(node, data)
    setPropsForBlendProtocol(node:getSprite(), data)
    if data.progress_type == 0 then
        node:setType(0)
    elseif data.progress_type == 1 then
        node:setType(0)
        node:setReverseDirection(true)
    elseif data.progress_type == 2 then
        node:setType(1)
        node:setBarChangeRate(cc.p(0, 1))
    elseif data.progress_type == 3 then
        node:setType(1)
        node:setBarChangeRate(cc.p(0, 1))
    elseif data.progress_type == 4 then
        node:setType(1)
        node:setBarChangeRate(cc.p(1, 0))
    elseif data.progress_type == 5 then
        node:setType(1)
        node:setBarChangeRate(cc.p(1, 0))
    end
    node:setMidpoint(cc.p(data.mid_point_x, data.mid_point_y))
    node:setPercentage(data.percentage)
end

-------------------------------------
-- function makeSpine
-- @brief Spine type을 임시로 Visual에서 생성
-------------------------------------
local function makeSpine(filename)
    if (not filename) then
        return
    end
    
    local node = nil
    local isIntegratedSpine = false
    -- 경로를 '/'로 나누어 리스트로 저장
    local path_list = plSplit(filename, '/')

    -- json 통합 사용 여부
    -- 경로 검사하면서 _all, _all_ 있는지 확인
    for _, path_part in ipairs(path_list) do
        if (pl.stringx.endswith(path_part, '_all') or string.find(path_part, '_all_')) then
            isIntegratedSpine = true
            break
        end 
    end 

    local path, name, extention= string.match(filename, "(.-)([^//]-)(%.[^%.]+)$")
    path = 'res/' .. path
    if (isIntegratedSpine) then
        -- ex) res/character/dragon/abyssedge_all_01/abyssedge_earth_01/abyssedge_all_01.atlas 을
        -- ex) res/character/dragon/abyssedge_all_01/abyssedge_earth_01.spine 으로 수정하는 과정
        path = pl.stringx.rpartition(path,'/')
        path = path .. '.spine'
        node = MakeAnimatorSpineToIntegrated(path).m_node
    else
        path = path .. name .. '.json'
        node = MakeAnimator(path).m_node
    end
	
    return node
end

local function loadNode(ui, data, vars, parent, keep_z_order, use_sprite_frames)
    if not data.loaded then
        -- 저해상도(3GS)를 위해 Label을 강제로 ui property를 변경해준다.
        -- adjustLabelPropsForLowResolution(data)
        data.loaded = true
    end

    local node
    local delegator
    local type = data.type
    local ui_name = data.ui_name
    local flag = data.flag
    local var = data.lua_name

    -- UIMaker에서 영역 확인용으로 생성한 컬러 레이어는 생성하지 않음
    if (type == 'LayerColor') and ((ui_name == 'hide') or (flag =='hide')) then
        return
    end

        
    if data.font_name then
        -- 시스템 폰트는 폰트명을 지정하지 않게 변경
        if (type == 'LabelSystemFont') then
            data.font_name = ''
        else
			-- ui 파일에서 지정된 폰트 사용
			if (data.ui_name == 'fontFix') or (flag =='fontFix') then
				
			-- std 언어 이외는 font 변경
			elseif (Translate:isNeedTranslate()) then
				data.font_name = 'font/' .. Translate:getFontName()
			end
        end
    end

    if type == 'Node' then
        node = cc.Node:create()
        --node = cc.Menu:create()
        setPropsForNode(node, data)
        --setPropsForLayer(node, data)
    elseif type == 'Menu' then
        node = cc.Menu:create()
        setPropsForLayer(node, data)
        if (data.ui_name == 'swallowMenu') or (flag =='swallowMenu') then
            node:setSwallowTouch(false)
        end

    elseif type == 'LayerColor' then
        node = cc.LayerColor:create()
        setPropsForLayerColor(node, data)
    elseif type == 'LayerGradient' then
        node = cc.LayerGradient:create()
        setPropsForLayerGradient(node, data)
    elseif type == 'Scale9Sprite' then
        UILoader.checkTranslate(data)
        local rect = cc.rect(data.center_rect_x, data.center_rect_y, data.center_rect_width, data.center_rect_height)

        if (data.file_name == nil) or (data.file_name == '') then
            data.file_name = 'common/empty.png'
        end

        -- @ochoi 20210204
        -- ui파일에서 지정된 Scale9Sprite 리소스가 없을 경우 EMPTY_PNG를 생성하도록 한다.
        local filePath = data.file_name ~= '' and uiRoot .. data.file_name or nil

        node = cc.Scale9Sprite:create(
            rect
            , filePath
        )

        setPropsForScale9Sprite(node, data)
    elseif type == 'LabelSystemFont' then
        --TODO: 디폴트 폰트 셋팅 과정이 필요        
        node = cc.Label:createWithSystemFont(
            Str(data.text)
            , data.font_name
            , data.font_size
            , cc.size(data.dimension_width, data.dimension_height)
            , data.h_alignment
            , data.v_alignment
            )
        setPropsForLabel(node, data)
    elseif (type == 'LabelTTF') and ((ui_name == 'rich') or (ui_name == 'scroll') or (flag =='rich') or (flag =='scroll')) then
        local rich_label = UIC_RichLabel()
        node = rich_label.m_node
        setPropsForNode(node, data)

        local size = node:getContentSize()

        -- label의 속성들
        rich_label:setString(Str(data.text))
        rich_label:setFontSize(data.font_size)
        rich_label:setDimension(size['width'], size['height'])
        rich_label:setAlignment(data.h_alignment, data.v_alignment)
        
        -- 기본 색상 지정
        local r,g,b = unpack(data.color)
        rich_label.m_defaultColor = cc.c3b(r,g,b)

        -- STROKE
        if data.has_stroke then
            local r,g,b = unpack(data.stroke_color)
            local a = data.opacity
            rich_label:enableOutline(cc.c4b(r,g,b,a), data.stroke_tickness)
        end
		-- SHADOW
		if data.has_shadow then
			local r,g,b = unpack(data.shadow_color)
			local a = data.shadow_opacity
            local shadow_size = cc.size(0,0)
            local distance = data.shadow_distance
            if data.shadow_direction == 0 then -- 90
                shadow_size = cc.size(0, -distance)
            elseif data.shadow_direction == 1 then -- 45
                shadow_size = cc.size(distance, -distance)
            elseif data.shadow_direction == 2 then -- 135
                shadow_size = cc.size(-distance, -distance)
            else
                shadow_size = cc.size(0, 0)
            end
            rich_label:enableShadow(cc.c4b(r,g,b,a), shadow_size, 0)
		end

        -- AUTO FONT SIZE SCALING (라벨 영역에 텍스트가 들어가도록 자동으로 폰트 사이즈 스케일링)
        if data.use_auto_fontsize then
            rich_label:setAutoFontSizeScaling(true)
        end

        if (ui_name == 'scroll') or (flag =='scroll') then
            delegator = UIC_ScrollLabel:create(rich_label)
            node = delegator.m_node
        elseif (ui_name == 'rich') or (flag =='rich') then
            delegator = rich_label
        else
            error('ui_name : ' .. ui_name)
        end

    elseif type == 'LabelTTF' then
        local use_ttf = nil
        -- CustomStroke타입은 create함수에서 stroke_tickness를 0으로 넘겨야 한다.
        local stroke_tickness = 0
        if data.has_stroke and (data.stroke_type == 0) then
            stroke_tickness = data.stroke_tickness
        end

        node, use_ttf = UILoader:createWithTTF(
            Str(data.text)
            , uiRoot .. data.font_name
            , data.font_size
            , stroke_tickness
            , cc.size(data.dimension_width, data.dimension_height)
            , data.h_alignment
            , data.v_alignment
            )
        if not node then
            node = cc.Label:createWithSystemFont(
                Str(data.text)
                , uiRoot .. data.font_name
                , data.font_size
                , cc.size(data.dimension_width, data.dimension_height)
                , data.h_alignment
                , data.v_alignment
            )
            use_ttf = false
        end
        setPropsForLabel(node, data)

        delegator = UIC_LabelTTF(node)

		-- STROKE
        if data.has_stroke then
            node:setStrokeType(data.stroke_type or 0)
            node:setStrokeDetailLevel(data.stroke_detail_level or 0)
            node:setSharpTextInCustomStroke(data.is_sharp_text or true)
            local r,g,b = unpack(data.stroke_color)
            local a = data.opacity
            --node:enableOutline(cc.c4b(r,g,b,a), data.stroke_tickness)
            delegator:enableOutline(cc.c4b(r,g,b,a), data.stroke_tickness)
        end
		-- SHADOW
		if data.has_shadow then
			local r,g,b = unpack(data.shadow_color)
			local a = data.shadow_opacity
            local shadow_size = cc.size(0,0)
            local distance = data.shadow_distance
            if data.shadow_direction == 0 then -- 90
                shadow_size = cc.size(0, -distance)
            elseif data.shadow_direction == 1 then -- 45
                shadow_size = cc.size(distance, -distance)
            elseif data.shadow_direction == 2 then -- 135
                shadow_size = cc.size(-distance, -distance)
            else
                shadow_size = cc.size(0, 0)
            end
			--node:enableShadow(cc.c4b(r,g,b,a), shadow_size, 0) -- // enableShadow(shadowColor = Color4B::BLACK, offset = Size(2,-2),int 	blurRadius = 0)
            delegator:enableShadow(cc.c4b(r,g,b,a), shadow_size, 0) -- // enableShadow(shadowColor = Color4B::BLACK, offset = Size(2,-2),int 	blurRadius = 0)
		end

        -- AUTO FONT SIZE SCALING (라벨 영역에 텍스트가 들어가도록 자동으로 폰트 사이즈 스케일링)
        if data.use_auto_fontsize then
            delegator:setAutoFontSizeScaling(true)
        end

		-- SPACE BETWEEN LETTER
        if (use_ttf == true) then -- Not supported system font!
		    if data['letter_spacing'] and data['letter_spacing'] ~= 0 then
			    node:setAdditionalKerning(data['letter_spacing'])
		    end
        end

        --언어별 스케일
        local rateX, rateY = Translate:getFontScaleRate()
        delegator:setScaleX( rateX )
        delegator:setScaleY( rateY )

    elseif type == 'EditBox' then
        UILoader.checkTranslate(data)
        if (data.normal_bg == nil) or (data.normal_bg == '') then
            data.normal_bg = 'common/empty.png'
        end
        local normalBGFilename = data.normal_bg ~= '' and uiRoot .. data.normal_bg or nil
        local pressedBGFilename = data.pressed_bg ~= '' and uiRoot .. data.pressed_bg or nil
        local disabledBGFilename = data.disabled_bg ~= '' and uiRoot .. data.disabled_bg or nil
        local normalBG = cc.Scale9Sprite:create(normalBGFilename)
        local pressedBG = cc.Scale9Sprite:create(pressedBGFilename)
        local disabledBG = cc.Scale9Sprite:create(disabledBGFilename)

        -- @sgkim 2021.02.03 EditBox:create에서 사이즈와, normalBG는 필수 인자이다.
        -- ui파일에서 지정된 normalBG 리소스가 없을 경우 EMPTY_PNG를 생성하도록 한다.
        node = cc.EditBox:create(cc.size(data.width, data.height), normalBG, pressedBG, disabledBG)
        setPropsForEditBox(node, data)
    elseif type == 'TextFieldTTF' then
        --TODO: 추후 다시 구현할 것
        node = cc.TextFieldTTF:textFieldWithPlaceHolder(
            Str(data.text)
            , cc.size(data.width, data.height)
            , data.h_alignment
            , data.font_name
            , data.font_size
            )
        setPropsForSprite(node, data)
    elseif type == 'Button' then
        UILoader.checkTranslate(data)
        if (data.normal == nil) or (data.normal == '') then
            data.normal = 'common/empty.png'
        end

        local normalFilename = uiRoot .. data.normal
        local selectedFilename = data.selected ~= '' and uiRoot .. data.selected or nil
        local disableFilename = data.disable ~= '' and uiRoot .. data.disable or nil
        node = cc.MenuItemImage:create(
            normalFilename
            , selectedFilename
            , disableFilename
            , data.image_type or 0
            )
        setPropsForButton(node, data)
        delegator = UIC_Button(node)

        -- 2018-03-21 klee 청약철회 문구가 국내법이라 국내 유저에게만 노출되어야함 (노출여부는 언어선택으로)
        -- 모든 UI 파일 네이밍 검사한 결과 contractBtn은 상품쪽에서만 쓰이고 있고 앞으로도 상품쪽에서만 쓰기로 결정
        local res_name = ui.m_resName or ''
        if (string.find(res_name, 'package') and data.lua_name == 'contractBtn') then
            local lang = g_localData:getLang() or ''
            local visible = (lang == 'ko')
            node:setVisible(visible)
        end

    elseif type == 'TableView' then
        -- 2017-07-10 sgkim TableView대신 UIC_TableView로 전환함
		cclog('2017-07-10 sgkim TableView대신 UIC_TableView로 전환함')
    elseif type == 'Sprite' then
        if (ui_name == 'spine') or (flag =='rich') then
            node = makeSpine(data.file_name)
            if (node) then
                setPropsForNode(node, data)
            end
        else
		    UILoader.checkTranslate(data)
		    local res = uiRoot .. data.file_name

		    if use_sprite_frames then
		        -- 확장자를 포함한 파일명만 얻어옴
		        local file_name = res:match('([^/]+)$')

		        -- SpriteFrames를 통해 Sprite를 생성
		        node = cc.Sprite:createWithSpriteFrameName(file_name)
		    else
		        node = cc.Sprite:create(res)
		    end

		    if (not node) then
		        error(string.format('"%s"(이)가 없습니다.', res))
		    end
		    setPropsForSprite(node, data)
        end
    elseif type == 'ProgressTimer' then
        UILoader.checkTranslate(data)
        local spr = cc.Sprite:create(uiRoot .. data.file_name)
        spr:setFlippedX(data.flip_x)
        spr:setFlippedY(data.flip_y)
        node = cc.ProgressTimer:create(spr)
        setPropsForProgressTimer(node, data)
    elseif type == 'ClippingNode' then
        node = cc.ClippingNode:create()
        setPropsForClippingNode(node, data, parent)
        delegator = UIC_ClippingNode(node)
    elseif type == 'Visual' then
        local res_name = string.sub(data.file_name, 1, string.len(data.file_name) - 4)

        -- 번역 이미지 체크
        UILoader.addTranslatedTypoPlist(data)

        -- vrp 생성
        local vrp_name = res_name .. '.vrp'
        node = cc.AzVRP:create(uiRoot .. vrp_name)
        if not node then
            node = cc.AzVisual:create(uiRoot .. data.file_name)
        end
        node:loadPlistFiles('')
        node:buildSprite('')

        local idx = string.find(data.visual_id, ';')
        if idx then
            local visual_group_name = string.sub(data.visual_id, 0, idx - 1)
            local visual_name = string.sub(data.visual_id, idx + 1)
            node:setVisual(visual_group_name, visual_name)
        end
        
        node:setRepeat(data.is_repeat)
        setPropsForNode(node, data)
        setPropsForRGBAProtocol(node, data)

        -- vrp의 대리자를 AnimatorVrp로 생성
        local animator = AnimatorVrp(nil)
        animator.m_node = node
        delegator = animator

        if (ui_name == 'low_mode') or (flag =='low_mode') then
            animator:setIgnoreLowEndMode(true)
        end

    elseif type == 'SocketNode' then
        -- 소켓노드를 포함하는 Visual부모노드가 항상 존재한다고 가정
        if not parent then
            cclog('[UILoader] invalid SocketNode:' .. luadump(var))
        else
            node = parent:getSocketNode(data.socket_name)
        end
    elseif type == 'Particle' then
        node = cc.ParticleSystemQuad:create(uiRoot .. data.file_name)
        if not parent then
            setPropsForNode(node, data)
        end
    elseif type == 'RotatePlate' then
        node = cc.RotatePlate:create(data.radius_x, data.radius_y, data.min_scale, data.max_scale, data.origin_dir)
        setPropsForRotatePlate(node, data)
    else
        cclog('[UILoader] invalidnode:' .. luadump(var))
    end

    -- Action
    if data.action_type and data.action_type ~= 0 then
        ui:addAction(node, data.action_type, data.action_delay_1 + data.action_delay_2, data.action_duration)
    end

    for z_order,v in ipairs(data) do
        local child = loadNode(ui, v, vars, node, keep_z_order, use_sprite_frames)

        -- 소켓노드를 위한 예외처리...
        if child and v.type ~= 'SocketNode' then
            if keep_z_order then
                node:addChild(child, z_order)
            else
                node:addChild(child)
            end
        end
    end

    if var and var ~= '' then
        if vars[var] ~= nil then
            cclog('duplicate var name: ' .. var)
        end

        if delegator then
            vars[var] = delegator
        else
            vars[var] = node
        end
    
    -- label 검증을 위해 luaname 지정되지 않은 label도 따로 저장한다
    elseif (IS_TEST_MODE()) then
        if (delegator) then
            if (isInstanceOf(delegator, UIC_LabelTTF)) then
                vars['label_' .. math_random(50)] = delegator
            end
        end
    end

    return node
end

-------------------------------------
-- function checkTranslate
-- @brief png 번역
-- @comment png를 사용하는 UI객체
--      Sprite
--      Scale9Sprite
--      Button
--      EditBox
--      ProgressTimer
-------------------------------------
function UILoader.checkTranslate(data)
    -- 번역이 필요한 경우에만 동작
    if (not Translate:isNeedTranslate()) then
        return
    end

    -- png를 사용하는 data를 확인
    data.file_name      = Translate:getTranslatedPath(data.file_name)
    data.normal_bg      = Translate:getTranslatedPath(data.normal_bg)
    data.pressed_bg     = Translate:getTranslatedPath(data.pressed_bg)
    data.selected       = Translate:getTranslatedPath(data.selected)
    data.disabled_bg    = Translate:getTranslatedPath(data.disabled_bg)
    data.normal         = Translate:getTranslatedPath(data.normal)
end

-------------------------------------
-- function addTranslatedTypoPlist
-- @brief a2d를 불러올 때 해당 a2d 하위의 typo 폴더를 탐색하여 spriteFrame에 추가한다.
-------------------------------------
function UILoader.addTranslatedTypoPlist(data)
    if (not data) then
        return
    end

    local full_path = data.file_name
    Translate:a2dTranslate(full_path)
end

-------------------------------------
-- function load
-------------------------------------
function UILoader.load(ui, url, keep_z_order, use_sprite_frames)
	if (not CHECK_UI_LOAD_TIME) then
		local data = getUIFile(url)
		data = setUIHeader(data)

		local vars = {}
		local root = loadNode(ui, data, vars, nil, keep_z_order, use_sprite_frames)

		return root, vars
	end

	local stopwatch = Stopwatch()
	stopwatch:start()

	local data = getUIFile(url)

	--record
	stopwatch:record('UI File load')

	data = setUIHeader(data)

	local vars = {}
	local root = loadNode(ui, data, vars, nil, keep_z_order, use_sprite_frames)

	-- record
	stopwatch:record('UI Node load')
	stopwatch:stop()
	stopwatch:print()

	return root, vars
end

-------------------------------------
-- function setPermanent
-------------------------------------
function UILoader.setPermanent(url)
    if UILoaderFileCache[url] then
		UILoaderFileCache[url]['permanent'] = true
	end
end

-------------------------------------
-- function cache
-------------------------------------
function UILoader.cache(url)
    if not UILoaderFileCache[url] then
        local content = cc.FileUtils:getInstance():getStringFromFile(uiRoot .. url)
        data = loadstring('return ' .. content)()
        UILoaderFileCache[url] = data
    end
end

-------------------------------------
-- function clearCache
-------------------------------------
function UILoader.clearCache()
	for url, ui in pairs(UILoaderFileCache) do
		if ui['permanent'] == true then
			-- NOTHING TO DO
		else
			UILoaderFileCache[url] = nil
		end
	end
end



-------------------------------------
-- function createWithTTF
-- @brief TTF라벨 사용이 불가한 경우 SystemFont라벨을 생성
-- @return label, available_ttf(bool)
-------------------------------------
function UILoader:createWithTTF(text, font, fontSize, outlineSize, dimensions, hAlignment, vAlignment)
    
    -- 파라미터 기본값 설정
    local text = text or ''
    local font = font
    local fontSize = fontSize or 10
    local outlineSize = outlineSize or 0
    local dimensions = dimensions or cc.size(0, 0)
    local hAlignment = hAlignment or cc.TEXT_ALIGNMENT_LEFT
    local vAlignment = vAlignment or cc.VERTICAL_TEXT_ALIGNMENT_TOP

    -- 기본 변수
    local label = nil
    local available_ttf = true

    -- 페르시아어는 RTL이슈로 인해 시스템 폰트를 사용해야 함
    if (Translate:getGameLang() == 'fa') then
        available_ttf = false
    end

    if available_ttf then
        -- ttf 라벨 생성
        label = cc.Label:createWithTTF(
            text
            , font
            , fontSize
            , outlineSize
            , dimensions
            , hAlignment
            , vAlignment
        )
    else
        -- 시스템 폰트 라벨 생성
        label = cc.Label:createWithSystemFont(
            text
            , font
            , fontSize
            , dimensions
            , hAlignment
            , vAlignment
        )
    end

    return label, available_ttf
end
