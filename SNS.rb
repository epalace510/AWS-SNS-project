#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'
AWS.config(
    :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
)
@sns=AWS::SNS.new
@cloudWatch=AWS::CloudWatch.new
#D requirements
alpha = @sns.topics.create('CSC470Test-Alpha')
@cloudWatch.alarms.create('2DollarAlarm', :namespace => 'AWS/Billing', :comparison_operator => 'GreaterThanThreshold' , :dimensions => [{:name => 'Currency', :value => 'USD'}], :metric_name => 'EstimatedCharges', :evaluation_periods => 1, :period => 86400, :statistic => 'Maximum', :threshold => 2, :alarm_actions => [alpha.arn])
@sns.topics.create('CSC470Test-Beta')
temp=gets
@sns.topics.each do |topic|
  puts topic.name
  if(topic.name=='CSC470Test-Beta')
    topic.delete
  end
end
puts
puts 'Beta now deleted.'
puts
@sns.topics.each do |topic|
  puts topic.name
end
puts
temp=gets
puts
#C requirements
@sns.topics.each do |topic|
  if(topic.name=='CSC470Test-Alpha')
    subbed1=false
    subbed2=false
    subbed3=false
    topic.subscriptions.each do |sub|
      if(sub.endpoint=='palacee1@tcnj.edu') 
        subbed1=true;
      end
      if(sub.endpoint=='peter.depasquale@gmail.com')
        subbed2=true;
      end
      if(sub.endpoint=='http://cloud.comtor.org/csc470logger/logger')
        subbed3=true;
      end
    end
    if(!subbed1)
      puts 'Subscribed palacee1.'
      topic.subscribe('palacee1@tcnj.edu')
    end
    if(!subbed2)
      puts 'Subscribed Dr Depasquale'
      topic.subscribe('peter.depasquale@gmail.com', :json => true)
    end
    if(!subbed3)
      puts 'Subscribed comtor site.'
      topic.subscribe('http://cloud.comtor.org/csc470logger/logger')
    end
  end
end
temp=gets
puts 'Topics with info:'
@sns.topics.each do |topic|
  puts
  puts 'Arn'
  puts topic.arn
  puts 'Owner'
  puts topic.owner
  puts 'Policy'
  puts topic.policy
  puts 'Name'
  puts topic.display_name
  puts 'Confirmed Subscriptions:'
  puts topic.subscriptions.
    select{ |s| s.arn != 'PendingConfirmation' }.
    map(&:endpoint)
#  if(subs.confirmation_authenticated?)
  #  puts 'Arn: ' + subs.arn
  #  puts 'Endpoint: ' + subs.endpoint
  #  puts 'Protocol: ' + subs.protocol
 # end
end
puts
temp=gets
@sns.subscriptions.each do |subs|
  puts "SubscriptionARN: #{ subs.arn} "
  puts "TopicARN: #{subs.topic_arn} "
  puts "Owner: #{subs.owner_id} "
  puts "Delivery Policy: #{ subs.delivery_policy_json} "
  end

puts 'Enter a message to send to the Alpha topic.'
message = gets 
message.chomp!
@sns.topics.each do |topic|
  if topic.name=='CSC470Test-Alpha'
    topic.publish(message, :subject => 'SNS Message')
  end
end
