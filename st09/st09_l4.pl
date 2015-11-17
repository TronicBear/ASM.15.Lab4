
package ST09;
use strict;


use LWP::UserAgent;
use Encode qw(encode decode);
my $flag=0;
my $StudentNunber=3;#$global->{student};

my @temp_arr_obj=();



sub print_obj
{
	print "Name:".$_[0]->{NAME};
	print "\nFamily:". $_[0]->{FAMILY};
	print "\nAddress:". $_[0]->{ADDRESS}."\n";
}
sub crt_obj
{

	my $record = {
		NAME =>"",
		FAMILY => "",
		ADDRESS => ""
	};
	if(!($_[0] && $_[1] && $_[2])){
		print "Enter customer's Name:";
		chomp(my $name=<STDIN>);
		print "Enter customer's Family:";
		chomp(my $family=<STDIN>);
		print "Enter customer's Address:";
		chomp(my $address=<STDIN>);
		$record->{NAME}=$name;
		$record->{FAMILY}=$family;
		$record->{ADDRESS}=$address;
	
	}else
	{
		$record->{NAME}=$_[0];
		$record->{FAMILY}=$_[1];
		$record->{ADDRESS}=$_[2];
	}
	return (\$record);
}
sub add_obj
{	
	push(@temp_arr_obj ,crt_obj());
	print "\nObject has been added\n";	
}
sub edit_obj
{
	print "Enter number of customer:";
	chomp(my $id=<STDIN>);
	if($id>0 && $temp_arr_obj[$id-1]){
		$temp_arr_obj[$id-1]=crt_obj();
	}else{
		print "There is no such element!\n";
	}
}
sub del_obj
{
	print "Enter number of customer:";
	chomp(my $id=<STDIN>);
	if($id>0 && $temp_arr_obj[$id-1]){
		splice (@temp_arr_obj,$id-1,1);
		print "\nObject has been deleted\n";	
	}else{
		print "There is no such element!\n";
	}
}

sub print_list
{
	my $id=1;
	if(@temp_arr_obj>0)
	{
		for my $i (@temp_arr_obj)
		{
			print "Customer [$id]\n";
			print_obj($$i);
			print "\n";
			++$id;
		}
	}else{
		print "List is empty:(\n";
	}
}

sub save_list {
	print "Enter name of file to save:";
	chomp(my $file_out=<STDIN>);
	my %hash;
	my $id=0;
	dbmopen(%hash, $file_out,0644);
	for my $i (@temp_arr_obj)
	{	
		$hash{$id} = join('#%', $$i->{NAME},$$i->{FAMILY},$$i->{ADDRESS});
		++$id;
	}
	dbmclose(%hash);
	print "file $file_out has been saved\n";	
}

sub load_list {
	print "Enter name of file to open:";
	chomp(my $file_in=<STDIN>);
	dbmopen(my %hash, $file_in, 0644) || die "Load error!\n";
	if(!%hash){
		print "File is empty\n";
	}
	@temp_arr_obj=();

	while((my $key, my $value)=each %hash){	
		my ($name, $family, $address) = split(/#%/, $value);
		push(@temp_arr_obj,crt_obj($name,$family,$address));
	}
	dbmclose(%hash);
	print "file has $file_in been loaded\n";	
};

sub exit_pm{
	print "Goodbye\n";
	return 1;

}

sub encode {
	my ($result) = @_;
	Encode::from_to($result,'cp866','cp1251');
	return $result;
}

sub push_to_lab3{
	my $UsrAg=LWP::UserAgent->new;

	if(@temp_arr_obj==0){
		print "Nothing to send( \n";
	}else{
		for my $i (@temp_arr_obj)
		{
			$UsrAg->post( 
				"http://localhost/ASM.15.Lab3/lab3.cgi",
				{
					'student' => 3,
					'Name' => encode($$i->{NAME}),
					'Family' => encode($$i->{FAMILY}),
					'Address' => encode($$i->{ADDRESS}),					
					'Action' => 'add'
				}
			);
		}
		print "data has been sent";
	}

}
my @action=(
	\&exit_pm,
	\&add_obj,
	\&edit_obj,
	\&del_obj,
	\&print_list,
	\&save_list,
	\&load_list,
	\&push_to_lab3
);

sub menu
{
	if($flag==0)
	{
	$flag=1;
	print
	q{

            .---.
            |[X]|
     _.==._.""""".___n__
    d __ ___.-''-. _____b
    |[__]  /."""".\\ _   |
    |     // /""\\ \\\_)  |
    |     \\\ \\__/ //    |
    |      \\`.__.'/     |
    \\=======`-..-'======/
     `-----------------'  
};


}
	print
q{==============================
 1. Add contact               |
 2. Edit contact              |
 3. Delete contact            |
 4. Print contact List        |
 5. Save contact List         |
 6. Read contact List         |
 7. Send to Lab 3             |
 0. Exit                      |
==============================};
	print"\n";
}


sub st09
{
	
	while(1)
	{
		menu();
		print "\nEnter command:";
		chomp(my $ch=<STDIN>);

		if($ch =~/[0-7]/ && @action[$ch]){
			@action[$ch]->();
			if($ch==0){
				return 1;
			}			
			print "\n\n";
		}else {
			print "There is no such operation!\n\n"
		}

			
	}

	
}

st09();