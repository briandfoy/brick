# $Id$
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";

WriteMakefile(
	'NAME'	       => 'Brick',
	'VERSION_FROM' => 'lib/Brick.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
q	'PREREQ_PM'    => { 
		'Test::More' => '0',
		'DateTime'   => '0.36',
		},

	'PM'           => {
		'lib/Brick.pm'        => '$(INST_LIBDIR)/Brick.pm',
		'lib/Bucket.pm'       => '$(INST_LIBDIR)/Brick/Bucket.pm',
		'lib/Composers.pm'    => '$(INST_LIBDIR)/Brick/Composers.pm',
		'lib/Numbers.pm'      => '$(INST_LIBDIR)/Brick/Numbers.pm',
		'lib/Strings.pm'      => '$(INST_LIBDIR)/Brick/Strings.pm',
		'lib/Regexes.pm'      => '$(INST_LIBDIR)/Brick/Regexes.pm',
		'lib/Dates.pm'        => '$(INST_LIBDIR)/Brick/Dates.pm',
		'lib/General.pm'      => '$(INST_LIBDIR)/Brick/General.pm',
		'lib/Constraints.pm'  => '$(INST_LIBDIR)/Brick/Constraints.pm',
		'lib/Filters.pm'      => '$(INST_LIBDIR)/Brick/Filters.pm',
		'lib/Selectors.pm'    => '$(INST_LIBDIR)/Brick/Selectors.pm',
		},

	clean  => { FILES    => q|Brick-*| },

	);
