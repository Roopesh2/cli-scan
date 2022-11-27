#!/bin/sh

start=`date +%s.%N`
mkdir temp
echo "width: $1px"

[[ -z $2 ]] && filter="sc1" || filter="$2"
echo "filter:" $filter
# no. of jpgs to compile
count=$(ls | grep .jpg | wc -l)

#no. of images parsed
dn=1
N=4 #max no. of background tasks

for f in *.jpg ; do
	((i=i%N)); ((i++==0)) && wait
	echo "processing $f ($dn/$count)"
	convert $f -resize $1x temp/$f
	if [[ "$filter" =~ ^sc1 ]]; then
		convert temp/$f -brightness-contrast 21x33 -enhance -despeckle -sharpen 2 temp/$f
	fi
	((dn++))
done

n="$(basename $PWD).pdf"
echo "converting to pdf"
convert temp/*.jpg $n

echo "compressing..."
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="c_${n}" $n

echo "removing temp"
rm temp -r

end=`date +%s.%N`
runtime=$( echo "$end - $start" | bc -l )
echo "completed in" $runtime "s"
