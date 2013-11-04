# NAME

WWW::Pushover - A lightweight Pushover API warpper.

# SYNOPSIS

    use WWW::Pushover;

# DESCRIPTION

WWW::Pushover is [Pushover](http://www.pushover.net/) interface.

# METHODS

## WWW::Pushover->new( token => TOKEN, user => USER, ... )

    my $pushover = WWW::Pushover->new( token => TOKEN, user => USER );
    $pushover->notify();

Constructor. It gives some key/value pair parameters.
__token and user keys are required__.

Other keys, this keys are defined in source code.

    my @OPTINOS = (qw/device title url url_title priority timestamp sound/);

See following methods for detail.

## sounds

    # In list context.
    my @sounds_detail = WWW::Pushover->sounds(); # output detail
    my @sounds        = WWW::Pushover->sounds(":all"); # sounds name only

Output sound data that this module has information.

This option likes Encode->encodinds(":all") on [Encode](http://search.cpan.org/perldoc?Encode) module.

## device

## title

## url

## url\_title

## priority

## timestamp

## sound

## \_json\_parser

Internal method.

## \_ua

Internal method.

## \_http\_post

Internal method.

## notify

Execution notify operation.

    $pushover->notify( message => "some message" );

# MOTIVATION

As perl pushover API, [WebService::Pushover](http://search.cpan.org/perldoc?WebService::Pushover) is exist.
But it is too heavy, e.g. dependecy of [Moose](http://search.cpan.org/perldoc?Moose), and so on.

[WWW::Pushover](http://search.cpan.org/perldoc?WWW::Pushover) concept is light interface and only core module implementation
over Perl5.14 or it's later.

# LICENSE

Copyright (C) OGATA Tetsuji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

OGATA Tetsuji <tetsuji.ogata@gmail.com>
