package File::Find::Rule::DIZ;

use strict;
use File::Find::Rule;
use base qw( File::Find::Rule );
use vars qw( @EXPORT $VERSION );

@EXPORT  = @File::Find::Rule::EXPORT;
$VERSION = '0.02';

use Archive::Zip;
use Archive::Zip::MemberRead;

sub File::Find::Rule::diz {
	my $self = shift()->_force_object;

	# Procedural interface allows passing arguments as a hashref.
	my %criteria = UNIVERSAL::isa($_[0], "HASH") ? %{$_[0]} : @_;

	$self->exec( sub {
		my $file   = shift;

		return unless -B $file;

		my $zip = Archive::Zip->new();
		return unless $zip->read( $file ) == 0;

		my $member = $zip->memberNamed('FILE_ID.DIZ');

		my $diz    = '';
		
		if ( defined $member ) {
			my $line;
			my $fh = $member->readFileHandle();
			$diz  .= "$line\n" while (defined($line = $fh->getline()));
		}

		return unless $diz =~ $criteria{text};

		return 1;
	} );
}

1;

=pod

=head1 NAME

File::Find::Rule::DIZ - Rule to match the contents of a FILE_ID.DIZ

=head1 SYNOPSIS

	use File::Find::Rule::DIZ;

	my @files = find( diz => { text => qr/stuff and things/ }, in => '/archives' );

=head1 DESCRIPTION

This module will search through a ZIP archive, specifically the contents of the FILE_ID.DIZ
file in the archive.

=head1 METHODS

	my @files = find( diz => { text => qr/stuff and things/ }, in => '/archives' );

For now, all you can do is search the text using a regex. Yehaw.

=head1 BUGS

If you have any questions, comments, bug reports or feature suggestions, 
email them to Brian Cassidy <brian@alternation.net>.

=head1 CREDITS

This module was written by Brian Cassidy (http://www.alternation.net/). It borrows heavily
from File::Find::Rule::MP3Info.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms
of the Artistic License, distributed with Perl.

=head1 SEE ALSO

	File::Find::Rule
	File::Find::Rule::MP3Info

=cut