package Reply::Plugin::Otogiri;
use strict;
use warnings;

use base qw/ Reply::Plugin /;
use Carp;
use File::Spec;
use Otogiri;
use Otogiri::Plugin;
use List::Compare;

our $VERSION = "0.01";
my $OTOGIRI;
my @UNNECESSARY_METHODS = qw/
    _deflate_param
    _inflate_rows
    BEGIN
    connect_info
    dbh
    import
    load_plugin
    maker
    new
/;

sub new {
    my $class = shift;
    my %opts  = @_;

    if ($opts{plugins}) {
        Otogiri->load_plugin($_) for split /,/, $opts{plugins};
    } 

    Carp::croak "Please set database config file." unless $opts{config};  
    my $config = do File::Spec->catfile($ENV{HOME}, $opts{config});

    my $db = defined $ENV{PERL_REPLY_PLUGIN_OTOGIRI}
        ? $ENV{PERL_REPLY_PLUGIN_OTOGIRI}
        : Carp::croak q{Please set database name to environment variable "PERL_REPLY_PLUGIN_OTOGIRI".};

    $OTOGIRI = Otogiri->new( connect_info => $config->{$db}->{connect_info} ); 
    my @methods = keys %{DBIx::Otogiri::};
    my $lc = List::Compare->new(\@methods, \@UNNECESSARY_METHODS);
  
    my @alias;
    no strict 'refs';
    for my $method ($lc->get_Lonly) {
        $method =~ s/(^.)/uc $1/ge;
        push @alias, $method;
        *{"main::$method"} = sub { _command(lc $method, @_ ) };
    }
    *main::DB = sub { _command(shift, @_ ) };
    use strict 'refs';
 
    return $class->SUPER::new(@_,
        alias => \@alias,
    );
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
    } @{$self->{alias}};
}

1;
__END__

=encoding utf-8

=head1 NAME

Reply::Plugin::Otogiri - Reply + Otogiri

=head1 SYNOPSIS

    ; .replyrc 
    [Otogiri]
    config = .otogiri.config

    ; .otogiri.config
    {
        sample => {
            connect_info = ["dbi:...", '', '', +{ ... }]
        },
    }

    $ PERL_REPLY_PLUGIN_OTOGIRI=sample reply

=head1 DESCRIPTION

Reply::Plugin::Otogiri is Reply's plugin for using Otogiri. 

=head1 LICENSE

Copyright (C) papix.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

papix E<lt>mail@papix.netE<gt>

=cut

