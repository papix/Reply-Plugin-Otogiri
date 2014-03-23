requires 'perl', '5.008001';
requires 'Carp';
requires 'File::Spec';
requires 'Reply';
requires 'Otogiri';
requires 'Otogiri::Plugin';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

