Strongbox
=========

Ruby gem and command-line interface for decrypting and reading www.Strongbox.io files.

Description
-----------

**Strongbox** (https://www.strongbox.io/) provides a simple way to effectively
organize, secure, and share sensitive textual data, the kind that has no other
home: passwords, credentials, credit card & account numbers, encryption keys,
certificates, etc. - essentially, anything we're not comfortable simply putting
into an unencrypted text document file or sharing via email, Skype, etc.

**This gem** enables decrypting and reading Strongbox files using the following
Ruby Standard Libraries:

 * `openssl` (for decryption)
 * `zlib` (for decompression)
 * `base64` (for decoding)

and the following third-party libraries:

 * `nokogiri` (for xml parsing)
 * `highline` (for password input)

**This gem** also ships with a command-line interface (an executable Ruby
program). See *command-line usage* below.

Examples
--------

Given a Strongbox file and password, `Strongbox.decrypt` will handle everything
from opening the Strongbox file (extension `.sbox`), reading the XML content,
extracting the XML's Data node, decoding from Base64, decrypting
(`AES-256-CBC`), decompressing, and returning the raw content (which itself is
XML structured data, represented below as variable `d`).

At this point, the data just needs to be rendered (displayed); so we create a
strongbox object (`sb`) and call `render` on it.

    d  = Strongbox.decrypt(filename, password)
    sb = Strongbox.new(d)
    sb.render

Command-line usage
==================

RVM users: you probably want to install this gem into your default Ruby's global gemset.

Examples
--------

These examples assume `strongbox.rb` is executable and in a directory in `PATH`.

    $ strongbox.rb
    Usage /Users/abatko/bin/strongbox.rb input.sbox

    $ strongbox.rb the_case_of_everything.sbox
    Enter the password to unlock this box: ********
    2012-11-27T23:29:23.18873Z

    VanCity bank info
    credit card, debit card, online banking
    Credit, Debit, Card, Online, Banking
    credit card number:
    1234 5678 9012 3456
    credit card expiration:
    11/2012
    credit card verification value:
    123
    debit card PIN:
    1234
    online banking password:
    qwerty

    fake Gmail account
    used for Stackoverflow
    Fake Gmail Stackoverflow
    username:
    ima_fake@gmail.com
    password:
    password1
    gender:
    other
    backup:
    bart_simpson@gmail.com

Contributing
============

 1. Fork it
 2. Create your feature branch (`git checkout -b my_new_feature`)
 3. Commit your changes (`git commit -am 'Add some feature'`)
 4. Push to the branch (`git push origin my_new_feature`)
 5. Create new Pull Request

