import datetime
import csv
import json
import html
from google.cloud import translate

# search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    PROJECT_ID = config_json['project_id']
    GLOSSARY_PREFIX = config_json['glossary_id_prefix']


def translate_text_with_glossary(
    text_list,
    source_lang,
    target_lang
):
    client = translate.TranslationServiceClient()
    location = "us-central1"
    parent = f"projects/{PROJECT_ID}/locations/{location}"

    glossary_id = f"{GLOSSARY_PREFIX}_{source_lang}_{target_lang}"
    glossary = client.glossary_path(
        PROJECT_ID, "us-central1", glossary_id  # The location of the glossary
    )

    glossary_config = translate.TranslateTextGlossaryConfig(glossary=glossary)
    model_path = f"projects/{PROJECT_ID}/locations/us-central1/models/general/nmt" # 기본적인 인공신경망 번역 모델

    # Supported language codes: https://cloud.google.com/translate/docs/languages
    response = client.translate_text(
        request={
            "contents": text_list,
            "target_language_code": target_lang,
            "source_language_code": source_lang,
            "parent": parent,
            "glossary_config": glossary_config,
            "model": model_path,
        }
    )

    # 번역 결과물 리스트로 반환
    apply_glossary = True
    return_list = []
    for translation in response.glossary_translations:
        #용어집 지원 안하는 언어의 경우에는 해당 텍스트가 공백으로 나온다.
        if translation.translated_text == "": 
            apply_glossary = False
            break
        # print(f"\t {translation.translated_text}")
        # return_list.append(html.unescape(translation.translated_text))

    #용어집 지원 안하는 언어는 일반 텍스트 번역
    # if apply_glossary == False:
        # for translation in response.translations: #이거는 용어집 적용 안된 버전
            # print(f"\t {translation.translated_text}")
            # return_list.append(html.unescape(translation.translated_text))

    return_list.append(str(apply_glossary))
    return return_list


# 메인 함수
def main():
    # 1. input.csv 파일을 읽는다.
    f = open('input.csv', 'r', encoding='utf-8')
    rdr = csv.reader(f)
    column_list = None
    total_source_list = [] # 하나의 리스트에 모든 번역 텍스트 넣은 것
    source_list_list = [] # API 분할 요청 사이즈대로 작게 나눈 리스트를 모은 리스트 
    source_list = []
    max_text_size = 28000 # 한 번의 API에서 최대로 요청보낼 수 있는 텍스트 사이즈
    cur_text_size = 0

    for line in rdr:
        if column_list is None:
            column_list = line
        else:
            source_text = line[0]
            source_list.append(source_text)
            total_source_list.append(source_text)

            cur_text_size += len(source_text)
            # 한 번에 너무 많은 번역은 불가능하다. 이에 따라 한 번에 보낼 수 있는 API 사이즈 정도로 구분한다.
            # Advanced는 
            # 1. 한번에 3만자를 요청할 수 있다.
            # 2. 한 번에 최대 1024 문장 번역을 요청할 수 있다.
            if (max_text_size <= cur_text_size) or (len(source_list) >= 1024):
                source_list_list.append(source_list)
                source_list = []
                cur_text_size = 0

    if cur_text_size > 0:
        source_list_list.append(source_list)

    f.close()

    # 2. 첫 번째 칼럼의 언어 코드를 기준으로 두 번째 칼럼부터 마지막 칼럼까지 번역한다.
    source_lang = column_list[0]
    target_list_map = {}
    datetime_str = datetime.datetime.now().strftime("%Y-%m-%d_%H%M%S")

    for target_lang in column_list[1:]:
        result_list = []
        for _, small_source_list in enumerate(source_list_list):
            small_result_list = translate_text_with_glossary(small_source_list, source_lang, target_lang)
            result_list.extend(small_result_list)
        target_list_map[target_lang] = result_list

    # 3. result_{날짜및시간}.csv 파일을 생성하고 종료. (소중한 결과물이 덮어쓰기로 지워지지 않도록 unique한 파일명)
    file_name = 'check_avail_use_glossary_{0}.csv'.format(datetime_str)
    f = open(file_name, 'w', encoding='utf-8', newline='')
    wr = csv.writer(f)
    wr.writerow(column_list) # 칼럼 작성
    for i, source_lang in enumerate(total_source_list):
        line = []
        line.append(source_lang)
        for target_lang in column_list[1:]:
            line.append(target_list_map[target_lang][i])
        wr.writerow(line)
            
    print('{0} 생성 완료!'.format(file_name))
    f.close()


if __name__ == '__main__':
    main()