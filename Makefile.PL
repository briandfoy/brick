# $Id$
use ExtUtils::MakeMaker;

require 5.008;

eval "use Test::Manifest 1.14";

WriteMakefile(
	'NAME'	       => 'Brick',
	'VERSION'      => '0.226_02',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
	'PREREQ_PM'    => { 
		'Test::Data'     => '0',
		'Test::More'     => '0',
		'Test::Output'   => '0',
		'DateTime'       => '0.36',
		'Test::Manifest' => '1.14',
		'Storable'       => '0',
		},

	'PM'           => {
		'lib/Brick.pm'        => '$(INST_LIBDIR)/Brick.pm',
		'lib/Bucket.pm'       => '$(INST_LIBDIR)/Brick/Bucket.pm',

		'lib/Profile.pm'      => '$(INST_LIBDIR)/Brick/Profile.pm',

		'lib/Composers.pm'    => '$(INST_LIBDIR)/Brick/Composers.pm',
		'lib/Numbers.pm'      => '$(INST_LIBDIR)/Brick/Numbers.pm',
		'lib/Strings.pm'      => '$(INST_LIBDIR)/Brick/Strings.pm',
		'lib/Regexes.pm'      => '$(INST_LIBDIR)/Brick/Regexes.pm',
		'lib/Dates.pm'        => '$(INST_LIBDIR)/Brick/Dates.pm',
		'lib/General.pm'      => '$(INST_LIBDIR)/Brick/General.pm',
		'lib/Files.pm'        => '$(INST_LIBDIR)/Brick/Files.pm',

		'lib/Constraints.pm'  => '$(INST_LIBDIR)/Brick/Constraints.pm',

		'lib/Filters.pm'      => '$(INST_LIBDIR)/Brick/Filters.pm',

		'lib/Selectors.pm'    => '$(INST_LIBDIR)/Brick/Selectors.pm',

		'lib/Result.pm'       => '$(INST_LIBDIR)/Brick/Result.pm',
		'lib/Result-Item.pm'  => '$(INST_LIBDIR)/Brick/Result/Item.pm',

		'lib/Tutorial.pm'     => '$(INST_LIBDIR)/Brick/Tutorial.pm',
		'lib/UserGuide.pm'    => '$(INST_LIBDIR)/Brick/UserGuide.pm',
		},

	clean  => { FILES    => q|Brick-*| },

	);
