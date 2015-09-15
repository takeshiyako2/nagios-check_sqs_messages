#!/usr/bin/env ruby
require 'rubygems'
require 'optparse'
require 'aws-sdk-v1' # AWS SDK for Ruby version 1

access_key = "#{ARGV[0]}"
secret_key = "#{ARGV[1]}"
region = "#{ARGV[2]}"
rds_region = "#{ARGV[3]}"
db_instance_identifier = "#{ARGV[4]}"
warning = "#{ARGV[5]}".to_i
critical = "#{ARGV[6]}".to_i

options = {}

OptionParser.new do |opt|
  opt.banner = "Usage: #{$0} command <options>"
  opt.separator ""
  opt.separator "Nagios options:"

  opt.on("-a", "--access_key access_key", "CloudWatch access_key") { |access_key| options[:access_key] = access_key }
  opt.on("-s", "--secret_key secret_key", "CloudWatch secret_key") { |secret_key| options[:secret_key] = secret_key }
  opt.on("-r", "--region region", "CloudWatch region") { |region| options[:region] = region}
  opt.on("-i", "--queue_name --queue_name", "Queue Name") { |queue_name| options[:queue_name] = queue_name}
  opt.on("-w", "--warn WARN", "Nagios warning level. warn percent <= current SQS messages") { |warn| options[:warn] = warn.to_i }
  opt.on("-c", "--crit CRIT", "Nagios critical level. crit percent <= current SQS messages") { |crit| options[:crit] = crit.to_i }

  opt.on_tail("-h", "--help", "Show this message") do
    puts opt
    exit 0
  end

  begin
    opt.parse!
  rescue
    puts "Invalid option. \nsee #{opt}"
    exit
  end

end.parse!

class CheckSQSMessages

  def initialize(options)
    start_time = Time.now - 300
    end_time = Time.now

    AWS.config(
      :access_key_id => options[:access_key],
      :secret_access_key => options[:secret_key],
      :region => options[:region]
    )

    start_time = Time.now - 300
    end_time = Time.now

    cw = AWS::CloudWatch.new
    metric = AWS::CloudWatch::Metric.new('AWS/SQS', 'ApproximateNumberOfMessagesVisible')
    stats = metric.statistics(
      :statistics  => ['Average'],
      :dimensions  => [
        { :name => "QueueName", :value => options[:queue_name] }
      ],
      :period      => 60,
      :start_time  => start_time.iso8601,
      :end_time    => end_time.iso8601
    )

    message = stats.datapoints[0][:average].truncate.to_i

    ## puts result
    information = " - #{options[:queue_name]} message count is #{message} |message=#{message}"
    if options[:crit].to_i <= message
      puts "CRITICAL" + information
      exit 2
    elsif options[:warn].to_i <= message
      puts "WARNING" + information
      exit 1
    else
    puts "OK" + information
    end

  end
end

CheckSQSMessages.new(options)
