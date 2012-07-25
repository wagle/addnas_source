
package nas::backup;

use Exporter;
@ISA=qw(nasCore);

use strict;
use nasCommon;

sub main($$$) {
	
	my ($self, $cgi, $config) = @_;

	my $volroot = "/shares/external";

	my $script = "/etc/init.d/tsi-archiver";
	my $restore_id = $cgi->param('restore_id');
	my $backup_id = $cgi->param('backup_id');
	my $delete_id = $cgi->param('delete_id');
	my $comments = $cgi->param('backup_comment');
	my $volume = $cgi->param('backup_volume');
	my $new_backup = $cgi->param('new_backup');
	my $barevol = $volume;
	if(!$volume){
		my @vols = ();
		listExternals(\@vols);
		$volume = $vols[0]->{path};
	}
        
	$volume = $volroot."/".$volume;

	if($restore_id){
		###WAGLE### the archiver kills network services (and thus the webserver)
		sudo("$script $volume restore $restore_id");
                sudo("/sbin/reboot");
		sleep(60);
	}elsif($new_backup){
		sudo("$script $volume init");
		sudo("$script $volume backup \"$comments\"");
	}elsif($delete_id){
		sudo("$script $volume delete $delete_id");
	}


	my $table = "<table>\n";
	$table .= "<tr>\n<th>Volume</th><th>Backups</th></tr>\n";
	$table .= "<tr>\n<td>".$self->getExternalsHTML($config,$barevol) . "</td>\n<td>\n";
	
	my @options = ();	
	open(CMD, "$script $volume list |");
	while (<CMD>){
  		chomp;
  		my ($id, $comment) = split (/\t/);
		my ($date,$time) = split /\-/, $id;
		my $fdate = substr($date,0,4).'-'.substr($date,4,2).'-'.substr($date,6,2);
		push @options, "<option value=\"$id\">$fdate $comment</option>";
	}
	close(CMD);
	if(@options){
		$table .= "<select id=\"backup_id\">\n";
		$table .= join "\n", @options;
		$table .= "\n</select>\n";
	}else{
	 	$table .= "(No backups found)";
	}
	$table .= "</td>\n</tr>\n";

	#Restore & Delete buttons
	if(@options){
		$table .= "<tr>\n<td></td>\n<td align=\"right\" nowrap=\"nowrap\"><input type=\"button\" value=\"Restore Selected\" onClick=\"restore_backup()\">";
		$table .= "<input type=\"button\" value=\"Delete Selected\" onClick=\"delete_backup()\"></td>\n</tr>\n";
	}
	#New backup
	$table .= "<tr>\n<td nowrap=\"nowrap\" colspan=\"3\"><br><br>New Backup Comments: <input type=\"textarea\" size=\"30\" id=\"backup_comment\">";
	$table .= "<input type=\"button\" value=\"Create Backup\" onClick=\"new_backup()\"></td>\n</tr>\n";
	$table .= "</table>\n";
	$self->outputTemplate('backup.tpl', {tabon => 'general', backup_table => $table, volume => $volume, backup_id => $backup_id, delete_id => $delete_id, restore_id => $restore_id, comments => $comments});
}

sub getExternalsHTML{
	my ($self,$config,$vol) = @_;
	my $ret = "";
	my @vols = ();
	unless (listExternals(\@vols)) {
		$self->fatalError($config, 'f00026');
		return;
	}

	$ret = "<select id=\"backup_volume\" onchange=\"openVolume(this.options[this.selectedIndex].value)\">\n";
	for my $ext (@vols){
		if($ext->{path} eq $vol){
			$ret .= "<option value=\"$ext->{path}\" selected=\"selected\">$ext->{prefix} $ext->{path}</option>\n";
		}else{
			$ret .= "<option value=\"$ext->{path}\">$ext->{prefix} $ext->{path}</option>\n";
		}
	}
	$ret .= "</select>\n";
	return $ret;
}

1;
