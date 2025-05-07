locals {
  availability_zones = {
    public  = "us-east-1a",
    private = "us-east-1b"
  }

  instance_tags = {
    pub  = "UST-A-Pub-Instance",
    priv = "UST-A-Priv-Instance"
  }

  cidr_all = "0.0.0.0/0"
}