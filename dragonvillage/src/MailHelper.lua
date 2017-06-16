MailHelper = {}

-------------------------------------
-- function getMailText
-------------------------------------
function MailHelper:getMailText(event_type, t_data)
	local title = ''
	local context = ''

	-- 드래곤의 선물
	if (event_type == 'dg') then
		local did = t_data['did']
		
		local dragon_name = TableDragon:getDragonName(did)
		title = '[' .. dragon_name .. ']'

		context = TableDragonPhrase:getMailPhrase(did)

	elseif (event_type == 'api') then
		title = t_data['title']
		context = t_data['text']

	end

	return {title = title, context = context}
end


-------------------------------------
-- function getFpointMailText
-- @brief 임시 우정포인트 메세지 - 서버 작업 필요함 위와 같은 형태로
-------------------------------------
function MailHelper:getFpointMailText(t_data)
    local title = Str('우정의 징표 {1}개', t_data['items_list'][1]['count'])
	local context = Str('{1}님이 우정의 징표를 보냄', t_data['nick'])

    return {title = title, context = context}
end