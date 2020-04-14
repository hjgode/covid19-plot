#!/bin/bash

echo '#####################################'
echo '   get current corona data for ...'
echo ' select country and region/province'
echo '#####################################'

#country="$(awk -F "," '{if($1!="") {print $2,"-", $1;} else {print $2} }' time_series_covid19_confirmed_global.csv )"

#country="$(csvtool drop 1 time_series_covid19_confirmed_global.csv |csvtool format '%(2) %(1)\n' - )"

#country="$(csvtool drop 1 time_series_covid19_confirmed_global.csv |csvtool format '%(2);%(1)\n' - |sed 's/ /_/g')"

country="$(csvtool drop 1 time_series_covid19_confirmed_global.csv |csvtool format '%(2)\n' -| uniq -u |sort)"

#field separator for select
OLD_IFS=${IFS}; IFS="
";

#    country="$(awk -F "," '{if($1!="") print $1}' time_series_covid19_confirmed_global.csv)"

#select_province() {
#    province="$(awk -F "," '{if($1!="") {print $1;} else {print $1, $2;} }' time_series_covid19_confirmed_global.csv)"
#$country
#echo $province

    select co in $country
    do

    case $co in
        *)
            echo "you have selected $co"
            break
        ;;
    esac
    done
#}

echo $co

province="$(csvtool drop 1 time_series_covid19_confirmed_global.csv |csvtool format '%(2); %(1)\n' -| grep ${co})"

    select pr in $province
    do

    case $pr in
        *)
            echo "you have selected $pr"
            break
        ;;
    esac
    done

#split selection at ;
first="$(echo ${pr} | cut -f1 -d\;)"
second="$(echo ${pr} | cut -f2 -d\;)"
#remove trailing blank
second="$(echo ${second} |sed 's/^ //g')"

echo "country='$first'"
echo "province='$second'"

if [ '${second}' != '' ]
then
   result="$(./_do_plot.sh ${first} ${second})"
else
    result="$(./_do_plot.sh ${first})"
fi
