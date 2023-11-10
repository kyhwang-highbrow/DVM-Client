#############################################################################
## 각종 업로드 함수와 func 비교후 매핑해주는 코드입니다.
#############################################################################


from tools.make_form.make_form_DVM_plain_text import make_DVM_plain_text
from tools.make_form.make_form_DVM_scenario_text import make_DVM_scenario_text

make_func = {}
make_func['make_DVM_plain_text'] = make_DVM_plain_text
make_func['make_DVM_scenario_text'] = make_DVM_scenario_text


def make_form(func_name, delta_sheet_name, backup_sheet_name, spreadsheet_id, locale_list):
    return make_func[func_name](delta_sheet_name, backup_sheet_name, spreadsheet_id, locale_list)
