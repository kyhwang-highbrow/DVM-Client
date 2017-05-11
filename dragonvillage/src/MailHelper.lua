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