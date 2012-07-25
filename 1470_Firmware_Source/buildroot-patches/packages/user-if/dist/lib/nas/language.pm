
package nas::language;

use Exporter;
@ISA=qw(nasCore);

use strict;
use nasCommon ;

sub main($$$) {

	my ($self, $cgi, $config) = @_;

	if ($cgi->param('submit')) {

		# Update the laguage setting
		# Check for language file available.
		my $langFile = nasCommon->nas_lib . '/' . $cgi->param('lang') . 'NasLanguage.pm' ;
		if ( -r $langFile || $cgi->param('lang') eq 'en' ) {

			$self->{lang}=$cgi->param('lang');
			# check language file available before committing 
			$config->setval('general', 'language', $self->{lang} );
			unless ($config->RewriteConfig) {
				$self->fatalError($config, 'f00003');
				return;
			}
			print $cgi->redirect('/home.pl');
			$self->outputTemplate('home.tpl', { tabon => 'home' } );
		}
		else {
			$self->fatalError($config, 'f00000');
			return;
		}
	} else {
		$self->outputTemplate('language.tpl', { tabon => 'home' } );
	}

}

1;
