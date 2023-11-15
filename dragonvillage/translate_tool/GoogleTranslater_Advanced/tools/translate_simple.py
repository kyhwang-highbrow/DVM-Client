import threading
import datetime
import csv
import json
import html
import threading
from google.cloud import translate
from google.api_core.exceptions import DeadlineExceeded
from google.api_core.exceptions import ResourceExhausted

# search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    PROJECT_ID = config_json['project_id']
    GLOSSARY_PREFIX = config_json['glossary_id_prefix']


TARGET_LIST_MAP = {}
DATETIME_STR = datetime.datetime.now().strftime("%Y-%m-%d_%H%M%S")

def translate_text_thread(
    text_list_list,
    source_lang,
    target_lang
):
    result_list = []
    for _, text_list in enumerate(text_list_list):
        small_result_list = translate_text(text_list, source_lang, target_lang)
        result_list.extend(small_result_list)
    TARGET_LIST_MAP[target_lang] = result_list

    # 번역 언어가 여러 개일 때 도중에 에러가 난 경우, 소중한 번역 파일이 지워지지 않도록 중간 파일 저장 (result_middle_{언어}_{날짜}.csv)
    file_name = 'result_middle_{0}_{1}.csv'.format(target_lang, DATETIME_STR)
    f = open(file_name, 'w', encoding='utf-8', newline='')
    wr = csv.writer(f)
    for _, result_row in enumerate(result_list):
        wr.writerow([result_row])
    f.close()
    print('{0} 중간 백업 생성 완료!'.format(file_name))


def translate_text(
    text_list,
    source_lang,
    target_lang
):
    client = translate.TranslationServiceClient()
    location = "us-central1"
    parent = f"projects/{PROJECT_ID}/locations/{location}"

    model_path = f"projects/{PROJECT_ID}/locations/us-central1/models/general/nmt" # 기본적인 인공신경망 번역 모델

    try:
        # Supported language codes: https://cloud.google.com/translate/docs/languages
        response = client.translate_text(
            request={
                "contents": text_list,
                "target_language_code": target_lang,
                "source_language_code": source_lang,
                "parent": parent,
                "model": model_path,
            }
        )

        # 번역 결과물 리스트로 반환
        return_list = []
        for translation in response.translations:
            # print(f"\t {translation.translated_text}")
            return_list.append(html.unescape(translation.translated_text))

    except DeadlineExceeded as e:
        print(f"Deadline Excceed. Retry Translate: {target_lang}")
        return translate_text(text_list, source_lang, target_lang)
    except ResourceExhausted as e:
        print(f"Resource Exhausted. Retry Translate: {target_lang}")
        return translate_text(text_list, source_lang, target_lang)

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
    max_text_size = 25000 # 한 번의 API에서 최대로 요청보낼 수 있는 텍스트 사이즈
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
    threads = []
    source_lang = column_list[0]

    for target_lang in column_list[1:]:
        thread = threading.Thread(target=translate_text_thread, args=(source_list_list, source_lang, target_lang))
        thread.start()
        threads.append(thread)

    # 모든 스레드가 완료될 때까지 기다림
    for thread in threads:
        thread.join()    


    # 3. result_{날짜및시간}.csv 파일을 생성하고 종료. (소중한 결과물이 덮어쓰기로 지워지지 않도록 unique한 파일명)
    file_name = 'result_{0}.csv'.format(DATETIME_STR)
    f = open(file_name, 'w', encoding='utf-8', newline='')
    wr = csv.writer(f)
    wr.writerow(column_list) # 칼럼 작성
    for i, source_lang in enumerate(total_source_list):
        line = []
        line.append(source_lang)
        for target_lang in column_list[1:]:
            line.append(TARGET_LIST_MAP[target_lang][i])
        wr.writerow(line)
            
    print('{0} 생성 완료!'.format(file_name))
    f.close()


if __name__ == '__main__':
    main()