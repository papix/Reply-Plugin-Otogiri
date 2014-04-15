package Reply::Plugin::Otogiri;
use strict;
use warnings;

use base qw/ Reply::Plugin /;
use Carp;
use Otogiri;
use Otogiri::Plugin;
use List::Compare;
use Path::Tiny;

our $VERSION = "0.01";
my $OTOGIRI;
my @UNNECESSARY_METHODS = qw/
    _deflate_param
    _inflate_rows
    BEGIN
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

    my $config = _load_config($opts{config});
    my $db     = defined $ENV{PERL_REPLY_PLUGIN_OTOGIRI}
        ? $ENV{PERL_REPLY_PLUGIN_OTOGIRI}
        : Carp::croak "Please set database name to environment variable 'PERL_REPLY_PLUGIN_OTOGIRI'.";

    $OTOGIRI = Otogiri->new( connect_info => $config->{$db}->{connect_info} ); 
    my $list = List::Compare->new([ keys %{DBIx::Otogiri::} ], \@UNNECESSARY_METHODS);
  
    my @methods = map { s/(^.)/uc $1/e; $_ } $list->get_Lonly;
    no strict 'refs';
    for my $method (@methods) {
        use DDP { deparse => 1 };
        p $method;
        *{"main::$method"} = sub { _command(lc $method, @_ ) };
    }
    *main::Show_dbname = sub { return $db };
    use strict 'refs';
 
    return $class->SUPER::new(@_,
        methods => [ @methods, 'Show_dbname' ],
    );
}

sub _load_config {
    my ($config_path) = @_;
    Carp::croak "[Error] Please set database config file." unless $config_path;

    my $config_fullpath = path($config_path);
    Carp::croak "[Error] Not found: $config_fullpath" unless -f $config_fullpath;

    my $config = do($config_fullpath) or die "[Error] Failed to load config file: $config_fullpath ($!)";
    return $config;
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
    } @{$self->{methods}};
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

