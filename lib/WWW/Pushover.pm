package WWW::Pushover;
use 5.008005;
use strict;
use warnings;

use Carp qw(croak);

use constant HAVE_HTTP_TINY => eval {
    require HTTP::Tiny; 1;
};
use constant HAVE_LWP_UA    => eval {
    return 0 if HAVE_HTTP_TINY; # unnecessary
    require LWP::UserAgent; 1;
};
use JSON::PP;

use constant ENDPOINT_URL   => 'https://api.pushover.net';
use constant HTTP_TIMEOUT   => 10;

our $VERSION = "0.01";
our $UA_NAME = "Perl/WWW::Pushover/$VERSION";

my @OPTINOS = (qw/device title url url_title priority timestamp sound/);

sub new {
    my $class = shift;
    my %arg   = @_;
    my $self  = {};
    ### required parameters
    $self->{token} = $arg{token} or croak "token parameter is required";
    $self->{user}  = $arg{user}  or croak "user parameter is required";
    ### optional parameters
    for my $key (@OPTIONS) {
        $self->{$key} = $arg{$key} if exists $arg{$key};
    }
    return bless $self, $class;
}

# make accessors of @OPTIONS
for my $method (@OPTIONS) {
    no strict 'refs';
    *{$method} = sub {
        my $self = shift;
        return $self->{$method} if @_ == 1;
        return $self->{$method} = shift;
    }
}

# print WWW::Pushover->all_sounds();
# like Encode->encodings(":all")
sub sounds {
    my $class = shift;
    my $type = shift;

    my $data = <<END_DATA;
    pushover - Pushover (default)
    bike - Bike
    bugle - Bugle
    cashregister - Cash Register
    classical - Classical
    cosmic - Cosmic
    falling - Falling
    gamelan - Gamelan
    incoming - Incoming
    intermission - Intermission
    magic - Magic
    mechanical - Mechanical
    pianobar - Piano Bar
    siren - Siren
    spacealarm - Space Alarm
    tugboat - Tug Boat
    alien - Alien Alarm (long)
    climb - Climb (long)
    persistent - Persistent (long)
    echo - Pushover Echo (long)
    updown - Up Down (long)
    none - None (silent)
END_DATA

    if ( !$type || $type eq ':line' ) {
        return wantarray ? $data =~ /^\s*([^\n]+)$/mg : $data;
    }
    elsif ( $type eq ':name' || $type eq ':all' ) {
        return wantarray ? $data =~ /^\s*(\S+)/mg : $data;
    }
}

# JSON Parser accessor
sub _json_parser {
    my $self = shift;
    $self->{json_parser} ||= JSON::PP->new();
    return $self->{json_parser};
}

# Browser accessor
sub _ua {
    my $self = shift;
    if ( HAVE_HTTP_TINY ) {
        $self->{ua} ||= HTTP::Tiny->new(
            agent => $UA_NAME,
            timeout => HTTP_TIMEOUT,
        );
    }
    elsif ( HAVE_LWP_UA ) {
        $self->{ua} ||= LWP::UserAgent->new(
            agent => $UA_NAME,
            timeout => HTTP_TIMEOUT,
        );
    }
    else {
        die "require HTTP::Tiny or LWP::UserAgent";
    }
}

# HTTP post method
sub _http_post {
    my $self = shift;
    my $url = shift;
    my $form_data = shift;
    my $ua = $self->_ua();
    # key: url, reason(OK/NG), success(0/1), status, content, headers(response headers hash refrence lower), protocol
    if ( $ua->isa('HTTP::Tiny') ) {
        my $response = $ua->post_form($url, $form_data);
        return $response;
    }
    elsif ( $ua->isa('LWP::UserAgent') ) {
        my $res = $ua->post($url, $form_data);
        my $response = {
            url => $url,
            reason => $res->is_success ? 'OK' : 'NG',
            success => $res->is_success ? 1 : 0,
            content => $res->content,
            headers => $res->headers(), # loose
            protocol => $res->protocol(),
        };
        return $response;
    }
    else {
        die "Browser is not found.";
    }
}

# $p->notify( ... )
sub notify {
    my $self = shift;
    my %arg  = @_;
    my %option;
    for my $option_key (@OPTIONS) {
        if ( exists $arg{$option_key} ) {
            $option{$option_key} = $arg{$option_key};
        }
        elsif ( exists $self->{$option_key} ) {
            $option{$option_key} = $self->{$option_key};
        }
    }
    $self->_ua->_http_post(
        ENDPOINT_URL . '/1/messages.json', \%option
    );
}

1;
__END__

=pod

=encoding utf-8

=head1 NAME

WWW::Pushover - A lightweight Pushover API warpper.

=head1 SYNOPSIS

    use WWW::Pushover;

=head1 DESCRIPTION

WWW::Pushover is L<Pushover|http://www.pushover.net/> interface.

=head1 METHODS

(stub)

=head1 MOTIVATION

As perl pushover API, L<Webservice::Pushover> is exist.
But it is too heavy, e.g. dependecy of L<Moose>, and so on.

L<WWW::Pushover> concept is light interface and only core module implementation.

=head1 LICENSE

Copyright (C) OGATA Tetsuji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

OGATA Tetsuji E<lt>tetsuji.ogata@gmail.comE<gt>

=cut

