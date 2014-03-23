package Reply::Plugin::Otogiri;
use strict;
use warnings;

use base qw/ Reply::Plugin /;
use Carp;
use File::Spec;
use Otogiri;
use Otogiri::Plugin;

our $VERSION = "0.01";
my @METHODS = qw/
    Insert
    Fast_insert
    Select 
    Single
    Search_by_sql
    Update
    Delete
    Do
    Txn_scope
    Last_insert_id
/;
my $OTOGIRI;

sub new {
    my $class = shift;
    my %opts  = @_;

    if ($opts{plugins}) {
        Otogiri->load_plugin($_) for split /,/, $opts{plugins};
    } 

    Carp::croak "Please set database config file." unless $opts{config};  
    my $config_path = File::Spec->catfile($ENV{HOME}, $opts{config});
    my $config = do "$config_path";

    Carp::croak q{Please set database name to environment variable "PERL_REPLY_PLUGIN_OTOGIRI".}
        unless $ENV{PERL_REPLY_PLUGIN_OTOGIRI};
    my $db = $ENV{PERL_REPLY_PLUGIN_OTOGIRI};

    $OTOGIRI = Otogiri->new( connect_info => $config->{$db}->{connect_info} ); 
    
    no strict 'refs';
    for my $method (@METHODS) {
        *{"main::$method"} = sub { _command(lc $method, @_ ) };
    }
    *main::DB = sub { _command(shift, @_ ) };
    use strict 'refs';
    
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

