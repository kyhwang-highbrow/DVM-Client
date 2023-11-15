import json
from google.cloud import translate

# search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    PROJECT_ID = config_json['project_id']

def list_glossaries(
) -> translate.Glossary:
    client = translate.TranslationServiceClient()

    location = "us-central1"

    parent = f"projects/{PROJECT_ID}/locations/{location}"

    # Iterate over all results
    print(f"glossary list info")
    for glossary in client.list_glossaries(parent=parent):
        print(f"Name: {glossary.name}")
        print(f"Entry count: {glossary.entry_count}")
        print(f"Input uri: {glossary.input_config.gcs_source.input_uri}")

        # Note: You can create a glossary using one of two modes:
        # language_code_set or language_pair. When listing the information for
        # a glossary, you can only get information for the mode you used
        # when creating the glossary.
        for language_code in glossary.language_codes_set.language_codes:
            print(f"Language code: {language_code}")

list_glossaries()