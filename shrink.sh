out=$1

statef=${out}/shrink.done

if [ -f "$statef" ];then
    echo "skipping convert as this has been done already on $(cat $statef)"
    exit 0
else
    for i in $(find $out -name *.png); do 
	convert ${i} -quality 10% ${i} || echo "fail to convert $i"
    done
    date > $statef
fi
