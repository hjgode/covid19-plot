#!/bin/bash

if [ '$1' == '' ]
then
    land=Germany
else
    land=$1
fi

echo '#####################################'
echo '   get current corona data for ...'
echo '   selected country= '${land}
echo '#####################################'

#cd ~/Documents/covid19

# see special quotes being used!
if [ ! -f ./time_series_covid19_confirmed_global.csv ]
then
    echo "Getting new updated file"
    #confirmed
    echo 'deleting old confirmed file...'
    rm time_series_covid19_confirmed_global.csv

    echo 'getting new confirmed file...'
    wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv

else
    if test `find time_series_covid19_confirmed_global.csv -mmin +120`
    then
        echo "Getting new updated file"
        #confirmed
        echo 'deleting old confirmed file...'
        rm time_series_covid19_confirmed_global.csv

        echo 'getting new confirmed file...'
        wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv
    else
        echo "Using previous downloaded file"
    fi
fi

egrep -c -w "^,$land" time_series_covid19_confirmed_global.csv
check=$?
if [ "$check" -eq 0 ]
then
    echo "found data for $land"
else
    echo "no data for $land"
    exit -1
fi

echo "creating time_series_covid19_work.csv..."
rm "time_series_covid19_work.csv"
egrep -w "State|^,$land" time_series_covid19_confirmed_global.csv >"time_series_covid19_work.csv"

echo "transposing table for '"$land"'"
csvtool transpose "time_series_covid19_work.csv" >"time_series_covid19_work_transposed.csv"

if [ ! -f ./time_series_covid19_recovered_global.csv ]
then
    echo "Getting new updated recovered file"
    #recovered
    echo 'deleting old recovered file...'
    rm time_series_covid19_recovered_global.csv

    echo 'getting new recovered file...'
    wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv
else
    if test `find time_series_covid19_recovered_global.csv -mmin +120`
    then
        echo "Getting new updated recovered file"
        #recovered
        echo 'deleting old recovered file...'
        rm time_series_covid19_recovered_global.csv

        echo 'getting new recovered file...'
        wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv
    else
        echo "Using previous downloaded recovered file"
    fi
fi

egrep -c -w "^,$land" time_series_covid19_recovered_global.csv
check=$?
if [ "$check" -eq 0 ]
then
    echo "found data for $land"
else
    echo "no data for $land"
    exit -1
fi

echo "creating time_series_covid19_work_recovered.csv..."
rm "time_series_covid19_work_recovered.csv"
# grep only country with blank Province/State
egrep -w "State|^,$land" time_series_covid19_recovered_global.csv >"time_series_covid19_work_recovered.csv"

csvtool transpose "time_series_covid19_work_recovered.csv" >"time_series_covid19_work_recovered_transposed.csv"

echo 'Joining files...'
#merge/join
csvtool join 1 2 "time_series_covid19_work_transposed.csv" "time_series_covid19_work_recovered_transposed.csv" >"time_series_work.csv"

#sort correctly
echo 'Sorting files...'
cat "time_series_work.csv" |sort -k1,2g -k2,2g --field-separator="/" >"time_series_work_sorted.csv"

echo 'Plotting file...'
gnuplot -e "filename='time_series_work_sorted.csv';outfile='$land.png';mytitle='$land'" plot_covid.gplot

echo "Show plot file"
feh -Z -F "$land.png"
