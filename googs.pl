# Dumping old code - 2006
# http://www.infointox.net/?paged=21
# monitors google not needed anymore. 
# googs.pl
# 
#!/usr/bin/perl
 
use strict;     
use SOAP::Lite;
use MIME::Lite;
use Net::SMTP;
use Cal::Date qw(DJM MJD today);
 
#Get Todays Date
my $date = today();
 
#convert to julian
my $jul_today= DJM($date);
 
#Put Your Google API Key Here
my $google_key='your_google_key_here';
 
#Google WSDL File Location
my $google_wsdl = "./GoogleSearch.wsdl";
 
#Put querys here, escape any "'s with \" 
my $query;
my @query = ("company + hacking",
	     "allintext:company + hacking",
             "your querys"
	     );
 
 
#assign current julian date to query
my $goog_daterange = " + daterange:".$jul_today."-".$jul_today;
 
#SOAP::Lite instance with GoogleSearch.wsdl.
my $google_soap = SOAP::Lite-&gt;service("file:$google_wsdl");
 
 
#Set Up Mail Vars
my $faddy = 'from_address@blah.com';
my $taddy = 'to_address@blah.com';
my $mail_host = 'your_mail_host';
 
my $subject = "New Information Posted!";
my $msg_body ="";
 
#Its Google Time
 
#Loop Through Array of Querys
foreach $query (@query){
 
	#add daterange: operator to curren query
	my $query_date=$query.$goog_daterange;
 
	my $results = $google_soap -&gt; 
    		doGoogleSearch(
      			$google_key, $query_date , 0, 10, "false", "",  "false",
      			"", "latin1", "latin1"
    		);
 
	# Exit On No Results
	@{$results-&gt;{resultElements}} or exit;
 
	# Loop Results and Output to HTML
	foreach my $result (@{$results-&gt;{resultElements}}) {
 
        #had to take brackets out for this post for the html breaks and lines
	$msg_body .= "br".
  		      $result-&gt;{'title'}."br".
  		      "a href=".$result-&gt;{URL}."&gt;".$result-&gt;{URL}."/a br".
  		      $result-&gt;{snippet}.
		      "
hr";
 
	}
}
#Setup Message
 
my $msg=MIME::Lite-&gt;new (
        From =&gt; $faddy,
        To =&gt; $taddy,
        Subject =&gt; $subject,
	Type =&gt; 'TEXT/HTML',
	Encoding =&gt; 'quoted-printable',
	Data =&gt; $msg_body,
)       or die "Could Not Create Msg: $!\n";
 
 
#Send Message
MIME::Lite-&gt;send('smtp', $mail_host, Timeout=&gt;60);
$msg-&gt;send;
