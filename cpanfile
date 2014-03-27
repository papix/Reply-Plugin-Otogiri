requires 'perl', '5.008001';
requires 'base';
requires 'Carp';
requires 'File::Spec';
requires 'List::Compare';
requires 'Reply';
requires 'Otogiri';
requires 'Otogiri::Plugin';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

