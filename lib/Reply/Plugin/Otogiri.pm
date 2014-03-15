package Reply::Plugin::Otogiri;
use strict;
use warnings;

use base qw/ Reply::Plugin /;
use Otogiri;
use Otogiri::Plugin;

our $VERSION = "0.01";
our @METHODS = qw/
    INSERT
    FAST_INSERT
    SELECT 
    SINGLE
    SEARCH_BY_SQL
    UPDATE
    DELETE
    DO
    TXN_SCOPE
    LAST_INSERT_ID
/;
our $OTOGIRI;

no strict 'refs';
for my $method (@METHODS) {
    *{"main::$method"} = sub { _command(lc $method, @_ ) };
}
*main::db = sub { _command(shift, @_ ) };
use strict 'refs';

sub new {
    my $class = shift;
    my %opts  = @_;

    if ($opts{plugins}) {
        Otogiri->load_plugin($_) for split /,/, $opts{plugins};
    } 

    $OTOGIRI = Otogiri->new( connect_info => eval $opts{connect_info} ); 
    return $class->SUPER::new(@_);
}

sub _command {
    my $command = shift || '';
    return $OTOGIRI->$command(@_);
}

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    return if length $line <= 0; 
    return if $line =~ /^#/; # command
    return if $line =~ /->\s*$/; # method call
    return if $line =~ /[\$\@\%\&\*]\s*$/;

    return sort grep {
        index ($_, $line) == 0
    } @METHODS;    
}

1;
__END__

=encoding utf-8

=head1 NAME

Reply::Plugin::Otogiri - It's new $module

=head1 SYNOPSIS

    ; .replyrc 
    [Otogiri]
    connect_info = ["dbi:...", '', '', +{ ... }]

=head1 DESCRIPTION

Reply::Plugin::Otogiri is ...

=head1 LICENSE

Copyright (C) papix.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

papix E<lt>mail@papix.netE<gt>

=cut

