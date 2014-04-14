package WWW::Pushover;
use 5.008005;
use strict;
use warnings;

use Carp qw(croak);
use Encode;

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

use constant DEBUG => $ENV{DEBUG};

our $VERSION = "0.01";
our $UA_NAME = "Perl/WWW::Pushover/$VERSION";

my @OPTIONS = (qw/
  device
  title
  url
  url_title
  priority
  timestamp
  sound
/);

sub new {
    my $class = shift;
    my %arg   = @_;
    my $self  = {};
    ### required parameters
    $self->{token} = delete $arg{token} or croak "token parameter is required";
    $self->{user}  = delete $arg{user}  or croak "user parameter is required";
    ### optional parameters
    for my $key (@OPTIONS) {
        $self->{$key} = delete $arg{$key} if exists $arg{$key};
    }
    ### User-Agent change.
    $self->{agent} = delete $arg{agent} if exists $arg{agent};

    return bless $self, $class;
}

# make accessors of @OPTIONS
for my $method (@OPTIONS) {
    no strict 'refs';
    *{$method} = sub {
        my $self = shift;
        return $self->{$method} if @_ == 1;
        return $self->{$method} = shift;
    };
}

# print $pushover->all_sounds();
# like Encode->encodings(":all")
sub sounds {
    my $self = shift;
    my $type = shift;
    my $res = $self->_http_get( ENDPOINT_URL . '/1/sounds.json?token=' . $self->{token} );
    if ( $res->{success} ) {
        my $data = $self->_json_parser->decode($res->{content});
        my @sounds = sort keys %{$data->{sounds}};
        return wantarray ? @sounds : \@sounds;
    }
    else {
        die "Sounds API is failed.";
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
            agent => $self->{agent} || $UA_NAME,
            timeout => HTTP_TIMEOUT,
        );
    }
    elsif ( HAVE_LWP_UA ) {
        $self->{ua} ||= LWP::UserAgent->new(
            agent => $self->{agent} || $UA_NAME,
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
    if ( !ref $form_data || ref $form_data ne 'HASH' ) {
        croak "form_data is required as HASH reference.";
    }
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

sub _http_get {
    my $self = shift;
    my $url = shift;
    my $ua = $self->_ua();
    if ( $ua->isa('HTTP::Tiny') ) {
        my $response = $ua->get($url);
        return $response;
    }
    elsif ( $ua->isa('LWP::UserAgent') ) {
        my $res = $ua->get($url);
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
    for my $option_key (@OPTIONS, qw/token user message/) {
        if ( exists $arg{$option_key} ) {
            # specify key is high priority.
            $option{$option_key} = $arg{$option_key};
        }
        elsif ( exists $self->{$option_key} ) {
            # method memory key is low priority.
            $option{$option_key} = $self->{$option_key};
        }
    }
    if ( !$option{token} || !$option{user} ) {
        croak "token and user are required.";
    }
    if ( !$option{message} ) {
        croak "message key is required.";
    }
    else {
        # TODO: Is message flagged UTF-8 string?
#        $option{message} = encode('utf-8', $option{message});
    }
    if ( DEBUG ) {
        require Data::Dumper;
        print Data::Dumper::Dumper(\%option);
    }
    $self->_http_post(
        ENDPOINT_URL . '/1/messages.json',
        \%option
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
    my $pushover = WWW::Pushover->new(
        token => MY_PUSHOVER_TOKEN,
        user  => MY_PUSHOVER_USER,
    );
    $pushover->notify(
         message => "Hello! Pushover",
    );

=head1 DESCRIPTION

WWW::Pushover is L<Pushover|http://www.pushover.net/> interface.

=head1 FIRST, YOU HAVE TO CREATE API KEY

This method is required Pushover API key.

If you are Pushover user alredy,
then you can create "Your Applications" on L<http://www.pushover.net/>.
You see this "Your Application" detail, you can get "API Token/Key".

If you are not Pushover user yet,
register it. However pushover client application is charged.

Now I consider whether "API Token/Key" packs together WWW::Pushover
CPAN distribution package. In future version WWW::Pushover,
it has its exclusive "API Token/Key" for module users convenience.

=head1 METHODS

=head2 WWW::Pushover->new( token => TOKEN, user => USER, ... )

    my $pushover = WWW::Pushover->new( token => TOKEN, user => USER );
    $pushover->notify(
        message => $message,
    );

Constructor. It gives some key/value pair parameters.
B<token and user keys are required>.

Other keys, this keys are defined in source code.

    my @OPTINOS = (qw/device title url url_title priority timestamp sound/);

See following methods for detail.

=head2 sounds

    # In list context.
    my @sounds_detail = $pushover->sounds(); # output detail

Output sound names. There are feteched newest data from API server.

Getting sound name is used on B<sound> method. See below.

=head2 device

Specify device. This is optional.

Your user's device name to send the message directly to that device,
rather than all of the user's devices

=head2 title

Speicfy title. This is optional.

Your message's title, otherwise your app's name is used.

=head2 url

Specify URL. This is optional.

It is specified iOS specific application launched URL schema.
You can use it to launch other application.

A supplementary URL to show with your message.

=head2 url_title

Specify URL's title. This is optional.

A title for your supplementary URL, otherwise just the URL is shown

=head2 priority

Specify priority. This is optional.

Send as -1 to always send as a quiet notification,
1 to display as high-priority and bypass the user's quiet hours,
or 2 to also require confirmation from the user.

=head2 timestamp

A Unix timestamp of your message's date and time to display to the user,
rather than the time your message is received by our API.

=head2 sound

Specify sound to notify.

See B<sounds> method for getting sound names.

=head2 _json_parser

Internal method.

=head2 _ua

Internal method.

=head2 _http_post

Internal method.

=head2 notify

Execution notify operation.

    $pushover->notify( message => "some message" );

When this method is called, WWW::Pushover sends message to specify device(s).

If you want to send non-ASCII multibyte character,
you must construct message as UTF-8.

And this message's UTF-8 string is B<required as flagged (Perl internal) string> on current version's WWW::Pushover (VERSION=0.01).

=head1 MOTIVATION

As perl pushover API, L<WebService::Pushover> is already exist.
But it is too heavy, e.g. dependecy of L<Moose>, and so on.

L<WWW::Pushover> concept is light interface and
only core module implementation over Perl5.14 or it's later.

And we supports some trivial API which is not supported L<WebService::Pushover>.

=head1 SEE ALSO

L<WebService::Pushover>,

L<Pushover REST API|https://pushover.net/api>

=head1 LICENSE

Copyright (C) OGATA Tetsuji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

OGATA Tetsuji E<lt>tetsuji.ogata@gmail.comE<gt>

=cut

