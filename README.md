# NAME

WWW::Pushover - A lightweight Pushover API warpper.

# SYNOPSIS

    use WWW::Pushover;
    my $pushover = WWW::Pushover->new(
        token => MY_PUSHOVER_TOKEN,
        user  => MY_PUSHOVER_USER,
    );
    $pushover->notify(
         message => "Hello! Pushover",
    );

# DESCRIPTION

WWW::Pushover is [Pushover](http://www.pushover.net/) interface.

# FIRST, YOU HAVE TO CREATE API KEY

This method is required Pushover API key.

If you are Pushover user alredy,
then you can create "Your Applications" on [http://www.pushover.net/](http://www.pushover.net/).
You see this "Your Application" detail, you can get "API Token/Key".

If you are not Pushover user yet,
register it. However pushover client application is charged.

Now I consider whether "API Token/Key" packs together WWW::Pushover
CPAN distribution package. In future version WWW::Pushover,
it has its exclusive "API Token/Key" for module users convenience.

# METHODS

## WWW::Pushover->new( token => TOKEN, user => USER, ... )

    my $pushover = WWW::Pushover->new( token => TOKEN, user => USER );
    $pushover->notify(
        message => $message,
    );

Constructor. It gives some key/value pair parameters.
__token and user keys are required__.

Other keys, this keys are defined in source code.

    my @OPTINOS = (qw/device title url url_title priority timestamp sound/);

See following methods for detail.

## sounds

    # In list context.
    my @sounds_detail = $pushover->sounds(); # output detail

Output sound names. There are feteched newest data from API server.

Getting sound name is used on __sound__ method. See below.

## device

Specify device. This is optional.

Your user's device name to send the message directly to that device,
rather than all of the user's devices

## title

Speicfy title. This is optional.

Your message's title, otherwise your app's name is used.

## url

Specify URL. This is optional.

It is specified iOS specific application launched URL schema.
You can use it to launch other application.

A supplementary URL to show with your message.

## url\_title

Specify URL's title. This is optional.

A title for your supplementary URL, otherwise just the URL is shown

## priority

Specify priority. This is optional.

Send as -1 to always send as a quiet notification,
1 to display as high-priority and bypass the user's quiet hours,
or 2 to also require confirmation from the user.

## timestamp

A Unix timestamp of your message's date and time to display to the user,
rather than the time your message is received by our API.

## sound

Specify sound to notify.

See __sounds__ method for getting sound names.

## \_json\_parser

Internal method.

## \_ua

Internal method.

## \_http\_post

Internal method.

## notify

Execution notify operation.

    $pushover->notify( message => "some message" );

When this method is called, WWW::Pushover sends message to specify device(s).

If you want to send non-ASCII multibyte character,
you must construct message as UTF-8.

And this message's UTF-8 string is __required as flagged (Perl internal) string__ on current version's WWW::Pushover (VERSION=0.01).

# MOTIVATION

As perl pushover API, [WebService::Pushover](http://search.cpan.org/perldoc?WebService::Pushover) is already exist.
But it is too heavy, e.g. dependecy of [Moose](http://search.cpan.org/perldoc?Moose), and so on.

[WWW::Pushover](http://search.cpan.org/perldoc?WWW::Pushover) concept is light interface and
only core module implementation over Perl5.14 or it's later.

And we supports some trivial API which is not supported [WebService::Pushover](http://search.cpan.org/perldoc?WebService::Pushover).

# SEE ALSO

[WebService::Pushover](http://search.cpan.org/perldoc?WebService::Pushover),

[Pushover REST API](https://pushover.net/api)

# LICENSE

Copyright (C) OGATA Tetsuji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

OGATA Tetsuji <tetsuji.ogata@gmail.com>
