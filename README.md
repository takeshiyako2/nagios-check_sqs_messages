# nagios-check_sqs_messages

This is nagios plugin for message queue of Amazon SQS.  
You can check count of message queue.

# Setup

```
# gem install aws-sdk
# gem list | grep aws-sdk
aws-sdk (2.1.20)
aws-sdk-core (2.1.20)
aws-sdk-resources (2.1.20)
```

if you use aws-sdk-v1, use check_sqs_messages_aws_sdk_v1.rb

# Usage

```
ruby check_sqs_messages.rb -c 10 -w 5 -q <Queue Name> -a <access_key> -s <secret_key> -r <region>
ruby check_sqs_messages.rb -c 10 -w 5 -q my-queue-name -a XXXX -s YYYY -r ap-northeast-1
```
