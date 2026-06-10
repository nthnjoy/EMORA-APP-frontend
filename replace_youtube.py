import re
import sys

file_path = r'e:\kuliah\Mobile\frontend\EMORA-APP-frontend\lib\screens\music_page.dart'

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace source: 'YouTube' with source: 'Audio API'
    content = re.sub(r"source:\s*'YouTube'", "source: 'Audio API'", content)
    
    # Replace youtube URLs with an mp3 URL
    # https://www.youtube.com/watch?v=...
    content = re.sub(r"audioUrl:\s*'https://www\.youtube\.com/watch\?v=[^']+'", "audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'", content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Successfully replaced YouTube URLs with MP3 URLs.")
except Exception as e:
    print(f"Error: {e}")
