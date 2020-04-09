# covid19-plot
fast bash / gnuplot based country centric covid-19 case plotter

# prerequisites

to use it you need a copy of csvtool, egrep and gnuplot

Internet connection to get csv data from https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/

# usage

just call _do_plot.sh with a country name, for example

bash ./_do_plot.sh Germany

or

bash ./_do_plot.sh "United Kingdom"

The data is plotted for confirmed, recovered and delta (new infections compared to previous day). If you subtract the recovered from confirmed, you get a picture of how many actual infections are known.
