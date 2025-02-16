## Stacks Testing

To deploy with cloudfront/ALB, you will need a hosted zone in the account you run.  

Example:

  Hosted zone: stacks.testing.com

To create ALB's and Cloudfront set:

external_albs = ["stacks.testing.com"]

Set role variables.


