/*data airline_delay;
infile '/home/tomgianelle0/Stats 2/Project 1 - 2 Way ANOVA/Final_Data.csv' dlm=',' firstobs=2;
input IATA_CODE carrier $ arr_delay;
run;*/

FILENAME REFFILE '/home/tomgianelle0/Stats 2/Project 1 - 2 Way ANOVA/Final_Data_2_Way_ANOVA.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=delay_2_way;
	GETNAMES=YES;
RUN;

proc print data=delay_2_way;
run;
*Later procedures need data sorted by group;
proc sort data = delay_2_way;
by IATA_CODE;
run;



*Perform a log transform;
data delay_2_way;
set delay_2_way;
logarr_delay = log(arr_delay);
run;

*To address ANOVA assumptions on original data with histograms and q-q plots;
proc univariate data = delay_2_way;
by IATA_CODE;
histogram logarr_delay;
qqplot logarr_delay;
run; 

*add to HW --- To address ANOVA assumptions on original data with scatter plots;
proc sgplot data = delay_2_way;
scatter x= IATA_CODE y = logarr_delay;
run;
*Calculating a summary stats table and outputing the results in a dataset called "meansout";

proc means data=delay_2_way n mean max min range std fw=8;
class IATA_CODE carrier;
var logarr_delay;
output out=meansout mean=mean std=std;
title 'Summary of Arrival Delays';
run;

/*  with interaction variable  */
/*
proc mixed data=delay_2_way PLOTS=(RESIDUALPANEL);
class IATA_CODE carrier;
model logarr_delay = IATA_CODE carrier IATA_CODE*carrier;
lsmeans IATA_CODE carrier / pdiff tdiff CL adjust=bon;
run; 
*/

/*  without interaction variable  */
proc mixed data=delay_2_way PLOTS=(RESIDUALPANEL);
class IATA_CODE carrier;
model logarr_delay = IATA_CODE carrier;
lsmeans IATA_CODE carrier / pdiff tdiff CL adjust=bon;
run; 




*The following chunk of code is some basic code to plot the summary statistics in a convenient profile type plot.;
*This will probably take you some time to understand how sas works to finally get the plot but for those who put in the effort, your understanding of SAS
will be better for it and you will soon figure out you can do a lot of differnt things. For those of you who do not have the time,
 the alternative is to take the summary statistics
output and move them over to excel and create a plot over there.;

data summarystats;
set meansout;
if _TYPE_=0 then delete;
if _TYPE_=1 then delete;
if _TYPE_=2 then delete;
run;


*This data step creates the necessary data set to plot the mean estimates along with the error bars;
data plottingdata(keep=IATA_CODE carrier mean std newvar);                                                                                                      
   set summarystats;
by IATA_CODE carrier;
 
   newvar=mean;  
   output;                                                                                                                              
                                                                                                                                        
   newvar=mean - std;                                                                                                                  
   output;                                                                                                                              
                                                                                                                                        
   newvar=mean + std;                                                                                                                  
   output;                                                                                                                              
run;  



*Plotting options to make graph look somewhat decent;
 title1 'Plot Means with Standard Error Bars from Calculated Data for Groups';  

   symbol1 interpol=hiloctj color=vibg line=1;                                                                                          
   symbol2 interpol=hiloctj color=depk line=1;                                                                                          
                                                                                                                                        
   symbol3 interpol=none color=vibg value=dot height=1.5;                                                                               
   symbol4 interpol=none color=depk value=dot height=1.5;  

   axis1 offset=(2,2) ;                                                                                                       
   axis2 label=("Arrival Delay") order=(0 to 40 by 10) minor=(n=1); 

   *data has to be sorted on the variable which you are going to put on the x axis;
   proc sort data=plottingdata;
   by carrier;
   run;



proc gplot data=plottingdata;
plot NewVar*carrier=IATA_CODE / vaxis=axis2 haxis=axis1;
*Since the first plot is actually 2 (male female) the corresponding symbol1 and symbol2 options 
* are used which is telling sas to make error bars.  The option is hiloctj;
plot2 Mean*carrier=IATA_CODE / vaxis=axis2 noaxis nolegend;
*This plot uses the final 2 symbols options to plot the mean points;
run;quit;
*This is the end of the plotting code;


*Running 2way anova analysis;
proc glm data=delay_2_way PLOTS=(DIAGNOSTICS RESIDUALS);
class IATA_CODE carrier;
model logarr_delay= carrier IATA_CODE;
lsmeans carrier / pdiff tdiff adjust=bon;


run;
/*
proc glm data=math PLOTS=(DIAGNOSTICS RESIDUALS);
class sex background;
model score= background sex background*sex;
lsmeans background / pdiff tdiff adjust=bon;
estimate 'B vs A' background -1 1 0;
estimate 'What do you think?' background -1 0 1;
estimate 'What do you think2?' sex -1 1;

run;
*/


