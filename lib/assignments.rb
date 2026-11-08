require 'net/http'
require 'date'
require 'json'
require_relative 'auth'
require_relative 'authenticator'

class Assignments

  def initialize
    @authenticator = Auth::Authenticator.new
  end

  def get_all_reviews
    uri = get_base_uri
    query_ar = URI.decode_www_form(uri.query || '') << ["burned", "false"]
    uri.query = URI.encode_www_form(query_ar)
    response = Net::HTTP::get_response(uri, initheader = {
      'Wanikani-Revision' => '20170710',
      'Authorization' => @authenticator.get_auth_value
    })
    if response.is_a?(Net::HTTPSuccess)
      puts response.body
    else
      puts response.code
    end
    response.body
  end

  def get_all_current_reviews
    uri = get_base_uri
    query_ar = URI.decode_www_form(uri.query || '') << ["burned", "false"], ["immediately_available_for_review", "true"]
    uri.query = URI.encode_www_form(query_ar)
    response = Net::HTTP::get_response(uri, initheader = {
      'Wanikani-Revision' => '20170710',
      'Authorization' => @authenticator.get_auth_value
    })
    if response.is_a?(Net::HTTPSuccess)
      puts response.body
    else
      puts response.code
    end
    response.body
  end

  def get_new_reviews_in(time_period)
    uri = get_base_uri
    query_ar = URI.decode_www_form(uri.query || '') << ["burned", "false"], ["available_before", time_period]
    uri.query = URI.encode_www_form(query_ar)
    response = Net::HTTP::get_response(uri, initheader = {
      'Wanikani-Revision' => '20170710',
      'Authorization' => @authenticator.get_auth_value
    })
    if response.is_a?(Net::HTTPSuccess)
      res_body = JSON.parse response.body
      res_body['total_count']
    end
  end

  private
  def get_base_uri
    URI(@authenticator.get_base_url + 'assignments')
  end
end

app = Assignments.new
now = Time.now
tonight_at_midnight = Time.new(now.year, now.month, now.day, 23, 59, 59.5, now.utc_offset)
# tomorrow_at_midnight = tonight_at_midnight + 60 * 60 * 24
timegoal_at_midnight = tonight_at_midnight + 60 * 60 * 24 * 7
reviews_tonight = app.get_new_reviews_in tonight_at_midnight.iso8601
# reviews_tomorrow = app.get_new_reviews_in tomorrow_at_midnight.iso8601
reviews_timegoal = app.get_new_reviews_in timegoal_at_midnight.iso8601

daily_review = (reviews_timegoal - reviews_tonight) / 7

puts "In order to be ahead of next week's reviews, you must do #{daily_review + 7} reviews every day"