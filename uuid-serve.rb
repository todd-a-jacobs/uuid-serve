#!/usr/bin/env ruby
# vim:et:sw=2:tw=72

# Name:
#    uuid-serve.rb
#
# Version:
#    $Format:Git ID: (%h) %ci$
#
# Purpose:
#    Serve random universally-unique identifiers (UUID Version 4) in
#    accordance with RFC-4122.
#
# Copyright:
#    Copyright 2010, 2011 Todd A. Jacobs
#    All Rights Reserved
#
# License:
#    Released under the GNU General Public License (GPL)
#    http://www.gnu.org/copyleft/gpl.html
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License
#    as published by the Free Software Foundation; either version 3
#    of the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

require 'rubygems'
require 'sinatra'
require 'securerandom'

# Maximum number of UUIDs that can be generated from a single request.
# Set this to a sensible limit to prevent abuse.
MAX_COUNT = 100

enable :inline_templates

get '/' do
  haml :home
end

get '/uuid/?' do
  content_type 'text/plain'
  SecureRandom.uuid
end

get '/bulk/:count/?' do
  count = params[:count].to_i
  return 403, \
    "Invalid value: #{count}" if count < 1
  return 403, \
    "Limit of #{MAX_COUNT} UUIDs exceeded" if count > MAX_COUNT
  uuids = []
  content_type 'text/plain'
  count.times { uuids << SecureRandom::uuid }
  uuids.join "\n"
end

__END__
@@ layout
%html
  %head
    %title CodeGnome UUID Generator
  %body
    %p
      %a(href='/') Home
      |
      %a(href='/uuid') Generate UUID
      |
      %a(href='https://github.com/CodeGnome/uuid-serve') GPLv3 Source Code
    = yield
    %hr
    Copyright &copy; 2010,2011 Todd A. Jacobs. All rights reserved.

@@ home
%h1 CodeGnome UUID Generator
%h2 Why use uuid-serve?
%p
  Ruby doesn't provide cross-platform support for RFC-4122 UUIDs in the
  standard library. You have to install a third-party gem or roll your
  own code in order to generate UUIDs. There are a number of use-cases
  in which uuid-serve is a better alternative.
%h3 Example Use Cases
%ul
  %li
    Strict change-control policies make installing a third-party gem
    into multiple applications sub-optimal. With uuid-serve, you only
    have to make changes in a single server application, which is then
    available to all consumer processes.
  %li
    Regulatory environments where third-party gems must be audited
    before inclusion into applications. By ensuring that only one
    application is generating the UUIDs, it may reduce the scope of any
    audit requirements.
  %li
    Company policies which prohibit the inclusion of third-party gems
    within core applications. By treating UUIDs as a consumable web
    resource, rather than building them into the core application, it
    may be possible to place UUID generation outside an application's
    policy footprint.
%hr
%h2 UUID Requests
%h3 Requesting a Single UUID
%p
  Please be a good netizen and use the single-request API whenever possible. The
  %a(href='/uuid') /uuid
  link will provide you one Version 4 (random) UUID per request as plain
  text, with no HTML markup to strip away. How much easier could it get?
%h3 Bulk Requests
%p
  If you need more than one UUID at a time, use the bulk-request API by
  passing an integer to the bulk URL:
  %blockquote<
    #{request.scheme}://#{request.host}/bulk/
    %em<>
      &= "<1..#{MAX_COUNT}>"
  For example,
  %a(href='/bulk/10') /bulk/10
  will give you 10 UUIDs as plain text, separated by newline characters.
%hr
%h2 SSL Connections
%p
  If you need to ensure that your UUIDs are not transmitted
  %em en claire,
  make sure you use a secure transport layer such as SSL.
%h3 Special Note About Piggyback Certificates
%p
  If you are hosting this application on a system where the SSL
  certificate might not match the hostname (e.g. as a Heroku app using a
  custom domain name piggybacking on the Heroku wildcard SSL cert)
  you'll need to point your user-agent directly at the real hostname
  rather than the CNAME to avoid problems with the SSL certificate. If
  you don't, your browser may complain. For example, FireFox reports
  "ssl_error_bad_cert_domain" if you reach the page using a custom
  domain name.
%h3 SSL Example for Shared Certificates
%p
  Given a URI of
  %samp http://foo.custom.domain
  and a wildcard SSL certificate assigned to
  %samp *.example.com
  you should use
  %samp https://foo.example.com
  for requesting UUIDs over a secure socket. This is a limitation of
  SSL, not of uuid-serve.
