provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "ap-southeast-2"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"

	tags {
    Name = "tf_vpc"
  }
}

resource "aws_internet_gateway" "tf_internet_gateway" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	tags {
    Name = "tf_internet_gateway"
  }
}

# Public subnets
resource "aws_subnet" "ap_southeast_2a_public" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	cidr_block = "10.0.0.0/24"
	availability_zone = "ap-southeast-2a"

	tags {
    Name = "ap_southeast_2a_public"
  }
}

resource "aws_subnet" "ap_southeast_2b_public" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	cidr_block = "10.0.2.0/24"
	availability_zone = "ap-southeast-2b"

	tags {
    Name = "ap_southeast_2b_public"
  }
}

# Private subnets
resource "aws_subnet" "ap_southeast_2a_private" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	cidr_block = "10.0.1.0/24"
	availability_zone = "ap-southeast-2a"

	tags {
    Name = "ap_southeast_2a_private"
  }
}

resource "aws_subnet" "ap_southeast_2b_private" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	cidr_block = "10.0.3.0/24"
	availability_zone = "ap-southeast-2b"

	tags {
    Name = "ap_southeast_2b_private"
  }
}

# Routing table for public subnets
resource "aws_route_table" "ap_southeast_2_public" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.tf_internet_gateway.id}"
	}

	tags {
    Name = "ap_southeast_2_public"
  }
}

# Routing table association for public subnets
resource "aws_route_table_association" "ap_southeast_2a_public" {
	subnet_id = "${aws_subnet.ap_southeast_2a_public.id}"
	route_table_id = "${aws_route_table.ap_southeast_2_public.id}"
}

resource "aws_route_table_association" "ap_southeast_2b_public" {
	subnet_id = "${aws_subnet.ap_southeast_2b_public.id}"
	route_table_id = "${aws_route_table.ap_southeast_2_public.id}"
}

# Routing table for private subnets
resource "aws_route_table" "ap_southeast_2_private" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	tags {
    Name = "ap_southeast_2_private"
  }
}

# Routing table association for private subnets
resource "aws_route_table_association" "ap_southeast_2a_private" {
	subnet_id = "${aws_subnet.ap_southeast_2a_private.id}"
	route_table_id = "${aws_route_table.ap_southeast_2_private.id}"
}

resource "aws_route_table_association" "ap_southeast_2b_private" {
	subnet_id = "${aws_subnet.ap_southeast_2b_private.id}"
	route_table_id = "${aws_route_table.ap_southeast_2_private.id}"
}

# Create Network ACL resource
resource "aws_network_acl" "aws_network_acl_2a" {
  vpc_id = "${aws_vpc.tf_vpc.id}"

  # subnet association
  subnet_ids = ["${aws_subnet.ap_southeast_2a_public.id}", "${aws_subnet.ap_southeast_2a_private.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # SSH outbound travels on either 22 or any ephermal port (1024 - 65535)
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  tags {
    Name = "aws_network_acl_2a"
  }
}

# Create Network ACL resource
resource "aws_network_acl" "aws_network_acl_2b" {
  vpc_id = "${aws_vpc.tf_vpc.id}"

  # subnet association
  subnet_ids = ["${aws_subnet.ap_southeast_2b_public.id}", "${aws_subnet.ap_southeast_2b_private.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # RDP port
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }

  # SSH outbound travels on either 22 or any ephermal port (1024 - 65535)
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # RDP port
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }

  tags {
    Name = "aws_network_acl_2b"
  }
}

# RDS SG
resource "aws_security_group" "aws_security_group_rds" {
  name        = "aws_security_group_rds"
  description = "aws_security_group_rds"

  vpc_id = "${aws_vpc.tf_vpc.id}"

  tags {
    Name = "aws_security_group_rds"
  }
}

## Leave SG outbound rules as default ALL ??
resource "aws_security_group_rule" "aws_security_group_rule_rds_rdp" {
  type            = "ingress"
  from_port       = 3389
  to_port         = 3389
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.aws_security_group_rds.id}"
}

resource "aws_security_group_rule" "aws_security_group_rule_rds_http" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.aws_security_group_rds.id}"
}

resource "aws_security_group_rule" "aws_security_group_rule_rds_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.aws_security_group_rds.id}"
}

# EC2 SG
resource "aws_security_group" "aws_security_group_ec2" {
  name        = "aws_security_group_ec2"
  description = "aws_security_group_ec2"

  vpc_id = "${aws_vpc.tf_vpc.id}"

  tags {
    Name = "aws_security_group_ec2"
  }
}

## Leave SG outbound rules as default ALL ??
resource "aws_security_group_rule" "aws_security_group_rule_ec2_http" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.aws_security_group_ec2.id}"
}

resource "aws_security_group_rule" "aws_security_group_rule_ec2_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.aws_security_group_ec2.id}"
}
