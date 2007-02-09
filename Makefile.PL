# $Id$
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";

WriteMakefile(
	'NAME'	       => 'Beancounter',
	'VERSION_FROM' => 'lib/Beancounter.pm',
	'LICENSE'      => 'perl',
	
	'PREREQ_PM'    => { 
		'Test::More' => '0',
		},

	'PM'           => {
		'lib/Beancounter.pm'  => '$(INST_LIBDIR)/Beancounter.pm',
		'lib/Pool.pm'         => '$(INST_LIBDIR)/Beancounter/Pool.pm',
		'lib/Composers.pm'    => '$(INST_LIBDIR)/Beancounter/Composers.pm',
		'lib/Numbers.pm'      => '$(INST_LIBDIR)/Beancounter/Numbers.pm',
		'lib/Strings.pm'      => '$(INST_LIBDIR)/Beancounter/Strings.pm',
		'lib/Regex.pm'        => '$(INST_LIBDIR)/Beancounter/Regex.pm',
		'lib/Date.pm'         => '$(INST_LIBDIR)/Beancounter/Date.pm',
		'lib/General.pm'      => '$(INST_LIBDIR)/Beancounter/General.pm',
		'lib/Constraints.pm'  => '$(INST_LIBDIR)/Beancounter/Constraints.pm',
		'lib/Filters.pm'      => '$(INST_LIBDIR)/Beancounter/Filters.pm',
		},

	clean  => { FILES    => q|Beancounter-*| },

	);
