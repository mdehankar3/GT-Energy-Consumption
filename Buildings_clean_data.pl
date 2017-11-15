#!/usr/bin/perl

use strict;
use warnings;
use File::chdir;
open(FH,"info1.txt");
my $title=<FH>;
my %age;my %area;my %category;
while(my $line=<FH>)
{
	chomp($line);
	my @parts=split("\t",$line);
	$area{$parts[1]}=$parts[4];
	$category{$parts[1]}=$parts[7];
	my @date1=split(" ",$parts[5]);
	my @date2=split(/\//,$date1[0]);
	#calculate age
	if($date2[2]> 100)
	{
		$age{$parts[1]}= $date2[2];
	}
	if($date2[2]> 17 && $date2[2] < 100)
	{
		$age{$parts[1]}=( (100 -$date2[2]) + 17 );
	}
	if($date2[2] < 17)
	{
		$age{$parts[1]}=( 17 - $date2[2] );	
	}
}
close(FH);
#________________________________________________________________________________________________________________________________________

my @files=`ls -d *`;
for(my $i=0;$i<scalar(@files);$i++)
{
	chomp($files[$i]); my $f = $files[$i];
	my @parts =split ' ',$files[$i]; print "found Building : $parts[-1]\n";
	if($parts[-1] ne "test.pl" && $parts[-1] ne "test2.pl" &&  $parts[-1] ne "test3.pl" && $parts[-1] ne "info1.txt" && $parts[-1] ne "info.txt") 
	{
		
		$CWD="/home/aditi/Desktop/DVA_project/DVA_Data1/$f";
		if(exists $area{$parts[-1]})
		{
			print "Processing Building $parts[-1]\n";
			`rm all.csv`;
			my @file =`ls -1 *.csv`;
			my %vals; my %rm_repeat;
			my $head; my %repeat_no; my %timestamp;
			my $count=0;my @first;my @second;
			my $area1=$area{$parts[-1]};my $age1=$age{$parts[-1]}; print "The age is $age1\n";
			for(my $i=0;$i<scalar(@file);$i++)
			{
				chomp($file[$i]);
				my $f1=$file[$i];
				my $count_line=0;
				open(FH,"$f1");
				$head=<FH>;chomp($head);chomp($head);
				#print "$head\n";
				while(my $line=<FH>)
				{
					chomp($line);
					my @parts=split(",",$line);
					if(exists $rm_repeat{$parts[0]}) {$rm_repeat{$parts[0]} +=$parts[2]; $repeat_no{$parts[0]}++;
				}
					else {$rm_repeat{$parts[0]} += $parts[2];$repeat_no{$parts[0]}++; $timestamp{$parts[0]}=$parts[1];}
					$count_line++;
				}
				$count++;
				foreach (keys %repeat_no)
				{
					if($repeat_no{$_} >1)
					{
						$rm_repeat{$_} = $rm_repeat{$_}/$repeat_no{$_};
					}
					$vals{$_} += $rm_repeat{$_};
				}
				%repeat_no=();%rm_repeat=();
				close(FH);
			}
			open(FT,">all.csv");
			print FT "Time,$parts[-1]\n";
			foreach (sort keys %vals)
			{
				$vals{$_}=$vals{$_}/$area1;
				$vals{$_}=sprintf "%.6f" ,$vals{$_};
				print FT "$timestamp{$_},$vals{$_}\n";
			}
			
		}
	}
	
}
close(FH);
close(FT);
#___________________________________________________________________________________________________________________________________________

open(FH,"info1.txt");
my $head=<FH>;
%age=();%area=();%category=();
while(my $line=<FH>)
{
	chomp($line);
	my @parts=split("\t",$line);
	$area{$parts[1]}=$parts[4];
	$category{$parts[1]}=$parts[7];
	my @date1=split(" ",$parts[5]);
	my @date2=split(/\//,$date1[0]);
	#calculate age
	if($date2[2]> 100)
	{
		$age{$parts[1]}= $date2[2];
	}
	if($date2[2]> 17 && $date2[2] < 100)
	{
		$age{$parts[1]}=( (100 -$date2[2]) + 17 );
	}
	if($date2[2] < 17)
	{
		$age{$parts[1]}=( 17 - $date2[2] );	
	}
}
close(FH);
#____________________________________________________________________________________
@files=();
@files=`ls -d *`; my $name;
for(my $i=0;$i<scalar(@files);$i++)
{
	chomp($files[$i]); my $f = $files[$i];
	my @parts =split ' ',$files[$i];
	if($parts[-1] ne "test.pl" && $parts[-1] ne "test2.pl" && $parts[-1] ne "test3.pl"&& $parts[-1] ne "info.txt" && $parts[-1] ne "info1.txt" && $parts[-1] ne "files.txt" && $files[$i] ne "all.csv") 
	{
		print "processing folder $f\n";
		$CWD="/home/aditi/Desktop/DVA_project/DVA_Data1/$f";
		if(exists $area{$parts[-1]})
		{
			`cp all.csv ../`;
		}
		$CWD="/home/aditi/Desktop/DVA_project/DVA_Data1";
	}
if ($category{$parts[-1]} eq "ACADI&R")
{
	 $name="ACAD.$parts[-1].csv";
}
else
{
	$name="$category{$parts[-1]}.$parts[-1].csv";
}
`mv all.csv $name`;
my $pwd =`pwd`;
print "$pwd\n";
}

#______________________________________________________________________________________________________________________________

@files=();
@files=`ls *.csv`;
my $count=0;
open(FK,">All_buildings.csv");
for(my $i=0;$i<scalar(@files);$i++)
{
	chomp($files[$i]); my $f1=$files[$i];
	open(FH,"$f1");
	if ($count==0)
	{
		while(my $line=<FH>)
		{
			chomp($line);
			print FK "$line\n";
		}
	}
	else 
	{
		my $head =<FH>;
		while(my $line=<FH>)
		{
			chomp($line);
			print FK "$line\n";
		}
	}
$count++;	
}
