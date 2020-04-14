# covid19-plot
fast bash / gnuplot based country centric covid-19 case plotter

# prerequisites

to use it you need a copy of csvtool, egrep and gnuplot

Internet connection to get csv data from https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/

# usage

just call _do_plot.sh with a country name, for example

./_do_plot.sh Germany

or

./_do_plot.sh "United Kingdom"

The data is plotted for confirmed, recovered and delta (new infections compared to previous day). If you subtract the recovered from confirmed, you get a picture of how many actual infections are known.

Added option to use country and region. Just start the script provoding a country and region. For example "United Kingdom" and then "Bermuda"

./_do_plot.sh "United Kingdom" "Bermuda"

# update 2: find country and region

Added another script to select country and region from screen. Just start

_test_select.sh

You will get a list of countries in the database and then can then select a region. For example select "United Kingdom" and then "Bermuda"

The final plot is then done for this country and region/province.

# update 3: add date / time

added a script to capture last modification date/time from github web page. The date / time is then added to the plot.
