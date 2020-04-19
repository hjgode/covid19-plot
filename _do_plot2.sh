#!/bin/bash

# using github repo at https://github.com/CSSEGISandData/COVID-19
# https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv

if [ '$1' == '' ]
then
    land=Germany
else
    land=$1
fi

if [ '$2' != '' ]
then
    province=$2
else
    province=""
fi

echo '#####################################'
echo '   get current corona data for ...'
echo '   selected country= '${land}
echo '   selected province= '${province}
echo '   version 2 with deaths plot'
echo '#####################################'

#cd ~/Documents/covid19

##########
# get data function
#          $1 = in_file
#          $2 = category: confirmed, recovered, deaths
#          $3 = province
#          $4 = country
##########
function get_data() {
    ### CONFIRMED
    #IN_FILE=time_series_covid19_confirmed_global.csv
    IN_FILE=$1 #first argument
    IN_CATEGORY=$2  # confirmed, recovered, deaths
    province=$3
    land=$4
    echo "get_data() called with ${IN_FILE}, ${IN_CATEGORY}, ${province}, ${land}" 
    # see special quotes being used!
    if [ ! -f ./$IN_FILE ]
    then
        echo "Getting updated file"
        #confirmed
        echo 'deleting old file...'
        rm $IN_FILE

        echo 'getting current file ...'
        wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/$IN_FILE

    else
        echo "test if file older than 120min..."
        if test `find $IN_FILE -mmin +120`
        then
            echo "Getting new file"
            #confirmed
            echo 'deleting old file...'
            rm $IN_FILE

            echo 'getting new current file...'
            wget https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/$IN_FILE
        else
            echo "Using previous downloaded file"
        fi
    fi

    if [ "$province" == "" ]
    then
        egrep -c -w "^,$land" $IN_FILE
        check=$?
    else
        egrep -c -w "$province,$land" $IN_FILE
        # test result of last cmd
        check=$?
    fi

    if [ "$check" -eq 0 ]
    then
        echo "found data for $land"
    else
        echo "no data for $land"
        exit -1
    fi

    echo "creating time_series_covid19_work.csv..."
    rm "time_series_covid19_work.csv"

    if [ "$province" == "" ]
    then
        egrep -w "State|^,$land" $IN_FILE >"time_series_covid19_work.csv"
    else
        egrep -w "State|$province,$land" $IN_FILE >"time_series_covid19_work.csv"
    fi

    echo "transposing table for '"$province $land"'"
    csvtool transpose "time_series_covid19_work.csv" >"time_series_work_${IN_CATEGORY}_transposed.csv"
    echo "$IN_FILE done."
}

get_data "time_series_covid19_confirmed_global.csv" "confirmed" "$province" "$land"
get_data "time_series_covid19_recovered_global.csv" "recovered" "$province" "$land"
get_data "time_series_covid19_deaths_global.csv" "deaths" "$province" "$land"

echo 'Joining files...'
#merge/join
csvtool join 1 2 "time_series_work_confirmed_transposed.csv" "time_series_work_recovered_transposed.csv" >"time_series_work.csv"
#4/7/20,107663,36081
#4/8/20,113296,46300
#4/9/20,118181,52407
csvtool join 1 2,3 "time_series_work.csv" "time_series_work_deaths_transposed.csv" >"time_series_work_all.csv"


#sort correctly
echo 'Sorting files...'
cat "time_series_work_all.csv" |sort -k1,2g -k2,2g --field-separator="/" >"time_series_work_sorted.csv"

#date, confirmed, recovered, deaths
#4/16/20,137698,77000,4052,
#4/17/20,141397,83114,4352,
#4/18/20,143342,85400,4459,

echo "getting date of files..."
#get modification date scraping the github html page
tmpdate="$(./_get_date.sh)"

if [ "$tmpdate" != "" ]
then
    #convert ISO date time to local time
    tmpdate="$(date --date $tmpdate +'%d.%m.%Y %H:%M')"
    #append date time to country name
    filedate="$tmpdate"
fi

echo 'Plotting file...'
if [ "$province" == "" ]
then
    gnuplot -e "filename='time_series_work_sorted.csv';outfile='$land.png';mytitle='$land $filedate'" plot_covid2.gplot
else
    gnuplot -e "filename='time_series_work_sorted.csv';outfile='$land.png';mytitle='$land - $province $filedate'" plot_covid2.gplot
fi


echo "Show plot file"
feh -Z -F "$land.png"
