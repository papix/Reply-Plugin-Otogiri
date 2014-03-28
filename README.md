# NAME

Reply::Plugin::Otogiri - Reply + Otogiri

# SYNOPSIS

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

# DESCRIPTION

Reply::Plugin::Otogiri is Reply's plugin for using Otogiri. 

# LICENSE

Copyright (C) papix.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

papix <mail@papix.net>
