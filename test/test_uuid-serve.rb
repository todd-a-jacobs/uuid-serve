#!/usr/bin/env ruby
# vim:et:sw=2:tw=72

# Name:
#    test_uuid-serve.rb
#
# Version:
#    $Format:Git ID: (%h) %ci$
#
# Purpose:
#    Unit tests for uuid-serve.rb using the Capybara DSL.
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

require 'uuid-serve'
require 'capybara'
require 'capybara/dsl'
require 'test/unit'

class UuidServeTest < Test::Unit::TestCase
  include Capybara::DSL

  UUID_PATTERN = Regexp.new /[[:xdigit:]]{8}-
                             ([[:xdigit:]]{4}-){3}
                             [[:xdigit:]]{12}/x

  TYPE4_UUID = Regexp.new /[[:xdigit:]]{8}-
                           [[:xdigit:]]{4}-
                           4
                           [[:xdigit:]]{3}-
                           [89ab]
                           [[:xdigit:]]{3}-
                           [[:xdigit:]]{12}/ix
  def setup
    Capybara.app = Sinatra::Application.new
    visit '/'
  end

  def test_home_page_has_h1
    assert page.has_xpath? '//h1'
  end

  def test_home_page_has_use_cases
    assert page.has_content? 'Use Case'
  end

  def test_home_has_generate_uuid_link
    assert has_link? 'Generate UUID'
  end

  def test_generated_uuids_are_served_as_plain_text
    click_link 'Generate UUID'
    assert page.response_headers['Content-Type'] =~ %r!text/plain!i
  end

  def test_generated_uuid_is_valid_uuid
    visit '/uuid'
    assert page.body =~ UUID_PATTERN
  end

  def test_generated_uuid_is_valid_uuid_type
    visit '/uuid'
    assert page.body =~ TYPE4_UUID
  end

  def test_partial_bulk_path_with_slash_returns_404_error
    visit '/bulk/'
    assert page.driver.response.status == 404
  end

  def test_partial_bulk_path_without_slash_returns_404_error
    visit '/bulk'
    assert page.driver.response.status == 404
  end

  def test_bulk_returns_multiple_uuids
    uuid_count = 10
    visit "/bulk/#{uuid_count}"
    uuids = find(:xpath, '//p').text
    assert uuids.split.size == uuid_count
  end

  def test_exceeding_bulk_max_count_returns_error
    # Get the MAX_COUNT from inside the Sinatra app, rather than
    # hardcoding it.
    max_count = File.readlines('uuid-serve.rb').
                grep(/MAX_COUNT\s*=\s*(\d+)/).first.
                scan(/\d+/).first.
                to_i
    visit "/bulk/#{max_count + 1}"
    assert page.body.match /limit.*exceeded/i
  end

  def test_zero_is_invalid_bulk_argument
    visit "/bulk/0"
    assert page.has_content? 'Invalid value: 0'
  end

  def test_negative_integers_are_invalid_bulk_arguments
    visit "/bulk/-1"
    assert page.has_content? 'Invalid value: -1'
  end

end # class UuidServeTest
