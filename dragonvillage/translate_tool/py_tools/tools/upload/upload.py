#############################################################################
## 각종 업로드 함수와 func 비교후 매핑해주는 코드입니다.
#############################################################################


from tools.upload.upload_DVM_plain_text import upload_DVM_plain_text
from tools.upload.upload_DVM_scenario_text import upload_DVM_scenario_text

upload_func = {}
upload_func['upload_DVM_plain_text'] = upload_DVM_plain_text
upload_func['upload_DVM_scenario_text'] = upload_DVM_scenario_text


def upload(func_name, delta_sheet_name, backup_sheet_name, spreadsheet_id, data_list, locale_list):
    return upload_func[func_name](delta_sheet_name, backup_sheet_name, spreadsheet_id, data_list, locale_list)
