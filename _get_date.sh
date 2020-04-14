#!/bin/bash

if [ -f ./csse_covid_19_time_series ]
then
    rm csse_covid_19_time_series
fi

wget https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series -o NUL
mv csse_covid_19_time_series tmp_file

#replace all new lines
tr '\n' ' ' < tmp_file >tmp_file1

#insert new lines before and after name and datetime
sed -n 's/time_series_covid19_confirmed_global.csv/\ntime_series_covid19_confirmed_global.csv\n/p;s/datetime="/datetime="\n/p;s/Z"/Z\n"/p' tmp_file >tmp_file4

#insert new lines
#sed 's/<td /\n<td /g;s/<\/td>/\n<\/td>\n/g' tmp_file1 >tmp_file2

#find all content and age
#sed -n '/<td class="content"/,/<\/td>/p;/<td class="age"/,/<\/td>/p' tmp_file2 >tmp_file3

#separate name and datetime onto single lines
#sed 's/href="/\nhref="\n/g;s/datetime="/\ndatetime="\n/g;s/">/\n">\n/g;s/Z"/Z\n"/g;s/<\/a>/\n<\/a>/g' tmp_file3 >tmp_file4

#read line by line
while read LINE
    do
        if [[ "$LINE" =~ ^time_series_covid19_confirmed_global.csv$ ]] || [[ "$LINE" =~ ^2020* ]]
        then
            if [[ "$LINE" =~ ^time_series_covid19_confirmed_global.csv$ ]]
            then
                filenamecsv=$LINE
            else
                filedate=$LINE #"$(echo $LINE |tr '\n' ' ')"
                continue
            fi
            if [ "$filenamecsv" != "" ] && [ "$filedate" != "" ]
            then
                echo "$filedate" #echo "$filenamecsv $filedate"
                break;
            fi
        fi
done <tmp_file4

