MailHelper = {}

-------------------------------------
-- function getMailText
-------------------------------------
function MailHelper.getMailText(struct_mail)
	local table_template = TABLE:get('mail_template')
	local mail_type = struct_mail:getMailType()
    local t_template

    -- 예외 처리 구간
    do
	    -- mail_type이 없다면 탈출
	    if (not mail_type) or (mail_type == '') then
		    return {title = '형식 없음', content = '내용 없음'}
	    end

	    -- 테이블에 템플릿이 없다면 탈출
        t_template = table_template[mail_type]
	    if (not t_template) then
		    return {title = mail_type, content = '정의 되지 않은 mail_type 입니다.'}
	    end

        -- system인 경우 포함된 텍스트 반환
        if (t_template['template_type'] == 'system') then
            return {title = Str(t_template['t_title']), content = struct_mail:getMessage() or Str(t_template['t_content'])}
        end

        -- custom인 경우 별도 로직 태움
        if (t_template['template_type'] == 'custom') then
            return MailHelper.makeCustomMail(struct_mail, t_template)
        end
    end

    -- 생성
    return MailHelper.makeFormalMail(struct_mail, t_template)
end

-------------------------------------
-- function makeFormalMail
-- @brief form 타입 메일 문구를 생성해준다.
-------------------------------------
function MailHelper.makeFormalMail(struct_mail, t_template)
    -- value key에 맞는 value값들을 만든다.
	local t_value = {}
	for i = 1, 5 do
        local value = t_template['value_' .. i]
        if (not value or value == '' or value == 'x') then break end
         
        -- 아이템 이름
        if (value == 'item') then
           	local t_item = struct_mail:getItemList()[1]
			t_value[i] = UIHelper:makeItemName(t_item)
                 
		-- 닉네임
        elseif (value == 'nick') then
            t_value[i] = struct_mail:getNickName()
        
        -- 메세지
        elseif (value == 'msg') then
            t_value[i] = struct_mail:getMessage()

        end
    end

	local title = Str(t_template['t_title'])
	local content = Str(t_template['t_content'], t_value[1], t_value[2], t_value[3], t_value[4], t_value[5])

	return {title = title, content = content}
end

-------------------------------------
-- function makeCustomMail
-- @brief custom 타입의 메일 문구를 생성해준다.
-------------------------------------
function MailHelper.makeCustomMail(struct_mail, t_template)
    local t_custom = struct_mail:getCustom()
    MailHelper.translateText(t_custom)

    local title = Str(t_template['t_title'])
	local content = Str(t_template['t_content'], t_custom['v1'], t_custom['v2'], t_custom['v3'], t_custom['v4'], t_custom['v5'])

	return {title = title, content = content}
end

-------------------------------------
-- function translateText
-- @brief 필요한 경우에 특정 키가 치환되도록 한다.
-------------------------------------
local T_TRANSLATE = {
    ['dv1'] = '드빌1',
    ['dv2'] = '드빌2',
}
function MailHelper.translateText(t_custom)
    for i, v in pairs(t_custom) do
        if (T_TRANSLATE[v]) then
            t_custom[i] = T_TRANSLATE[v]
        end
    end
end