# Wallpaper-downloader
Утилита для скачки обоев.
Зависмости: curl, jq, zenity

Утилита подтягивает обои с wallhaven, чтобы скачивать nsfw зарегистрируйтесь на wallhaven и вставьте api ключ из профиля в конец 63 строки:
63.        API_URL="${API_BASE}?q=${QUERY}&categories=111&purity=${PURITY_PARAM}&sorting=random&atleast=1920x1080&page=${PAGE}${RATIO_PARAM}&apikey=<api_key>"
