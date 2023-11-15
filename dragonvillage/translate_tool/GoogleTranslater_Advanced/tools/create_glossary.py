import threading
import json
from google.cloud import translate_v3 as translate
from google.api_core.exceptions import DeadlineExceeded

# search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    PROJECT_ID = config_json['project_id']
    GLOSSARY_URI = config_json['glossary_uri']
    GLOSSARY_PREFIX = config_json['glossary_id_prefix']
    SOURCE_LANG = config_json['source_lang']
    TARGET_LANG_LIST = config_json['target_lang_list']


def create_glossary(
    source_lang,
    target_lang,
    timeout: int = 180,
) -> translate.Glossary:
    client = translate.TranslationServiceClient()

    # Supported language codes: https://cloud.google.com/translate/docs/languages
    glossary_id = f"{GLOSSARY_PREFIX}_{source_lang}_{target_lang}"
    location = "us-central1"  # The location of the glossary

    name = client.glossary_path(PROJECT_ID, location, glossary_id)
    language_codes_set = translate.types.Glossary.LanguageCodesSet(
        language_codes=[source_lang, target_lang]
    )

    gcs_source = translate.types.GcsSource(input_uri=GLOSSARY_URI)

    input_config = translate.types.GlossaryInputConfig(gcs_source=gcs_source)

    glossary = translate.types.Glossary(
        name=name, language_codes_set=language_codes_set, input_config=input_config
    )

    parent = f"projects/{PROJECT_ID}/locations/{location}"
    
    try:
        # glossary is a custom dictionary Translation API uses
        # to translate the domain-specific terminology.
        operation = client.create_glossary(parent=parent, glossary=glossary)

        print(f"Create Glossary Success: {glossary_id}")
        result = operation.result(timeout)
        # print(f"Created: {result.name}")
        # print(f"Input Uri: {result.input_config.gcs_source.input_uri}")
        
    # API 허용 요청 수 초과한 경우
    except DeadlineExceeded as e:
        print(f"Deadline Excceed. Retry Create Glossary: {glossary_id}")
        create_glossary(source_lang, target_lang)

    except Exception as e:
        print(f"Create Glossary Error: {glossary_id}")
        print(e)


threads = []

# 현재 버킷에 올라가있는 dvm_glosssary.csv 사용하여
# 단어집 생성
for target_lang in TARGET_LANG_LIST:
    thread = threading.Thread(target=create_glossary, args=(SOURCE_LANG, target_lang))
    thread.start()
    threads.append(thread)

# 모든 스레드가 완료될 때까지 기다림
for thread in threads:
    thread.join()

print('## Finish!')