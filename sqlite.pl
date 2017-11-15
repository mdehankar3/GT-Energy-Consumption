#!/usr/bin/perl

use DBI;

$files = `ls *.csv`;
@file = split(/\n/,$files);

for($f=0;$f<scalar@file;$f++){
$name = $file[$f];
$out = $name.".out";
print"For $name...\n";

my $driver   = "SQLite"; 
my $database = "test.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) 
                      or die $DBI::errstr;

print "Opened database successfully\n";

#create table
my $stmt = qq(CREATE TABLE date_day
      (DATE_IN         TEXT););
my $rv = $dbh->do($stmt);
if($rv < 0){
   print $DBI::errstr;
} else {
   print "Table created successfully\n";
}

open(F1,$name) || die"Cannot open\n";
open(F2,">$out");
$rec = 0;

while(<F1>){
	if($_ =~ /^Code.*/){
		@main = split(",",$_);	
	
	#extract date,month,year
	for($i=3;$i<scalar@main;$i++){
		@main_parts = split(" ",$main[$i]);
		$main_parts[0] =~ s/"//g;
		$main_parts[1] =~ s/"//g;
		@date = split("-",$main_parts[0]);
	
		#Create @time
		@time = split(":",$main_parts[1]);
		push(@hour,$time[0]);
		push(@minute,$time[1]);
		
		#original All_buildings.csv	
		$year = $date[0]; $month = $date[1]; $date = $date[2];
		
		#Create @yearly		
		push(@yearly,$year);
	
		#Create @monthly
		push(@monthly,$month);

		#Create @dately
		push(@dately,$date);

		#extract season
		if (($month == 5) || ($month == 4) || (($month == 3) && ($date>= 20)) || (($month == 6) && ($date <= 20))){
			$season = 0;	#spring
			#Create @seasonality
			push(@seasonality,$season);
		}
		elsif (($month == 7) || ($month == 8) || (($month == 6) && ($date>= 21)) || (($month == 9) && ($date <= 21))){
			$season = 1;	#summer
			#Create @seasonality
			push(@seasonality,$season);
		}
		elsif (($month == 10) || ($month == 11) || (($month == 9) && ($date>= 22)) || (($month == 12) && ($date <= 20))){
			$season = 2;	#fall
			#Create @seasonality
			push(@seasonality,$season);
		}
		elsif (($month == 1) || ($month == 2) || (($month == 12) && ($date>= 21)) || (($month == 3) && ($date <= 19))){
			$season = 3;	#winter
			#Create @seasonality
			push(@seasonality,$season);
		}
	
	#print F2 "$year\t$month\t$date\t$season\t$main_parts[0]\n";
	$in_date = $main_parts[0];
	
	#extract day of week
	my $stmt = qq(INSERT INTO date_day (DATE_IN)
      		VALUES ("$in_date"));
	my $rv = $dbh->do($stmt) or die $DBI::errstr;;
	#print "Records created successfully:\t$stmt\n";
	$rec++;					
	}
	}
	
	else{
		push(@int_records,$_);
	}
}

#Select operation
my $stmt = qq(SELECT strftime('%w', DATE_IN) as servdayofweek from date_day;);
my $sth = $dbh->prepare( $stmt );
my $rv = $sth->execute() or die $DBI::errstr;
if($rv < 0){
   print $DBI::errstr;
}
$select = 0;
while(my @row = $sth->fetchrow_array()) {
 	#print "day of week = ". $row[0] . "\n";
	$select++;
	#Create @day
	push(@day,$row[0]);
	
	if(($row[0] == 0) || ($row[0] == 6)){
		#Create @type of day= work = 1, weekend = 0
		push(@type,0);
	}
	else{
		push(@type,1);	
	}
}
print "Operations done successfully\n";
#print "Number of records:$rec\nNumber of records selected:$select\n";

#PRINT IN A FILE
#print F2 "Code\tHour\tMinute\tRecord\tYear\tMonth\tDate\tType\tDay\tSeason\n";

print F2 "Code\tArea\tAge\tHour\tMinute\tRecord\tYear\tMonth\tDate\tType\tDay\tSeason\n";
for($i=0;$i<scalar@int_records;$i++){
	@parts = split(",",$int_records[$i]);
	
	#Create @records
	for ($k=3;$k<scalar@parts;$k++){
		$parts[$k] =~ s/\n//g;
		push(@records,$parts[$k]);	
	}
	
	#Print
	for($j=0;$j<scalar@records;$j++){
		print F2 "$parts[0]\t$parts[1]\t$parts[2]\t$hour[$j]\t$minute[$j]\t$records[$j]\t$yearly[$j]\t$monthly[$j]\t$dately[$j]\t$type[$j]\t$day[$j]\t$seasonality[$j]\n";
	}

	#Flush @records
	@records = ();
}
print scalar@records."\n";

#delete
my $stmt = qq(DROP TABLE date_day;);
	my $rv = $dbh->do($stmt);
	if( $rv < 0 ){
   		print $DBI::errstr;
	}else{
   		print "Table date_day deleted\n";
	}
}

