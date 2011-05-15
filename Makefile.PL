#
# Copyright (c) 2011 by the cairo perl team (see the file README)
#
# Licensed under the LGPL, see LICENSE file for more information.
#

BEGIN { require 5.008; }

use strict;
use warnings;
use ExtUtils::MakeMaker;

our %build_reqs = (
  'perl-ExtUtils-Depends'   => '0.2',
  'perl-ExtUtils-PkgConfig' => '1.0',
  'perl-Cairo'              => '1.062',
  'perl-Glib'               => '1.224',
  'cairo-gobject'           => '1.10.0',
);

our %pre_reqs = (
  'ExtUtils::Depends'   => $build_reqs{'perl-ExtUtils-Depends'},
  'ExtUtils::PkgConfig' => $build_reqs{'perl-ExtUtils-PkgConfig'},
  'Cairo'               => $build_reqs{'perl-Cairo'},
  'Glib'                => $build_reqs{'perl-Glib'},
);

unless (eval "use ExtUtils::Depends '$build_reqs{'perl-ExtUtils-Depends'}';"
           . "use ExtUtils::PkgConfig '$build_reqs{'perl-ExtUtils-PkgConfig'}';"
           . "use Cairo '$build_reqs{'perl-Cairo'}';"
           . "use Glib '$build_reqs{'perl-Glib'}';"
           . "use Glib::MakeHelper;"
           . "1") {
  warn "$@\n";
  WriteMakefile(
    PREREQ_FATAL => 1,
    PREREQ_PM    => \%pre_reqs,
  );
  exit 1; # not reached
}

# If the package can't be found, warn and exit with status 0 to indicate to
# CPAN testers that their system is not supported.
my %pkgcfg;
unless (eval { %pkgcfg = ExtUtils::PkgConfig->find (
                 "cairo-gobject >= $build_reqs{'cairo-gobject'}");
	       1; })
{
	warn $@;
	exit 0;
}

mkdir 'build', 0777;

my $dep = ExtUtils::Depends->new('Cairo::GObject', qw/Cairo Glib/);
$dep->set_inc($pkgcfg{cflags});
$dep->set_libs($pkgcfg{libs});
$dep->add_xs('CairoGObject.xs');
$dep->add_pm('lib/Cairo/GObject.pm' => '$(INST_LIBDIR)/GObject.pm');
$dep->save_config('build/IFiles.pm');

WriteMakefile(
  NAME          => 'Cairo::GObject',
  VERSION_FROM  => 'lib/Cairo/GObject.pm',
  ABSTRACT_FROM => 'lib/Cairo/GObject.pm',
  PREREQ_PM     => \%pre_reqs,
  XSPROTOARG    => '-noprototypes',

  META_MERGE    => {
    configure_requires => \%pre_reqs,
  },

  $dep->get_makefile_vars,
);

sub MY::postamble {
  return Glib::MakeHelper->postamble_clean ();
}
