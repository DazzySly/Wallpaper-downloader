
# Зависимости: curl, jq, zenity


WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
API_BASE="https://wallhaven.cc/api/v1/search"

mkdir -p "$WALLPAPER_DIR"

TAGS=$(zenity --entry \
    --title="Wallhaven Downloader — Шаг 1/2" \
    --text="Введи теги через запятую (например: anime, night, -gore):" \
    --width=450)

if [ -z "$TAGS" ]; then
    exit 0
fi

FORM=$(zenity --forms \
    --title="Wallhaven Downloader — Шаг 2/2" \
    --text="Настрой параметры загрузки" \
    --add-entry="Сколько обоев скачать (по умолчанию 24):" \
    --add-combo="Соотношение сторон:" --combo-values="Любое|16x9|16x10|21x9|9x16|3x2|4x3" \
    --add-combo="Рейтинг:" --combo-values="SFW|SFW + Sketchy|Всё (включая NSFW)" \
    --width=450)

if [ -z "$FORM" ]; then
    exit 0
fi

COUNT=$(echo "$FORM" | cut -d'|' -f1)
RATIO=$(echo "$FORM" | cut -d'|' -f2)
PURITY=$(echo "$FORM" | cut -d'|' -f3)

if [ -z "$COUNT" ]; then
    COUNT=24
fi

case "$RATIO" in
    "16x9")  RATIO_PARAM="&ratios=16x9" ;;
    "16x10") RATIO_PARAM="&ratios=16x10" ;;
    "21x9")  RATIO_PARAM="&ratios=21x9" ;;
    "9x16")  RATIO_PARAM="&ratios=9x16" ;;
    "3x2")   RATIO_PARAM="&ratios=3x2" ;;
    "4x3")   RATIO_PARAM="&ratios=4x3" ;;
    *)       RATIO_PARAM="" ;;
esac

case "$PURITY" in
    "SFW")                PURITY_PARAM="100" ;;
    "SFW + Sketchy")      PURITY_PARAM="110" ;;
    "Всё (включая NSFW)") PURITY_PARAM="111" ;;
    *)                    PURITY_PARAM="100" ;;
esac

QUERY=$(echo "$TAGS" | tr -d ' ' | tr ',' '+')

PAGES=$(( (COUNT + 23) / 24 ))
COLLECTED=0

(
    for PAGE in $(seq 1 $PAGES); do
        API_URL="${API_BASE}?q=${QUERY}&categories=111&purity=${PURITY_PARAM}&sorting=random&atleast=1920x1080&page=${PAGE}${RATIO_PARAM}&apikey="

        URLS=$(curl -s "$API_URL" | jq -r '.data[].path')

        if [ -z "$URLS" ]; then
            break
        fi

        echo "$URLS" | while read -r url; do
            if [ "$COLLECTED" -ge "$COUNT" ]; then
                break
            fi

            FILENAME=$(basename "$url")
            FILEPATH="$WALLPAPER_DIR/$FILENAME"

            if [ ! -f "$FILEPATH" ]; then
                curl -s -o "$FILEPATH" "$url"
            fi

            COLLECTED=$((COLLECTED + 1))
            PERCENT=$((COLLECTED * 100 / COUNT))
            echo "$PERCENT"
            echo "# Скачано: $COLLECTED из $COUNT ($FILENAME)"
        done

        if [ "$COLLECTED" -ge "$COUNT" ]; then
            break
        fi
    done
) | zenity --progress \
    --title="Скачивание обоев" \
    --text="Начинаю..." \
    --percentage=0 \
    --auto-close

zenity --info --text="Готово! Скачано $COLLECTED обоев в $WALLPAPER_DIR"
