import threading
import json
from google.cloud import translate_v3 as translate
from google.api_core.exceptions import DeadlineExceeded

# search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    PROJECT_ID = config_json['project_id']
    GLOSSARY_PREFIX = config_json['glossary_id_prefix']
    SOURCE_LANG = config_json['source_lang']
    TARGET_LANG_LIST = config_json['target_lang_list']


def delete_glossary(
    source_lang,
    target_lang,
    timeout: int = 180,
) -> translate.Glossary:
    client = translate.TranslationServiceClient()

    glossary_id = f"{GLOSSARY_PREFIX}_{source_lang}_{target_lang}"
    name = client.glossary_path(PROJECT_ID, "us-central1", glossary_id)

    try:
        operation = client.delete_glossary(name=name)
        result = operation.result(timeout)
        print(f"Deleted Success: {result.name}")

    # API 허용 요청 수 초과한 경우
    except DeadlineExceeded as e:
        print(f"Deadline Excceed. Retry Deleted Glossary: {glossary_id}")
        delete_glossary(source_lang, target_lang)

    except Exception as e:
        print(f"Deleted Error: {name}")
        print(e)


threads = []

# 등록된 용어집 삭제
for target_lang in TARGET_LANG_LIST:
    thread = threading.Thread(target=delete_glossary, args=(SOURCE_LANG, target_lang))
    thread.start()
    threads.append(thread)

# 모든 스레드가 완료될 때까지 기다림
for thread in threads:
    thread.join()

print('## Finish!')