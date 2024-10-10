locals {
    env = var.env
    app = var.app
    zone1 = "${var.region}a"
    zone2 = "${var.region}b"
}

locals {
  vpc_cidr = {
    dev = "10.0.0.0/20"
    staging = "10.0.16.0/20"
    prod = "10.0.32.0/20"
  }

  subnet_cidr = {
    private_zone1 = {
        dev = "10.0.0.0/22"
        staging = "10.0.16.0/22"
        prod = "10.0.32.0/22"
    }
    private_zone2 = {
        dev = "10.0.4.0/22"
        staging = "10.0.20.0/22"
        prod = "10.0.36.0/22"
    }
    public_zone1 = {
        dev = "10.0.8.0/22"
        staging = "10.0.24.0/22"
        prod = "10.0.40.0/22"
    }
    public_zone2 = {
        dev = "10.0.12.0/22"
        staging = "10.0.28.0/22"
        prod = "10.0.44.0/22"
    }
  }
}