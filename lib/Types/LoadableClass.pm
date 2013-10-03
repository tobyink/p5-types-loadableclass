use 5.006001;
use strict;
use warnings;

package Types::LoadableClass;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.002';

use Type::Library
	-base,
	-declare => qw( ModuleName LoadableClass LoadableRole );

use Type::Utils -all;
use Types::Standard qw( StrMatch RoleName );

use Module::Runtime qw($module_name_rx is_module_name);
use Class::Load qw(load_optional_class is_class_loaded);

declare ModuleName,
	as StrMatch[ qr/\A$module_name_rx\z/ ],
	message {
		"'$_' is not a valid module name";
	};

declare LoadableClass,
	as ModuleName,
	where {
		load_optional_class($_)
	}
	inline_as {
		(undef, "Class::Load::load_optional_class($_)");
	}
	message {
		ModuleName->validate($_) or "'$_' could not be loaded";
	};

declare LoadableRole,
	as intersection([ LoadableClass, RoleName ]),
	message {
		LoadableClass->validate($_) or "'$_' is not a loadable role";
	};

1;

__END__

=pod

=encoding utf-8

=for stopwords Mannsåker

=head1 NAME

Types::LoadableClass - type constraints with coercion to load the class

=head1 SYNOPSIS

   package MyClass;
   use Moose;  # or Mouse, or Moo, or whatever
   use Types::LoadableClass qw/ LoadableClass /;
   
   has foobar_class => (
      is       => 'ro',
      required => 1,
      isa      => LoadableClass,
   );
   
   MyClass->new(foobar_class => 'FooBar'); # FooBar.pm is loaded or an
                                           # exception is thrown.

=head1 DESCRIPTION

A L<Type::Tiny>-based clone of L<MooseX::Types::LoadableClass>.

This is to save yourself having to do this repeatedly...

  my $tc = subtype as ClassName;
  coerce $tc, from Str, via { Class::Load::load_class($_); $_ };

Despite the abstract for this module, C<LoadableClass> doesn't actually
have a coercion, so no need to use C<< coerce => 1 >> on the attribute.
Rather, the class gets loaded as a side-effect of checking that it's
loadable.

=head2 Type Constraints

=over

=item C<< ModuleName >>

A subtype of C<Str> (see L<Types::Standard>) representing a string that
is a valid Perl package name (according to L<Module::Runtime>).

=item C<< LoadableClass >>

A subtype of C<ModuleName> that names a module which is either already
loaded (according to L<Class::Load>), or can be loaded (by
L<Class::Load>).

=item C<< LoadableRole >>

A subtype of C<LoadableClass> that names a module which appears to be
a role rather than a class.

(Because this type constraint is designed to work with Moose, Mouse,
Moo, or none of the above, it can't rely on the features of any
particular implementation of roles. Therefore is needs to use a
heuristic to detect whether a loaded package represents a role or not.
Curently this heuristic is the absence of a method named C<new>.)

=back

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Types-LoadableClass>.

=head1 SEE ALSO

L<Types::Standard>, L<MooseX::Types::LoadableClass>, L<Class::Load>,
L<Module::Runtime>.

=head1 AUTHOR

Dagfinn Ilmari Mannsåker E<lt>ilmari@ilmari.orgE<gt>.

Improvements and packaging by Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Dagfinn Ilmari Mannsåker,
Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

