#!/usr/bin/perl
use strict;
use warnings;
use Net::Domain qw(hostname hostfqdn hostdomain);

# ---------------------------------------------------------------------------------------
# esta script faz o levantamento de varios estados do sistema e envia um relatorio
# 

# my version
my $version='1.0';
my $copyright1='Universidade do Minho - Braga';
my $copyright2='Portugal';

# email a quem enviar o relatorio
my $email_origem="tecnicos\@di.uminho.pt";
my $email_destino="jose\@di.uminho.pt,aaragao\@di.uminho.pt";
#my $email_destino="jose\@di.uminho.pt";
my $maquina = hostfqdn();
my $hora='';


#
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
$hora=sprintf("%02d:%02d",$hour,$min);
$year += 1900;
$mon += 1;
my @meses=qw.January February March April May June July August September October November December.;


# variaveis a usar na TAREFA 1
my $padrao_pesquisa="[^/dev/|^/mnt/]";
#my $padrao_pesquisa="^/dev/";
my $comando='';
my $treshold=90;
my @parcelas=();
my $percentagem = 0;
my $mensagem = "<hr><h4>relatório sobre partições no disco</h4>\n<hr>\n";
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
$comando="df -Ph | grep \"$padrao_pesquisa\" |";
open(DSK,$comando);
$mensagem .= "<table class=\"report\">\n";
$mensagem .= "<tr><th>partição</th><th>espaço</th><th>ocupa</th><th>% ocupa</th><th>% alarme</th><th>livre</th><th>caminho</th></tr>\n";
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

	if (($treshold-$ocupa_percentagem)<=10) {
		$mensagem_parte .="<tr class=\"prealarm\">\n";
		$mensagem_parte .= "<td><b>$particao</b></td><td align=\"right\"><b>$espaco</b></td><td align=\"right\"><b>$ocupa</b></td><td align=\"right\"><b>$ocupa_percentagem%</b></td><td align=\"right\"><b><blink>$treshold%</blink></b></td><td align=\"right\"><b>$livre</b></td><td><b>$caminho</b></td></tr>\n";
	} elsif ($ocupa_percentagem>=$treshold) {
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
# preparar relatorio e enviar
#
# ---------------------------------------------------------------------------------------------------
my $subject="Relatório da máquina $maquina no dia $year/$mon/$mday às $hora";
open(MAIL,"|/usr/sbin/sendmail -t");

## Mail Header
print MAIL "To: $email_destino\n";
print MAIL "From: $email_origem\n";
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
print MAIL "table.report tr.prealarm {\n";
print MAIL "  background-color: #CCFF00;\n";
print MAIL "}\n";
print MAIL "table.report tr.alarm {\n";
print MAIL "  background-color: #F88017;\n";
print MAIL "}\n";
print MAIL "</style>\n\n";
print MAIL "</head><body>\n";

# cabecalho da mensagem
print MAIL "<h3>Relatório Global da Máquina $maquina</h3>";
print MAIL "<h4>Data e hora: $year/$mon/$mday às $hora</h4>\n";

# corpo da mensagem
print MAIL $mensagem;

# rodape da mensagem
print MAIL "<br><br><br>\n";
print MAIL "<hr>\n";
print MAIL "Equipa de Administração de Sistemas<br>\n";
print MAIL "Universidade do Minho<br>\n";
print MAIL "Escola de Engenharia<br>\n";
print MAIL "Departamento de Informática<br>\n";
print MAIL "Campus de Gualtar<br>\n";
print MAIL "4710-057 Braga<br>\n";
print MAIL "<br><br>\n";
print MAIL "<hr>\n";
print MAIL "dr-Disk Report v. $version<br>\n";
print MAIL "&copy; $copyright1<br>\n";
print MAIL "$copyright2<br>\n";
print MAIL "\n</body>\n</html>\n";
close(MAIL)
