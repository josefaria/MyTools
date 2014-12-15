#!/usr/bin/perl
## -----------------------------------------------------------------------------------------
##
## dr - Disk Report
##
##  purpose: Search partions on machine and generate a report with total/free/occupied space for each partition.
##           This report is sent by email.
##
##  version: 0.1 (2014)
##
##  Jose Luis Faria, jose@di.uminho.pt,joseluisfaria@gmail.com
##  Universidade do Minho, Braga, Portugal
##
##
## -----------------------------------------------------------------------------------------

use strict;
use warnings;
use Net::Domain qw(hostname hostfqdn hostdomain);


## -----------------------------------------------------------------------------------------
##
##  definitions all here!
##
## -----------------------------------------------------------------------------------------

# email to and from
my $email_from="tecnicos\@di.uminho.pt";
my $email_to="jose\@di.uminho.pt,aaragao\@di.uminho.pt";
my $search_patern="[^/dev/|^/mnt/]";

# treshold alarm 90%
my $treshold=90;
#


## -----------------------------------------------------------------------------------------
##
##                      stop your definitions here !
##
## -----------------------------------------------------------------------------------------




## -----------------------------------------------------------------------------------------
##
##                      let's work!
##
## -----------------------------------------------------------------------------------------

my $version='0.1';
my $copyright1='Universidade do Minho - Braga';
my $copyright2='Portugal';
my $host = hostfqdn();
my $report_hour='';
my @month=qw.January February March April May June July August September October November December.;
my @dayofweek=qw.Sunday Monday Tueday Wednesday Thurday Friday Saturday Sunday.;
# variaveis a usar na TAREFA 1
my $comando='';
my @parcelas=();
my $percentagem = 0;
my $mensagem = "<hr><h4>report about disk partitions</h4>\n<hr>\n";
my $mensagem_parte = "";
my $num_parcelas=0;
my $indice=0;
my $particao='';
my $espaco='';
my $ocupa='';
my $ocupa_percentagem='';
my $livre='';
my $caminho='';
my $i=0;

# TAREFA 1
# fazer levantamento do estado do disco
$comando="df -Ph | grep \"$search_patern\" |";
open(DSK,$comando);
$mensagem .= "<table class=\"report\">\n";
$mensagem .= "<tr><th>partition</th><th>space</th><th>used</th><th>% used</th><th>% alarm</th><th>free</th><th>path</th></tr>\n";
while (<DSK>) {
	if ($_ =~ /Size  Used Avail/) {
		next;
	}
	chomp($_);
	$_ =~ s/(\s)+/ /g;
	#print $_;exit(0);
	@parcelas=split(/ /,$_);

	$num_parcelas=@parcelas;
	$indice=$num_parcelas-1;
	$caminho=$parcelas[$indice];
	$ocupa_percentagem=$parcelas[$indice-1];
	$livre=$parcelas[$indice-2];
	$ocupa=$parcelas[$indice-3];
	$espaco=$parcelas[$indice-4];
	$ocupa_percentagem =~ s/%//; 

	$particao='';
	for($i=0;$i<($indice-4);$i++) {
		$particao = $particao . $parcelas[$i];
	}

	if ($ocupa_percentagem>=$treshold) {
		$mensagem_parte .="<tr class=\"alarm\">\n";
		$mensagem_parte .= "<td><b>$particao</b></td><td align=\"right\"><b>$espaco</b></td><td align=\"right\"><b>$ocupa</b></td><td align=\"right\"><b>$ocupa_percentagem%</b></td><td align=\"right\"><b><blink>$treshold%</blink></b></td><td align=\"right\"><b>$livre</b></td><td><b>$caminho</b></td></tr>\n";
	} else {
		$mensagem_parte .="<tr>\n";
		$mensagem_parte .= "<td>$particao</td><td align=\"right\">$espaco</td><td align=\"right\">$ocupa</td><td align=\"right\">$ocupa_percentagem%</td><td align=\"right\">$treshold%</td><td align=\"right\">$livre</td><td>$caminho</td></tr>\n";
	}
}
$mensagem .= "" . $mensagem_parte;
$mensagem .= "</table>\n";

#
# prepare report to send
#
# ---------------------------------------------------------------------------------------------------

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
$year += 1900;
$min =sprintf("%02d",$min);
$hour =sprintf("%02d",$hour);
$mday =sprintf("%02d",$mday);
$mon =sprintf("%02d",$mon);

my $subject="Disk Report on ($dayofweek[$wday]) $month[$mon] $mday, $year at $hour:$min";

open(MAIL,"|/usr/sbin/sendmail -t");

## Mail Header
print MAIL "To: $email_to\n";
print MAIL "From: $email_from\n";
print MAIL "Subject: $subject\n";
print MAIL "Content-Type: text/html; charset=ISO-utf8\n\n";
## Mail Body
print MAIL "<html><head>\n";
print MAIL "<style>\n";
print MAIL "table.report {\n";
print MAIL "  border: 1px solid #5F5A59;\n";
print MAIL "  border-collapse: collapse;\n";
print MAIL "}\n";
print MAIL "table.report th {\n";
print MAIL "  border: 1px solid #5F5A59;\n";
print MAIL "  text-align: center;\n";
print MAIL "  background-color: #D0D0D0;\n";
print MAIL "  padding: 3px 5px 3px 3px;\n";
print MAIL "}\n";
print MAIL "table.report td {\n";
print MAIL "  border: 1px solid #5F5A59;\n";
print MAIL "}\n";
print MAIL "table.report td.alarm {\n";
print MAIL "	color: #FFFFFF;\n";
print MAIL "}\n";
print MAIL "table.report tr.alarm {\n";
print MAIL "  background-color: #F88017;\n";
print MAIL "}\n";
print MAIL "</style>\n\n";
print MAIL "</head><body>\n";

# cabecalho da mensagem
print MAIL "<h3>Disk Report : $host</h3>";

# corpo da mensagem
print MAIL $mensagem;

# message foot
print MAIL "<br><br><br>\n";
print MAIL "<hr>\n";
print MAIL "dr-Disk Report v. $version<br>\n";
print MAIL "&copy; $copyright1<br>\n";
print MAIL "$copyright2<br>\n";
print MAIL "\n</body>\n</html>\n";
close(MAIL);