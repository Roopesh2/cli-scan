#!/bin/bash
start=$(date +%s.%N)
tmpdir=".temp"
width=$1
if [ ! -d "$tmpdir" ]; then
    mkdir $tmpdir
fi
echo "width: ${width}px"
[[ -z $2 ]] && filter="sc1" || filter="$2"
echo "filter:" "$filter"
prefix="$tmpdir/$1-$filter"
find . -maxdepth 1 -name "*.jpg" | sort | cut -c 3- > a
sc1() {
	convert "$2" -resize "$1x" \
   -brightness-contrast 21x33 \
   -enhance -despeckle -sharpen 2 "$3-$2"
	ffmpeg -i "$3-$2" "$3-$2" -y -hide_banner -loglevel error
}

sc2() {
	convert "$2" -resize "$1x" \
   -brightness-contrast 19x45 \
   -sharpen 1 -despeckle -despeckle \
   -enhance "$3-$2"
  ffmpeg -i "$3-$2" "$3-$2" -y -hide_banner -loglevel error
}

sc3() {
	convert "$2" -resize "$1x" \
   -brightness-contrast 19x35 \
   -sharpen 1 -enhance -despeckle \
   -gamma 1.05 \
   -brightness-contrast -30x90 \
   -enhance "$3-$2"
  ffmpeg -i "$3-$2" "$3-$2" -y -hide_banner -loglevel error
}

export -f sc1 sc2 sc3
if [[ "$filter" =~ ^sc1 ]]; then
  parallel --maxargs 1 sc1 "$width" {} "$prefix" < a
elif [[ "$filter" =~ ^sc2 ]]; then
  parallel sc2 "$width" {} "$prefix" < a
elif [[ "$filter" =~ ^sc3 ]]; then
  parallel sc3 "$width" {} "$prefix" < a
fi

rm a

n="$(basename "$PWD")_$1px.pdf"
echo "converting to pdf"
convert $tmpdir/"$1"-"$filter"-*.jpg "$n"
if [[ "$3" =~ ^y ]]; then
   echo "removing temp"
   rm "$tmpdir" -r
fi
end=$(date +%s.%N)
runtime=$( echo "$end - $start" | bc -l )
echo "completed in ${runtime}s"
