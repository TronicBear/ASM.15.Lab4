#!/usr/bin/perl

use strict;

use st01::st01;
use st02::st02;
use st03::st03;
use st04::st04;
use st06::st06;
use st07::st07;
use st11::st11;
use st18::st18;
use st19::st19;
use st22::st22;
use st24::st24;
use st28::st28;
use st29::st29;
use st31::st31;
use st32::st32;
use st37::st37;
use st39::st39;
use st42::st42;
use st45::st45;
use st46::st46;

my @MODULES =
(
	\&ST01::st01,
	\&ST02::st02,
	\&ST03::st03,
	\&ST04::st04,
	\&ST06::st06,
	\&ST07::st07,	
	\&ST11::st11,
	\&ST18::st18,
	\&ST19::st19,
	\&ST22::st22,
	\&ST24::st24,
	\&ST28::st28,
	\&ST29::st29,
	\&ST31::st31,
	\&ST32::st32,
	\&ST37::st37,
	\&ST39::st39,
	\&ST42::st42,
	\&ST45::st45,
	\&ST46::st46,	
);

my @NAMES =
(
	"01. Baglikova",
	"02. Badrudinova",
	"03. Baranov",
	"04. Borisenko",
	"06. Goncharov",
	"07. Gorinov",
	"11. Drojjin",
	"18. Klykov",
	"19. Konstantinova",
	"22. Lomakina",
	"24. Mamedov",
	"28. Nikolaeva",
	"29. Novozhentsev",
	"31. Podkolzin",
	"32. Pyatakhina",
	"37. Stankevich",
	"39. Stupin",
	"42. Umnikov",
	"45. Yazkov",
	"46. Bushmakin",
);

sub menu
{
	my $i = 0;
	print "\n------------------------------\n";
	foreach my $s(@NAMES)
	{
		print "$i. $s\n";
		$i++;
	}
	print "------------------------------\n";
	my $ch = <STDIN>;
	return ($ch);
}

while(1)
{
	my $ch = menu();
	if(defined $MODULES[$ch])
	{
		print $NAMES[$ch]." launching...\n\n";
		$MODULES[$ch]->();
	}
	else
	{
		exit();
	}
}
