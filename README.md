# halffare

> This software is in no way affiliated with, authorized, maintained, sponsored or endorsed by sbb.ch or any of its affiliates or subsidiaries.

`halffare` evaluates whether a SBB Half-Fare travelcard is profitable based on
your online order history.

Provides commands to download your online order history from sbb.ch and
evaluate it.

![halffare evaluation results](https://raw.githubusercontent.com/rndstr/halffare/master/media/halffare-results.png)

## Getting started

Install

    $ gem install halffare

Download order history

    $ halffare fetch --months=12 --output=year.halffare

Evaluate orders

    $ halffare stats --input=year.halffare

More options

    $ halffare help

## Usage

See [halffare.rdoc](https://github.com/rndstr/halffare/blob/master/halffare.rdoc)

## License

[MIT license](https://github.com/rndstr/halffare/blob/master/LICENSE)

