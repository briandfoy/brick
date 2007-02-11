#!/usr/bin/perl

use Test::More 'no_plan';

my $class = 'Brick';
use_ok( $class );

my $brick = $class->new;
isa_ok( $brick, $class );

my $bucket = $brick->bucket_class->new();
isa_ok( $bucket, $brick->bucket_class );


ok( defined &Brick::Bucket::get_from_bucket_by_name, "Method is defined" );