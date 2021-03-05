

%let root     = C:\Users\psioda\Documents\GitHub\BIOS-767-Programming;
%let dataPath = &root.\data\basics; 
%let outPath  = &root.\output\basics;

libname basics "&dataPath.";

ods html newfile=proc;

title "First 5 Observations in Dental Data";
proc print data = basics.dental(obs=5) noobs; 
run;



/*** using PROC TRANSPOSE ***/

	proc transpose data = basics.dental out = work.dental;
		by id gender;
		var age8 age10 age12 age14;
	run;

	data work.dental2;
	 set work.dental;

		/** code to create "age" variable from _NAME_ **/
	 	/** format --> w.d; w=# of digits left of decimal; d=# of digits right of decimal **/
	 	age = input(compress(_name_,'eag '),best.);

		drop _name_ _label_;
		rename col1 = distance;
	run;


/*** using DATA Step + ARRAYS ***/

	data work.dental2;
	 set basics.dental;

		array dist[4] age8 age10 age12 age14;

		do i = 1 to 4;
			time     = 6 + 2*i;
			distance = dist[i];
			output;
		end;

		drop age: i;
	run;


/*** create a basic plot ***/
	ods noproctitle;
	title;
	proc means data = work.dental2 noprint nway;
		class gender time;
		var distance;
		output out=summary_data(drop=_:) mean=dmean std=dstd;
	run;

	data summary_data2;
	 set summary_data;

	  high = dmean + 2*dstd;
	  low  = dmean - 2*dstd;

	  		 length display $10;
		     if gender = 'M' then do; display = 'Male';   time = time - 0.1; end;
		else if gender = 'F' then do; display = 'Female'; time = time + 0.1; end;
	run;

	/** global statement -- stays in affect until changed **/
	ods graphics / height=4in width=6in;
	options nodate nonumber 
            leftmargin=0.1in rightmargin=0.1in topmargin=0.1in bottommargin=0.1in
            papersize=("6.2in","4.2in");


	ods pdf file = "&outpath.\Example1-Plot.pdf" dpi=350;
		proc sgplot data = summary_data2;
		 series x=time y=dmean / group=display markers 
	           lineattrs=(thickness=3 pattern=1)
	           markerattrs=(symbol=diamondFilled size=10) name='A';

		 highlow x=time high=high low=low / 
               lineattrs=(thickness=3)
               group=display highcap=serif lowcap=serif name='B';

		 xaxis label="Age (years)" grid;
		 yaxis label="Mean Distance +/- 2SD (mm)" grid;

		 label display = 'Gender';

		 keylegend 'A' / location=inside position=topleft opaque;

		run;
	ods pdf close;
