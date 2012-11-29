Strongbox
=========

Ruby gem for decrypting and reading www.Strongbox.io files.

Description
-----------

**Strongbox** (https://www.strongbox.io/) provides a simple way to effectively
organize, secure, and share sensitive textual data, the kind that has no other
home: passwords, credentials, credit card & account numbers, encryption keys,
certificates, etc. - essentially, anything we're not comfortable simply putting
into an unencrypted text document file or sharing via email, Skype, etc.

**This gem** enables decrypting and reading Strongbox files using common libraries:
`openssl` (for decryption), `zlib` (for decompression), `base64` (for decoding),
and `nokogiri` (for xml parsing).

Examples
--------

Given a Strongbox file and password, `Strongbox.decrypt` will handle everything
from opening the Strongbox file (extension `.sbox`), reading the XML content,
extracting the XML's Data node, decoding from Base64, decrypting
(`AES-256-CBC`), decompressing, and returning the raw content (which itself is
XML structured data, represented below as variable `d`).

At this point, the data just needs to be rendered (displayed); so we create a
strongbox object (`sb`) and call `render`.

    d  = Strongbox.decrypt(filename, password)
    sb = Strongbox.new(d)
    sb.render

Command-line usage
------------------

See https://github.com/abatko/strongbox.rb

