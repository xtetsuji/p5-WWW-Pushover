# -*- perl -*-

requires 'perl', '5.008001';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
on 'develop' => sub {
    recommends 'Data::Dumper';
};

requires 'Carp';
requires 'JSON::PP';

recommends 'HTTP::Tiny';
recommends 'LWP::UserAgent';

