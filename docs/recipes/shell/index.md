動画分割

<video width="320" height="240" controls>
  <source src="./output.mp4" type="video/mp4">
</video>

```sh
# IN_FILE=./1690596770471-3fe0fb36363033f3-3fa2de8a4027aa60.mp4
IN_FILE="/home/smpiun/Downloads/MAH00915.MP4"
OUT_FILE="./output.mp4"
# IN_FILE="/home/smpiun/Downloads/lis.webm"
GRID_SIZE=4
GRID_DIV_NUM=$((GRID_SIZE*GRID_SIZE))
WIDTH=1920
CLIP_LEN=1000
FILTER=""
# VIDEO_CODEC=mpeg4
VIDEO_CODEC=libvpx-vp9
VIDEO_QUALITY=30

# 動画の全フレーム数を取得
TOTAL_FRAMES=$(ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames -of default=nokey=1:noprint_wrappers=1 "${IN_FILE}")

# 各クリップのフレーム数を計算
FRAMES_PER_CLIP=$((TOTAL_FRAMES / GRID_DIV_NUM))

# trimの設定
TRIM=""
LST_INDEX=$((GRID_DIV_NUM-1))
echo ${LST_INDEX}
for ((i=0;i<=LST_INDEX;i++)); do
  CLIP_START=$((i*FRAMES_PER_CLIP))
  CLIP_END=$((CLIP_START+CLIP_LEN))
  TRIM+="[0:v]trim=start_frame=${CLIP_START}:end_frame=${CLIP_END},"
  TRIM+="setpts=PTS-STARTPTS,"
  TRIM+="scale=$((WIDTH/GRID_SIZE)):-1[${i}];"
done
TRIM+=$(printf "[%s]" $(seq 0 $LST_INDEX))

# layoutのパターンを自動生成
LAYOUT=""
for ((i=0;i<=LST_INDEX;i++)); do
  WLAYOUT="0"
  HLAYOUT="0"
  for ((w=0; w < $((i % GRID_SIZE));w++)); do
    WLAYOUT+="+w0"
  done
  for ((h=0; h < $((i / GRID_SIZE));h++)); do
    HLAYOUT+="+h0"
  done
  LAYOUT+="${WLAYOUT}_${HLAYOUT}|"
done
LAYOUT=${LAYOUT%?}  # 最後の"|"を削除


FILTER="${TRIM}xstack=inputs=${GRID_DIV_NUM}:layout=${LAYOUT}[v]"

echo ffmpeg -i ${IN_FILE} -filter_complex ${FILTER} -map "[v]" -movflags +faststart -c:v ${VIDEO_CODEC} -crf ${VIDEO_QUALITY} "${OUT_FILE}" 
ffmpeg -i ${IN_FILE} -filter_complex ${FILTER} -map "[v]" -movflags +faststart -c:v ${VIDEO_CODEC} -crf ${VIDEO_QUALITY} "${OUT_FILE}"
```