requires 'perl', '5.008001';
requires 'base';
requires 'Carp';
requires 'List::Compare';
requires 'Path::Tiny';
requires 'Reply';
requires 'Otogiri';
requires 'Otogiri::Plugin';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

